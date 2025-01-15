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

    // MARK: - Map Settings
    @Published var mapIsSatellite: Bool {
        didSet {
            UserDefaults.standard.set(mapIsSatellite, forKey: "mapIsSatellite")
        }
    }
    
    @Published var mapShowNumbers: Bool {
        didSet {
            UserDefaults.standard.set(mapShowNumbers, forKey: "mapShowNumbers")
        }
    }
    
    @Published var mapScale: CGFloat {
        didSet {
            UserDefaults.standard.set(mapScale, forKey: "mapScale")
        }
    }
    
    // MARK: - Virtual Walkthrough
    @Published var isVirtualWalkthrough: Bool {
        didSet {
            UserDefaults.standard.set(isVirtualWalkthrough, forKey: "isVirtualWalkthrough")
            // Auto-configure map when walkthrough changes
            configureMapSettings(forWalkthrough: isVirtualWalkthrough)
        }
    }
    
    @Published var currentStructureIndex: Int {
        didSet {
            UserDefaults.standard.set(currentStructureIndex, forKey: "currentStructureIndex")
        }
    }
    
    // Helper method to configure map settings based on mode
    func configureMapSettings(forWalkthrough: Bool? = nil, inCanyon: Bool? = nil) {
        // Only set defaults on first ever launch
        if forWalkthrough == nil && inCanyon == nil {
            if !UserDefaults.standard.bool(forKey: "hasConfiguredMapSettings") {
                mapIsSatellite = false
                mapShowNumbers = true
                mapScale = 1.0
                UserDefaults.standard.set(true, forKey: "hasConfiguredMapSettings")
            }
            return
        }
        
        // Handle exiting walkthrough or leaving canyon
        if (forWalkthrough == false) || (adventureModeEnabled && inCanyon == false) {
            mapIsSatellite = false
            mapShowNumbers = true
            mapScale = 1.0
            return
        }
        
        // Virtual walkthrough takes precedence (entering walkthrough)
        if forWalkthrough == true {
            mapIsSatellite = true
            mapShowNumbers = false
            mapScale = 1.5
            return
        }
        
        // Adventure mode & physically present (entering canyon)
        if adventureModeEnabled && inCanyon == true {
            mapIsSatellite = true
            mapShowNumbers = true
            mapScale = 1.5
            return
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.adventureModeEnabled = UserDefaults.standard.bool(forKey: "adventureMode")
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
        self.hasShownBackgroundLocationAlert = UserDefaults.standard.bool(forKey: "hasShownBackgroundLocationAlert")
        self.hasVisitedCanyon = UserDefaults.standard.bool(forKey: "hasVisitedCanyon")
        
        // Initialize map settings
        self.mapIsSatellite = UserDefaults.standard.bool(forKey: "mapIsSatellite")
        self.mapShowNumbers = UserDefaults.standard.bool(forKey: "mapShowNumbers")
        self.mapScale = UserDefaults.standard.double(forKey: "mapScale") != 0 ? 
            UserDefaults.standard.double(forKey: "mapScale") : 1.0
        self.isVirtualWalkthrough = UserDefaults.standard.bool(forKey: "isVirtualWalkthrough")
        self.currentStructureIndex = UserDefaults.standard.integer(forKey: "currentStructureIndex")
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
