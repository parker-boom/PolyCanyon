import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        if !appState.isOnboardingCompleted {
            OnboardingView(
                isOnboardingCompleted: $appState.isOnboardingCompleted,
                isAdventureModeEnabled: $appState.adventureModeEnabled
            )
        } else {
            MainView()
        }
    }
}