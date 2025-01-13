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
    
    /*
    // Used for map offset when map isn't full screen
    @Published var circleY: CGFloat? = nil
    @Published var circleX: CGFloat? = nil
    @Published var dotVisible: Bool = false
    */
    
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
    
    // MARK: - Global Alert System
    @Published var activeAlert: AlertType?
    
    enum AlertType: Identifiable {
        case backgroundLocation
        case resetConfirmation(type: ResetType)
        case modePicker(currentMode: Bool)
        
        enum ResetType {
            case structures
            case favorites
        }
        
        var id: String {
            switch self {
            case .backgroundLocation: return "background"
            case .resetConfirmation: return "reset"
            case .modePicker: return "mode"
            }
        }
    }
    
    // Alert helper methods
    func showAlert(_ type: AlertType) {
        activeAlert = type
    }
    
    func dismissAlert() {
        activeAlert = nil
    }

    // Add property to track if background alert was shown
    @Published var hasShownBackgroundLocationAlert: Bool {
        didSet {
            UserDefaults.standard.set(hasShownBackgroundLocationAlert, forKey: "hasShownBackgroundLocationAlert")
        }
    }

    @Published var hasVisitedCanyon: Bool {
        didSet {
            UserDefaults.standard.set(hasVisitedCanyon, forKey: "hasVisitedCanyon")
        }
    }

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.adventureModeEnabled = UserDefaults.standard.bool(forKey: "adventureMode")
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
        self.hasShownBackgroundLocationAlert = UserDefaults.standard.bool(forKey: "hasShownBackgroundLocationAlert")
        self.hasVisitedCanyon = UserDefaults.standard.bool(forKey: "hasVisitedCanyon")
    }

    func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Reinitialize defaults
        isDarkMode = false
        hasVisitedCanyon = false
        adventureModeEnabled = false
        isOnboardingCompleted = false
    }
}
