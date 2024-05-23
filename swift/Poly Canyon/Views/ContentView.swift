// MARK: ContentView.swift
// This SwiftUI view file is the entry point for the "Arch Graveyard" app's UI. It controls the presentation flow between the onboarding and main content views based on user preferences and first-launch detection.

// Notable features include:
// - User preference storage for themes and modes using @AppStorage.
// - Conditional rendering to switch between OnboardingView and MainView based on the isFirstLaunch flag.

// This setup ensures users are properly onboarded on their first app launch, while returning users are directly taken to the main content with their settings preserved.





// MARK: Code
import SwiftUI

struct ContentView: View {
    @AppStorage(Constants.currentOnboardingVersion) private var isNewOnboardingCompleted = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isAdventureModeEnabled") private var isAdventureModeEnabled = true


    var body: some View {
        if !isNewOnboardingCompleted {
            OnboardingView(isNewOnboardingCompleted: $isNewOnboardingCompleted)
        } else {
            MainView(isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled)
        }
    }
}

struct Constants {
    static let currentOnboardingVersion = "currentOnboardingVersion"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
