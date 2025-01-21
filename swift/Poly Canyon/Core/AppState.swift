import SwiftUI

/*
 AppState manages the global application state and user preferences with automatic persistence. It provides
 essential flags for app-wide features like dark mode, adventure mode, and onboarding status. This class is 
 injected as an environment object (@EnvironmentObject) throughout the app, allowing views to observe and 
 react to state changes. All properties automatically sync with UserDefaults for persistence across app launches.
*/

class AppState: ObservableObject {

    // Temporary flag to force light mode
    private let forceLightMode: Bool = true

    // Dark mode - updates UI to theme accordingly  
    @Published var isDarkMode: Bool {
        didSet {
            if !forceLightMode { // Only save if not forcing light mode
                UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            }
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
    
    // MARK: - Global Alert System
    enum AlertType: Identifiable {
            case resetConfirmation(type: ResetType)
            case modePicker(currentMode: Bool)
            
            enum ResetType {
                case structures
                case favorites
            }
            
            var id: String {
                switch self {
                case .resetConfirmation: return "reset"
                case .modePicker: return "mode"
                }
            }
    }

    
    @Published var activeAlert: AlertType?
    
    
    // Alert helper methods
    func showAlert(_ type: AlertType) {
        activeAlert = type
    }
    
    func dismissAlert() {
        activeAlert = nil
    }

    // Add property to track if background alert was shown
    @Published var hasVisitedCanyon: Bool {
        didSet {
            UserDefaults.standard.set(hasVisitedCanyon, forKey: "hasVisitedCanyon")
        }
    }

    // MARK: - FullScreen Views
    // Tracks which full-screen view is currently active
    @Published var activeFullScreenView: FullScreenView? = nil  

    // Tracks which struct being displayed in struct info
    @Published var structInfoNum: Int = 0
    
    // Tracks which structure is being displayed in tinder mode
    @Published var tinderModeStructureNum: Int = -1 // -1 is starting msg, 31 is end msg


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
    
    // Helper method to configure map container settings based on mode
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
    
    // Add near the top with other UserDefaults-backed properties
    @Published private(set) var needsFullReset: Bool {
        didSet {
            UserDefaults.standard.set(needsFullReset, forKey: "needsFullReset")
        }
    }
    
    init() {

        // Force Light Mode or initialize with UserDefaults
        if forceLightMode {
            self.isDarkMode = false // Light Mode
        } else {
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        }
        
        self.adventureModeEnabled = UserDefaults.standard.bool(forKey: "adventureMode")
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
        self.hasVisitedCanyon = UserDefaults.standard.bool(forKey: "hasVisitedCanyon")
        
        // Initialize map settings
        self.mapIsSatellite = UserDefaults.standard.bool(forKey: "mapIsSatellite")
        self.mapShowNumbers = UserDefaults.standard.bool(forKey: "mapShowNumbers")
        self.mapScale = UserDefaults.standard.double(forKey: "mapScale") != 0 ? 
            UserDefaults.standard.double(forKey: "mapScale") : 1.0
        self.isVirtualWalkthrough = UserDefaults.standard.bool(forKey: "isVirtualWalkthrough")
        self.currentStructureIndex = UserDefaults.standard.integer(forKey: "currentStructureIndex")
        
        self.needsFullReset = UserDefaults.standard.bool(forKey: "needsFullReset")
    }

    func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Reset location services
        LocationService.shared.reset()
        
        // Reset our state
        isDarkMode = false
        hasVisitedCanyon = false
        adventureModeEnabled = false
        isOnboardingCompleted = false
        needsFullReset = false  // Ensure we don't reset again
    }
}
