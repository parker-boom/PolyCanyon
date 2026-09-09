import SwiftUI

/*
 AppState manages the global application state and user preferences with automatic persistence. It provides
 essential flags for app-wide features like dark mode, adventure mode, and onboarding status. This class is
 injected as an environment object (@EnvironmentObject) throughout the app, allowing views to observe and
 react to state changes. User preferences sync with UserDefaults; transient presentation intent stays in memory.
*/

enum OnboardingDestination { case map, tour }

@MainActor
final class AppState: ObservableObject {
    private let defaults: UserDefaults


    // Temporary flag to force light mode
    private let forceLightMode: Bool = true

    // Dark mode - updates UI to theme accordingly
    @Published var isDarkMode: Bool {
        didSet {
            if !forceLightMode { // Only save if not forcing light mode
                defaults.set(isDarkMode, forKey: "isDarkMode")
            }
        }
    }

    // Virtual Tour full screen state
    @Published var isVirtualTourFullScreen: Bool = false

    // Adventure mode - effects the entire user experience and every view rendered differently
    // FALSE = Virtual tour mode - for non-in person use, viewing information only
    // TRUE = Adventure mode - for in person use, location and progress tracking
    @Published var adventureModeEnabled: Bool {
        didSet {
            defaults.set(adventureModeEnabled, forKey: "adventureMode")
        }
    }

    // The chosen experience is independent of permission and active visit recording.
    @Published private(set) var exploresInPerson: Bool {
        didSet { defaults.set(exploresInPerson, forKey: "exploresInPerson") }
    }

    // Used to show onboarding flow once
    @Published var isOnboardingCompleted: Bool {
        didSet {
            defaults.set(isOnboardingCompleted, forKey: "onboardingProcess")
        }
    }

    // Consumed once by MainView; not a preference that can override a later tab choice.
    private var initialDestination: OnboardingDestination?

    func completeOnboarding(exploringInPerson: Bool) {
        exploresInPerson = exploringInPerson
        initialDestination = exploringInPerson ? .map : .tour
        isOnboardingCompleted = true
    }

    func consumeInitialDestination() -> OnboardingDestination? {
        defer { initialDestination = nil }
        return initialDestination
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

    // Tracks whether the canyon welcome has been shown
    @Published var hasVisitedCanyon: Bool {
        didSet {
            defaults.set(hasVisitedCanyon, forKey: "hasVisitedCanyon")
        }
    }

    // MARK: - FullScreen Views
    // Tracks which full-screen view is currently active
    @Published var activeFullScreenView: FullScreenView? = nil

    // Tracks which struct being displayed in struct info
    @Published var structInfoNum: Int = 0

    // Tracks which ghost structure is being displayed in ghost struct info
    @Published var ghostStructInfoNum: Int = 0



    // MARK: - Map Settings
    @Published var mapIsSatellite: Bool {
        didSet {
            defaults.set(mapIsSatellite, forKey: "mapIsSatellite")
        }
    }

    @Published var mapShowNumbers: Bool {
        didSet {
            defaults.set(mapShowNumbers, forKey: "mapShowNumbers")
        }
    }

    @Published var mapScale: CGFloat {
        didSet {
            defaults.set(mapScale, forKey: "mapScale")
        }
    }

    // MARK: - Virtual Walkthrough
    @Published var isVirtualWalkthrough: Bool {
        didSet {
            defaults.set(isVirtualWalkthrough, forKey: "isVirtualWalkthrough")
            // Auto-configure map when walkthrough changes
            configureMapSettings(forWalkthrough: isVirtualWalkthrough)
        }
    }

    @Published var currentStructureIndex: Int {
        didSet {
            defaults.set(currentStructureIndex, forKey: "currentStructureIndex")
        }
    }

    // Helper method to configure map container settings based on mode
    func configureMapSettings(forWalkthrough: Bool? = nil, inCanyon: Bool? = nil) {
        // Only set defaults on first ever launch
        if forWalkthrough == nil && inCanyon == nil {
            if !defaults.bool(forKey: "hasConfiguredMapSettings") {
                mapIsSatellite = false
                mapShowNumbers = true
                mapScale = 1.0
                defaults.set(true, forKey: "hasConfiguredMapSettings")
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
            defaults.set(needsFullReset, forKey: "needsFullReset")
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Force Light Mode or initialize with UserDefaults
        if forceLightMode {
            self.isDarkMode = false // Light Mode
        } else {
            self.isDarkMode = defaults.bool(forKey: "isDarkMode")
        }

        self.adventureModeEnabled = defaults.bool(forKey: "adventureMode")
        self.exploresInPerson = defaults.object(forKey: "exploresInPerson") as? Bool
            ?? defaults.bool(forKey: "adventureMode")
        self.isOnboardingCompleted = defaults.bool(forKey: "onboardingProcess")
        self.hasVisitedCanyon = defaults.bool(forKey: "hasVisitedCanyon")

        // Initialize map settings
        self.mapIsSatellite = defaults.bool(forKey: "mapIsSatellite")
        self.mapShowNumbers = defaults.bool(forKey: "mapShowNumbers")
        let savedScale = defaults.double(forKey: "mapScale")
        self.mapScale = savedScale.isFinite && (1...2).contains(savedScale) ? savedScale : 1
        self.isVirtualWalkthrough = defaults.bool(forKey: "isVirtualWalkthrough")
        self.currentStructureIndex = defaults.integer(forKey: "currentStructureIndex")

        self.needsFullReset = defaults.bool(forKey: "needsFullReset")
    }

    func resetAllSettings() {
        ["isDarkMode", "adventureMode", "exploresInPerson", "onboardingProcess", "hasVisitedCanyon",
         "mapIsSatellite", "mapShowNumbers", "mapScale", "isVirtualWalkthrough",
         "currentStructureIndex", "needsFullReset", "hasConfiguredMapSettings"]
            .forEach { defaults.removeObject(forKey: $0) }

        // Reset location services
        LocationService.shared.reset()

        // Reset our state
        initialDestination = nil
        isDarkMode = false
        hasVisitedCanyon = false
        adventureModeEnabled = false
        exploresInPerson = false
        isOnboardingCompleted = false
        needsFullReset = false
        isVirtualWalkthrough = false
        currentStructureIndex = 0
        mapIsSatellite = false
        mapShowNumbers = true
        mapScale = 1
        activeAlert = nil
        activeFullScreenView = nil
        isVirtualTourFullScreen = false
        structInfoNum = 0
        ghostStructInfoNum = 0
    }
}
