// MARK: Overview
/*
    ContentView.swift

    This file defines the ContentView structure, managing the initial view of the app.

    ContentView:
    - Uses @AppStorage to persist user preferences and settings.
    - Displays OnboardingView if onboarding is not completed.
    - Switches to MainView after onboarding is finished.

    Constants:
    - Contains the key for tracking the onboarding version.
*/



// MARK: Code
import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingProcess") private var isNewOnboardingCompleted = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("adventureMode") private var isAdventureModeEnabled = true
    @StateObject private var structureData = StructureData()

    init() {
        // Initialize isDarkMode based on the system setting
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        _isDarkMode = AppStorage(wrappedValue: userInterfaceStyle == .dark, "isDarkMode")
    }

    var body: some View {
        if !isNewOnboardingCompleted {
            OnboardingView(
                isNewOnboardingCompleted: $isNewOnboardingCompleted,
                isAdventureModeEnabled: $isAdventureModeEnabled
            )
        } else {
            MainView(isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled, structureData: structureData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
