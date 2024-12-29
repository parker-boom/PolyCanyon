/*
 AppView acts as the primary router for the application's main navigation flow. It determines whether to show 
 the onboarding experience or the main application interface. The view observes the app state to manage this 
 conditional navigation. It serves as a clean separation between onboarding and main app experiences.
*/

import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        if !appState.isOnboardingCompleted {
            OnboardingView()
        } else {
            MainView()
        }
    }
}