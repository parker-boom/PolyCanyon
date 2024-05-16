// MARK: MapView.swift
// This file defines the MapView for the "Arch Graveyard" app, providing an interactive and dynamic map interface for users to explore Cal Poly's architectural graveyard. It integrates CoreLocation to track and update the user's position within a defined safe zone and uses SwiftUI for the UI elements.

// Notable features include:
// - Dynamic map scaling and panning capabilities, allowing users to zoom and navigate the map efficiently.
// - Conditional rendering of the map's visual style based on user settings for dark mode and satellite view.
// - Integration of location-based alerts and onboarding, enhancing user interaction and providing contextual information based on the user's location and app settings.
// - Custom pulsing circle animation to indicate the user's current location when within a landmark's vicinity.

// This view handles complex gestures for map interactions and manages state changes related to location services and user preferences, making it a critical component for delivering a rich user experience in the architectural graveyard exploration app.





// MARK: Code
import SwiftUI
import CoreLocation

struct MapView: View {
    // MARK: - Properties
    
    // BINDING
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    
    // STATE
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @StateObject private var locationManager = LocationManager(mapPointManager: MapPointManager())
    @State private var isSatelliteView: Bool = false
    @State private var showPermissionAlert = false
    @State private var showOnboardingImage = true
    @State private var showAdventureModeAlert = false
    
    @State private var showResetButton = false
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    
    @State private var showVisitedStructurePopup = false
    @State private var visitedStructure: Structure?
    
    @State private var showAllVisitedPopup = false
    
    // CONSTANTS
    let maxScale: CGFloat = 3.0
    let minScale: CGFloat = 1.0
    
    let safeZoneCorners = (
        bottomLeft: CLLocationCoordinate2D(latitude: 35.31214, longitude: -120.65529),
        topRight: CLLocationCoordinate2D(latitude: 35.31813, longitude: -120.65110)
    )
    
    let originalWidth = 5529.0
    let originalHeight = 12492.0
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                
                // Background color based on dark mode
                Color(isDarkMode ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                // Blurred background image
                if isSatelliteView {
                    Image("BlurredBG")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Calculate image sizes
                let imageSize = geometry.size
                let originalImageSize = CGSize(width: originalWidth, height: originalHeight)
                let displayedSize = displayedImageSize(originalSize: originalImageSize, containerSize: geometry.size, scale: scale)
                
                // Map image based on satellite view and dark mode
                Image(mapImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .scaleEffect(scale)
                    .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / self.lastScale
                                self.lastScale = value
                                let newScale = self.scale * delta
                                self.scale = min(self.maxScale, max(self.minScale, newScale))
                                self.offset = self.limitOffset(imageSize: imageSize)
                                
                                if self.scale < 1.1 {
                                    self.scale = self.minScale
                                    self.offset = .zero
                                    self.dragOffset = .zero
                                }
                            }
                            .onEnded { _ in
                                self.lastScale = 1.0
                                self.offset = self.limitOffset(imageSize: imageSize)
                                
                                if self.scale < 1.1 {
                                    self.scale = self.minScale
                                    self.offset = .zero
                                    self.dragOffset = .zero
                                }
                            }
                    )
                    .onChange(of: scale) { newScale in
                        showResetButton = newScale > minScale
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if self.scale > self.minScale {
                                    self.isDragging = true
                                    
                                    // Adjust the sensitivity by changing the value of 'sensitivity'
                                    // A higher value will make the panning less sensitive
                                    let sensitivity = self.scale * 0.5
                                    
                                    let newOffset = CGSize(
                                        width: value.translation.width / sensitivity,
                                        height: value.translation.height / sensitivity
                                    )
                                    self.dragOffset = self.limitDragOffset(newOffset: newOffset, imageSize: imageSize)
                                }
                            }
                            .onEnded { _ in
                                if self.isDragging {
                                    self.isDragging = false
                                    self.offset = self.limitOffset(newOffset: CGSize(width: self.offset.width + self.dragOffset.width, height: self.offset.height + self.dragOffset.height), imageSize: imageSize)
                                    self.dragOffset = .zero
                                }
                            }
                    )
                        
                
                // Map view toggle button
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
                
