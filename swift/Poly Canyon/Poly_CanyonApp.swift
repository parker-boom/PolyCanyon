/*
 PolyCanyonApp serves as the main entry point for the Poly Canyon application. It initializes core services 
 including Firebase, AppState, DataStore, and LocationService. The app handles global state management and 
 dependency injection through environment objects. It follows a standard SwiftUI app structure with a 
 WindowGroup scene containing the root AppView.
*/

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
  // Register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  @StateObject private var appState = AppState()
  @StateObject private var dataStore = DataStore.shared
  @StateObject private var locationService = LocationService.shared

  init() {
    // Configure LocationService
    LocationService.shared.configure() 
    
    // Initialize LocationService mode from AppState's persisted value
    let savedMode = UserDefaults.standard.bool(forKey: "adventureMode")
    LocationService.shared.setMode(savedMode ? .adventure : .virtualTour)
  }

  var body: some Scene {
    WindowGroup {
      AppView()
        .environmentObject(appState)
        .environmentObject(dataStore)
        .environmentObject(locationService)
    }
  }
}

