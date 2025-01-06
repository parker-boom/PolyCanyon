import SwiftUI
import CoreLocation

struct MapWithLocationDot: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Map Properties
    let mapImage: String
    let isSatelliteView: Bool
    let geometry: GeometryProxy
    
    // Virtual Tour (not strictly changed here)
    let isVirtualWalkthroughActive: Bool
    let currentStructureIndex: Int
    let currentWalkthroughMapPoint: MapPoint?
    
    // MARK: - Interaction State
    // This might come from pinch-to-zoom gestures, etc.
    let scale: CGFloat    // e.g., 1.0 means normal size, 2.0 means double zoom
    let offset: CGSize    // x/y panning offset
    
    // Original map image size (px) used for pixelPosition references
    private let originalWidth: CGFloat = 4519
    private let originalHeight: CGFloat = 2000
    
    // Show location dot only in adventure mode within range
    private var showPulsingCircle: Bool {
        guard appState.adventureModeEnabled else { return false }
        guard let userLoc = locationService.lastLocation else { return false }
        return locationService.isWithinBackgroundRange(userLoc)
    }
    
    var body: some View {
        ZStack {
            // Base map layer
            Image(mapImage)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
            
            // Location indicator overlay
            if showPulsingCircle {
                PulsingCircle()
                    .position(circlePosition())
                    .shadow(color: isSatelliteView ? .white.opacity(0.8) : .black.opacity(0.8),
                            radius: 4, x: 0, y: 0)
            }
        }
    }
    
    // MARK: - Position Calculations
    
    private func circlePosition() -> CGPoint {
        guard let userLoc = locationService.lastLocation else {
            return CGPoint(x: -100, y: -100) // Hide off-screen if no location
        }
        
        // Only show if user is within the safe zone
        if !locationService.isWithinSafeZone(userLoc) {
            return CGPoint(x: -100, y: -100)
        }
        
        // Find the nearest map point and translate to screen coordinates
        guard let nearestPoint = locationService.findNearestMapPoint(to: userLoc.coordinate) else {
            return CGPoint(x: -100, y: -100)
        }
        
        return mapPointToScreenPosition(nearestPoint)
    }
    
    /// Converts the `pixelPosition` of a MapPoint to the displayed screen coordinates,
    /// accounting for the scaledToFit() behavior, plus our custom `scale` and `offset`.
    private func mapPointToScreenPosition(_ mapPoint: MapPoint) -> CGPoint {
        // 1) Base scale from fitting the entire original image into our geometry
        //    This is the ratio if we had no manual scale or offset.
        let fitRatio = min(
            geometry.size.width / originalWidth,
            geometry.size.height / originalHeight
        )
        
        // 2) Our final scale is fitRatio * user scale (e.g., pinch zoom).
        let finalScale = fitRatio * scale
        
        // 3) Calculate the displayed image size
        let displayedWidth = originalWidth * finalScale
        let displayedHeight = originalHeight * finalScale
        
        // 4) Center the image if there's leftover space in either dimension
        let leftoverX = (geometry.size.width - displayedWidth) / 2
        let leftoverY = (geometry.size.height - displayedHeight) / 2
        
        // 5) Translate the point's pixelPosition by the finalScale
        let scaledX = mapPoint.pixelPosition.x * finalScale
        let scaledY = mapPoint.pixelPosition.y * finalScale
        
        // 6) Add leftover offsets + any user panning
        let screenX = leftoverX + scaledX + offset.width
        let screenY = leftoverY + scaledY + offset.height
        
        return CGPoint(x: screenX, y: screenY)
    }
}

// MARK: - Pulsing Circle
struct PulsingCircle: View {
    @State private var circleScale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 14, height: 14)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .scaleEffect(circleScale)
                    .opacity(2 - circleScale)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                    circleScale = 1.5
                }
            }
    }
}

struct MapBackgroundLayer: View {
    let isDarkMode: Bool
    let isSatelliteView: Bool
    
    var body: some View {
        ZStack {
            Color(isDarkMode ? .black : .white)
                .ignoresSafeArea(.container, edges: .top)
            
            if isSatelliteView {
                Image("BlurredBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
