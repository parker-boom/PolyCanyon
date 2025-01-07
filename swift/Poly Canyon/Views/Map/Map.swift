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
    
    // Original map dimensions from Photoshop
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
        guard let userLoc = locationService.lastLocation,
              locationService.isWithinSafeZone(userLoc),
              let nearestPoint = locationService.findNearestMapPoint(to: userLoc.coordinate) else {
            return CGPoint(x: -100, y: -100) // Hide off-screen if no valid location
        }
        
        // Calculate the actual rendered size of the map
        let renderedSize = calculateRenderedMapSize()
        
        // Simple scale factors
        let scaleX = renderedSize.width / originalWidth
        let scaleY = renderedSize.height / originalHeight
        
        // Scale the Photoshop pixel coordinates
        let scaledX = nearestPoint.pixelPosition.x * scaleX
        let scaledY = nearestPoint.pixelPosition.y * scaleY
        
        return CGPoint(x: scaledX, y: scaledY)
    }
    
    private func calculateRenderedMapSize() -> CGSize {
        let aspectRatio = originalWidth / originalHeight
        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height
        
        if availableWidth / availableHeight > aspectRatio {
            // Height constrained
            let width = availableHeight * aspectRatio
            return CGSize(width: width, height: availableHeight)
        } else {
            // Width constrained
            let height = availableWidth / aspectRatio
            return CGSize(width: availableWidth, height: height)
        }
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
