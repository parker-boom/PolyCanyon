// PolyCanyonContainerView.swift
import SwiftUI

struct PCContainerView: View {
    @StateObject private var appState = AppState()
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var locationService = LocationService.shared

    init() {
        // Configure the location service as needed.
        LocationService.shared.configure()
    }

    var body: some View {
        AppView()
            .environmentObject(appState)
            .environmentObject(dataStore)
            .environmentObject(locationService)
    }
}

struct PCContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PCContainerView()
    }
}

