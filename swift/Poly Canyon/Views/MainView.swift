// MARK: MainView.swift

import SwiftUI

// Possible full-screen views
enum FullScreenView {
    case structInfo
    case settings
    case tinderMode
}

// Main app routing:
//* tab bar: map, home, detail
//* full-screen view: struct info, settings, tinder mode
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
                    .opacity(appState.activeFullScreenView == nil ? 1 : 0) // Hide tab bar during full-screen
            }

            // Full-Screen View Routing
            if let activeView = appState.activeFullScreenView {
                fullScreenView(for: activeView)
                    .transition(.opacity) 
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

    @ViewBuilder
    private func fullScreenView(for view: FullScreenView) -> some View {
        switch view {
        case .structInfo:
            StructInfo()
                .environmentObject(appState)
                .environmentObject(dataStore)
        case .settings:
            SettingsView()
                .environmentObject(appState)
        case .tinderMode:
            StructureSwipingView()
                .environmentObject(appState)
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
