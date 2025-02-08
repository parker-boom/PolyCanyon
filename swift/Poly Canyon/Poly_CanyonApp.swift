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
    /// nil means “decision not made yet” (only possible for existing users during the event).
    @State private var designVillageMode: Bool? = nil

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

    var body: some Scene {
        WindowGroup {
            RootRouter(designVillageMode: $designVillageMode,
                       eventStartDate: eventStartDate,
                       eventEndDate: eventEndDate)
                .onAppear {
                    let now = Date()
                    // If it's before the event or after the event, force Poly Canyon mode.
                    if now < eventStartDate || now >= eventEndDate {
                        designVillageMode = false
                        UserDefaults.standard.set(false, forKey: "designVillageModeOverride")
                    } else {
                        // We're in the event window (April 25-27).
                        // If no decision has been made yet...
                        if designVillageMode == nil {
                            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingProcess")
                            if !onboardingCompleted {
                                // New user: auto-route to DV.
                                designVillageMode = true
                                UserDefaults.standard.set(true, forKey: "designVillageModeOverride")
                            }
                            // For existing users, leave designVillageMode as nil to trigger the prompt.
                        }
                    }
                }
        }
    }
}
