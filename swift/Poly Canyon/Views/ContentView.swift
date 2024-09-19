// MARK: ContentView.swift

import SwiftUI

/**
 * ContentView
 *
 * Serves as the entry point of the Poly Canyon app, managing the initial user interface based on onboarding status.
 * Utilizes @AppStorage to persist user preferences such as onboarding completion, dark mode, and adventure mode.
 * Switches between OnboardingView and MainView depending on whether the user has completed the onboarding process.
 */
struct ContentView: View {
    @AppStorage("onboardingProcess") private var isNewOnboardingCompleted = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("adventureMode") private var isAdventureModeEnabled = true
    @StateObject private var structureData = StructureData()

    /**
     * Initializes the ContentView and sets the dark mode based on the system's current interface style.
     */
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
            MainView(
                isDarkMode: $isDarkMode,
                isAdventureModeEnabled: $isAdventureModeEnabled,
                structureData: structureData
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
