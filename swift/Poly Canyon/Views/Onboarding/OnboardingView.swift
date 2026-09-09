import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationService: LocationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var flow = OnboardingFlow()
    @State private var revealed = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let location = status(at: context.date)
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        if flow.stage == .title {
                            titleMoment
                        } else {
                            Image(systemName: flow.stage == .location ? "location" : (flow.recommendsMap(location) ? "map" : "figure.walk"))
                                .font(.system(size: 36, weight: .light)).foregroundStyle(FieldPalette.gold)
                                .accessibilityHidden(true)
                            if flow.stage == .location { locationQuestion(location) }
                            else { introduction(location) }
                        }
                        actions(location)
                    }
                    .frame(maxWidth: 480)
                    .padding(28)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .center)
                }.id(flow.stage).clipped()
            }
            .onChange(of: location) { flow.observe($0) }
        }
        .background(FieldPalette.wash.ignoresSafeArea())
        .foregroundStyle(FieldPalette.green).tint(FieldPalette.green)
        .preferredColorScheme(.light)
        .task {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.7)) { revealed = true }
        }
    }
    private var titleMoment: some View {
        VStack(spacing: 28) {
            Image("Icon").resizable().scaledToFit()
                .frame(width: typeSize.isAccessibilitySize ? 120 : 180, height: typeSize.isAccessibilitySize ? 120 : 180)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .scaleEffect(revealed || reduceMotion ? 1 : 0.96)
                .opacity(revealed || reduceMotion ? 1 : 0)
                .accessibilityHidden(true)
            Rectangle().fill(FieldPalette.gold).frame(width: 44, height: 2).accessibilityHidden(true)
            Text("Poly Canyon")
                .font(.system(.largeTitle, design: .serif).weight(.semibold))
                .multilineTextAlignment(.center).accessibilityAddTraits(.isHeader)
        }.frame(maxWidth: .infinity).padding(.vertical, 20)
    }
    private func locationQuestion(_ location: OnboardingFlow.Location) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Already visiting the canyon?").font(.largeTitle.weight(.semibold)).accessibilityAddTraits(.isHeader)
            Text("Let’s check. Use your location to follow the map and mark the structures you visit while the app is open.").font(.title3)
            HStack(alignment: .top, spacing: 10) {
                if flow.requestPending || location == .locating { ProgressView().padding(.top, 3) }
                Text(feedback(location)).font(.callout).foregroundStyle(.secondary)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
    private func introduction(_ location: OnboardingFlow.Location) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(flow.recommendsMap(location) ? "Walk through the canyon." : "Tour from anywhere.")
                .font(.largeTitle.weight(.semibold)).accessibilityAddTraits(.isHeader)
            Text("Poly Canyon is a collection of student-built architectural experiments in the hills behind Cal Poly.")
                .font(.title3)
            Text(flow.recommendsMap(location)
                 ? "Follow your position on the map as you walk. Tap a structure to open its photographs and story."
                 : (typeSize.isAccessibilitySize
                    ? "Use the list above the map to choose a structure. Tap its card to open the photographs and story."
                    : "Swipe the structure cards to move around the illustrated map. Tap a card to open its photographs and story."))
                .font(.body).foregroundStyle(.secondary)
        }.fixedSize(horizontal: false, vertical: true)
    }
    private func actions(_ location: OnboardingFlow.Location) -> some View {
        VStack(spacing: 10) {
            Button {
                switch flow.stage {
                case .title: advance { flow.begin() }
                case .location:
                    if location == .undecided {
                        if flow.request() { locationService.requestInitialPermission() }
                    } else { advance { flow.introduce(usingLocation: location != .denied) } }
                case .introduction: finish()
                }
            } label: {
                Text(primaryTitle(location)).font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity, minHeight: 48)
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
            if location == .undecided { return flow.requestPending ? "Waiting for your choice" : "Allow location" }
            return location == .denied ? "Continue virtually" : "Continue"
        case .introduction: return flow.recommendsMap(location) ? "Open the map" : "Start the tour"
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
    private func advance(_ action: () -> Void) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25), action)
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
