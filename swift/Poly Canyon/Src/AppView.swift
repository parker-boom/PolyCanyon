import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if !appState.isOnboardingCompleted {
            OnboardingView(
                isNewOnboardingCompleted: $appState.isOnboardingCompleted,
                isAdventureModeEnabled: $appState.adventureModeEnabled
            )
        } else {
            MainView()
        }
    }
} 