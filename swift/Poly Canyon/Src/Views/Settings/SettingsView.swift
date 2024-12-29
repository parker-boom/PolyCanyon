/*
 SettingsView manages the app's configuration interface with three main sections: general settings, 
 statistics (in adventure mode), and credits. It handles mode switching, data reset confirmations, and 
 location settings access. The view coordinates with multiple environment objects to manage app state 
 and data persistence while providing a consistent theme-aware interface.
*/

import SwiftUI
import AlertPopUp

struct SettingsView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Alert States
    @State private var showModePopUp = false
    @State private var showResetAlert = false
    @State private var resetAlertType: ResetAlertType?
    
    // MARK: - Alert Types
    enum ResetAlertType {
        case structures  // Reset visited structures in adventure mode
        case favorites  // Reset liked structures in virtual tour mode
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App configuration options
                GeneralSettingsSection(
                    showModePopUp: $showModePopUp,
                    showResetAlert: $showResetAlert,
                    resetAlertType: $resetAlertType
                )
                
                // Progress tracking (adventure mode only)
                if appState.adventureModeEnabled {
                    StatisticsSection()
                }
                
                // App information and support
                CreditsSection()
            }
            .padding()
        }
        .background(appState.isDarkMode ? Color.black : Color.white)
        
        // MARK: - Modal Overlays
        .overlay(
            Group {
                // Mode switching interface
                if showModePopUp {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { showModePopUp = false }
                    
                    CustomModePopUp(isPresented: $showModePopUp)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                }
                
                // Reset confirmation dialog
                if showResetAlert {
                    resetAlertView
                }
            }
        )
    }
    
    // Reset confirmation alert with dynamic content
    private var resetAlertView: some View {
        Group {

            // Switches between visited and favorites based on mode
            if let type = resetAlertType {
                CustomAlert(
                    icon: type == .structures ? "arrow.counterclockwise" : "heart.slash.fill",
                    iconColor: type == .structures ? .orange : .red,
                    title: type == .structures
                        ? "Reset Visited Structures"
                        : "Reset Favorites",
                    subtitle: type == .structures
                        ? "Are you sure you want to reset all visited structures? This action cannot be undone."
                        : "Are you sure you want to reset all favorite structures? This action cannot be undone.",
                    primaryButton: .init(title: "Reset") {
                        if type == .structures {
                            dataStore.resetStructures()
                            dataStore.resetMapPoints()
                        } else {
                            dataStore.resetFavorites()
                        }
                        showResetAlert = false
                    },
                    secondaryButton: .init(title: "Cancel") {
                        showResetAlert = false
                    },
                    isPresented: $showResetAlert
                )
            }
        }
    }
}