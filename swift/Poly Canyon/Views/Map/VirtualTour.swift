import SwiftUI

struct VirtualTour: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    @Namespace private var mapTransition
    @StateObject private var circlePositionStore = CirclePositionStore()
    @State private var opacity: Double = 1.0
    @State private var currentWalkthroughMapPoint: MapPoint?
    
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Background blur for top safe area
            Image("BlurredBG")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()

                VirtualTourMapContainer(
                    circlePositionStore: circlePositionStore
                ) {
                    MapWithLocationDot(
                        mapImage: currentMapImage(),
                        geometry: geometry,
                        currentWalkthroughMapPoint: currentWalkthroughMapPoint,
                        circlePositionStore: circlePositionStore
                    )
                    .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)
                    .matchedGeometryEffect(id: "mapContainer", in: mapTransition)
                }
                .onAppear {
                    let structure = dataStore.structures[appState.currentStructureIndex]
                    currentWalkthroughMapPoint = locationService.getMapPointForStructure(structure.number)
                    appState.isVirtualTourFullScreen = true
                }
                .onDisappear {
                    appState.isVirtualTourFullScreen = false
                }
                .frame(height: UIScreen.main.bounds.height * 0.6-20)
                
                VirtualTourBottomBar()
                    .frame(height: UIScreen.main.bounds.height * 0.35)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Material.ultraThinMaterial)
                    .clipShape(RoundedCorner2(radius: 24, corners: [.topLeft, .topRight]))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                    .clipShape(RoundedCorner2(radius: 24, corners: [.topLeft, .topRight]))
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .ignoresSafeArea()
        .opacity(opacity)
        .onChange(of: appState.currentStructureIndex) { _ in
            let structure = dataStore.structures[appState.currentStructureIndex]
            currentWalkthroughMapPoint = locationService.getMapPointForStructure(structure.number)
        }
    }
    
    private func currentMapImage() -> String {
        let baseImage = appState.mapIsSatellite
            ? "SatelliteMap"
            : (appState.isDarkMode ? "DarkMap" : "LightMap")
        return !appState.mapShowNumbers ? baseImage + "NN" : baseImage
    }
}

/// A specialized container for a 60% screen-height map in Virtual Tour mode,
/// preserving the vertical offset to center the dot, while properly anchoring
/// zooming at the dot's position. White space is clamped to prevent overshoot.
struct VirtualTourMapContainer<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var circlePositionStore: CirclePositionStore
    
    private let content: Content
    
    init(
        circlePositionStore: CirclePositionStore,
        @ViewBuilder content: () -> Content
    ) {
        self.circlePositionStore = circlePositionStore
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { containerGeometry in
            VStack(spacing: 0) {
                // Subtract toolbar height from the total container
                let adjustedMapHeight = containerGeometry.size.height - 44
                
                // 1) Compute how much to shift map vertically so dot is near center
                let verticalShift = computeVerticalDotShift(
                    containerHeight: adjustedMapHeight
                )
                
                // 2) Calculate the map's anchor point (0..1) based on dot location
                let dotAnchorPoint = computeDotAnchor(
                    geometry: containerGeometry
                )
                
                // 3) Determine how to clamp X/Y after zoom to avoid white space
                let zoomClamps = computeZoomClamp(
                    scale: appState.mapScale,
                    geometry: containerGeometry,
                    anchor: dotAnchorPoint
                )
                
                // The scrollable map content
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    content
                        .frame(width: containerGeometry.size.width,
                               height: adjustedMapHeight)
                        .offset(
                            x: zoomClamps.width * 0.4,
                            y: verticalShift + zoomClamps.height
                        )
                        .scaleEffect(appState.mapScale, anchor: dotAnchorPoint)
                        .animation(.easeInOut(duration: 0.4), value: verticalShift)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7),
                                   value: appState.mapScale)
                }
                .clipped()
                .overlay(alignment: .topTrailing) {
                    // Close button overlay
                    Button(action: {
                        withAnimation {
                            appState.isVirtualWalkthrough = false
                            appState.configureMapSettings(forWalkthrough: false)
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .frame(width: 36, height: 36)
                            .glassButton()
                    }
                    .padding(16)
                }
            }
            .background(appState.isDarkMode ? Color.black : Color.white)
            .clipShape(
                RoundedCorner2(radius: 24, corners: [.topLeft, .topRight])
            )
            .overlay(StructureMapOverlay(structure: dataStore.structures[appState.currentStructureIndex]))
            .overlay(
                Rectangle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(appState.isDarkMode ? 0.4 : 0.8),
                                Color(white: 0.6).opacity(appState.isDarkMode ? 0.15 : 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .clipShape(
                        RoundedCorner2(radius: 24, corners: [.topLeft, .topRight])
                    )
            )
        }
    }
}

