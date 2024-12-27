//
//  Arch_GraveyardApp.swift
//  Arch Graveyard
//
//  Created by Parker Jones on 4/3/24.
//

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
struct Poly_CanyonApp: App {
  // Register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  @StateObject private var appState = AppState()
  @StateObject private var dataStore = DataStore.shared
  @StateObject private var locationService = LocationService.shared

  var body: some Scene {
    WindowGroup {
      AppView()
        .environmentObject(appState)
        .environmentObject(dataStore)
        .environmentObject(locationService)
    }
  }
}

