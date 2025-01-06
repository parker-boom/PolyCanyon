// MARK: MainView.swift

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Main Content (Tabs)
            VStack(spacing: 0) {
                switch selectedTab {
                case 0: MapView()
                case 1: DetailView()
                case 2: SettingsView()
                default: EmptyView()
                }
                
                // Tab Bar
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        Button(action: { selectedTab = index }) {
                            Image(systemName: tabIcon(for: index))
                                .font(.system(size: 30))
                                .foregroundColor(
                                    selectedTab == index
                                    ? (appState.isDarkMode ? .white : .black)
                                    : (appState.isDarkMode ? .gray : .gray)
                                )
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.top, 14)
                .frame(height: 36)
                .background(appState.isDarkMode ? Color.black : .white)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.gray.opacity(0.3)),
                    alignment: .top
                )
            }
            
            // Popup Overlay (Visit Notification)
            if let structure = dataStore.lastVisitedStructure {
                VisitNotificationView(structure: structure)
            }
            
            if let alert = appState.activeAlert {
                AlertContainer(alert: alert)
            }
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return selectedTab == 0 ? "map.fill" : "map"
        case 1: return selectedTab == 1 ? "house.fill" : "house"
        case 2: return selectedTab == 2 ? "gearshape.fill" : "gearshape"
        default: return ""
        }
    }
}


// MARK: - Alert Container
private struct AlertContainer: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataStore: DataStore
    let alert: AppState.AlertType
    
    var body: some View {
        switch alert {
        case .backgroundLocation:
            CustomAlert(
                icon: "figure.walk",
                iconColor: .green,
                title: "Enable Background Location",
                subtitle: "Tracks the structures you visit even when the app is closed.",
                primaryButton: .init(title: "Allow") {
                    locationService.requestAlwaysAuthorization()
                    appState.hasShownBackgroundLocationAlert = true
                    appState.dismissAlert()
                },
                secondaryButton: .init(title: "Cancel") {
                    appState.hasShownBackgroundLocationAlert = true
                    appState.dismissAlert()
                },
                isPresented: .constant(true)
            )
            
        case .rateStructures(let hasShown):
            CustomAlert(
                icon: "heart.fill",
                iconColor: .red,
                title: "Rate Structures",
                subtitle: "Swipe through and rate the structures to customize your experience!",
                primaryButton: .init(title: "Start Rating") {
                    appState.hasShownRateStructuresPopup = true
                    // Need to handle showing StructureSwipingView
                    appState.dismissAlert()
                },
                secondaryButton: .init(title: "Maybe Later") {
                    appState.hasShownRateStructuresPopup = true
                    appState.dismissAlert()
                },
                isPresented: .constant(true)
            )
            
        case .virtualWalkthrough(let hasShown):
            CustomAlert(
                icon: "figure.walk",
                iconColor: .blue,
                title: "Virtual Walkthrough",
                subtitle: "Go through each structure as if you were there in person.",
                primaryButton: .init(title: "Start Walkthrough") {
                    UserDefaults.standard.set(true, forKey: "hasShownVirtualWalkthroughPopup")
                    // Need to handle activating walkthrough
                    appState.dismissAlert()
                },
                secondaryButton: .init(title: "Maybe Later") {
                    UserDefaults.standard.set(true, forKey: "hasShownVirtualWalkthroughPopup")
                    appState.dismissAlert()
                },
                isPresented: .constant(true)
            )
            
        case .resetConfirmation(let type):
            CustomAlert(
                icon: type == .structures ? "arrow.counterclockwise" : "heart.slash.fill",
                iconColor: type == .structures ? .orange : .red,
                title: type == .structures ? "Reset Visited Structures" : "Reset Favorites",
                subtitle: type == .structures 
                    ? "Are you sure you want to reset all visited structures? This action cannot be undone."
                    : "Are you sure you want to reset all favorite structures? This action cannot be undone.",
                primaryButton: .init(title: "Reset") {
                    dataStore.resetStructures()
                    appState.dismissAlert()
                },
                secondaryButton: .init(title: "Cancel") {
                    appState.dismissAlert()
                },
                isPresented: .constant(true)
            )
            
        case .modePicker:
            ModePickerAlert(
                isPresented: .constant(true),
                onDismiss: { appState.dismissAlert() }
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppState())
            .environmentObject(DataStore.shared)
            .environmentObject(LocationService.shared)
    }
}
