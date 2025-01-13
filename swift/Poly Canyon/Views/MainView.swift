// MARK: MainView.swift

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
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
            
            if locationService.isInPolyCanyonArea && !appState.hasVisitedCanyon {
                WelcomeToCanyonAlert()
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


// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            MainView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode Preview
            MainView()
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
