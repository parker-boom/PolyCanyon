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
                case 1: HomeView()
                case 2: DetailView()
                default: EmptyView()
                }
                
                CustomTabBar(selectedTab: $selectedTab)
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
