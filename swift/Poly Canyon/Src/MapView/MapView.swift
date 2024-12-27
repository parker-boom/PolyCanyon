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
    // MARK: - Binding Properties
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    // MARK: - Observed Objects
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @ObservedObject var locationManager: LocationManager
    
    // MARK: - State Properties
    @State private var visitedStructure: Structure?
    @State private var selectedStructure: Structure?
    @State private var nearbyMapPoints: [MapPoint] = []
    @State private var showRateStructuresPopup = false
    @State private var showStructureSwipingView = false
    
    // Gesture-related states
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    // Toggle and alert states
    @State private var isSatelliteView: Bool = false
    @State private var showPermissionAlert = false
    @State private var showAdventureModeAlert = false
    @State private var showResetButton = false
    @State private var showVisitedStructurePopup = false
    @State private var showAllVisitedPopup = false
    @State private var allStructuresVisitedFlag = false
    @State private var showNearbyStructures = false
    @State private var showStructPopup = false
    @State private var showNearbyUnvisitedView = false
    @State private var isZoomedIn = false
    @State private var currentScale: CGFloat = 1.0
    @State private var mapImageSize: CGSize = .zero
    @State private var isVirtualWalkthroughActive = false
    @State private var currentWalkthroughMapPoint: MapPoint?
    @State private var firstVisitedStructure: Int?
    @State private var showVirtualWalkthroughPopup = false
    
    // Nearby unvisited structures
    @State private var nearbyUnvisitedStructures: [Structure] = []
    @GestureState private var magnifyBy = 1.0
    
    // App storage for persistent states
    @AppStorage("visitedAllCount") private var visitedAllCount: Int = 0
    @AppStorage("dayCount") private var dayCount: Int = 0
    @AppStorage("previousDayVisited") private var previousDayVisited: String?
    @AppStorage("showVirtualTourButton") private var showVirtualTourButton = true
    @AppStorage("hasShownRateStructuresPopup") private var hasShownRateStructuresPopup: Bool = false
    @AppStorage("virtualTourCurrentStructure") private var currentStructureIndex: Int = 0
    @AppStorage("hasCompletedFirstVisit") private var hasCompletedFirstVisit: Bool = false
    @AppStorage("hasShownAdventureModeAlert") private var hasShownAdventureModeAlert: Bool = false
    @AppStorage("hasShownVirtualWalkthroughPopup") private var hasShownVirtualWalkthroughPopup: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background Color
                Color(isDarkMode ? .black : .white)
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
                    isDarkMode: isDarkMode,
                    isSatelliteView: isSatelliteView,
                    locationManager: locationManager,
                    structureData: structureData,
                    mapPointManager: mapPointManager,
                    isAdventureModeEnabled: isAdventureModeEnabled,
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
                if isAdventureModeEnabled,
                   let location = locationManager.lastLocation,
                   locationManager.isWithinSafeZone(coordinate: location.coordinate) {
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
                            .foregroundColor(isDarkMode ? .white : .black)
                            .background(isDarkMode ? Color.black : Color.white)
                            .cornerRadius(15)
                            .padding()
                    }
                    .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                    .padding(.top, -10)
                }
                
                // Virtual Walkthrough Button
                if !isAdventureModeEnabled {
                    virtualWalkThroughButton
                }
                
                // Map View Toggle Button (Top Right)
                Button(action: {
                    isSatelliteView.toggle()
                }) {
                    Image(systemName: isSatelliteView ? "map.fill" : "globe.americas.fill")
                        .font(.system(size: 24))
                        .frame(width: 50, height: 50)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .background(isDarkMode ? Color.black : Color.white)
                        .cornerRadius(15)
                        .padding()
                }
                .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                .padding(.top, -10)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                
                // Bottom Messages
                VStack {
                    Spacer()
                    
                    if isAdventureModeEnabled {
                        if locationManager.locationStatus == .denied || locationManager.locationStatus == .restricted {
                            bottomMessage("Enable location services")
                                .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                        } else if let location = locationManager.lastLocation {
                            if !locationManager.isWithinSafeZone(coordinate: location.coordinate) {
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
                        structureData: structureData,
                        locationManager: locationManager,
                        mapPointManager: mapPointManager,
                        isDarkMode: $isDarkMode,
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
                            isDarkMode: $isDarkMode,
                            showStructPopup: $showStructPopup,
                            selectedStructure: $selectedStructure,
                            structureData: structureData
                        )
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 15)
                    }
                    
                    // All Structures Visited Popup
                    if showAllVisitedPopup {
                        AllStructuresVisitedPopup(isPresented: $showAllVisitedPopup, isDarkMode: $isDarkMode)
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
                        structureData: structureData,
                        structure: selectedStructure,
                        isDarkMode: $isDarkMode,
                        isPresented: $showStructPopup
                    )
                    .padding(15)
                    .frame(width: geometry.size.width - 30, height: geometry.size.height - 30)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .onAppear {
                if isAdventureModeEnabled && !hasShownAdventureModeAlert {
                    showAdventureModeAlert = true
                } else if !isAdventureModeEnabled && !hasShownRateStructuresPopup {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showRateStructuresPopup = true
                    }
                }
                subscribeToVisitedStructureNotification()
            }
            .sheet(isPresented: $showStructureSwipingView) {
                StructureSwipingView(structureData: structureData, isDarkMode: $isDarkMode)
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
                                locationManager.requestAlwaysAuthorization()
                                isAdventureModeEnabled = true
                                UserDefaults.standard.set(true, forKey: "adventureModeEnabled")
                                showAdventureModeAlert = false
                                hasShownAdventureModeAlert = true
                            },
                            secondaryButton: .init(title: "Cancel") {
                                showAdventureModeAlert = false
                                hasShownAdventureModeAlert = true
                            },
                            isPresented: $showAdventureModeAlert,
                            isDarkMode: $isDarkMode
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
                                hasShownRateStructuresPopup = true
                                checkAndShowVirtualWalkthroughPopup()
                            },
                            secondaryButton: .init(title: "Maybe Later") {
                                isPresented = false
                                hasShownRateStructuresPopup = true
                                checkAndShowVirtualWalkthroughPopup()
                            },
                            isPresented: $showRateStructuresPopup,
                            isDarkMode: $isDarkMode
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
                            isDarkMode: $isDarkMode
                        )
                    }
                }
            )
            .onChange(of: locationManager.locationStatus) { newStatus in
                switch newStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    // Signal to the system to update location, which should trigger the display of the pulsing circle if in the right area
                    locationManager.startUpdatingLocation()
                default:
                    // Handle other statuses if needed
                    break
                }
            }
            .onChange(of: allStructuresVisitedFlag) { newValue in
                // Increment visited all count for stats
                visitedAllCount += 1
                
                if allStructuresVisitedFlag {
                    // Show congrats popup after closing structure popup
                    showAllVisitedPopup = true
                    allStructuresVisitedFlag = false
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isDarkMode ? Color.black : Color.white)
        }
        
        // MARK: - Helper Functions
        
        /**
         * Checks and shows the virtual walkthrough popup if conditions are met.
         */
        private func checkAndShowVirtualWalkthroughPopup() {
            if !isAdventureModeEnabled && !hasShownVirtualWalkthroughPopup {
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
                    .foregroundColor(isDarkMode ? .white : .black)
                    .frame(width: 50, height: 50)
                    .background(isDarkMode ? Color.black : Color.white)
                    .cornerRadius(15)
            }
            .padding(.leading, 15)
            .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
        }
        
        /**
         * Updates the current map point for the virtual walkthrough.
         */
        private func updateCurrentMapPoint() {
            let currentStructure = structureData.structures[currentStructureIndex]
            currentWalkthroughMapPoint = mapPointManager.mapPoints.first { $0.landmark == currentStructure.number }
        }
        
        /**
         * Moves to the next structure in the virtual walkthrough.
         */
        private func moveToNextStructure() {
            currentStructureIndex = (currentStructureIndex + 1) % structureData.structures.count
            updateCurrentMapPoint()
        }
        
        /**
         * Moves to the previous structure in the virtual walkthrough.
         */
        private func moveToPreviousStructure() {
            currentStructureIndex = (currentStructureIndex - 1 + structureData.structures.count) % structureData.structures.count
            updateCurrentMapPoint()
        }
        
        /**
         * Displays the adventure mode alert if needed.
         */
        private func showAdventureModeAlertIfNeeded() {
            if isAdventureModeEnabled && locationManager.locationStatus == .notDetermined {
                showAdventureModeAlert = true
            }
        }
        
        /**
         * Virtual Walkthrough Bar View.
         */
        private var virtualWalkThroughBar: some View {
            VirtualWalkThroughBar(
                structure: structureData.structures[currentStructureIndex],
                onNext: moveToNextStructure,
                onPrevious: moveToPreviousStructure,
                onTap: {
                    selectedStructure = structureData.structures[currentStructureIndex]
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
                .background(isDarkMode ? Color.black : Color.white)
                .foregroundColor(isDarkMode ? .white : .black)
                .cornerRadius(10)
                .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
        }
        
        /**
         * Determines if there are any unvisited structures.
         *
         * - Returns: A Boolean indicating the presence of unvisited structures.
         */
        var hasUnvisitedStructures: Bool {
            return structureData.structures.contains { !$0.isVisited }
        }
        
        /**
         * Updates the list of nearby unvisited structures based on the user's location.
         */
        private func updateNearbyUnvisitedStructures() {
            guard let userLocation = locationManager.lastLocation else {
                nearbyUnvisitedStructures = []
                return
            }
            
            nearbyUnvisitedStructures = structureData.structures
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
            guard let structureLocation = mapPointManager.mapPoints.first(where: { $0.landmark == structure.number })?.coordinate else {
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
                return isDarkMode ? "DarkMap" : "LightMap"
            }
        }
        
        /**
         * Finds nearby map points based on the user's location.
         *
         * - Returns: An array of nearby MapPoint objects.
         */
        private func findNearbyMapPoints() -> [MapPoint] {
            guard let userLocation = locationManager.lastLocation else { return [] }
            
            let nearbyPoints = mapPointManager.mapPoints
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
            if let structure = structureData.structures.first(where: { $0.number == mapPoint.landmark }) {
                visitedStructure = structure
                showVisitedStructurePopup = true
            }
        }
        
        /**
         * Subscribes to the structureVisited notification to update structures as visited.
         */
        private func subscribeToVisitedStructureNotification() {
            NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { [self] notification in
                print("DEBUG: Received structure visited notification")
                if let landmarkId = notification.object as? Int,
                   let structure = structureData.structures.first(where: { $0.number == landmarkId }) {
                    
                    print("DEBUG: Structure visited - ID: \(landmarkId), Title: \(structure.title)")
                    
                    if !hasCompletedFirstVisit {
                        firstVisitedStructure = landmarkId
                        hasCompletedFirstVisit = true
                        print("DEBUG: First visit completed - Structure: \(landmarkId)")
                        showVisitedStructurePopup(for: structure)
                    } else if structure.number != firstVisitedStructure {
                        print("DEBUG: Showing popup for non-first visit - Structure: \(landmarkId)")
                        showVisitedStructurePopup(for: structure)
                    } else {
                        print("DEBUG: Skipping popup for first structure revisit")
                    }
                    
                    // Check and update day count
                    let currentDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let todayString = dateFormatter.string(from: currentDate)
                    
                    if let lastVisited = self.previousDayVisited {
                        if lastVisited != todayString {
                            self.dayCount += 1
                            self.previousDayVisited = todayString
                            print("DEBUG: Updated day count: \(self.dayCount)")
                        }
                    } else {
                        self.dayCount += 1
                        self.previousDayVisited = todayString
                        print("DEBUG: First day visit recorded")
                    }
                    
                    // Check if all structures are visited
                    if self.structureData.structures.allSatisfy({ $0.isVisited }) {
                        print("DEBUG: All structures have been visited")
                        self.allStructuresVisitedFlag = true
                    }
                } else {
                    print("DEBUG: Failed to process structure visited notification")
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
        let structure: Structure
        let onNext: () -> Void
        let onPrevious: () -> Void
        let onTap: () -> Void
        @Environment(\.colorScheme) var colorScheme
    
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
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
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                        
                        Text(structure.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(10)
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
        }
        
        // MARK: - Arrow Buttons
        private func arrowButton(direction: ArrowDirection) -> some View {
            Button(action: direction == .next ? onNext : onPrevious) {
                Image(systemName: direction == .next ? "chevron.right" : "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(width: 40, height: 40)
                    .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
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
        let mapImage: String
        let isDarkMode: Bool
        let isSatelliteView: Bool
        let locationManager: LocationManager
        let structureData: StructureData
        let mapPointManager: MapPointManager
        let isAdventureModeEnabled: Bool
        let geometry: GeometryProxy
        let isVirtualWalkthroughActive: Bool
        let currentStructureIndex: Int
        let currentWalkthroughMapPoint: MapPoint?
    
        @State private var showPulsingCircle = false
        @State private var scale: CGFloat = 1.0
        @State private var offset: CGSize = .zero
        
        let originalWidth = 1843.0
        let originalHeight = 4164.0
    
        var body: some View {
            ZStack {
                // Map Image
                Image(mapImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Location Dot with Pulsing Animation
                if showPulsingCircle {
                    PulsingCircle()
                        .position(circlePosition())
                        .shadow(color: isSatelliteView ? Color.white.opacity(0.8) : Color.black.opacity(0.8), radius: 4, x: 0, y: 0)
                }
            }
            .onAppear(perform: updateCircleVisibility)
            .onChange(of: locationManager.lastLocation) { _ in
                updateCircleVisibility()
            }
            .onChange(of: isVirtualWalkthroughActive) { _ in
                updateCircleVisibility()
            }
            .onChange(of: currentStructureIndex) { _ in
                updateCircleVisibility()
            }
        }
        
        // MARK: - Helper Methods
        
        /**
         * Updates the visibility of the pulsing circle based on adventure mode and user location.
         */
        private func updateCircleVisibility() {
            if isAdventureModeEnabled {
                guard locationManager.locationStatus == .authorizedAlways ||
                      locationManager.locationStatus == .authorizedWhenInUse else {
                    showPulsingCircle = false
                    return
                }
    
                guard let location = locationManager.lastLocation else {
                    showPulsingCircle = false
                    return
                }
    
                showPulsingCircle = locationManager.isWithinSafeZone(coordinate: location.coordinate)
            } else {
                // Virtual Tour Mode
                showPulsingCircle = isVirtualWalkthroughActive
            }
        }
        
        /**
         * Calculates the position of the pulsing circle based on the map point.
         *
         * - Returns: A CGPoint representing the position of the pulsing circle.
         */
        private func circlePosition() -> CGPoint {
            if isAdventureModeEnabled {
                return regularCirclePosition()
            } else if isVirtualWalkthroughActive {
                return walkthroughCirclePosition()
            }
            return CGPoint(x: -100, y: -100) // Off-screen position
        }
        
        /**
         * Calculates the circle position for adventure mode.
         *
         * - Returns: A CGPoint for the pulsing circle in adventure mode.
         */
        private func regularCirclePosition() -> CGPoint {
            guard let location = locationManager.lastLocation,
                  let nearestPoint = findNearestMapPoint(to: location.coordinate) else {
                return .zero
            }
            return calculateCirclePosition(for: nearestPoint)
        }
        
        /**
         * Calculates the circle position for virtual walkthrough mode.
         *
         * - Returns: A CGPoint for the pulsing circle in virtual walkthrough mode.
         */
        private func walkthroughCirclePosition() -> CGPoint {
            if let mapPoint = currentWalkthroughMapPoint {
                return calculateCirclePosition(for: mapPoint)
            }
            return CGPoint(x: -100, y: -100) // Off-screen position if no point is set
        }
        
        /**
         * Calculates the exact position of the pulsing circle based on the map point's pixel position.
         *
         * - Parameter mapPoint: The MapPoint object representing the structure.
         * - Returns: A CGPoint for the pulsing circle.
         */
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
        
        /**
         * Finds the nearest map point to the user's current location.
         *
         * - Parameter coordinate: The user's current CLLocationCoordinate2D.
         * - Returns: An optional MapPoint object representing the nearest structure.
         */
        private func findNearestMapPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
            var nearestPoint: MapPoint?
            var minDistance = Double.infinity
            
            let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            for point in mapPointManager.mapPoints {
                let pointLocation = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                let distance = userLocation.distance(from: pointLocation)
                if distance < minDistance {
                    minDistance = distance
                    nearestPoint = point
                }
            }
            
            return nearestPoint
        }
        
        /**
         * Calculates the top-left position of the image within the container to align the pulsing circle correctly.
         *
         * - Parameter imageSize: The CGSize of the container.
         * - Returns: A CGPoint representing the top-left position of the image.
         */
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
        
        /**
         * Calculates the size that the image is actually displaying on screen when scaled to device size.
         *
         * - Parameters:
         *   - originalSize: The original CGSize of the image.
         *   - containerSize: The CGSize of the container view.
         *   - scale: The current scale applied to the image.
         * - Returns: A CGSize representing the displayed size of the image.
         */
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
        let structure: Structure
        @Binding var isPresented: Bool
        @Binding var isDarkMode: Bool
        @Binding var showStructPopup: Bool
        @Binding var selectedStructure: Structure?
        @ObservedObject var structureData: StructureData
        
        var body: some View {
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 10) {
                    // Close Button
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 28))
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    .padding(.leading, 15)
    
                    // Main Clickable Area
                    Button(action: {
                        selectedStructure = structure
                        showStructPopup = true
                        if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                            structureData.structures[index].isOpened = true
                        }
                        isPresented = false
                    }) {
                        HStack {
                            // Structure Image
                            Image(structure.mainPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .shadow(color: isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8), radius: 5, x: 0, y: 0)
                            
                            // Structure Information
                            VStack(alignment: .leading) {
                                Text("Just Visited!")
                                    .font(.system(size: 14))
                                    .foregroundColor(isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8))
    
                                Text(structure.title)
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: geometry.size.width - 250, alignment: .leading)
                            .padding(.leading, 10)
                            
                            // Structure Number
                            Text(String(structure.number))
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                                .padding(.leading, 5)
    
                            Spacer() // Pushes content to the edges
    
                            // Right-pointing Arrow
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 15)
                }
                .frame(width: geometry.size.width - 30)
                .background(isDarkMode ? Color.black : Color.white)
                .cornerRadius(15)
                .shadow(color: isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8), radius: 5, x: 0, y: 0)
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
        @ObservedObject var structureData: StructureData
        @ObservedObject var locationManager: LocationManager
        @ObservedObject var mapPointManager: MapPointManager
        @Binding var isDarkMode: Bool
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
                        .shadow(color: isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2), radius: 4, x: 0, y: 0)
                        .onTapGesture {
                            selectedStructure = structure
                            showStructPopup = true
                        }
    
                        Spacer()
                    }
                }
    
                Text("Nearby Unvisited")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(10)
            .background(isDarkMode ? Color.black : Color.white)
            .cornerRadius(15)
            .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
            .frame(maxWidth: UIScreen.main.bounds.width - 20)
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
            .padding(.top, -10)
        }
    }
    
    /**
     * AllStructuresVisitedPopup
     *
     * Congratulates the user when they have visited all structures in the app.
     */
    struct AllStructuresVisitedPopup: View {
        @Binding var isPresented: Bool
        @Binding var isDarkMode: Bool
    
        var body: some View {
            ZStack {
                if isPresented {
                    VStack {
                        Text("Congratulations!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white : .black)
                        Text("You have visited all structures!")
                            .foregroundColor(isDarkMode ? .white : .black)
                        Image("partyHat")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    }
                    .frame(width: 300, height: 200)
                    .background(isDarkMode ? Color.black : Color.white)
                    .cornerRadius(20)
                    .shadow(color: isDarkMode ? Color.white : Color.black, radius: 10)
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
        @Binding var isPresented: Bool
        @Binding var showStructureSwipingView: Bool
        @AppStorage("hasShownRateStructuresPopup") private var hasShownRateStructuresPopup: Bool = false
        
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
                    hasShownRateStructuresPopup = true
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
                    hasShownRateStructuresPopup = true
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
    
    // MARK: - Preview
    struct MapView_Previews: PreviewProvider {
        static var previews: some View {
            MapView(
                isDarkMode: .constant(true),
                isAdventureModeEnabled: .constant(false),
                structureData: StructureData(),
                mapPointManager: MapPointManager(),
                locationManager: LocationManager(
                    mapPointManager: MapPointManager(),
                    structureData: StructureData(),
                    isAdventureModeEnabled: true
                )
            )
        }
    }
}

/**
 * VirtualWalkThroughBar
 *
 * A UI component that provides navigation controls and information for the virtual walkthrough feature.
 */
struct VirtualWalkThroughBar: View {
    let structure: Structure
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
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
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                    
                    Text(structure.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
    
    // MARK: - Arrow Buttons
    private func arrowButton(direction: ArrowDirection) -> some View {
        Button(action: direction == .next ? onNext : onPrevious) {
            Image(systemName: direction == .next ? "chevron.right" : "chevron.left")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 40, height: 40)
                .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    // MARK: - Arrow Direction Enum
    private enum ArrowDirection {
        case next, previous
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
