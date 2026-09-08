import SwiftUI
import CoreLocation

/// Two steps, with the existing location recommendation kept behind the presentation.
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let forest = Color(red: 0.16, green: 0.30, blue: 0.23)
    private var paper: Color { colorScheme == .dark ? Color(red: 0.09, green: 0.11, blue: 0.10) : Color(red: 0.97, green: 0.96, blue: 0.92) }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Image("M-1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: max(190, min(geometry.size.height * 0.40, 370)))
                        .clipped()
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 18) {
                        Text("POLY CANYON")
                            .font(.caption.weight(.semibold))
                            .tracking(2)
                            .foregroundStyle(.secondary)
                        Text(page == 0 ? "Explore Poly Canyon" : "Discover as\nyou walk.")
                            .font(.largeTitle.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                        Text(page == 0
                             ? "Follow the map, explore student-built structures, and read their stories. Available offline."
                             : "Your location puts you on the map and records the structures you visit, only while the app is active. Everything stays on your device.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        if page == 1 {
                            Text(locationExplanation)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 28)
                    Spacer(minLength: 0)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 10) {
                    Button(action: primaryAction) {
                        Text(primaryTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(forest)
                    if page == 1 && !locationService.isLocationPermissionDenied {
                        Button("Explore without location") { finish(useLocation: false) }
                            .font(.callout.weight(.medium))
                            .frame(minHeight: 44)
                            .tint(colorScheme == .dark ? .white : forest)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(paper)
            }
            .background(paper.ignoresSafeArea())
        }
    }

    private var locationExplanation: String {
        if locationService.isLocationPermissionDenied {
            return "You can explore every photo and story without location. Enable it later in Your visit."
        }
        if locationService.hasLocationPermission, let location = locationService.lastLocation {
            if locationService.isInPolyCanyonArea {
                return "You’re in Poly Canyon. Visits will be recorded as you explore."
            }
            if locationService.getRecommendedMode(location) {
                return "You’re near Poly Canyon. Visits will be recorded when you explore the canyon."
            }
            return "Explore from wherever you are. Start with the map or take a walkthrough."
        }
        if locationService.hasLocationPermission {
            return "You’re ready to explore. Your position will appear when a location is available."
        }
        return "Just looking around? The map, photos, and virtual walkthrough work without location, too."
    }

    private var primaryTitle: String {
        if page == 0 { return "Continue" }
        if locationService.isLocationPermissionDenied { return "Explore the canyon" }
        return locationService.hasLocationPermission ? "Start exploring" : "Use my location"
    }

    private func primaryAction() {
        if page == 0 {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { page = 1 }
        } else if locationService.isLocationPermissionDenied {
            finish(useLocation: false)
        } else if locationService.hasLocationPermission {
            finish(useLocation: true)
        } else {
            locationService.requestInitialPermission()
        }
    }

    private func finish(useLocation: Bool) {
        // Preserve the field-tested recommendation and its no-fix fallback.
        let recording: Bool
        if !useLocation || !locationService.hasLocationPermission {
            recording = false
        } else if let location = locationService.lastLocation {
            recording = locationService.isInPolyCanyonArea || locationService.getRecommendedMode(location)
        } else {
            recording = true
        }
        appState.adventureModeEnabled = recording
        locationService.setMode(recording ? .adventure : .virtualTour)
        appState.isOnboardingCompleted = true
    }
}
