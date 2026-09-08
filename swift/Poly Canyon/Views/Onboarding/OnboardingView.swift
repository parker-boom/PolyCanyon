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
                        Image("M-1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: typeSize.isAccessibilitySize ? 180 : max(190, min(geometry.size.height * 0.43, 390)))
                            .clipped()
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("POLY CANYON")
                                .font(.caption.weight(.semibold))
                                .tracking(2)
                                .foregroundStyle(ink)
                            Text(page == 0 ? "Explore Poly Canyon" : heading(at: context.date))
                                .font(.largeTitle.weight(.bold))
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityAddTraits(.isHeader)
                            Text(page == 0
                                 ? "Follow the map, explore student-built structures, and read their stories. Available offline."
                                 : explanation(at: context.date))
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            if page == 1 && locationService.hasLocationPermission {
                                Label("Location stays on your device", systemImage: "location")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(28)
                        .id(page)
                        .transition(reduceMotion ? .identity : .opacity)
                        if typeSize.isAccessibilitySize { actions }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if !typeSize.isAccessibilitySize { actions }
                }
                .background(.white)
            }
        }
        .preferredColorScheme(.light)
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
            if page == 1 && !locationService.isLocationPermissionDenied {
                Button("Explore without location") { finish(useLocation: false) }
                    .font(.callout.weight(.medium))
                    .frame(minHeight: 44)
                    .tint(ink)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(.white)
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
            return "The map, photos, and walkthrough are all yours to explore. You can enable location later in Info."
        }
        guard locationService.hasLocationPermission else {
            return "Use your location to see where you are and record the structures you visit while the app is open. Or explore without it."
        }
        guard let location = usableLocation(at: date) else {
            return "Finding your position. You can continue now; visits can be recorded when you reach the canyon and a location is available."
        }
        if locationService.isWithinCanyon(location) || locationService.isWithinNearbyRange(location) {
            return "Follow the canyon map. Structures you visit can be recorded while the app is open."
        }
        if locationService.getRecommendedMode(location) {
            return "Browse the map now. Visit recording will be ready when you explore the canyon with the app open."
        }
        return "Start with the illustrated map or take a walkthrough. You can enable visit recording in Info when you visit."
    }

    private var primaryTitle: String {
        if page == 0 { return "Continue" }
        if locationService.isLocationPermissionDenied { return "Explore the canyon" }
        return locationService.hasLocationPermission ? "Start exploring" : "Use my location"
    }

    private func primaryAction() {
        if page == 0 {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { page = 1 }
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
