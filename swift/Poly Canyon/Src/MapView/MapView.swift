// MARK: MapView.swift

import SwiftUI
import CoreLocation
import Zoomable

/**
 * MapView
 *
 * Displays a navigable map interface for the Poly Canyon app. Users can interact with the map through zoom and drag gestures,
 * toggle between satellite and standard map views, and view nearby unvisited structures. The view also handles location services,
 * displays relevant UI elements based on the user's location and adventure mode status, and manages various popups related to
 * structure visits and walkthroughs.
 */
struct MapView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Map-Specific Persistence
    @AppStorage("showVirtualTourButton") private var showVirtualTourButton = true
    @AppStorage("virtualTourCurrentStructure") private var currentStructureIndex: Int = 0
    @AppStorage("hasShownAdventureModeAlert") private var hasShownAdventureModeAlert: Bool = false
    @AppStorage("hasShownVirtualWalkthroughPopup") private var hasShownVirtualWalkthroughPopup: Bool = false
    
    // MARK: - Structure Selection States
    @State private var visitedStructure: Structure?
    @State private var selectedStructure: Structure?
    @State private var nearbyMapPoints: [MapPoint] = []
    @State private var nearbyUnvisitedStructures: [MapPoint] = []
    
    // MARK: - UI Popup States
    @State private var showRateStructuresPopup = false
    @State private var showStructureSwipingView = false
    @State private var showPermissionAlert = false
    @State private var showAdventureModeAlert = false
    @State private var showVisitedStructurePopup = false
    @State private var showAllVisitedPopup = false
    @State private var showStructPopup = false
    @State private var showNearbyUnvisitedView = false
    @State private var showVirtualWalkthroughPopup = false
    
    // MARK: - Map View States
    @State private var isSatelliteView: Bool = false
    @State private var isVirtualWalkthroughActive = false
    @State private var currentWalkthroughMapPoint: MapPoint?
    @State private var isZoomedIn = false
    
    // MARK: - Gesture States
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var mapImageSize: CGSize = .zero
    @GestureState private var magnifyBy = 1.0
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background Color
                Color(appState.isDarkMode ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                // Blurred Satellite View Background
                if isSatelliteView {
                    Image("BlurredBG")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Main Map with Location Dot and Zoomable Features
                MapWithLocationDot(
                    mapImage: mapImage(),
                    isSatelliteView: isSatelliteView,
                    geometry: geometry,
                    isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                    currentStructureIndex: currentStructureIndex,
                    currentWalkthroughMapPoint: currentWalkthroughMapPoint
                )
                .onChange(of: isVirtualWalkthroughActive) { newValue in
                    if newValue {
                        updateCurrentMapPoint()
                    }
                }
                .zoomable(
                    minZoomScale: 1.0,
                    doubleTapZoomScale: 2.0
                )
                
                // Nearby Unvisited Structures Toggle Button
                if appState.adventureModeEnabled,
                   let location = locationService.lastLocation,
                   locationService.isWithinSafeZone(coordinate: location.coordinate) {
                    Button(action: {
                        withAnimation {
                            showNearbyUnvisitedView.toggle()
                            if showNearbyUnvisitedView {
                                updateNearbyUnvisitedStructures()
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
                    }
                    .shadow(color: appState.isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                    .padding(.top, -10)
                }
                
                // Virtual Walkthrough Button
                if !appState.adventureModeEnabled {
                    virtualWalkThroughButton
                }
                
                // Map View Toggle Button (Top Right)
                Button(action: {
                    isSatelliteView.toggle()
                }) {
                    Image(systemName: isSatelliteView ? "map.fill" : "globe.americas.fill")
                        .font(.system(size: 24))
                        .frame(width: 50, height: 50)
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                        .background(appState.isDarkMode ? Color.black : Color.white)
                        .cornerRadius(15)
                        .padding()
                }
                .shadow(color: appState.isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                .padding(.top, -10)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                
                // Bottom Messages
                VStack {
                    Spacer()
                    
                    if appState.adventureModeEnabled {
                        if locationService.locationStatus == .denied || locationService.locationStatus == .restricted {
                            bottomMessage("Enable location services")
                                .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                        } else if let location = locationService.lastLocation {
                            if !locationService.isWithinSafeZone(coordinate: location.coordinate) {
                                bottomMessage("Enter the area of Poly Canyon")
                                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                            }
                        }
                    }
                }
                
                // MARK: - Pop-Ups
                // Nearby Unvisited Structures View
                if showNearbyUnvisitedView && !nearbyUnvisitedStructures.isEmpty {
                    NearbyUnvisitedView(
                        selectedStructure: $selectedStructure,
                        showStructPopup: $showStructPopup,
                        nearbyUnvisitedStructures: nearbyUnvisitedStructures
                    )
                    .padding(.top, 75)
                    .transition(.move(edge: .top))
                }
                
                // Virtual Walkthrough Bar
                VStack {
                    Spacer()
                    if isVirtualWalkthroughActive {
                        virtualWalkThroughBar
                            .transition(.move(edge: .bottom))
                    }
                }
                
                // Visited Structure and All Structures Visited Popups
                ZStack {
                    // Visited Structure Popup
                    if showVisitedStructurePopup, let structure = visitedStructure {
                        VisitedStructurePopup(
                            structure: structure,
                            isPresented: $showVisitedStructurePopup,
                            isDarkMode: $appState.isDarkMode,
                            showStructPopup: $showStructPopup,
                            selectedStructure: $selectedStructure,
                            structureData: dataStore
                        )
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 15)
                    }
                    
                    // All Structures Visited Popup
                    if showAllVisitedPopup {
                        AllStructuresVisitedPopup(isPresented: $showAllVisitedPopup, isDarkMode: $appState.isDarkMode)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                    }
                }
                
                // Structure Popup
                if showStructPopup, let selectedStructure = selectedStructure {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showStructPopup = false
                        }
                    
                    StructPopUp(
                        structureData: dataStore,
                        structure: selectedStructure,
                        isDarkMode: $appState.isDarkMode,
                        isPresented: $showStructPopup
                    )
                    .padding(15)
                    .frame(width: geometry.size.width - 30, height: geometry.size.height - 30)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .onAppear {
                if appState.adventureModeEnabled && !hasShownAdventureModeAlert {
                    showAdventureModeAlert = true
                } else if !appState.adventureModeEnabled && !hasShownRateStructuresPopup {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showRateStructuresPopup = true
                    }
                }
                subscribeToVisitedStructureNotification()
            }
            .sheet(isPresented: $showStructureSwipingView) {
                StructureSwipingView(structureData: dataStore, isDarkMode: $appState.isDarkMode)
            }
            // Overlay for Alerts and Popups
            .overlay(
                Group {
                    // Adventure Mode Alert
                    if showAdventureModeAlert {
                        CustomAlert(
                            icon: "figure.walk",
                            iconColor: .green,
                            title: "Enable Background Location",
                            subtitle: "Background location tracks the structures you visit even when the app is closed.",
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
                    
                    // Rate Structures Popup
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
                                isPresented = false
                                appState.hasShownRateStructuresPopup = true
                                checkAndShowVirtualWalkthroughPopup()
                            },
                            secondaryButton: .init(title: "Maybe Later") {
                                isPresented = false
                                appState.hasShownRateStructuresPopup = true
                                checkAndShowVirtualWalkthroughPopup()
                            },
                            isPresented: $showRateStructuresPopup,
                            isDarkMode: $appState.isDarkMode
                        )
                    }
                    
                    // Virtual Walkthrough Popup
                    if showVirtualWalkthroughPopup {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .transition(.opacity)
                        
                        CustomAlert(
                            icon: "figure.walk",
                            iconColor: .blue,
                            title: "Virtual Walkthrough",
                            subtitle: "Go through each structure as if you were there in person",
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
            )
            .onChange(of: locationService.locationStatus) { newStatus in
                switch newStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    // Signal to the system to update location, which should trigger the display of the pulsing circle if in the right area
                    locationService.startUpdatingLocation()
                default:
                    // Handle other statuses if needed
                    break
                }
            }
            .onChange(of: showAllVisitedPopup) { newValue in
                if newValue {
                    appState.visitedAllCount += 1
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appState.isDarkMode ? Color.black : Color.white)
        }
        
        // MARK: - Helper Functions
        
        /**
         * Checks and shows the virtual walkthrough popup if conditions are met.
         */
        private func checkAndShowVirtualWalkthroughPopup() {
            if !appState.adventureModeEnabled && !hasShownVirtualWalkthroughPopup {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showVirtualWalkthroughPopup = true
                    }
                }
            }
        }
        
        /**
         * Virtual Walkthrough Button View.
         */
        private var virtualWalkThroughButton: some View {
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
            }
            .padding(.leading, 15)
            .shadow(color: appState.isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
        }
        
        /**
         * Updates the current map point for the virtual walkthrough.
         */
        private func updateCurrentMapPoint() {
            let currentStructure = dataStore.structures[currentStructureIndex]
            currentWalkthroughMapPoint = dataStore.mapPoints.first { $0.landmark == currentStructure.number }
        }
        
        /**
         * Moves to the next structure in the virtual walkthrough.
         */
        private func moveToNextStructure() {
            currentStructureIndex = (currentStructureIndex + 1) % dataStore.structures.count
            updateCurrentMapPoint()
        }
        
        /**
         * Moves to the previous structure in the virtual walkthrough.
         */
        private func moveToPreviousStructure() {
            currentStructureIndex = (currentStructureIndex - 1 + dataStore.structures.count) % dataStore.structures.count
            updateCurrentMapPoint()
        }
        
        /**
         * Displays the adventure mode alert if needed.
         */
        private func showAdventureModeAlertIfNeeded() {
            if appState.adventureModeEnabled && locationService.locationStatus == .notDetermined {
                showAdventureModeAlert = true
            }
        }
        
        /**
         * Virtual Walkthrough Bar View.
         */
        private var virtualWalkThroughBar: some View {
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
        
        /**
         * Displays a bottom message with specified text.
         *
         * - Parameter text: The message text to display.
         * - Returns: A Text view styled as a bottom message.
         */
        private func bottomMessage(_ text: String) -> some View {
            Text(text)
                .fontWeight(.semibold)
                .padding()
                .background(appState.isDarkMode ? Color.black : Color.white)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .cornerRadius(10)
                .shadow(color: appState.isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
        }
        
        /**
         * Determines if there are any unvisited structures.
         *
         * - Returns: A Boolean indicating the presence of unvisited structures.
         */
        var hasUnvisitedStructures: Bool {
            return dataStore.structures.contains { !$0.isVisited }
        }
        
        /**
         * Updates the list of nearby unvisited structures based on the user's location.
         */
        private func updateNearbyUnvisitedStructures() {
            guard let userLocation = locationService.lastLocation else {
                nearbyUnvisitedStructures = []
                return
            }
            
            nearbyUnvisitedStructures = dataStore.structures
                .filter { !$0.isVisited }
                .sorted { getDistance(to: $0, from: userLocation) < getDistance(to: $1, from: userLocation) }
                .prefix(3)
                .map { $0 }
        }
        
        /**
         * Calculates the distance from the user's location to a given structure.
         *
         * - Parameters:
         *   - structure: The Structure object to calculate distance to.
         *   - userLocation: The user's current CLLocation.
         * - Returns: A CLLocationDistance representing the distance in meters.
         */
        private func getDistance(to structure: Structure, from userLocation: CLLocation) -> CLLocationDistance {
            guard let structureLocation = dataStore.mapPoints.first(where: { $0.landmark == structure.number })?.coordinate else {
                return .infinity
            }
            let structureCLLocation = CLLocation(latitude: structureLocation.latitude, longitude: structureLocation.longitude)
            return userLocation.distance(from: structureCLLocation)
        }
        
        // MARK: - Helper Methods
        
        /**
         * Determines the appropriate map image based on satellite view and dark mode settings.
         *
         * - Returns: The name of the map image to display.
         */
        private func mapImage() -> String {
            if isSatelliteView {
                return "SatelliteMap"
            } else {
                return appState.isDarkMode ? "DarkMap" : "LightMap"
            }
        }
        
        /**
         * Finds nearby map points based on the user's location.
         *
         * - Returns: An array of nearby MapPoint objects.
         */
        private func findNearbyMapPoints() -> [MapPoint] {
            guard let userLocation = locationService.lastLocation else { return [] }
            
            let nearbyPoints = dataStore.mapPoints
                .filter { $0.landmark != -1 }
                .sorted { point1, point2 in
                    let location1 = CLLocation(latitude: point1.coordinate.latitude, longitude: point1.coordinate.longitude)
                    let location2 = CLLocation(latitude: point2.coordinate.latitude, longitude: point2.coordinate.longitude)
                    return userLocation.distance(from: location1) < userLocation.distance(from: location2)
                }
            
            return Array(nearbyPoints.prefix(3))
        }
        
        /**
         * Displays the popup for a structure based on a map point.
         *
         * - Parameter mapPoint: The MapPoint object representing the structure.
         */
        private func showStructPopup(for mapPoint: MapPoint) {
            if let structure = dataStore.structures.first(where: { $0.number == mapPoint.landmark }) {
                visitedStructure = structure
                showVisitedStructurePopup = true
            }
        }
        
        /**
         * Subscribes to the structureVisited notification to update structures as visited.
         */
        private func subscribeToVisitedStructureNotification() {
            NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { [self] notification in
                if let landmarkId = notification.object as? Int,
                   let structure = dataStore.structures.first(where: { $0.number == landmarkId }) {
                    
                    if !appState.hasCompletedFirstVisit {
                        appState.hasCompletedFirstVisit = true
                        showVisitedStructurePopup(for: structure)
                    } else if structure.number != firstVisitedStructure { // This needs to be handled differently
                        showVisitedStructurePopup(for: structure)
                    }
                    
                    // Update day count through AppState
                    let currentDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let todayString = dateFormatter.string(from: currentDate)
                    
                    if let lastVisited = appState.previousDayVisited {
                        if lastVisited != todayString {
                            appState.dayCount += 1
                            appState.previousDayVisited = todayString
                        }
                    } else {
                        appState.dayCount += 1
                        appState.previousDayVisited = todayString
                    }
                    
                    // Check if all structures are visited
                    if dataStore.structures.allSatisfy({ $0.isVisited }) {
                        appState.visitedAllCount += 1
                        showAllVisitedPopup = true
                    }
                }
            }
        }
        
        /**
         * Displays the visited structure popup for a given structure.
         *
         * - Parameter structure: The Structure object that was visited.
         */
        private func showVisitedStructurePopup(for structure: Structure) {
            print("DEBUG: Showing visited structure popup for: \(structure.title)")
            self.visitedStructure = structure
            self.showVisitedStructurePopup = true
        }
    }
    
    // MARK: - Helper Structs and Extensions
    
    /**
     * VirtualWalkThroughBar
     *
     * A UI component that provides navigation controls and information for the virtual walkthrough feature.
     */
    struct VirtualWalkThroughBar: View {
        @EnvironmentObject var appState: AppState
        let structure: Structure
        let onNext: () -> Void
        let onPrevious: () -> Void
        let onTap: () -> Void

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(appState.isDarkMode ? Color.black : Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 5)
    
                    HStack(spacing: 0) {
                        arrowButton(direction: .previous)
                        
                        Spacer()
                        
                        structureInfo
                        
                        Spacer()
                        
                        arrowButton(direction: .next)
                    }
                    .padding(.horizontal, 15)
                }
                .frame(width: geometry.size.width, height: 120)
            }
            .frame(height: 120)
            .padding(.bottom, 10)
        }
        
        // MARK: - Structure Information
        private var structureInfo: some View {
            Button(action: onTap) {
                HStack(spacing: 15) {
                    Image(structure.mainPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("#\(structure.number)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                        
                        Text(structure.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
        }
        
        // MARK: - Arrow Buttons
        private func arrowButton(direction: ArrowDirection) -> some View {
            Button(action: direction == .next ? onNext : onPrevious) {
                Image(systemName: direction == .next ? "chevron.right" : "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                    .frame(width: 40, height: 40)
                    .background(appState.isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        
        // MARK: - Arrow Direction Enum
        private enum ArrowDirection {
            case next, previous
        }
    }
    
    /**
     * MapWithLocationDot
     *
     * Integrates the map image with a pulsing location dot indicating the user's position.
     * Handles the calculation of the dot's position based on the user's location and map scale.
     */
    struct MapWithLocationDot: View {
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var dataStore: DataStore
        @EnvironmentObject var locationService: LocationService
        
        let mapImage: String
        let isSatelliteView: Bool
        let geometry: GeometryProxy
        let isVirtualWalkthroughActive: Bool
        let currentStructureIndex: Int
        let currentWalkthroughMapPoint: MapPoint?

        var body: some View {
            ZStack {
                Image(mapImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                if showPulsingCircle {
                    PulsingCircle()
                        .position(circlePosition())
                        .shadow(color: isSatelliteView ? Color.white.opacity(0.8) : Color.black.opacity(0.8), radius: 4, x: 0, y: 0)
                }
            }
            .onAppear(perform: updateCircleVisibility)
            .onChange(of: locationService.lastLocation) { _ in
                updateCircleVisibility()
            }
        }
        
        private func updateCircleVisibility() {
            if appState.adventureModeEnabled {
                guard locationService.locationStatus == .authorizedAlways ||
                      locationService.locationStatus == .authorizedWhenInUse else {
                    showPulsingCircle = false
                    return
                }
                
                guard let location = locationService.lastLocation else {
                    showPulsingCircle = false
                    return
                }
                
                showPulsingCircle = locationService.isWithinSafeZone(coordinate: location.coordinate)
            } else {
                showPulsingCircle = isVirtualWalkthroughActive
            }
        }
        
        private func circlePosition() -> CGPoint {
            if appState.adventureModeEnabled {
                return regularCirclePosition()
            } else if isVirtualWalkthroughActive {
                return walkthroughCirclePosition()
            }
            return CGPoint(x: -100, y: -100) // Off-screen position
        }
        
        private func regularCirclePosition() -> CGPoint {
            guard let location = locationService.lastLocation,
                  let nearestPoint = findNearestMapPoint(to: location.coordinate) else {
                return .zero
            }
            return calculateCirclePosition(for: nearestPoint)
        }
        
        private func walkthroughCirclePosition() -> CGPoint {
            if let mapPoint = currentWalkthroughMapPoint {
                return calculateCirclePosition(for: mapPoint)
            }
            return CGPoint(x: -100, y: -100) // Off-screen position if no point is set
        }
        
        private func calculateCirclePosition(for mapPoint: MapPoint) -> CGPoint {
            let topLeft = topLeftOfImage(in: geometry.size)
            let displayedSize = displayedImageSize(originalSize: CGSize(width: originalWidth, height: originalHeight), containerSize: geometry.size, scale: scale)
            let scaleWidth = displayedSize.width / originalWidth
            let scaleHeight = displayedSize.height / originalHeight
            let correctScale = min(scaleWidth, scaleHeight)
    
            let circleX = ((mapPoint.pixelPosition.x) * correctScale) + topLeft.x
            let circleY = ((mapPoint.pixelPosition.y) * correctScale) + topLeft.y
    
            return CGPoint(x: circleX, y: circleY)
        }
        
        private func findNearestMapPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
            var nearestPoint: MapPoint?
            var minDistance = Double.infinity
            
            let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            for point in dataStore.mapPoints {
                let pointLocation = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                let distance = userLocation.distance(from: pointLocation)
                if distance < minDistance {
                    minDistance = distance
                    nearestPoint = point
                }
            }
            
            return nearestPoint
        }
        
        private func topLeftOfImage(in imageSize: CGSize) -> CGPoint {
            let containerAspectRatio = imageSize.width / imageSize.height
            let imageAspectRatio = originalWidth / originalHeight
            
            let scaledSize: CGSize
            if containerAspectRatio > imageAspectRatio {
                let height = min(imageSize.height, originalHeight * scale)
                let width = originalWidth * (height / originalHeight)
                scaledSize = CGSize(width: width, height: height)
            } else {
                let width = min(imageSize.width, originalWidth * scale)
                let height = originalHeight * (width / originalWidth)
                scaledSize = CGSize(width: width, height: height)
            }
            
            let x = (imageSize.width - scaledSize.width) / 2
            let y = (imageSize.height - scaledSize.height) / 2
            
            let topLeftAfterOffset = CGPoint(x: x + offset.width, y: y + offset.height)
            
            return topLeftAfterOffset
        }
        
        func displayedImageSize(originalSize: CGSize, containerSize: CGSize, scale: CGFloat) -> CGSize {
            let widthRatio = containerSize.width / originalSize.width
            let heightRatio = containerSize.height / originalSize.height
            let ratio = min(widthRatio, heightRatio) * scale
    
            let displayedWidth = originalSize.width * ratio
            let displayedHeight = originalSize.height * ratio
    
            return CGSize(width: displayedWidth, height: displayedHeight)
        }
    }
    
    /**
     * PulsingCircle
     *
     * A pulsing circle animation to indicate the user's location on the map.
     */
    struct PulsingCircle: View {
        @State private var circleScale: CGFloat = 1.0
        
        var body: some View {
            Circle()
                .fill(Color(red: 0.44, green: 0.92, blue: 0.25))
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .scaleEffect(circleScale)
                        .opacity(2 - circleScale)
                )
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.25)
                            .repeatForever(autoreverses: true)
                    ) {
                        circleScale = 1.5
                    }
                }
        }
    }
    
    /**
     * VisitedStructurePopup
     *
     * A popup that appears when a user visits a structure, providing information and a button to view details.
     */
    struct VisitedStructurePopup: View {
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var dataStore: DataStore
        let structure: Structure
        @Binding var isPresented: Bool
        @Binding var showStructPopup: Bool
        @Binding var selectedStructure: Structure?

        var body: some View {
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 28))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                    }
                    .padding(.leading, 15)
    
                    Button(action: {
                        selectedStructure = structure
                        showStructPopup = true
                        if let index = dataStore.structures.firstIndex(where: { $0.id == structure.id }) {
                            dataStore.structures[index].isOpened = true
                        }
                        isPresented = false
                    }) {
                        HStack {
                            Image(structure.mainPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .shadow(color: appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8), radius: 5, x: 0, y: 0)
                            
                            VStack(alignment: .leading) {
                                Text("Just Visited!")
                                    .font(.system(size: 14))
                                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8))
    
                                Text(structure.title)
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(appState.isDarkMode ? .white : .black)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: geometry.size.width - 250, alignment: .leading)
                            .padding(.leading, 10)
                            
                            Text(String(structure.number))
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                                .padding(.leading, 5)
    
                            Spacer()
    
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(appState.isDarkMode ? .white : .black)
                        }
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 15)
                }
                .frame(width: geometry.size.width - 30)
                .background(appState.isDarkMode ? Color.black : Color.white)
                .cornerRadius(15)
                .shadow(color: appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8), radius: 5, x: 0, y: 0)
                .padding(.horizontal, 15)
                .frame(width: geometry.size.width)
            }
            .frame(height: 120)
        }
    }
    
    /**
     * NearbyUnvisitedView
     *
     * Displays a list of nearby unvisited structures with images and numbers, allowing users to tap and view details.
     */
    struct NearbyUnvisitedView: View {
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var dataStore: DataStore
        @EnvironmentObject var locationService: LocationService
        
        @Binding var selectedStructure: Structure?
        @Binding var showStructPopup: Bool
        let nearbyUnvisitedStructures: [Structure]

        var body: some View {
            VStack {
                HStack {
                    ForEach(nearbyUnvisitedStructures, id: \.id) { structure in
                        Spacer()
                        
                        ZStack(alignment: .bottomTrailing) {
                            Image(structure.mainPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(15)
    
                            Text("\(structure.number)")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 0)
                                .padding(4)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(5)
                                .offset(x: -5, y: -5)
                        }
                        .frame(width: 80, height: 80)
                        .shadow(color: appState.isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2), radius: 4, x: 0, y: 0)
                        .onTapGesture {
                            selectedStructure = structure
                            showStructPopup = true
                        }
    
                        Spacer()
                    }
                }
    
                Text("Nearby Unvisited")
                    .font(.headline)
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(10)
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(15)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
            .frame(maxWidth: UIScreen.main.bounds.width - 20)
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
        }
    }
    
    /**
     * AllStructuresVisitedPopup
     *
     * Congratulates the user when they have visited all structures in the app.
     */
    struct AllStructuresVisitedPopup: View {
        @EnvironmentObject var appState: AppState
        @Binding var isPresented: Bool

        var body: some View {
            ZStack {
                if isPresented {
                    VStack {
                        Text("Congratulations!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                        Text("You have visited all structures!")
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                        Image("partyHat")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    }
                    .frame(width: 300, height: 200)
                    .background(appState.isDarkMode ? Color.black : Color.white)
                    .cornerRadius(20)
                    .shadow(color: appState.isDarkMode ? Color.white : Color.black, radius: 10)
                    .onTapGesture {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    /**
     * RateStructuresPopup
     *
     * Prompts the user to rate structures after they have enabled virtual walkthrough or adventure mode.
     */
    struct RateStructuresPopup: View {
        @EnvironmentObject var appState: AppState
        @Binding var isPresented: Bool
        @Binding var showStructureSwipingView: Bool

        var body: some View {
            VStack(spacing: 20) {
                PulsingHeart()
                    .frame(width: 80, height: 80)
                
                Text("Rate Structures")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Swipe through and rate the structures to customize your experience!")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    showStructureSwipingView = true
                    isPresented = false
                    appState.hasShownRateStructuresPopup = true
                }) {
                    Text("Start Rating")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    isPresented = false
                    appState.hasShownRateStructuresPopup = true
                }) {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
    
    /**
     * Extension for Comparable to clamp values within a range.
     */
    extension Comparable {
        /**
         * Clamps a value within the specified closed range.
         *
         * - Parameter limits: The range to clamp the value to.
         * - Returns: The clamped value.
         */
        func clamped(to limits: ClosedRange<Self>) -> Self {
            return min(max(self, limits.lowerBound), limits.upperBound)
        }
    }
    
    /**
     * Extension for Notification.Name to add custom notifications.
     */
    extension Notification.Name {
        static let structureVisited = Notification.Name("StructureVisited")
    }
    
}


/**
 * Extension to clamp values within a range.
 */
extension Comparable {
    /**
     * Clamps a value within the specified closed range.
     *
     * - Parameter limits: The range to clamp the value to.
     * - Returns: The clamped value.
     */
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

/**
 * Extension for Notification.Name to add custom notifications.
 */
extension Notification.Name {
    static let structureVisited = Notification.Name("StructureVisited")
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