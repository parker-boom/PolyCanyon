import SwiftUI

/*
 AppState manages the global application state and user preferences with automatic persistence. It provides
 essential flags for app-wide features like dark mode, adventure mode, and onboarding status. This class is 
 injected as an environment object (@EnvironmentObject) throughout the app, allowing views to observe and 
 react to state changes. All properties automatically sync with UserDefaults for persistence across app launches.
*/

class AppState: ObservableObject {

    // Dark mode - updates UI to theme accordingly  
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            // should update to match system setting
        }
    }
    
    // Adventure mode - effects the entire user experience and every view rendered differently
    // FALSE = Virtual tour mode - for non-in person use, viewing information only
    // TRUE = Adventure mode - for in person use, location and progress tracking
    @Published var adventureModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(adventureModeEnabled, forKey: "adventureMode")
        }
    }
    
    // Used to show onboarding flow once
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "onboardingProcess")
        }
    }
    
    // Used to show rate structures popup once 
    @Published var hasShownRateStructuresPopup: Bool {
        didSet {
            UserDefaults.standard.set(hasShownRateStructuresPopup, forKey: "hasShownRateStructuresPopup")
        }
    }

    // Could use more for global popups 
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.adventureModeEnabled = UserDefaults.standard.bool(forKey: "adventureMode")
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
        self.hasShownRateStructuresPopup = UserDefaults.standard.bool(forKey: "hasShownRateStructuresPopup")
    }
}