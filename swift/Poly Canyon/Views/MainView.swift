// MARK: MainView.swift

import SwiftUI

// Possible full-screen views
enum FullScreenView {
    case structInfo
    case settings
    case ratings
    case ghostStructInfo
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
                // *** Need to change back to Map -> Home -> Detail
                switch selectedTab {
                case 0: MapView()
                case 1: DetailView()
                case 2: SettingsView()
                default: EmptyView()
                }
                CustomTabBar(selectedTab: $selectedTab)
                    .opacity(appState.activeFullScreenView == nil && !appState.isVirtualTourFullScreen ? 1 : 0) // Hide tab bar during full-screen
            }

            // Full-Screen View Routing
            if let activeView = appState.activeFullScreenView {
                fullScreenView(for: activeView)
                    .transition(.opacity) 
            }

            // Popup Overlay (Visit Notification)
            if dataStore.lastVisitedStructure != nil || dataStore.lastVisitedGhostStructure != nil {
                VisitNotificationView()
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
                .environmentObject(dataStore)
        case .ratings:
            RatingsView()
                .environmentObject(appState)
                .environmentObject(dataStore)
        case .ghostStructInfo:
            // Show GhostInfo view with the appropriate ghost structure
            GhostInfo(initialGhostIndex: findGhostStructureIndex())
                .environmentObject(appState)
                .environmentObject(dataStore)
        }
    }
    
    // Helper to find the ghost structure index based on the appState.ghostStructInfoNum
    private func findGhostStructureIndex() -> Int? {
        // If ghostStructInfoNum is set, find the corresponding ghost structure
        if appState.ghostStructInfoNum > 0 {
            return dataStore.ghostStructures.firstIndex(where: { Int($0.number) == appState.ghostStructInfoNum })
        }
        return nil
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