// MARK: - Logic / Helper Methods
extension VirtualTourMapContainer {
    
    /// Computes how much to shift the map up/down so that
    /// the circle (dot) appears near the middle vertically.
    private func computeVerticalDotShift(containerHeight: CGFloat) -> CGFloat {
        // This is the maximum shift we allow from center
        let maxVerticalMotion = containerHeight * 0.35
        
        guard
            circlePositionStore.isDotVisible,
            let dotY = circlePositionStore.circleY
        else {
            // If we have no dot, shift downward by default
            return -maxVerticalMotion
        }
        
        let midpoint = containerHeight / 2
        let distance = dotY - midpoint
        let ratio = distance / midpoint
        
        // Cap ratio so we don't overshoot
        let clamped = max(-1, min(1, ratio))
        
        // Negative sign to move map upward if the dot is below center
        return -clamped * maxVerticalMotion
    }
    
    /// Derives a 0..1 anchor point for scaleEffect, so the map zooms around the circle position.
    private func computeDotAnchor(geometry: GeometryProxy) -> UnitPoint {
        guard
            circlePositionStore.isDotVisible,
            let dotX = circlePositionStore.circleX,
            let dotY = circlePositionStore.circleY
        else {
            return .init(x: 0.5, y: 1.0)
        }

        let rawMapSize = determineMapSize(in: geometry)
        let containerHeight = geometry.size.height - 44
        
        // Calculate basic relative X position
        let xOffset = (geometry.size.width - rawMapSize.width) / 2
        let relativeX = (dotX - xOffset) / rawMapSize.width
        
        // Calculate how far we are from the top as a percentage
        let percentFromTop = dotY / geometry.size.height
        
        // Keep our existing damping logic
        let dampingFactor = 1.0 - (percentFromTop * 0.5)
        let relativeY = percentFromTop * dampingFactor
        
        // may need hardline addition instead 
        let adjustedY = percentFromTop > 0.56 
            ? relativeY + ((percentFromTop - 0.56) / 0.44) * 0.025
            : relativeY

            
        let safeY = min(max(adjustedY, 0.1), 1)
        
        return UnitPoint(x: relativeX, y: safeY)
    }
    
    /// Once we're scaling around the dot, we also need to offset/pan so we don't show white space.
    /// This function clamps how far we can move in X and Y after zooming.
    private func computeZoomClamp(
        scale: CGFloat,
        geometry: GeometryProxy,
        anchor: UnitPoint
    ) -> CGSize {
        guard scale > 1.0 else { return .zero }
        
        let unscaledMap = determineMapSize(in: geometry)
        
        let scaledW = unscaledMap.width * scale
        let scaledH = unscaledMap.height * scale
        
        let maxX = (scaledW - unscaledMap.width) / 2
        let maxY = (scaledH - unscaledMap.height) / 2
        
        // Where the anchor tries to place the map
        let desiredX = (scaledW - unscaledMap.width) * (0.5 - anchor.x)
        let desiredY = (scaledH - unscaledMap.height) * (0.5 - anchor.y)
        
        // Clamp to avoid white space
        let finalX = max(-maxX, min(maxX, desiredX))
        let finalY = max(-maxY, min(maxY, desiredY))
        
        return CGSize(width: finalX, height: finalY)
    }
    
    /// Figures out how large the map is before scaling in this container, preserving aspect ratio.
    private func determineMapSize(in geometry: GeometryProxy) -> CGSize {
        let originalWidth: CGFloat = 2000
        let originalHeight: CGFloat = 4519
        let aspectRatio = originalWidth / originalHeight
        
        let availableW = geometry.size.width
        let availableH = geometry.size.height
        
        if availableW / availableH > aspectRatio {
            // The map is height-constrained
            let finalHeight = availableH
            let finalWidth = finalHeight * aspectRatio
            return CGSize(width: finalWidth, height: finalHeight)
        } else {
            // The map is width-constrained
            let finalWidth = availableW
            let finalHeight = finalWidth / aspectRatio
            return CGSize(width: finalWidth, height: finalHeight)
        }
    }
}

