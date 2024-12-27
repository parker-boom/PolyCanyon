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
  @StateObject private var structureData = StructureData()
  @StateObject private var mapPointManager = MapPointManager()
  @StateObject private var locationManager: LocationManager

  init() {
    let mapPointManager = MapPointManager()
    let structureData = StructureData()

    _structureData = StateObject(wrappedValue: structureData)
    _mapPointManager = StateObject(wrappedValue: mapPointManager)
    _locationManager = StateObject(wrappedValue: LocationManager(
      mapPointManager: mapPointManager,
      structureData: structureData,
      isAdventureModeEnabled: UserDefaults.standard.bool(forKey: "adventureMode")
    ))
  }

  var body: some Scene {
    WindowGroup {
      AppView()
        .environmentObject(appState)
        .environmentObject(structureData)
        .environmentObject(locationManager)
        .environmentObject(mapPointManager)
    }
  }
}

