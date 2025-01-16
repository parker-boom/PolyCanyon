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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button {
                    appState.activeFullScreenView = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            // Existing ScrollView content
            ScrollView {
                VStack(spacing: 20) {
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
                    
                    Button(action: {
                        appState.resetAllSettings()
                    }) {
                        Text("Reset App")
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .background(appState.isDarkMode ? Color.black : Color.white)
    }
}
