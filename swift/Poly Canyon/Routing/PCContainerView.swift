// PolyCanyonContainerView.swift
import SwiftUI

struct PCContainerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var locationService = LocationService.shared


    var body: some View {
        AppView()
            .environmentObject(appState)
            .environmentObject(dataStore)
            .environmentObject(locationService)
            .preferredColorScheme(appState.theme.colorScheme)
            .task {
                locationService.setAppActive(scenePhase == .active)
                locationService.configure()
            }
            .onChange(of: scenePhase) { phase in
                locationService.setAppActive(phase == .active)
                if phase == .active { dataStore.resumeAutomaticVisits() }
            }
    }
}

struct PCContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PCContainerView()
    }
}

