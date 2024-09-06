// MARK: Overview
/*
    MapView.swift

    This file defines the MapView structure, which displays a navigable map interface for the app.

    Key Components:
    - Binding properties for dark mode and adventure mode.
    - ObservedObject properties for data management (structureData, mapPointManager, locationManager).
    - State properties to manage UI interactions and gestures.

    Functionality:
    - Displays a map with zoom and drag gestures.
    - Toggles between satellite and map views.
    - Shows nearby unvisited structures and location markers.
    - Handles location services and displays relevant UI elements.

    Additional Views:
    - PulsingCircle: Indicates user location.
    - VisitedStructurePopup: Shows popup when a structure is visited.
    - AllStructuresVisitedPopup: Congratulates the user when all structures are visited.
*/




// MARK: Code
import SwiftUI
import CoreLocation
import Zoomable


struct MapView: View {
    // MARK: - Properties
    
    // BINDING
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    // objects
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @ObservedObject var locationManager: LocationManager
    @State private var visitedStructure: Structure?
    @State private var selectedStructure: Structure?
    @State private var nearbyMapPoints: [MapPoint] = []
    @State private var showRateStructuresPopup = false
    @State private var showStructureSwipingView = false
    
    // STATE
    // numbers for gestures
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    //@State private var dragOffset: CGSize = .zero
    
    // booleans
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
    
    @State private var nearbyUnvisitedStructures: [Structure] = []
    @GestureState private var magnifyBy = 1.0

    
    
