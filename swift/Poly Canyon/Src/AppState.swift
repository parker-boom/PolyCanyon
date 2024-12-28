import SwiftUI

class AppState: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var adventureModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(adventureModeEnabled, forKey: "adventureMode")
        }
    }
    
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "onboardingProcess")
        }
    }
    
    @Published var visitedCount: Int {
        didSet {
            UserDefaults.standard.set(visitedCount, forKey: "visitedCount")
        }
    }
    
    @Published var visitedAllCount: Int {
        didSet {
            UserDefaults.standard.set(visitedAllCount, forKey: "visitedAllCount")
        }
    }
    
    @Published var dayCount: Int {
        didSet {
            UserDefaults.standard.set(dayCount, forKey: "dayCount")
        }
    }
    
    @Published var previousDayVisited: String? {
        didSet {
            UserDefaults.standard.set(previousDayVisited, forKey: "previousDayVisited")
        }
    }
    
    @Published var hasCompletedFirstVisit: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedFirstVisit, forKey: "hasCompletedFirstVisit")
        }
    }
    
    @Published var hasShownRateStructuresPopup: Bool {
        didSet {
            UserDefaults.standard.set(hasShownRateStructuresPopup, forKey: "hasShownRateStructuresPopup")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.adventureModeEnabled = UserDefaults.standard.bool(forKey: "adventureMode")
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
        self.visitedCount = UserDefaults.standard.integer(forKey: "visitedCount")
    }
}