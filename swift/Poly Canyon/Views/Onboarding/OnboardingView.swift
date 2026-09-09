import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationService: LocationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var flow = OnboardingFlow()
    @State private var revealed = false

    @EnvironmentObject private var dataStore: DataStore
    @State private var movingForward = true
    @State private var sample = 0
    @State private var photoOpen = false
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
            .onChange(of: location) { flow.observe($0) }
        }
        .background(FieldPalette.wash.ignoresSafeArea())
        .foregroundStyle(FieldPalette.green).tint(FieldPalette.green)
        .preferredColorScheme(.light)
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
                HStack(spacing: 6) {
                    ForEach(1..<OnboardingFlow.Stage.allCases.count, id: \.self) { index in
                        Capsule().fill(index == flow.stage.rawValue ? FieldPalette.green : FieldPalette.green.opacity(0.15))
                            .frame(width: index == flow.stage.rawValue ? 24 : 6, height: 6)
                    }
                }.accessibilityElement(children: .ignore)
                    .accessibilityLabel("Step \(flow.stage.rawValue) of 4")
                Spacer()
                if flow.stage.rawValue >= OnboardingFlow.Stage.introduction.rawValue {
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
                Text("A field guide to the unexpected.").font(.title3).foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }.multilineTextAlignment(.center).frame(maxWidth: .infinity)
                .frame(minHeight: max(0, height - 40))
        case .location:
            Image(systemName: "location.circle").font(.system(size: 68, weight: .ultraLight))
                .foregroundStyle(FieldPalette.gold).accessibilityHidden(true)
            copy("Are you at Poly Canyon?", "Use your location to follow the map and mark the places you visit while the app is open.")
            Text(feedback(location)).font(.callout).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        case .introduction:
            GeometryReader { frame in
                Image("M-1").resizable().scaledToFill().frame(width: frame.size.width, height: visualHeight).clipped()
            }.frame(height: visualHeight).clipShape(RoundedRectangle(cornerRadius: 24))
                .accessibilityLabel("Entry Arch in Poly Canyon")
            copy("Built by students.\nFound in the hills.", "Poly Canyon is a collection of architectural experiments in the hills behind Cal Poly.")
        case .navigation:
            navigationDemo(height: visualHeight)
            copy(flow.recommendsMap(location) ? "Find your way on foot." : "Move through the canyon.",
                 flow.recommendsMap(location)
                 ? "Your position appears on the map during your visit. Tap a numbered structure to explore it."
                 : (typeSize.isAccessibilitySize ? "Use the arrows to move around the example map." : "Swipe the cards to move around the map. Try it above."))
        case .stories:
            storyDemo(height: visualHeight)
            copy("Every structure has a story.", "Open a structure for photographs and its history. Tap the photo above to take a closer look.")
        }
    }
    private func copy(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(.largeTitle, design: .serif).weight(.medium))
                .accessibilityAddTraits(.isHeader).accessibilityFocused($headingFocused)
            Text(detail).font(.title3).foregroundStyle(.secondary)
        }.fixedSize(horizontal: false, vertical: true)
    }
    private func navigationDemo(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            SpatialAtlas(selected: samples[sample], overview: false, reduceMotion: reduceMotion) { number in
                if let index = samples.firstIndex(of: number) { sample = index }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Example map focused on \(sampleStructure?.title ?? "Entry Arch")")
            .overlay(alignment: .topLeading) {
                Text("PREVIEW").font(.caption2.weight(.semibold)).tracking(2)
                    .padding(10).background(FieldPalette.wash, in: Capsule()).padding(12)
            }
            HStack(spacing: 0) {
                Button { changeSample(-1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 64) }
                    .accessibilityLabel("Previous example").disabled(sample == 0)
                if typeSize.isAccessibilitySize {
                    Text(sampleStructure?.title ?? "").font(.headline)
                        .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
                } else {
                TabView(selection: $sample) {
                ForEach(samples.indices, id: \.self) { index in
                    if let item = dataStore.structures.first(where: { $0.number == samples[index] }) {
                        HStack(spacing: 12) {
                            Image(item.images.first ?? "M-1").resizable().scaledToFill()
                                .frame(width: 52, height: 52).clipped().clipShape(RoundedRectangle(cornerRadius: 8))
                            Text(item.title).font(.headline)
                            Spacer(minLength: 0)
                        }.padding(12).tag(index)
                    }
                }
                }.tabViewStyle(.page(indexDisplayMode: .never)).frame(height: 76)
                }
                Button { changeSample(1) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 64) }
                    .accessibilityLabel("Next example").disabled(sample == samples.count - 1)
            }.fixedSize(horizontal: false, vertical: true)
                .background(.white)
                .accessibilityAction(named: "Next example") { sample = min(sample + 1, samples.count - 1) }
                .accessibilityAction(named: "Previous example") { sample = max(sample - 1, 0) }
        }.frame(height: typeSize.isAccessibilitySize ? 290 : height)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    private func changeSample(_ delta: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) { sample = min(max(0, sample + delta), samples.count - 1) }
    }
    private func storyDemo(height: CGFloat) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.85)) { photoOpen.toggle() }
        } label: {
            GeometryReader { frame in
                ZStack(alignment: .bottomLeading) {
                    Image("entryArch1").resizable().scaledToFill()
                        .frame(width: frame.size.width, height: height).scaleEffect(photoOpen ? 1.35 : 1).clipped()
                    Group {
                        if typeSize.isAccessibilitySize {
                            Image(systemName: photoOpen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        } else {
                            Label(photoOpen ? "Tap to return" : "Take a closer look", systemImage: photoOpen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        }
                    }.font(.callout.weight(.medium)).padding(12)
                        .background(.regularMaterial, in: Capsule()).padding(16)
                }.frame(width: frame.size.width, height: height).clipped()
            }.frame(height: height).clipShape(RoundedRectangle(cornerRadius: 24))
        }.buttonStyle(.plain).accessibilityLabel(photoOpen ? "Return to whole photo" : "Enlarge Entry Arch photo")
    }
    private func actions(_ location: OnboardingFlow.Location) -> some View {
        VStack(spacing: 6) {
            Button {
                switch flow.stage {
                case .title: advance { flow.begin() }
                case .location:
                    if location == .undecided {
                        if flow.request() { locationService.requestInitialPermission() }
                    } else { advance { flow.introduce(usingLocation: location != .denied) } }
                case .introduction, .navigation: advance { flow.next() }
                case .stories: finish()
                }
            } label: {
                HStack {
                    Text(primaryTitle(location)).font(.headline)
                    Spacer()
                    Image(systemName: "arrow.right")
                }.foregroundStyle(.white).padding(.horizontal, 16).frame(minHeight: 50)
            }.buttonStyle(.borderedProminent)
                .disabled(flow.stage == .location && flow.requestPending && location == .undecided)
            if flow.stage == .location && location != .denied {
                Button("Explore virtually instead") { advance { flow.introduce(usingLocation: false) } }
                    .font(.callout.weight(.medium)).frame(minHeight: 44)
            }
        }
    }
    private func primaryTitle(_ location: OnboardingFlow.Location) -> String {
        switch flow.stage {
        case .title: return "Begin"
        case .location:
            if location == .undecided { return flow.requestPending ? "Waiting for your choice" : "Use my location" }
            return location == .denied ? "Continue virtually" : "Continue"
        case .introduction, .navigation: return "Continue"
        case .stories: return flow.recommendsMap(location) ? "Open the map" : "Start the tour"
        }
    }
    private func feedback(_ location: OnboardingFlow.Location) -> String {
        switch location {
        case .undecided: return flow.requestPending ? "Choose location access in the prompt." : "You can also explore from anywhere."
        case .denied: return "Location is off. The map, photographs, and stories are still yours to explore."
        case .locating: return "Location is enabled. Finding your position—you can continue while we wait."
        case .visit: return "Location is ready. We’ll start with the map for your visit."
        case .remote: return "You’re away from the canyon. We’ll start with the virtual tour."
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
        let recording = flow.recordsVisits(location)
        appState.adventureModeEnabled = recording
        locationService.setMode(recording ? .adventure : .virtualTour)
        let recommended: Bool? = location == .locating ? nil : location == .visit
        appState.completeOnboarding(usingLocation: flow.usesLocation && locationService.hasLocationPermission, mapRecommended: recommended)
    }
}
