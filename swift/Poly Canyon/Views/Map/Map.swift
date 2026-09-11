import SwiftUI
import CoreLocation

struct MapWithLocationDot: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Map Properties
    let mapImage: String
    let geometry: GeometryProxy
    
    // Virtual Tour (not strictly changed here)
    let currentWalkthroughMapPoint: MapPoint?
    var markerScale: CGFloat = 1
    
    // ADDED: We bring in the CirclePositionStore
    @ObservedObject var circlePositionStore: CirclePositionStore
    
    // Original map dimensions from Photoshop
    private let originalWidth: CGFloat = 2000
    private let originalHeight: CGFloat = 4519
    
    // Show location dot only in adventure mode within range
    private var showPulsingCircle: Bool {
        if appState.isVirtualWalkthrough {
            return currentWalkthroughMapPoint != nil
        } else {
            guard appState.adventureModeEnabled else { return false }
            guard locationService.hasLocationPermission,
                  let userLoc = locationService.lastLocation,
                  LocationSamplePolicy.isUsable(userLoc, now: Date()) else { return false }
            return locationService.isWithinNearbyRange(userLoc)
        }
    }
    
    var body: some View {
        ZStack {
            // Background layer
            MapBackgroundLayer(isSatellite: mapImage.hasPrefix("Satellite"))
                .scaleEffect(appState.isVirtualWalkthrough ? 1.4 : 1.2)

            // Base map layer
            Image(mapImage)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            
            // Location indicator overlay
            if showPulsingCircle {
                PulsingCircle()
                    .scaleEffect(markerScale)
                    .position(circlePosition())
                    .onAppear {
                        circlePositionStore.isDotVisible = true
                    }
            } else {
                Color.clear
                    .onAppear {
                        circlePositionStore.circleY = nil
                        circlePositionStore.circleX = nil
                        circlePositionStore.isDotVisible = false
                    }
            }
        }
    }
    
    // MARK: - Position Calculations
    
    private func circlePosition() -> CGPoint {
        // We'll compute the dot position as before:
        let pos: CGPoint
        
        if appState.isVirtualWalkthrough, let walkPoint = currentWalkthroughMapPoint {
            let renderedSize = calculateRenderedMapSize()
            let scaleX = renderedSize.width / originalWidth
            let scaleY = renderedSize.height / originalHeight
            
            let xOffset = (geometry.size.width - renderedSize.width) / 2
            let yOffset = (geometry.size.height - renderedSize.height) / 2
            
            pos = CGPoint(
                x: (walkPoint.pixelPosition.x * scaleX * 1.09) + xOffset,
                y: (walkPoint.pixelPosition.y * scaleY * 1.09) + yOffset
            )
        } else {
            guard let userLoc = locationService.lastLocation,
                  locationService.isWithinCanyon(userLoc),
                  let nearestPoint = locationService.findNearestMapPoint(to: userLoc.coordinate)
            else {
                // If no valid location, place offscreen, and mark not visible
                pos = CGPoint(x: -100, y: -100)
                DispatchQueue.main.async {
                    if circlePositionStore.circleY != nil { circlePositionStore.circleY = nil }
                    if circlePositionStore.circleX != nil { circlePositionStore.circleX = nil }
                    if circlePositionStore.isDotVisible { circlePositionStore.isDotVisible = false }
                }
                return pos
            }
            
            let renderedSize = calculateRenderedMapSize()
            let scaleX = renderedSize.width / originalWidth
            let scaleY = renderedSize.height / originalHeight
            
            let xOffset = (geometry.size.width - renderedSize.width) / 2
            let yOffset = (geometry.size.height - renderedSize.height) / 2
            
            pos = CGPoint(
                x: (nearestPoint.pixelPosition.x * scaleX * 1.09) + xOffset,
                y: (nearestPoint.pixelPosition.y * scaleY * 1.09) + yOffset
            )
        }
        
        // ADDED: Publish to CirclePositionStore
        DispatchQueue.main.async {
            // Publishing unchanged coordinates schedules another render of this view.
            if circlePositionStore.circleY != pos.y { circlePositionStore.circleY = pos.y }
            if circlePositionStore.circleX != pos.x { circlePositionStore.circleX = pos.x }
            if !circlePositionStore.isDotVisible { circlePositionStore.isDotVisible = true }
        }
        
        return pos
    }
    
    private func calculateRenderedMapSize() -> CGSize {
        let aspectRatio = originalWidth / originalHeight
        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height
        
        if availableWidth / availableHeight > aspectRatio {
            // Width is proportionally larger than height, so we're height-constrained
            let height = availableHeight
            let width = height * aspectRatio
            return CGSize(width: width, height: height)
        } else {
            // Height is proportionally larger than width, so we're width-constrained
            let width = availableWidth
            let height = width / aspectRatio
            return CGSize(width: width, height: height)
        }
    }
}

// MARK: - Pulsing Circle
struct PulsingCircle: View {
    @State private var circleScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            Circle().fill(Color.green.opacity(0.16))
                .frame(width: 26, height: 26)
                .scaleEffect(reduceMotion ? 1 : circleScale)
                .opacity(reduceMotion ? 1 : 1.7 - circleScale * 0.5)
            Circle().fill(Color(red: 0.12, green: 0.65, blue: 0.36))
                .frame(width: 14, height: 14)
                .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
                .shadow(color: .black.opacity(0.22), radius: 2, y: 1)
        }
        .frame(width: 14, height: 14)
        .onAppear { updatePulse() }
        .onChange(of: reduceMotion) { _ in updatePulse() }
    }
    private func updatePulse() {
        circleScale = 1
        if !reduceMotion {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { circleScale = 1.35 }
        }
    }

}

struct MapBackgroundLayer: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var appState: AppState
    let isSatellite: Bool
    
    var body: some View {
        ZStack {
            CanyonStyle.paper
                .ignoresSafeArea(.container, edges: .top)
            
            if isSatellite {
                Image("BlurredBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
