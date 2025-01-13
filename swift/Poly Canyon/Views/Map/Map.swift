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
    
    // ADDED: We bring in the CirclePositionStore
    @ObservedObject var circlePositionStore: CirclePositionStore
    
    // Original map dimensions from Photoshop
    private let originalWidth: CGFloat = 2000
    private let originalHeight: CGFloat = 4519
    
    // Show location dot only in adventure mode within range
    private var showPulsingCircle: Bool {
        if isVirtualWalkthroughActive {
            return currentWalkthroughMapPoint != nil
        } else {
            guard appState.adventureModeEnabled else { return false }
            guard let userLoc = locationService.lastLocation else { return false }
            return locationService.isWithinBackgroundRange(userLoc)
        }
    }
    
    var body: some View {
        ZStack {
            // Background layer
            MapBackgroundLayer(isDarkMode: appState.isDarkMode, isSatelliteView: isSatelliteView)
            .scaleEffect(1.2)

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
        
        if isVirtualWalkthroughActive, let walkPoint = currentWalkthroughMapPoint {
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
                    circlePositionStore.circleY = nil
                    circlePositionStore.circleX = nil
                    circlePositionStore.isDotVisible = false
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
            circlePositionStore.circleY = pos.y
            circlePositionStore.circleX = pos.x
            circlePositionStore.isDotVisible = true
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
