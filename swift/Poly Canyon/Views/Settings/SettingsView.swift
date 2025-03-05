/*
 SettingsView manages the app's configuration interface with three main sections: general settings, 
 statistics (in adventure mode), and credits. It handles mode switching, data reset confirmations, and 
 location settings access. The view coordinates with multiple environment objects to manage app state 
 and data persistence while providing a consistent theme-aware interface.
*/

import SwiftUI

struct SettingsView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // Get the value from UserDefaults that's set by the RootRouter
    // This avoids recalculating the same logic
    private var isDesignVillageWeekend: Bool {
        // Get from UserDefaults directly
        UserDefaults.standard.bool(forKey: "isDesignVillageWeekend")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                    
                VStack(spacing: 30) {

                    // Only show during DV weekend
                    if isDesignVillageWeekend {
                        DesignVillageModeSection(
                            onSwitchToDV: switchToDesignVillageMode
                        )
                    }

                    GeneralSettingsSection(
                        onModeSwitch: {
                            appState.showAlert(.modePicker(currentMode: !appState.adventureModeEnabled))
                        },
                        onReset: {
                            let type: AppState.AlertType.ResetType = appState.adventureModeEnabled ? .structures : .favorites
                            appState.showAlert(.resetConfirmation(type: type))
                        }
                    )
                    
                    if appState.adventureModeEnabled {
                        StatisticsSection()
                    }

                    
                    CreditsSection()
                }
                .padding()
            }
        }
        .background(appState.isDarkMode ? Color.black : Color.white)
    }
    
    // Switch to Design Village mode
    private func switchToDesignVillageMode() {
        // Set UserDefaults to indicate DV mode
        UserDefaults.standard.set(true, forKey: "designVillageModeOverride")
        
        // Post notification to trigger mode switch
        NotificationCenter.default.post(name: Notification.Name("ModeSwitched"), object: nil)
        
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            SettingsView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode Preview
            SettingsView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}
