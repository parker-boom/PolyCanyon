// PolyCanyonApp.swift
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct PolyCanyonApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    /// A state variable to track if the Design Village mode is enabled.
    /// nil means "decision not made yet" (only possible for existing users during the event).
    @State private var designVillageMode: Bool? = nil {
        didSet {
            print("🔄 [PolyCanyonApp] designVillageMode changed to: \(String(describing: designVillageMode))")
        }
    }

    // Event window: April 25 (00:00) to April 28 (00:00)
    let eventStartDate: Date = {
        var components = DateComponents()
        components.year = 2025
        components.month = 4
        components.day = 25
        return Calendar.current.date(from: components)!
    }()

    let eventEndDate: Date = {
        var components = DateComponents()
        components.year = 2025
        components.month = 4
        components.day = 28
        return Calendar.current.date(from: components)!
    }()

    init() {
        // Check if we have a saved value
        let hasOverride = UserDefaults.standard.object(forKey: "designVillageModeOverride") != nil
        print("🔍 [PolyCanyonApp] Init - Override exists in UserDefaults: \(hasOverride)")
        
        if hasOverride {
            let savedMode = UserDefaults.standard.bool(forKey: "designVillageModeOverride")
            print("🔍 [PolyCanyonApp] Init - Loading saved mode: \(savedMode)")
            _designVillageMode = State(initialValue: savedMode)
        } else {
            print("🔍 [PolyCanyonApp] Init - No saved mode found, starting with nil")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootRouter(designVillageMode: $designVillageMode,
                       eventStartDate: eventStartDate,
                       eventEndDate: eventEndDate)
                .onAppear {
                    print("📱 [PolyCanyonApp] onAppear - Current mode: \(String(describing: designVillageMode))")
                    
                    let now = Date()
                    let inEventWindow = now >= eventStartDate && now < eventEndDate
                    print("📱 [PolyCanyonApp] onAppear - In event window: \(inEventWindow)")
                    
                    // If it's before the event or after the event, force Poly Canyon mode.
                    if now < eventStartDate || now >= eventEndDate {
                        print("📱 [PolyCanyonApp] onAppear - Outside event window, forcing PC mode")
                        designVillageMode = false
                        UserDefaults.standard.set(false, forKey: "designVillageModeOverride")
                    } else {
                        // We're in the event window (April 25-27).
                        print("📱 [PolyCanyonApp] onAppear - Inside event window")
                        
                        // If no decision has been made yet...
                        if designVillageMode == nil {
                            print("📱 [PolyCanyonApp] onAppear - No decision made yet")
                            
                            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
                            print("📱 [PolyCanyonApp] onAppear - Onboarding completed: \(onboardingCompleted)")
                            
                            if !onboardingCompleted {
                                // New user: auto-route to DV.
                                print("📱 [PolyCanyonApp] onAppear - New user, setting to DV mode")
                                designVillageMode = true
                                UserDefaults.standard.set(true, forKey: "designVillageModeOverride")
                            } else {
                                print("📱 [PolyCanyonApp] onAppear - Existing user, will show prompt")
                            }
                            // For existing users, leave designVillageMode as nil to trigger the prompt.
                        } else {
                            print("📱 [PolyCanyonApp] onAppear - Decision already made: \(String(describing: designVillageMode))")
                        }
                    }
                }
        }
    }
}