    // track number of time visiting all, and  times visited
    @AppStorage("visitedAllCount") private var visitedAllCount: Int = 0
    @AppStorage("dayCount") private var dayCount: Int = 0
    @AppStorage("previousDayVisited") private var previousDayVisited: String?
    @AppStorage("showVirtualTourButton") private var showVirtualTourButton = true
    @AppStorage("hasShownRateStructuresPopup") private var hasShownRateStructuresPopup = false
    @AppStorage("virtualTourCurrentStructure") private var currentStructureIndex = 0
    @AppStorage("hasCompletedFirstVisit") private var hasCompletedFirstVisit = false
    
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) { // Changed to .toƒpLeading
                // Background color based on dark mode
                Color(isDarkMode ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                // Blurred background image
                if isSatelliteView {
                    Image("BlurredBG")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Map with location dot
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
                    currentStructureIndex: currentStructureIndex, currentWalkthroughMapPoint: currentWalkthroughMapPoint
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
                
                // Nearby unvisited structures toggle button
                if isAdventureModeEnabled, let location = locationManager.lastLocation,
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
                
                if !isAdventureModeEnabled {
                    virtualWalkThroughButton
                }
                
                // Map view toggle button (top right)
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
                
                // Bottom messages
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
                // Nearby unvisited structures view
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
                
                VStack {
                    Spacer()
                    if isVirtualWalkthroughActive {
                        virtualWalkThroughBar
                            .transition(.move(edge: .bottom))
                    }
                }
                
                // PopUps when visiting structures
                ZStack {
                    // Show visited structure popup
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
                    // Congratulations message
                    if showAllVisitedPopup {
                        AllStructuresVisitedPopup(isPresented: $showAllVisitedPopup, isDarkMode: $isDarkMode)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                    }
                }
                
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
            if showRateStructuresPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)

                RateStructuresPopup(isPresented: $showRateStructuresPopup, showStructureSwipingView: $showStructureSwipingView)
                    .frame(width: geometry.size.width * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .transition(.opacity)
                    .zIndex(1)
            }
            

        }
        .onAppear {
            if !isAdventureModeEnabled && !hasShownRateStructuresPopup && !structureData.hasRatedStructures() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showRateStructuresPopup = true
                    }
                }
            }
        }
        .sheet(isPresented: $showStructureSwipingView) {
            StructureSwipingView(structureData: structureData, isDarkMode: $isDarkMode)
        }
        // Show the onboarding map if it hasn't ever been shown
        .onAppear {
            subscribeToVisitedStructureNotification()
        }
        
        // Ask user to enable location always after adventure mode pop up is shown
        .alert(isPresented: $showAdventureModeAlert) {
            Alert(
                title: Text("Allow Location Always"),
                message: Text("Adventure mode can track the structures you've been to even when you close the app. Do you want to enable it?"),
                primaryButton: .default(Text("Allow")) {
                    isAdventureModeEnabled = true
                    locationManager.requestAlwaysAuthorization()
                    UserDefaults.standard.set(true, forKey: "adventureModeEnabled")
                },
                secondaryButton: .cancel()
            )
        }
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
            // Count visited all count for stats
            visitedAllCount += 1
            
            if allStructuresVisitedFlag {
                // Show congrats popup after closing structure popup
                showAllVisitedPopup = true
                allStructuresVisitedFlag = false // Reset the flag
            }
        }
        // For the geometry reader
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDarkMode ? Color.black : Color.white)
    }
    

    
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

    private func updateCurrentMapPoint() {
        let currentStructure = structureData.structures[currentStructureIndex]
        currentWalkthroughMapPoint = mapPointManager.mapPoints.first { $0.landmark == currentStructure.number }
    }

    private func moveToNextStructure() {
        currentStructureIndex = (currentStructureIndex + 1) % structureData.structures.count
        updateCurrentMapPoint()
    }

    private func moveToPreviousStructure() {
        currentStructureIndex = (currentStructureIndex - 1 + structureData.structures.count) % structureData.structures.count
        updateCurrentMapPoint()
    }

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
    
    
    private func bottomMessage(_ text: String) -> some View {
            Text(text)
             .fontWeight(.semibold)
             .padding()
             .background(isDarkMode ? Color.black : Color.white)
             .foregroundColor(isDarkMode ? .white : .black)
             .cornerRadius(10)
             .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
             
        }
    

    // See if they are any structures not visited
    var hasUnvisitedStructures: Bool {
        return structureData.structures.contains { !$0.isVisited }
    }


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
    
    // Use distance function
    private func getDistance(to structure: Structure, from userLocation: CLLocation) -> CLLocationDistance {
        guard let structureLocation = mapPointManager.mapPoints.first(where: { $0.landmark == structure.number })?.coordinate else {
            return .infinity
        }
        let structureCLLocation = CLLocation(latitude: structureLocation.latitude, longitude: structureLocation.longitude)
        return userLocation.distance(from: structureCLLocation)
    }

    
    
    // MARK: - Functions
    
    // Selections mapImage based on if it's satelite, and then based on light/dark mode
    private func mapImage() -> String {
        if isSatelliteView {
            return "SatelliteMap"
        } else {
            return isDarkMode ? "DarkMap" : "LightMap"
        }
    }
    


    // Find nearby map points
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

    // Show the popup for a structure
    private func showStructPopup(for mapPoint: MapPoint) {
        if let structure = structureData.structures.first(where: { $0.number == mapPoint.landmark }) {
            visitedStructure = structure
            showVisitedStructurePopup = true
        }
    }

    
    
 
    
    
    // Get notifications when a user visits a structure
    private func subscribeToVisitedStructureNotification() {
        NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { [self] notification in
            if let landmarkId = notification.object as? Int,
               let structure = structureData.structures.first(where: { $0.number == landmarkId }) {
                
                if !hasCompletedFirstVisit {
                    firstVisitedStructure = landmarkId
                    hasCompletedFirstVisit = true
                    showVisitedStructurePopup(for: structure)
                } else if structure.number != firstVisitedStructure {
                    showVisitedStructurePopup(for: structure)
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
                    }
                } else {
                    self.dayCount += 1
                    self.previousDayVisited = todayString
                }
                
                // Check if all structures are visited
                if self.structureData.structures.allSatisfy({ $0.isVisited }) {
                    self.allStructuresVisitedFlag = true
                }
            }
        }
    }

    private func showVisitedStructurePopup(for structure: Structure) {
        self.visitedStructure = structure
        self.showVisitedStructurePopup = true
    }


}

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
    
    private enum ArrowDirection {
        case next, previous
    }
}


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
            // Map image
            Image(mapImage)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            // Location dot
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
            // Virtual tour mode
            showPulsingCircle = isVirtualWalkthroughActive
        }
    }

    private func circlePosition() -> CGPoint {
        if isAdventureModeEnabled {
            return regularCirclePosition()
        } else if isVirtualWalkthroughActive {
            return walkthroughCirclePosition()
        }
        return CGPoint(x: -100, y: -100) // Off-screen position
    }

    private func walkthroughCirclePosition() -> CGPoint {
        if let mapPoint = currentWalkthroughMapPoint {
            return calculateCirclePosition(for: mapPoint)
        }
        return CGPoint(x: -100, y: -100) // Off-screen position if no point is set
    }
    
    
    private func regularCirclePosition() -> CGPoint {
        guard let location = locationManager.lastLocation,
              let nearestPoint = findNearestMapPoint(to: location.coordinate) else {
            return .zero
        }
        return calculateCirclePosition(for: nearestPoint)
    }

    private func calculateCirclePosition(for mapPoint: MapPoint) -> CGPoint {
        let topLeft = topLeftOfImage(in: geometry.size)
        let displayedSize = displayedImageSize(originalSize: CGSize(width: 1843, height: 4164), containerSize: geometry.size, scale: scale)
        let scaleWidth = displayedSize.width / 1843
        let scaleHeight = displayedSize.height / 4164
        let correctScale = min(scaleWidth, scaleHeight)

        let circleX = ((mapPoint.pixelPosition.x) * correctScale) + topLeft.x
        let circleY = ((mapPoint.pixelPosition.y) * correctScale) + topLeft.y

        return CGPoint(x: circleX, y: circleY)
    }


    // Find the nearest of 60 map points based on the users current location, used to display current location
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

    // Calculate where the top left of the image is to help place the location circle in the correct position
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

    // Calculate the size that the image is actually displaying on screen when scaled to device size
    func displayedImageSize(originalSize: CGSize, containerSize: CGSize, scale: CGFloat) -> CGSize {
        let widthRatio = containerSize.width / originalSize.width
        let heightRatio = containerSize.height / originalSize.height
        let ratio = min(widthRatio, heightRatio) * scale

        let displayedWidth = originalSize.width * ratio
        let displayedHeight = originalSize.height * ratio

        return CGSize(width: displayedWidth, height: displayedHeight)
    }
}