                // Reset button
                if showResetButton {
                    Button(action: {
                        resetMap()
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 24))
                            .frame(width: 50, height: 50)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .background(isDarkMode ? Color.black : Color.white)
                            .cornerRadius(15)
                            .padding()
                    }
                    .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                    .padding(.top, -10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // if all the wayu zoomed out, location enabled, and in bounds, display the Pulsing circle
                if scale == 1.0 {
                    if locationManager.locationStatus == .authorizedAlways || locationManager.locationStatus == .authorizedWhenInUse {
                    if let location = locationManager.lastLocation {
                        let userCoordinate = location.coordinate
                        
                        if !locationManager.isMonitoringSignificantLocationChanges {
                            if let nearestPoint = findNearestMapPoint(to: userCoordinate) {
                                let topLeft = topLeftOfImage(in: imageSize)
                                
                                let scaleWidth = displayedSize.width / originalWidth
                                let scaleHeight = displayedSize.height / originalHeight
                                
                                let correctScale = min(scaleWidth, scaleHeight)
                                
                                let circleX = ((nearestPoint.pixelPosition.x * 1.5) * correctScale) + topLeft.x
                                let circleY = ((nearestPoint.pixelPosition.y * 1.5) * correctScale) + topLeft.y
                            
                                
                                PulsingCircle()
                                    .position(x: circleX, y: circleY)
                                    .shadow(color: isSatelliteView ? Color.white.opacity(0.8) : Color.black.opacity(0.8), radius: 4, x: 0, y: 0)
                            }
                        }
                        
                    }
                    
                    // Ask user to enable location services if not
                    else {
                        Text("Enter the area of Poly Canyon")
                            .fontWeight(.semibold)
                            .padding()
                            .background(isDarkMode ? Color.black : Color.white)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .cornerRadius(10)
                            .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                    }
                }
                    else {
                        Text("Enable location services")
                            .fontWeight(.semibold)
                            .padding()
                            .background(isDarkMode ? Color.black : Color.white)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .cornerRadius(10)
                            .shadow(color: isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.8), radius: 5, x: 0, y: 0)
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                    }
                }

                
                // Show onboarding image with white background if it hasn't ever been shown
                ZStack {
                    if showOnboardingImage {
                        Color.white.opacity(1)
                            .edgesIgnoringSafeArea(.all)
                        
                        Image("MapPopUp")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width)
                            .onTapGesture {
                                
                                // Ask about adventure mode and always location after dismissing graphic
                                withAnimation {
                                    showOnboardingImage = false
                                    UserDefaults.standard.set(true, forKey: "onboardingMapShown")
                                    showAdventureModeAlert = true
                                }
                            }
                    }
                    else {
                        if showVisitedStructurePopup, let structure = visitedStructure {
                            VisitedStructurePopup(structure: structure, isPresented: $showVisitedStructurePopup, isDarkMode: $isDarkMode, structureData: structureData)
                                .transition(.move(edge: .bottom))
                                .zIndex(1)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, 15)
                        } else {
                            AllStructuresVisitedPopup(isPresented: $showAllVisitedPopup)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.clear)
                        }
                    }
                }
                
 
            }
        }
        
        // Show the onboarding map if it hasn't ever been shown
        .onAppear {
            subscribeToVisitedStructureNotification()
            if !UserDefaults.standard.bool(forKey: "onboardingMapShown") {
                showOnboardingImage = true
            } else {
                showOnboardingImage = false
                showAdventureModeAlert = false
            }
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("allStructuresVisited"))) { _ in
            showAllVisitedPopup = true
        }
        // For the geometry reader
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDarkMode ? Color.black : Color.white)
    }
    
    // MARK: - Private Methods
    
    // Selections mapImage based on if it's satelite, and then based on light/dark mode
    private func mapImage() -> String {
        if isSatelliteView {
            return "SatelliteMap"
        } else {
            return isDarkMode ? "DrawnMapDark" : "DrawnMap"
        }
    }
    
    // Limits the offset of the map image when zoomed in, so you can't drag into free space
    private func limitOffset(newOffset: CGSize? = nil, imageSize: CGSize) -> CGSize {
        let offsetWidth = newOffset?.width ?? offset.width
        let offsetHeight = newOffset?.height ?? offset.height
        
        let maxHorizontalOffset = (imageSize.width * (scale - 1)) / 2
        let maxVerticalOffset = (imageSize.height * (scale - 1)) / 2
        
        let limitedOffsetWidth = min(max(offsetWidth, -maxHorizontalOffset), maxHorizontalOffset)
        let limitedOffsetHeight = min(max(offsetHeight, -maxVerticalOffset), maxVerticalOffset)
        
        return CGSize(width: limitedOffsetWidth, height: limitedOffsetHeight)
    }
    
    private func limitDragOffset(newOffset: CGSize, imageSize: CGSize) -> CGSize {
        let maxHorizontalOffset = (imageSize.width * (scale - 1)) / 2
        let maxVerticalOffset = (imageSize.height * (scale - 1)) / 2
        
        let limitedOffsetWidth = min(max(newOffset.width, -maxHorizontalOffset - offset.width), maxHorizontalOffset - offset.width)
        let limitedOffsetHeight = min(max(newOffset.height, -maxVerticalOffset - offset.height), maxVerticalOffset - offset.height)
        
        return CGSize(width: limitedOffsetWidth, height: limitedOffsetHeight)
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
    
    // zoom map all the way out
    private func resetMap() {
        withAnimation {
            scale = minScale
            offset = .zero
            dragOffset = .zero
        }
    }
    
    private func subscribeToVisitedStructureNotification() {
        NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { notification in
            if let landmarkId = notification.object as? Int,
               let structure = structureData.structures.first(where: { $0.number == landmarkId }) {
                self.visitedStructure = structure
                self.showVisitedStructurePopup = true
            }
        }
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

struct VisitedStructurePopup: View {
    let structure: Structure
    @Binding var isPresented: Bool
    @Binding var isDarkMode: Bool
    @State private var showStructPopup = false
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
                    showStructPopup = true
                    if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                        structureData.structures[index].isOpened = true
                    }
                }) {
                    HStack {
                        // Image of the visited structure
                        
                        
                        Image(structure.imageName)
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
        .sheet(isPresented: $showStructPopup) {
            StructPopUp(structure: structure, isDarkMode: $isDarkMode) {
                isPresented = false
            }
        }
    }
}


struct AllStructuresVisitedPopup: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if isPresented {
                VStack {
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("You have visited all structures!")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Image("partyHat")
                        .resizable() // Make the image resizable
                        .aspectRatio(contentMode: .fit) // Ensure the image fits within the frame
                        .frame(width: 100, height: 100) // Adjust the frame size as needed
                }
                .frame(width: 300, height: 200)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .onTapGesture {
                    isPresented = false
                }
            }
        }
    }
}





// Changing DarkMode constant will allow you to see both views
// Changing AdventureMode really won't do anything, change matters in DetailView
// MARK: - Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(isDarkMode: .constant(true), isAdventureModeEnabled: .constant(false), structureData: StructureData(), mapPointManager: MapPointManager())
    }
}


// Preview provider for VisitedStructurePopup
struct VisitedStructurePopup_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var isDarkMode = false
    static var previews: some View {
        VisitedStructurePopup(
            structure: StructureData().structures[10],
            isPresented: $isPresented,
            isDarkMode: $isDarkMode,
            structureData: StructureData()
        )
        .previewLayout(.fixed(width: 400, height: 120))
    }
}

