/*
 AppView acts as the primary router for the application's main navigation flow. It determines whether to show 
 the onboarding experience or the main application interface. The view observes the app state to manage this 
 conditional navigation. It serves as a clean separation between onboarding and main app experiences.
*/

import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        Group {
            if !appState.isOnboardingCompleted || appState.needsFullReset {
                OnboardingView()
            } else {
                MainView()
            }
        }
        .alert("Saved progress needs attention", isPresented: Binding(
            get: { dataStore.persistenceError != nil },
            set: { if !$0 { dataStore.dismissPersistenceError() } }
        )) {
            Button("OK") { dataStore.dismissPersistenceError() }
        } message: {
            Text(dataStore.persistenceError ?? "")
        }
        .onAppear {
            if appState.needsFullReset {
                appState.resetAllSettings()
            }
        }
    }
}


// MARK: - Preview
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            AppView()
                .environmentObject({
                    let state = AppState()
                    state.theme = .light
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode Preview
            AppView()
                .environmentObject({
                    let state = AppState()
                    state.theme = .dark
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}
