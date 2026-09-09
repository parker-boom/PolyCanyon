import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationService: LocationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.colorSchemeContrast) private var contrast
    private var secondaryInk: Color { FieldPalette.green.opacity(contrast == .increased ? 1 : 0.78) }
    @State private var flow = OnboardingFlow()
    @State private var revealed = false

    @EnvironmentObject private var dataStore: DataStore
    @State private var movingForward = true
    @State private var sample = 0
    @State private var photoOpen = false
    @State private var previewStory: StructurePresentation?
    @State private var previewSelection: Int? = 6
    @State private var visitExampleStart = Date()
    @State private var visitExampleDismissed = false
    @AccessibilityFocusState private var headingFocused: Bool
    private let samples = [6, 8, 11]
    private var sampleStructure: Structure? {
        dataStore.structures.first { $0.number == samples[sample] }
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let location = status(at: context.date)
            VStack(spacing: 0) {
                header
                GeometryReader { geometry in
                    ZStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 28) {
                                page(location, height: geometry.size.height)
                            }
                            .frame(width: min(480, max(0, geometry.size.width - 56)))
                            .padding(.horizontal, 28).padding(.vertical, 20)
                            .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .center)
                        }
                        .id(flow.stage)
                        .transition(pageTransition)
                    }.clipped()
                }
                actions(location).padding(.horizontal, 28).padding(.top, 16).padding(.bottom, 12)
                    .frame(maxWidth: 536)
            }
            .onChange(of: location) { value in advance { flow.observe(value) } }
        }
        .background(Color.white.ignoresSafeArea())
        .foregroundStyle(FieldPalette.green).tint(FieldPalette.green)
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $photoOpen) {
            if let entry = dataStore.structures.first(where: { $0.number == 1 }),
               let index = entry.images.firstIndex(of: "entryArch1") {
                StructureGallery(structure: entry, initialIndex: index) { photoOpen = false }
            }
        }
        .fullScreenCover(item: $previewStory) { selection in
            StructureExperience(numbers: selection.numbers, selected: selection.selected, recordsOpening: false) { number in
                if flow.stage != .visit, let index = samples.firstIndex(of: number) { sample = index; previewSelection = number }
            }
        }
        .task { withAnimation(reduceMotion ? nil : .easeOut(duration: 0.7)) { revealed = true } }
    }

    private var pageTransition: AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(insertion: .move(edge: movingForward ? .trailing : .leading).combined(with: .opacity),
                           removal: .move(edge: movingForward ? .leading : .trailing).combined(with: .opacity))
    }
    private var header: some View {
        HStack {
            if flow.stage != .title {
                Button { advance(forward: false) { flow.back() } } label: {
                    Image(systemName: "chevron.left").frame(width: 44, height: 44)
                }.accessibilityLabel("Back")
                Spacer()
                if flow.isVirtualIntroduction {
                HStack(spacing: 6) {
                    ForEach(2...4, id: \.self) { index in
                        Capsule().fill(index == flow.progress ? FieldPalette.green : FieldPalette.green.opacity(0.15))
                            .frame(width: index == flow.progress ? 24 : 6, height: 6)
                    }
                }.accessibilityElement(children: .ignore)
                    .accessibilityLabel("Introduction \(flow.progress - 1) of 3")
                }
                Spacer()
                if flow.isVirtualIntroduction {
                    Button("Skip") { finish() }.frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("Skip introduction")
                } else { Color.clear.frame(width: 44, height: 44) }
            } else { Color.clear.frame(height: 44) }
        }.padding(.horizontal, 16)
    }
    @ViewBuilder private func page(_ location: OnboardingFlow.Location, height: CGFloat) -> some View {
        let visualHeight = typeSize.isAccessibilitySize ? 150.0 : min(290, max(155, height * 0.49))
        switch flow.stage {
        case .title:
            VStack(spacing: 30) {
                Spacer(minLength: 0)
                Image("Icon").resizable().scaledToFit()
                    .frame(width: typeSize.isAccessibilitySize ? 130 : 210, height: typeSize.isAccessibilitySize ? 130 : 210)
                    .clipShape(RoundedRectangle(cornerRadius: 42))
                    .scaleEffect(revealed || reduceMotion ? 1 : 0.94)
                    .opacity(revealed || reduceMotion ? 1 : 0).accessibilityHidden(true)
                Rectangle().fill(FieldPalette.gold).frame(width: 40, height: 2).accessibilityHidden(true)
                Text("Poly Canyon").font(.system(.largeTitle, design: .serif).weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                Text("Explore Cal Poly’s architectural experiments.").font(.title3).foregroundStyle(secondaryInk)
                Spacer(minLength: 0)
            }.multilineTextAlignment(.center).frame(maxWidth: .infinity)
                .frame(minHeight: max(0, height - 40))
        case .location:
            Image(systemName: "location.circle").font(.system(size: 68, weight: .ultraLight))
                .foregroundStyle(FieldPalette.gold).accessibilityHidden(true)
            copy("Are you going to explore Poly Canyon?", "Explore on foot, or take a look around from anywhere.")
        case .permission:
            Image(systemName: "location").font(.system(size: 58, weight: .light))
                .foregroundStyle(FieldPalette.gold).accessibilityHidden(true)
            copy("Find your place in the canyon.", "Allow location while using the app to see your position and mark nearby structures as visited. Your progress stays on this device.")
        case .locating:
            ProgressView().controlSize(.large).accessibilityLabel("Finding your position")
            copy(location == .undecided ? "Choose location access." : "Finding your position.",
                 location == .undecided ? "Choose an option in the location prompt. You can also continue without location."
                 : "We’re waiting for a current position near the canyon. If it isn’t available, you can still explore the map and stories virtually.")
        case .visit:
            visitDemo(height: typeSize.isAccessibilitySize ? 220 : min(320, max(230, height * 0.48)))
            copy("You’re ready to explore Poly Canyon", "Follow your position on the map as nearby structures are marked visited.", tryIt: "Try it out: tap the visit notification.")
        case .virtualExplanation:
            Image(systemName: "map").font(.system(size: 58, weight: .light))
                .foregroundStyle(FieldPalette.gold).accessibilityHidden(true)
            copy("Explore without location.", "You can still browse the whole map, open every story, and take the virtual tour.")
        case .introduction:
            CanyonIntroductionPhotos()
                .frame(height: visualHeight).clipShape(RoundedRectangle(cornerRadius: 24))
            copy("Explore a canyon of ideas.", "Discover the structures Cal Poly students built to test their ideas at full scale.")
        case .navigation:
            navigationDemo(height: min(390, max(330, height * 0.55)))
            copy("Take a virtual tour", "Explore the structures and see where each one sits in the canyon.",
                 tryIt: typeSize.isAccessibilitySize ? "Try it out: use the arrows above." : "Try it out: swipe through the cards above.")
        case .stories:
            storyDemo(height: visualHeight)
            copy("Every structure has a story.", "Discover its history and take a closer look through photographs.", tryIt: "Try it out: tap the photo above.")
        }
    }
    private func copy(_ title: String, _ detail: String, tryIt: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(.largeTitle, design: .serif).weight(.medium))
                .accessibilityAddTraits(.isHeader).accessibilityFocused($headingFocused)
            Text(detail).font(.title3).foregroundStyle(secondaryInk)
            if let tryIt {
                Text(tryIt).font(.callout.weight(.medium)).padding(.top, 4)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
    private func visitDemo(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                let focus = locationService.getMapPointForStructure(2)?.pixelPosition ?? CanyonAtlasGeometry.defaultFocus
                let layout = CanyonAtlasGeometry(size: geometry.size, focus: focus, overview: false)
                SpatialAtlas(selected: 2, overview: false, reduceMotion: reduceMotion, showsMarkers: false)
                    .accessibilityHidden(true)
                TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { context in
                    let phase = max(0, context.date.timeIntervalSince(visitExampleStart)).truncatingRemainder(dividingBy: 15)
                    let progress = reduceMotion ? 1 : min(1, phase / 4.5)
                    let arrived = reduceMotion ? !visitExampleDismissed : (phase >= 4.5 && phase < 14)
                    ZStack(alignment: .top) {
                        // Bundled map path points 3 -> 2 -> 1. No device location or discovery writes.
                        PulsingCircle()
                            .position(layout.position(for: visitExamplePoint(progress)))
                            .accessibilityLabel(progress >= 1 ? "Example position at Entry Arch" : "Example position approaching Entry Arch")
                        if arrived, let entry = dataStore.structures.first(where: { $0.number == 1 }) {
                            DiscoveryBanner(structure: entry, open: {
                                previewStory = StructurePresentation(numbers: dataStore.structures.map(\.number), selected: 1)
                            }, dismiss: {
                                if reduceMotion { visitExampleDismissed = true }
                                else { visitExampleStart = Date() }
                            })
                            .padding(4)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: arrived)
                }
            }.frame(height: height).clipped()
            Text("Example visit").font(.caption).foregroundStyle(secondaryInk)
        }
        .onAppear { visitExampleStart = Date(); visitExampleDismissed = false }
        .onChange(of: reduceMotion) { _ in visitExampleDismissed = false }
    }
    private func visitExamplePoint(_ progress: Double) -> CGPoint {
        let path = [CGPoint(x: 976, y: 3642), CGPoint(x: 1004, y: 3885), CGPoint(x: 1018, y: 4045)]
        let segment = min(1, Int(progress * 2))
        let fraction = CGFloat(progress * 2 - Double(segment))
        return CGPoint(x: path[segment].x + (path[segment + 1].x - path[segment].x) * fraction,
                       y: path[segment].y + (path[segment + 1].y - path[segment].y) * fraction)
    }
    private func navigationDemo(height: CGFloat) -> some View {
        GeometryReader { geometry in
            let cardWidth = min(210, geometry.size.width * 0.60)
            VStack(spacing: -8) {
                SpatialAtlas(selected: samples[sample], overview: false, reduceMotion: reduceMotion)
                    .frame(height: typeSize.isAccessibilitySize ? 130 : max(110, height - cardWidth - 115))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Example map focused on \(sampleStructure?.title ?? "Tensile")")
                if typeSize.isAccessibilitySize {
                    HStack {
                        Button { changeSample(-1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 64) }
                            .accessibilityLabel("Previous example").disabled(sample == 0)
                        Text(sampleStructure?.title ?? "").font(.headline).fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                        Button { changeSample(1) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 64) }
                            .accessibilityLabel("Next example").disabled(sample == samples.count - 1)
                    }.padding(.top, 16)
                } else if #available(iOS 17, *) {
                    ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 14) {
                            ForEach(samples, id: \.self) { number in
                                if let item = dataStore.structures.first(where: { $0.number == number }) {
                                    Button {
                                        previewStory = StructurePresentation(numbers: samples, selected: number)
                                    } label: {
                                        TourStructureCard(item: item, width: cardWidth)
                                    }.buttonStyle(.plain).id(number)
                                }
                            }
                        }.scrollTargetLayout().padding(.vertical, 6)
                    }
                    .contentMargins(.horizontal, (geometry.size.width - cardWidth) / 2, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $previewSelection, anchor: .center)
                    .scrollClipDisabled()
                    .onAppear {
                        // The card strip is recreated when leaving accessibility sizes.
                        proxy.scrollTo(samples[sample], anchor: .center)
                    }
                    .onChange(of: previewSelection) { number in
                        if let number, let index = samples.firstIndex(of: number) { sample = index }
                    }
                    }
                } else {
                    TabView(selection: $sample) {
                        ForEach(samples.indices, id: \.self) { index in
                            if let item = dataStore.structures.first(where: { $0.number == samples[index] }) {
                                TourStructureCard(item: item, width: cardWidth).tag(index)
                            }
                        }
                    }.tabViewStyle(.page(indexDisplayMode: .automatic))
                }
            }
        }.frame(height: typeSize.isAccessibilitySize ? 290 : height)
    }
    private func changeSample(_ delta: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            sample = min(max(0, sample + delta), samples.count - 1)
            previewSelection = samples[sample]
        }
    }
    private func storyDemo(height: CGFloat) -> some View {
        Button {
            photoOpen = true
        } label: {
            GeometryReader { frame in
                ZStack(alignment: .bottomLeading) {
                    Image("entryArch1").resizable().scaledToFill()
                        .frame(width: frame.size.width, height: height).clipped()
                    Group {
                        if typeSize.isAccessibilitySize {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                        } else {
                            Label("Open photograph", systemImage: "arrow.up.left.and.arrow.down.right")
                        }
                    }.font(.callout.weight(.medium)).padding(12)
                        .background(.regularMaterial, in: Capsule()).padding(16)
                }.frame(width: frame.size.width, height: height).clipped()
            }.frame(height: height).clipShape(RoundedRectangle(cornerRadius: 24))
        }.buttonStyle(.plain).accessibilityLabel("Open historical Entry Arch photograph")
    }
    private func actions(_ location: OnboardingFlow.Location) -> some View {
        VStack(spacing: 6) {
            if flow.stage != .locating {
                Button {
                    switch flow.stage {
                    case .title: advance { flow.begin() }
                    case .location: advance { flow.chooseVisit(location: location) }
                    case .permission:
                        advance {
                            if flow.request() {
                                locationService.setMode(.initial)
                                if location == .undecided { locationService.requestInitialPermission() }
                                flow.observe(location)
                            }
                        }
                    case .virtualExplanation:
                        locationService.setMode(.virtualTour)
                        advance { flow.next() }
                    case .introduction, .navigation: advance { flow.next() }
                    case .visit, .stories: finish()
                    case .locating: break
                    }
                } label: {
                    HStack {
                        Text(primaryTitle(location)).font(.headline).fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }.foregroundStyle(.white).padding(.horizontal, 16).frame(minHeight: 50)
                }.buttonStyle(.borderedProminent)
            }
            if [.location, .permission, .locating, .visit].contains(flow.stage) {
                Button(flow.stage == .location ? "Visit virtually" : "Continue without location") {
                    locationService.setMode(.virtualTour)
                    advance { flow.introduce(usingLocation: false) }
                }.font(.callout.weight(.medium)).frame(minHeight: 44)
            }
        }
    }
    private func primaryTitle(_ location: OnboardingFlow.Location) -> String {
        switch flow.stage {
        case .title: return "Begin"
        case .location: return "Explore in person"
        case .permission: return "Continue"
        case .visit: return "Start my visit"
        case .stories: return "Start the tour"
        default: return "Continue"
        }
    }
    private func status(at date: Date) -> OnboardingFlow.Location {
        if locationService.isLocationPermissionDenied { return .denied }
        guard locationService.hasLocationPermission else { return .undecided }
        guard let fix = locationService.lastLocation, LocationSamplePolicy.isUsable(fix, now: date) else { return .locating }
        return locationService.isWithinCanyon(fix) || locationService.getRecommendedMode(fix) ? .visit : .remote
    }
    private func advance(forward: Bool = true, _ action: () -> Void) {
        movingForward = forward
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.38), action)
        headingFocused = true
    }
    private func finish() {
        let location = status(at: Date())
        // Permission can change while the introduction is visible. Proximity never changes the chosen journey.
        if flow.usesLocation && !locationService.hasLocationPermission {
            advance { flow.observe(location) }
            return
        }
        let recording = flow.recordsVisits(location)
        appState.adventureModeEnabled = recording
        locationService.setMode(recording ? .adventure : .virtualTour)
        appState.completeOnboarding(exploringInPerson: flow.usesLocation)
    }
}


private struct CanyonIntroductionPhotos: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selected = 0
    private let photos = ["M-19", "M-6", "M-23"]
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(photos[selected]).resizable().scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                    .id(selected).transition(.opacity)
            }
        }
        .accessibilityLabel("Student-built structures in Poly Canyon")
        .task(id: reduceMotion) {
            guard !reduceMotion else { selected = 0; return }
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(6)) }
                catch { return }
                withAnimation(.easeInOut(duration: 1.4)) { selected = (selected + 1) % photos.count }
            }
        }
    }
}
