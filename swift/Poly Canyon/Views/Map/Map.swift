/*
 Map provides the core map visualization components for the app. It handles rendering the map image, 
 location dot, and coordinate calculations for proper positioning. The view adapts to both adventure 
 and virtual tour modes, showing a pulsing location indicator when appropriate. It supports zooming, 
 panning, and coordinate translation between pixel and screen space.
*/

import SwiftUI
import CoreLocation

// MARK: - Map with Location Indicator
struct MapWithLocationDot: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Map Properties
    let mapImage: String
    let isSatelliteView: Bool
    let geometry: GeometryProxy
    
    // MARK: - Virtual Tour State
    let isVirtualWalkthroughActive: Bool
    let currentStructureIndex: Int
    let currentWalkthroughMapPoint: MapPoint?
    
    // MARK: - Interaction State
    let scale: CGFloat
    let offset: CGSize
    
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
    
    // Calculate location dot position based on nearest map point
    private func circlePosition() -> CGPoint {
        guard let userLoc = locationService.lastLocation else {
            return CGPoint(x: -100, y: -100) // Hide off-screen
        }
        
        // Verify user is in valid area
        if !locationService.isWithinSafeZone(userLoc) {
            return CGPoint(x: -100, y: -100)
        } 
        
        // Find nearest structure point
        guard let nearestPoint = locationService.findNearestMapPoint(to: userLoc.coordinate) else {
            return CGPoint(x: -100, y: -100)
        }
        return calculateCirclePosition(for: nearestPoint)
    }
    
    // Convert map point pixels to screen coordinates
    private func calculateCirclePosition(for mapPoint: MapPoint) -> CGPoint {
        let originalWidth: CGFloat = 4519
        let originalHeight: CGFloat = 2000
        
        let topLeft = topLeftOfImage(
            in: geometry.size,
            originalWidth: originalWidth,
            originalHeight: originalHeight
        )
        
        let displayedSize = displayedImageSize(
            originalSize: CGSize(width: originalWidth, height: originalHeight),
            containerSize: geometry.size,
            scale: scale
        )
        
        let correctScale = min(
            displayedSize.width / originalWidth,
            displayedSize.height / originalHeight
        )
        
        let circleX = (mapPoint.pixelPosition.x * correctScale) + topLeft.x
        let circleY = (mapPoint.pixelPosition.y * correctScale) + topLeft.y
        
        return CGPoint(x: circleX, y: circleY)
    }
    
    // Calculate map image origin accounting for container size and zoom
    private func topLeftOfImage(
        in containerSize: CGSize,
        originalWidth: CGFloat,
        originalHeight: CGFloat
    ) -> CGPoint {
        let containerAspectRatio = containerSize.width / containerSize.height
        let imageAspectRatio = originalWidth / originalHeight
        
        let scaledSize: CGSize
        if containerAspectRatio > imageAspectRatio {
            let height = min(containerSize.height, originalHeight * scale)
            let width = originalWidth * (height / originalHeight)
            scaledSize = CGSize(width: width, height: height)
        } else {
            let width = min(containerSize.width, originalWidth * scale)
            let height = originalHeight * (width / originalWidth)
            scaledSize = CGSize(width: width, height: height)
        }
        
        let x = (containerSize.width - scaledSize.width) / 2
        let y = (containerSize.height - scaledSize.height) / 2
        
        return CGPoint(x: x + offset.width, y: y + offset.height)
    }
    
    // Calculate displayed image size based on container and zoom
    private func displayedImageSize(
        originalSize: CGSize,
        containerSize: CGSize,
        scale: CGFloat
    ) -> CGSize {
        let widthRatio = containerSize.width / originalSize.width
        let heightRatio = containerSize.height / originalSize.height
        let ratio = min(widthRatio, heightRatio) * scale
        
        let displayedWidth = originalSize.width * ratio
        let displayedHeight = originalSize.height * ratio
        
        return CGSize(width: displayedWidth, height: displayedHeight)
    }
}

// MARK: - Location Indicator
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
