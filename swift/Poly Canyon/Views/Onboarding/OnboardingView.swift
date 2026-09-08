import SwiftUI
import CoreLocation

/// Location remains a choice; its response is visible before entering the guide.
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var page = 0
    private let ink = Color(red: 0.15, green: 0.27, blue: 0.21)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if page < 2 {
                            introduction(width: geometry.size.width, height: geometry.size.height)
                        } else {
                            SpatialAtlas(selected: 1, overview: true).frame(height: typeSize.isAccessibilitySize ? 160 : min(260, geometry.size.height * 0.35))
                                .allowsHitTesting(false).accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 16) {
                                Text(heading(at: context.date)).font(.largeTitle.weight(.semibold))
                                    .foregroundStyle(ink).accessibilityAddTraits(.isHeader)
                                Text(explanation(at: context.date)).font(.body).foregroundStyle(.secondary)
                            }.fixedSize(horizontal: false, vertical: true).padding(28)
                        }
                        if typeSize.isAccessibilitySize { actions }
                    }
                    .id(page)
                    .transition(reduceMotion ? .opacity : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if !typeSize.isAccessibilitySize { actions }
                }
                .background(FieldPalette.wash)
            }
        }.preferredColorScheme(.light)
    }

    @ViewBuilder private func introduction(width: CGFloat, height: CGFloat) -> some View {
        switch CanyonEdition.selected {
        case .fieldGuide:
            VStack(alignment: .leading, spacing: 0) {
                if page == 0 {
                    SpatialAtlas(selected: 7, overview: true).frame(height: typeSize.isAccessibilitySize ? 160 : height * 0.40)
                        .allowsHitTesting(false).accessibilityHidden(true)
                } else {
                    HStack(alignment: .bottom, spacing: 12) {
                        Image("M-7").resizable().scaledToFill().frame(width: width * 0.52, height: 220).clipped()
                        Image("M-6").resizable().scaledToFill().frame(width: width * 0.30, height: 165).clipped()
                    }.padding(.horizontal, 24).padding(.top, 24).accessibilityHidden(true)
                }
                introductionText.padding(28)
            }
        case .ramble:
            VStack(alignment: .leading, spacing: 0) {
                Image(page == 0 ? "M-7" : "M-24").resizable().scaledToFill()
                    .frame(width: width, height: typeSize.isAccessibilitySize ? 180 : height * 0.48).clipped()
                    .overlay(alignment: .bottomLeading) {
                        Text("Poly Canyon").font(.title3.weight(.medium)).foregroundStyle(.white)
                            .padding(24).frame(maxWidth: .infinity, alignment: .leading)
                            .background(LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                    }.accessibilityHidden(true)
                introductionText.padding(28)
            }
        case .archive:
            VStack(alignment: .leading, spacing: 22) {
                introductionText
                HStack(alignment: .top, spacing: 12) {
                    Image(page == 0 ? "M-6" : "M-7").resizable().scaledToFill()
                        .frame(width: (width - 68) * 0.56, height: 240).clipped()
                    VStack(alignment: .leading, spacing: 12) {
                        Image(page == 0 ? "M-5" : "M-24").resizable().scaledToFill()
                            .frame(width: (width - 68) * 0.44, height: 150).clipped()
                        Text(page == 0 ? "Cal Poly\nSan Luis Obispo" : "Ideas, materials,\nand the people\nwho built them.")
                            .font(.caption).foregroundStyle(ink).fixedSize(horizontal: false, vertical: true)
                    }
                }.accessibilityHidden(true)
            }.padding(28)
        }
    }

    private var introductionText: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle().fill(FieldPalette.gold).frame(width: 42, height: 3).accessibilityHidden(true)
            Text(page == 0 ? "A canyon built by students." : "Every structure has a story.")
                .font(.system(.largeTitle, design: CanyonEdition.selected == .archive ? .serif : .default).weight(.semibold))
                .foregroundStyle(ink).accessibilityAddTraits(.isHeader)
            Text(page == 0
                 ? "In the hills behind Cal Poly, students turned architectural ideas into full-scale experiments. Poly Canyon is where you can walk among them."
                 : "Find your way through the canyon, open the research, and explore the photographs that connect these places to their past.")
                .font(.body).foregroundStyle(.secondary)
        }.fixedSize(horizontal: false, vertical: true)
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(ink)
            if page == 2 && !locationService.isLocationPermissionDenied && !hasConfirmedRemoteLocation {
                Button("Explore without location") { finish(useLocation: false) }
                    .font(.callout.weight(.medium))
                    .frame(minHeight: 44)
                    .tint(ink)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(FieldPalette.wash)
    }

    private func usableLocation(at date: Date) -> CLLocation? {
        guard locationService.hasLocationPermission,
              let location = locationService.lastLocation,
              LocationSamplePolicy.isUsable(location, now: date) else { return nil }
        return location
    }

    private func heading(at date: Date) -> String {
        if locationService.isLocationPermissionDenied { return "Explore from anywhere" }
        guard locationService.hasLocationPermission else { return "Find yourself on the map" }
        guard let location = usableLocation(at: date) else { return "Location is enabled" }
        if locationService.isWithinCanyon(location) { return "You’re in Poly Canyon" }
        if locationService.isWithinNearbyRange(location) { return "You’re near Poly Canyon" }
        if locationService.getRecommendedMode(location) { return "Ready for a canyon visit" }
        return "Explore from wherever you are"
    }

    private func explanation(at date: Date) -> String {
        if locationService.isLocationPermissionDenied {
            return "The map, photographs, and stories are yours to explore. You can allow location later to see your position and mark your visits."
        }
        guard locationService.hasLocationPermission else {
            return "See your position on the map and mark the structures you visit. Location is used only while the app is open. You can also explore without it."
        }
        guard let location = usableLocation(at: date) else {
            return "Finding your position. Explore now; the app can mark places you visit once your location is available."
        }
        if locationService.isWithinCanyon(location) || locationService.isWithinNearbyRange(location) {
            return "Follow the map. As you reach a structure, the app can mark it visited while you explore."
        }
        if locationService.getRecommendedMode(location) {
            return "Explore the map now. When you reach the canyon, the app can show your position and mark the places you visit."
        }
        return "Take a tour of the map and stories from here. You can use location to mark your visits when you reach the canyon."
    }

    private var hasConfirmedRemoteLocation: Bool {
        guard let location = usableLocation(at: Date()) else { return false }
        return !locationService.isWithinCanyon(location) && !locationService.getRecommendedMode(location)
    }

    private var primaryTitle: String {
        if page < 2 { return page == 0 ? "Discover their stories" : "Explore the canyon" }
        if locationService.isLocationPermissionDenied { return "Explore the canyon" }
        return locationService.hasLocationPermission ? "Start exploring" : "Use my location"
    }

    private func primaryAction() {
        if page < 2 {
            withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.5, dampingFraction: 0.92)) { page += 1 }
        } else if locationService.isLocationPermissionDenied {
            finish(useLocation: false)
        } else if locationService.hasLocationPermission {
            finish(useLocation: true)
        } else {
            locationService.requestInitialPermission()
        }
    }

    private func finish(useLocation: Bool) {
        let recording: Bool
        if !useLocation || !locationService.hasLocationPermission {
            recording = false
        } else if let location = usableLocation(at: Date()) {
            recording = locationService.isWithinCanyon(location) || locationService.getRecommendedMode(location)
        } else {
            // Preserve the existing authorized/no-fix recording default, without claiming proximity.
            recording = true
        }
        appState.adventureModeEnabled = recording
        locationService.setMode(recording ? .adventure : .virtualTour)
        appState.isOnboardingCompleted = true
    }
}