// Pulsing circle used to indicate location, seperate structure so animation works after zooming in and out
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

// PopUp that comes up when a structure is visited
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
                // Close button
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

                // Main clickable area
                Button(action: {
                    selectedStructure = structure
                    showStructPopup = true
                    if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                        structureData.structures[index].isOpened = true
                    }
                    isPresented = false
                }) {
                    HStack {
                        // Image of the visited structure
                        
                        
                        Image(structure.mainPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                            .shadow(color: isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8), radius: 5, x: 0, y: 0)
                            .padding(.vertical, 10)
                        
                        

                        // Text describing the visited structure
                        VStack(alignment: .leading) {
                            Text("Just Visited!")
                                .font(.system(size: 14))
                                .foregroundColor(isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8))

                            Text(structure.title)
                                .font(.system(size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)  // Allow text to wrap to the next line
                        }
                        .frame(maxWidth: geometry.size.width - 250, alignment: .leading)
                        .padding(.leading, 10)// Adjusted width for arrow
                        
                        Text(String(structure.number))
                            .font(.system(size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            .padding(.leading, 5)

                        Spacer()  // Pushes all content to the left and right ends

                        // Right-pointing arrow without stem
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

// Congratulations message when visiting all structures
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


struct RateStructuresPopup: View {
    @Binding var isPresented: Bool
    @Binding var showStructureSwipingView: Bool
    @AppStorage("hasShownRateStructuresPopup") private var hasShownRateStructuresPopup = false
    
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




// Extension to clamp values within a range
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