struct VirtualTourBottomBar: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    @State private var isImageExpanded = false
    
    private var currentStructure: Structure {
        dataStore.structures[appState.currentStructureIndex]
    }
    
    var body: some View {
        GeometryReader { geo in
            let navigationHeight: CGFloat = 54
            let bottomPadding: CGFloat = 30
            let topPadding: CGFloat = 15
            let verticalSpacing: CGFloat = 15
            
            let availableContentHeight = geo.size.height - (navigationHeight + bottomPadding + topPadding + verticalSpacing)
            
            VStack(spacing: 0) {
                // Main Content Area
                HStack(alignment: .center, spacing: 15) {
                    // Large Image
                    Image(currentStructure.images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.4, height: availableContentHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.7),
                                            Color.white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .scaleEffect(isImageExpanded ? 1.02 : 1.0)
                        .onHover { hovering in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isImageExpanded = hovering
                            }
                        }

                    // Fun Fact Text
                    Text(currentStructure.funFact ?? "")
                        .font(.system(size: 24, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(appState.isDarkMode ? .white.opacity(0.95) : .black.opacity(0.9))
                        .lineSpacing(5)
                        .frame(width: geo.size.width * 0.5-5, height: availableContentHeight)
                }
                .padding(.horizontal, 15)
                .padding(.top, topPadding)
                
                Spacer()
                
                // Bottom Navigation Bar
                HStack(spacing: 24) {
                    // Previous Button
                    NavButton(
                        action: goPrevious,
                        icon: "chevron.left",
                        size: navigationHeight
                    )
                    
                    // Learn More Button
                    Button(action: {
                        appState.activeFullScreenView = .structInfo
                        appState.structInfoNum = currentStructure.number
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(appState.isDarkMode ? .white : .black)

                            Text("Learn More")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(appState.isDarkMode ? .white : .black)
                        }
                        .frame(width: geo.size.width * 0.5, height: navigationHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 27)
                                .fill(Material.ultraThinMaterial)
                        )
                            .overlay(
                                RoundedRectangle(cornerRadius: 27)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.7),
                                                Color.white.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    }
                    
                    // Next Button
                    NavButton(
                        action: goNext,
                        icon: "chevron.right",
                        size: navigationHeight
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, bottomPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appState.isDarkMode ? Color.black : Color.white)
        }
    }
    
    private func goNext() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            let nextIndex = (appState.currentStructureIndex + 1) % dataStore.structures.count
            appState.currentStructureIndex = nextIndex
        }
    }
    
    private func goPrevious() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            let prevIndex = (appState.currentStructureIndex - 1 + dataStore.structures.count) 
                % dataStore.structures.count
            appState.currentStructureIndex = prevIndex
        }
    }
}

struct NavButton: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    let icon: String
    let size: CGFloat
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Material.ultraThinMaterial)
                )
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
}

struct StructureMapOverlay: View {
    @EnvironmentObject var appState: AppState
    let structure: Structure
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            HStack(spacing: 16) {
                Text("#\(structure.number)")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                
                Text(structure.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .lineLimit(2)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity(appState.isDarkMode ? 0.15 : 0.3),
                                .white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.bottom, 10)
        .frame(maxWidth: 280, maxHeight: .infinity, alignment: .bottom)
    }
}


struct GlowingContainer: ViewModifier {
    @EnvironmentObject var appState: AppState
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color(red: 1, green: 0.84, blue: 0).opacity(0.2),
                        lineWidth: 1.2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .trim(from: 0.4, to: 0.6)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1, green: 0.84, blue: 0).opacity(0),
                                Color(red: 1, green: 0.84, blue: 0).opacity(0.8),
                                Color(red: 1, green: 0.84, blue: 0).opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(rotation))
            )
            .shadow(
                color: Color(red: 1, green: 0.84, blue: 0).opacity(0.15),
                radius: 8,
                x: 0,
                y: 0
            )
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

extension View {
    func glowingContainer() -> some View {
        modifier(GlowingContainer())
    }
}


struct RoundedCorner2: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
