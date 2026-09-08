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
            .preferredColorScheme(.light)
            .task {
                locationService.configure()
                locationService.setAppActive(scenePhase != .background)
            }
            .onChange(of: scenePhase) { phase in
                locationService.setAppActive(phase != .background)
                if phase == .active { dataStore.resumeAutomaticVisits() }
            }
    }
}

struct PCContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PCContainerView()
    }
}

