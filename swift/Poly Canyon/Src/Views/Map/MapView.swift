/*
 MapView provides the primary map interface for structure exploration. It handles two distinct modes: 
 adventure mode with live location tracking and virtual tour mode for remote browsing. The view manages 
 multiple overlays including structure popups, alerts, and mode-specific UI elements. It coordinates with 
 LocationService for tracking and DataStore for structure management.
*/

import SwiftUI
import CoreLocation
import Zoomable
import AlertPopUp

struct MapView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Persistent State
    @AppStorage("virtualTourCurrentStructure") private var currentStructureIndex: Int = 0
    @AppStorage("hasShownAdventureModeAlert") private var hasShownAdventureModeAlert: Bool = false
    @AppStorage("hasShownVirtualWalkthroughPopup") private var hasShownVirtualWalkthroughPopup: Bool = false
    
    // MARK: - Structure Selection
    @State private var selectedStructure: Structure?
    @State private var nearbyUnvisitedMapPoints: [MapPoint] = []
    
    // MARK: - Modal States
    @State private var showAdventureModeAlert = false
    @State private var showVisitedStructurePopup = false
    @State private var showAllVisitedPopup = false
    @State private var showStructPopup = false
    @State private var showNearbyUnvisitedView = false
    @State private var showRateStructuresPopup = false
    @State private var showStructureSwipingView = false
    @State private var showVirtualWalkthroughPopup = false
    
    // MARK: - View States
    @State private var isSatelliteView: Bool = false
    @State private var isVirtualWalkthroughActive: Bool = false
    @State private var currentWalkthroughMapPoint: MapPoint?
    
    // MARK: - Map Interaction
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Base map layers
                Color(appState.isDarkMode ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                if isSatelliteView {
                    Image("BlurredBG")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Interactive map content
                MapWithLocationDot(
                    mapImage: currentMapImage(),
                    isSatelliteView: isSatelliteView,
                    geometry: geometry,
                    isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                    currentStructureIndex: currentStructureIndex,
                    currentWalkthroughMapPoint: currentWalkthroughMapPoint,
                    scale: scale,
                    offset: offset
                )
                .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)
                .onChange(of: isVirtualWalkthroughActive) { newValue in
                    if newValue { updateCurrentMapPoint() }
                }
                
                // Adventure mode controls
                if locationService.canUseLocation {
                    Button(action: {
                        withAnimation {
                            showNearbyUnvisitedView.toggle()
                            if showNearbyUnvisitedView {
                                updateNearbyUnvisitedMapPoints()
                            }
                        }
                    }) {
                        Image(systemName: showNearbyUnvisitedView ? "xmark.circle.fill" : "mappin.circle.fill")
                            .font(.system(size: 24))
                            .frame(width: 50, height: 50)
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .background(appState.isDarkMode ? Color.black : Color.white)
                            .cornerRadius(15)
                            .padding()
                            .shadow(color: shadowColor, radius: 5, x: 0, y: 0)
                    }
                    .padding(.top, -10)
                }
                
                // Virtual tour controls
                if !appState.adventureModeEnabled {
                    Button(action: {
                        withAnimation {
                            isVirtualWalkthroughActive.toggle()
                            if isVirtualWalkthroughActive {
                                updateCurrentMapPoint()
                            }
                        }
                    }) {
                        Image(systemName: isVirtualWalkthroughActive ? "xmark.circle.fill" : "figure.walk.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .frame(width: 50, height: 50)
                            .background(appState.isDarkMode ? Color.black : Color.white)
                            .cornerRadius(15)
                            .shadow(color: shadowColor, radius: 5, x: 0, y: 0)
                    }
                    .padding(.leading, 15)
                }
                
                // Map type toggle
                Button(action: { isSatelliteView.toggle() }) {
                    Image(systemName: isSatelliteView ? "map.fill" : "globe.americas.fill")
                        .font(.system(size: 24))
                        .frame(width: 50, height: 50)
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                        .background(appState.isDarkMode ? Color.black : Color.white)
                        .cornerRadius(15)
                        .padding()
                        .shadow(color: shadowColor, radius: 5, x: 0, y: 0)
                }
                .padding(.top, -10)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                
                // Status messages
                bottomOnScreenMessages(geometry)
                
                // Nearby structures overlay
                if showNearbyUnvisitedView, !nearbyUnvisitedMapPoints.isEmpty {
                    NearbyUnvisitedView(
                        selectedStructure: $selectedStructure,
                        showStructPopup: $showStructPopup,
                        nearbyUnvisitedStructures: mapPointsToStructures(nearbyUnvisitedMapPoints)
                    )
                    .padding(.top, 75)
                    .transition(.move(edge: .top))
                }
                
                // Virtual walkthrough interface
                if isVirtualWalkthroughActive {
                    VStack {
                        Spacer()
                        VirtualWalkThroughBar(
                            structure: dataStore.structures[currentStructureIndex],
                            onNext: moveToNextStructure,
                            onPrevious: moveToPreviousStructure,
                            onTap: {
                                selectedStructure = dataStore.structures[currentStructureIndex]
                                showStructPopup = true
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
                
                // Structure interaction popups
                ZStack {
                    if showVisitedStructurePopup, let lastVisited = dataStore.lastVisitedStructure {
                        VisitedStructurePopup(
                            structure: lastVisited,
                            isPresented: $showVisitedStructurePopup,
                            showStructPopup: $showStructPopup,
                            selectedStructure: $selectedStructure
                        ) {
                            showVisitedStructurePopup = false
                        }
                    }
                    
                    if showAllVisitedPopup {
                        AllStructuresVisitedPopup(isPresented: $showAllVisitedPopup)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                    }
                }
                
                // Structure detail popup
                if showStructPopup, let s = selectedStructure {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { showStructPopup = false }
                    
                    StructPopUp(
                        structureData: dataStore,
                        structure: s,
                        isDarkMode: $appState.isDarkMode,
                        isPresented: $showStructPopup
                    )
                    .padding(15)
                    .frame(width: geometry.size.width - 30, height: geometry.size.height - 30)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .onAppear(perform: handleOnAppear)
            .sheet(isPresented: $showStructureSwipingView) {
                StructureSwipingView(structureData: dataStore, isDarkMode: $appState.isDarkMode)
            }
            .overlay(
                MapAlertsOverlay(
                    showAdventureModeAlert: $showAdventureModeAlert,
                    showRateStructuresPopup: $showRateStructuresPopup,
                    showVirtualWalkthroughPopup: $showVirtualWalkthroughPopup,
                    hasShownAdventureModeAlert: $hasShownAdventureModeAlert,
                    hasShownVirtualWalkthroughPopup: $hasShownVirtualWalkthroughPopup,
                    isVirtualWalkthroughActive: $isVirtualWalkthroughActive,
                    showStructureSwipingView: $showStructureSwipingView
                )
                .environmentObject(appState)
                .environmentObject(dataStore)
                .environmentObject(locationService)
            )
            .onChange(of: locationService.locationStatus) { newStatus in
                if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
                    locationService.startUpdatingLocation()
                }
            }
            .onChange(of: showAllVisitedPopup) { newValue in
                if newValue { appState.visitedAllCount += 1 }
            }
            .onChange(of: dataStore.lastVisitedStructure) { _ in
                if dataStore.lastVisitedStructure != nil {
                    showVisitedStructurePopup = true
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private func bottomOnScreenMessages(_ geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            if appState.adventureModeEnabled {
                if locationService.isLocationPermissionDenied {
                    bottomMessage("Enable location services")
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                } else if !locationService.canUseLocation {
                    bottomMessage("Enter the area of Poly Canyon")
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleOnAppear() {
        if appState.adventureModeEnabled, !hasShownAdventureModeAlert {
            showAdventureModeAlert = true
        } else if !appState.adventureModeEnabled, !showRateStructuresPopup {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showRateStructuresPopup = true
            }
        }
    }
    
    private func updateCurrentMapPoint() {
        let currentStructure = dataStore.structures[currentStructureIndex]
        currentWalkthroughMapPoint = dataStore.mapPoints.first { $0.landmark == currentStructure.number }
    }
    
    private func moveToNextStructure() {
        currentStructureIndex = (currentStructureIndex + 1) % dataStore.structures.count
        updateCurrentMapPoint()
    }
    
    private func moveToPreviousStructure() {
        currentStructureIndex = (currentStructureIndex - 1 + dataStore.structures.count) % dataStore.structures.count
        updateCurrentMapPoint()
    }
    
    private func currentMapImage() -> String {
        if isSatelliteView {
            return "SatelliteMap"
        } else {
            return appState.isDarkMode ? "DarkMap" : "LightMap"
        }
    }
    
    private func updateNearbyUnvisitedMapPoints() {
        nearbyUnvisitedMapPoints = dataStore.mapPoints.filter { !$0.isVisited }
    }
    
    private func mapPointsToStructures(_ mapPoints: [MapPoint]) -> [Structure] {
        mapPoints.compactMap { mp in
            dataStore.structures.first { $0.number == mp.landmark }
        }
    }
    
    private func bottomMessage(_ text: String) -> some View {
        Text(text)
            .fontWeight(.semibold)
            .padding()
            .background(appState.isDarkMode ? Color.black : Color.white)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .cornerRadius(10)
            .shadow(color: shadowColor, radius: 5, x: 0, y: 0)
    }
    
    private var shadowColor: Color {
        appState.isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8)
    }
}

// MARK: - Example of an Overlay Using Shared Alerts
struct MapAlertsOverlay: View {
    @Binding var showAdventureModeAlert: Bool
    @Binding var showRateStructuresPopup: Bool
    @Binding var showVirtualWalkthroughPopup: Bool
    
    @Binding var hasShownAdventureModeAlert: Bool
    @Binding var hasShownVirtualWalkthroughPopup: Bool
    
    @Binding var isVirtualWalkthroughActive: Bool
    @Binding var showStructureSwipingView: Bool
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        Group {
            if showAdventureModeAlert {
                // Reusing global CustomAlert from SharedAlerts
                CustomAlert(
                    icon: "figure.walk",
                    iconColor: .green,
                    title: "Enable Background Location",
                    subtitle: "Tracks the structures you visit even when the app is closed.",
                    primaryButton: .init(title: "Allow") {
                        locationService.requestAlwaysAuthorization()
                        appState.adventureModeEnabled = true
                        UserDefaults.standard.set(true, forKey: "adventureModeEnabled")
                        showAdventureModeAlert = false
                        hasShownAdventureModeAlert = true
                    },
                    secondaryButton: .init(title: "Cancel") {
                        showAdventureModeAlert = false
                        hasShownAdventureModeAlert = true
                    },
                    isPresented: $showAdventureModeAlert,
                    isDarkMode: $appState.isDarkMode
                )
            }
            
            if showRateStructuresPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                CustomAlert(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Rate Structures",
                    subtitle: "Swipe through and rate the structures to customize your experience!",
                    primaryButton: .init(title: "Start Rating") {
                        showStructureSwipingView = true
                        showRateStructuresPopup = false
                        appState.hasShownRateStructuresPopup = true
                    },
                    secondaryButton: .init(title: "Maybe Later") {
                        showRateStructuresPopup = false
                        appState.hasShownRateStructuresPopup = true
                    },
                    isPresented: $showRateStructuresPopup,
                    isDarkMode: $appState.isDarkMode
                )
            }
            
            if showVirtualWalkthroughPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                CustomAlert(
                    icon: "figure.walk",
                    iconColor: .blue,
                    title: "Virtual Walkthrough",
                    subtitle: "Go through each structure as if you were there in person.",
                    primaryButton: .init(title: "Start Walkthrough") {
                        showVirtualWalkthroughPopup = false
                        isVirtualWalkthroughActive = true
                        hasShownVirtualWalkthroughPopup = true
                    },
                    secondaryButton: .init(title: "Maybe Later") {
                        showVirtualWalkthroughPopup = false
                        hasShownVirtualWalkthroughPopup = true
                    },
                    isPresented: $showVirtualWalkthroughPopup,
                    isDarkMode: $appState.isDarkMode
                )
            }
        }
    }
}

// MARK: - Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            MapView()
                .environmentObject(AppState())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode Preview
            MapView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}