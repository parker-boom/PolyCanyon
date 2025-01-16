/*
 MapComponents provides the supporting UI elements for the map interface. It includes the virtual tour 
 navigation bar, structure visit notifications, nearby structure overlays, and achievement popups. These 
 components adapt to the current theme and provide consistent interaction patterns across the map experience.
*/

import SwiftUI


struct GlassBackground: ViewModifier {
    @EnvironmentObject var appState: AppState
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
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
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.15),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}


struct GlassButton: ViewModifier {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.7) :
            Color(white: 0.90)  // Slightly darker base
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                        Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 1,
                x: 0,
                y: 1
            )
    }
}



struct GlassButtonNoShadow: ViewModifier {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.7) :
            Color(white: 0.90)  
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                        Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

struct MapToolbarButton: ViewModifier {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.7) :
            Color(white: 0.90)
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                        Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 1,
                x: 0,
                y: 1
            )
    }
}

struct ToolbarBackground: ViewModifier {
    @EnvironmentObject var appState: AppState
    
    func body(content: Content) -> some View {
        content
            .background(
                BottomRoundedRectangle(cornerRadius: 12)
                    .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.93))
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        BottomRoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                Color.white.opacity(appState.isDarkMode ? 0.2 : 0.1),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 22) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
    
    func glassButton(isActive: Bool = false) -> some View {
        modifier(GlassButton(isActive: isActive))
    }
    
    func glassButtonNoShadow(isActive: Bool = false) -> some View {
        modifier(GlassButtonNoShadow(isActive: isActive))
    }
    
    func mapToolbarButton(isActive: Bool = false) -> some View {
        modifier(MapToolbarButton(isActive: isActive))
    }
    
    func toolbarBackground() -> some View {
        modifier(ToolbarBackground())
    }
}


struct MapContainerView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @Binding var isFullScreen: Bool
    let content: Content
    
    @ObservedObject var circlePositionStore: CirclePositionStore
    
    init(isSatelliteView: Binding<Bool>,
         hideNumbers: Binding<Bool>,
         isFullScreen: Binding<Bool>,
         circlePositionStore: CirclePositionStore,
         @ViewBuilder content: () -> Content) {
        
        self._isFullScreen = isFullScreen
        self.circlePositionStore = circlePositionStore
        self.content = content()
    }
    
    private func calculateAnchorPoint(in geometry: GeometryProxy) -> UnitPoint {
        if circlePositionStore.isDotVisible,
           let circleX = circlePositionStore.circleX,
           let circleY = circlePositionStore.circleY {
            
            let mapSize = calculateRenderedMapSize(in: geometry)
            let xOffset = (geometry.size.width - mapSize.width) / 2
            let yOffset = (geometry.size.height - mapSize.height) / 2
            
            // Convert to relative coordinates within the actual map content
            let relativeX = (circleX - xOffset) / mapSize.width
            let relativeY = (circleY - yOffset) / mapSize.height
            
            // Clamp Y to prevent white space when zooming
            let safeY = min(max(relativeY, 0.0), 1.0)
            
            return UnitPoint(x: relativeX, y: safeY)
        } else {
            // When no dot, anchor at bottom
            return UnitPoint(x: 0.5, y: 1.0)
        }
    }
    
    private func calculateZoomOffset(for scale: CGFloat, in geometry: GeometryProxy, anchorPoint: UnitPoint) -> CGSize {
        guard scale > 1.0 else { return .zero }
        
        let mapSize = calculateRenderedMapSize(in: geometry)
        let scaledWidth = mapSize.width * scale
        let scaledHeight = mapSize.height * scale
        
        // Calculate how much we can move without showing white space
        let maxXOffset = (scaledWidth - mapSize.width) / 2
        let maxYOffset = (scaledHeight - mapSize.height) / 2
        
        // Calculate desired offset based on anchor point
        let desiredXOffset = (scaledWidth - mapSize.width) * (0.5 - anchorPoint.x)
        let desiredYOffset = (scaledHeight - mapSize.height) * (0.5 - anchorPoint.y)
        
        // Clamp the offset to prevent white space
        let clampedXOffset = max(-maxXOffset, min(maxXOffset, desiredXOffset))
        let clampedYOffset = max(-maxYOffset, min(maxYOffset, desiredYOffset))
        
        return CGSize(width: clampedXOffset, height: 0)  // Still letting baseOffset handle Y
    }
    
    private func calculateRenderedMapSize(in geometry: GeometryProxy) -> CGSize {
        let originalWidth: CGFloat = 2000
        let originalHeight: CGFloat = 4519
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
    
    var body: some View {
        GeometryReader { containerGeometry in
            VStack(spacing: 0) {
                // Calculate dynamic offset:
                let mapHeight = containerGeometry.size.height - 44  // space for your toolbar
                let midY = mapHeight / 2
                let maxOffset = containerGeometry.size.height * 0.12  // ±10% is max shift
                let defaultOffset = containerGeometry.size.height * -0.12  // always want 10% down if no dot
                
                let baseOffset: CGFloat = {
                    guard circlePositionStore.isDotVisible,
                          let circleY = circlePositionStore.circleY else {
                        return defaultOffset
                    }
                    
                    let delta = circleY - midY
                    let normalized = delta / midY
                    
                    // Make middle section adjustment more subtle
                    let adjustedNormalized = if abs(normalized) < 0.5 {
                        // Reduce by 25% instead of 50%
                        normalized * 0.75
                    } else {
                        normalized
                    }
                    
                    let clamped = max(-1, min(1, adjustedNormalized))
                    return -clamped * maxOffset
                }()
                                    
                
                let anchorPoint = calculateAnchorPoint(in: containerGeometry)
                let zoomOffset = calculateZoomOffset(for: appState.mapScale, in: containerGeometry, anchorPoint: anchorPoint)
                let xAdjusted = zoomOffset.width * 0.65
                
                // Our actual scrollable content
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    content
                        .frame(width: containerGeometry.size.width,
                               height: mapHeight)
                        .offset(y: baseOffset)
                        .scaleEffect(
                            appState.mapScale,
                            anchor: anchorPoint
                        )
                        .offset(x: xAdjusted, y: zoomOffset.height)
                        .animation(.easeInOut(duration: 0.4), value: baseOffset)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: appState.mapScale)
                }
                .clipped()
                
                // The bottom toolbar (unchanged)
                MapToolbar(
                    isFullScreen: $isFullScreen
                )
            }
            .background(appState.isDarkMode ? Color.black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
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
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.25),
                radius: 10,
                x: 0,
                y: 4
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.15),
                radius: 2,
                x: 0,
                y: 1
            )
        }
        // The container still only takes 70% of screen height
        .frame(height: UIScreen.main.bounds.height * 0.7)
    }
}


// New ScaleSlider component
struct ScaleSlider: View {
    @EnvironmentObject var appState: AppState
    
    private let snapPoints: [CGFloat] = [1.0, 1.25, 1.5, 1.75, 2.0]
    private let mainPoints: [CGFloat] = [1.0, 1.5, 2.0]
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let rigidFeedback = UIImpactFeedbackGenerator(style: .rigid)
    
    var body: some View {
        GeometryReader { geometry in
            // Container using mapToolbarButton style
            RoundedRectangle(cornerRadius: 20)
                .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            Color.gray.opacity(0.025)
                        )
                )
                .overlay(
                    ZStack(alignment: .leading) {
                        // Timeline track - 15% darker
                        Rectangle()
                            .fill(appState.isDarkMode ? 
                                Color.white.opacity(0.4) : // Increased from 0.25
                                Color.black.opacity(0.25))  // Increased from 0.15
                            .frame(height: 3)
                            .padding(.horizontal, 16)
                        
                        // Main points (larger circles)
                        HStack(spacing: (geometry.size.width - 32) / 2) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(appState.isDarkMode ? Color.white.opacity(0.4) : Color.black.opacity(0.2))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Tick marks (smaller lines)
                        HStack(spacing: (geometry.size.width - 32) / 4) {
                            ForEach(0..<5) { i in
                                if i % 2 == 1 {
                                    Rectangle()
                                        .fill(appState.isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.15))
                                        .frame(width: 2, height: 4)
                                } else {
                                    Color.clear
                                        .frame(width: 2, height: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Draggable circle - matching toolbar button style
                        Circle()
                            .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.90))
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                                Color.white.opacity(0.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                                Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                                radius: 8
                            )
                            .shadow(
                                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                                radius: 1
                            )
                            .frame(width: 35, height: 35)
                            .overlay(
                                Text("×\(String(format: "%.1f", appState.mapScale))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(appState.isDarkMode ? .white : .black)
                            )
                            .offset(x: (geometry.size.width - 20) * (appState.mapScale - 1.0))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { gesture in
                                        let oldValue = appState.mapScale
                                        let newValue = 1.0 + gesture.location.x / (geometry.size.width - 20)
                                        appState.mapScale = max(1.0, min(2.0, newValue))
                                        
                                        if snapPoints.contains(where: { point in
                                            (oldValue < point && newValue >= point) || 
                                            (oldValue > point && newValue <= point)
                                        }) {
                                            lightFeedback.impactOccurred()
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            let targetValue = snapPoints.min(by: { abs($0 - appState.mapScale) < abs($1 - appState.mapScale) }) ?? 1.0
                                            appState.mapScale = targetValue
                                            rigidFeedback.impactOccurred()
                                        }
                                    }
                            )
                    }
                )
        }
        .frame(height: 15)  // Match the container height reduction
    }
}

struct MapToolbar: View {
    @EnvironmentObject var appState: AppState
    @Binding var isFullScreen: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: { appState.mapIsSatellite.toggle() }) {
                        HStack(spacing: 0) {
                            Image(systemName: "map.fill")
                                .frame(width: 44)
                                .foregroundColor(!appState.mapIsSatellite ? .black : .gray)
                                .scaleEffect(!appState.mapIsSatellite ? 1.1 : 1.0)
                            
                            Image(systemName: "globe.americas.fill")
                                .frame(width: 44)
                                .foregroundColor(appState.mapIsSatellite ? .black : .gray)
                                .scaleEffect(appState.mapIsSatellite ? 1.1 : 1.0)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(height: 32)
                        .mapToolbarButton()
                    }
                }
                
                Button(action: { appState.mapShowNumbers.toggle() }) {
                    Group {
                        if !appState.mapShowNumbers {
                            Image(systemName: "number")
                        } else {
                            Text("13")
                                .font(.system(size: 18, weight: .semibold))
                                .overlay(
                                    Line()
                                        .rotation(.degrees(90))
                                        .stroke(appState.isDarkMode ? .white : .black, lineWidth: 2)
                                        .frame(width: 15, height: 15)
                                )
                        }
                    }
                    .frame(width: 32, height: 32)
                    .mapToolbarButton(isActive: !appState.mapShowNumbers)
                }
            }
            
            Spacer()
            
            // Scale slider (no longer needs bindings)
            ScaleSlider()
                .frame(width: 120, height: 15)  
                .padding(.trailing, 4)
            
            Button(action: { isFullScreen.toggle() }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .mapToolbarButton()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .toolbarBackground()
    }
}


// Add this struct for the diagonal line
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

struct BottomRoundedRectangle: Shape, InsettableShape {
    let cornerRadius: CGFloat
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()
        
        // Top left corner - sharp
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Right edge and bottom right corner - rounded
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        // Bottom left corner - rounded
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
    
    func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.insetAmount = amount
        return shape
    }
}

struct FullScreenMapView: View {
    @EnvironmentObject var appState: AppState
    let mapImage: String
    let geometry: GeometryProxy
    let currentStructureIndex: Int
    let currentWalkthroughMapPoint: MapPoint?
    let onClose: () -> Void
    
    @ObservedObject var circlePositionStore: CirclePositionStore
    @State private var showTools: Bool = false
    
    var body: some View {
        ZStack {
            // Base map layer
            MapWithLocationDot(
                mapImage: mapImage,
                geometry: geometry,
                currentWalkthroughMapPoint: currentWalkthroughMapPoint,
                circlePositionStore: circlePositionStore
            )
            .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)
            
            // Bottom controls overlay
            VStack {
                Spacer()
                
                HStack {
                    // Tools button with expanding overlay
                    Button(action: { withAnimation(.spring()) { showTools.toggle() }}) {
                        Image(systemName: showTools ? "xmark" : "gearshape.fill")
                            .font(.system(size: showTools ? 16 : 22, weight: showTools ? .bold : .semibold))
                            .frame(width: showTools ? 32 : 44, height: showTools ? 32 : 44)
                            .glassButton(isActive: showTools)
                    }
                    .overlay(alignment: .top) {
                        if showTools {
                            VStack(spacing: 12) {
                                Button(action: { appState.mapIsSatellite.toggle() }) {
                                    Image(systemName: appState.mapIsSatellite ? "map.fill" : "globe.americas.fill")
                                        .font(.system(size: 22))
                                        .frame(width: 44, height: 44)
                                        .glassButton()
                                }
                                
                                Button(action: { appState.mapShowNumbers.toggle() }) {
                                    Group {
                                        if !appState.mapShowNumbers {
                                            Image(systemName: "number")
                                        } else {
                                            Text("13")
                                                .overlay(
                                                    Line()
                                                    .rotation(.degrees(90))
                                                    .stroke(appState.isDarkMode ? .white : .black, lineWidth: 3)
                                                    .frame(width: 18, height: 18))
                                        }
                                    }
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                                    .glassButton()
                                }
                            }
                            .offset(y: -120)
                        }
                    }
                    
                    Spacer()
                    
                    // Minimize button
                    Button(action: onClose) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 44, height: 44)
                            .glassButton()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct MapBottomBar: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataStore: DataStore
    @Binding var currentStructureIndex: Int
    
    private func moveToNextStructure() {
        withAnimation {
            currentStructureIndex = (currentStructureIndex + 1) % dataStore.structures.count
        }
    }
    
    private func moveToPreviousStructure() {
        withAnimation {
            currentStructureIndex = (currentStructureIndex - 1 + dataStore.structures.count) % dataStore.structures.count
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        appState.isDarkMode ? 
                        Color.black.opacity(0.7) :
                        Color(white: 0.93)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
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
                    )
                    .shadow(
                        color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.25),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
                    .overlay(
                        Group { 
                            if !appState.adventureModeEnabled {
                                virtualTourInactiveContent
                            } else {
                                switch locationService.adventureLocationState {
                                case .notVisiting:
                                    notVisitingContent
                                case .onTheWay:
                                    onTheWayContent
                                case .almostThere:
                                    almostThereContent
                                case .exploring:
                                    if locationService.isLocationPermissionDenied {
                                        permissionDeniedContent
                                    } else {
                                        nearbyStructuresContent
                                    }
                                }
                            }
                        }
                    )
            
        }
    }
    
    private var virtualTourInactiveContent: some View {
        HStack(spacing: 10) {
            Text("🚶‍♂️")
                .font(.system(size: 44))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Take a Virtual Tour")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                
                Text("Walk through and learn about each structure")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.7))
            }
            
            Spacer()
            
            Circle()
                .fill(appState.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.isVirtualWalkthrough.toggle()
        }
    }

    private var permissionDeniedContent: some View {
        HStack(spacing: 10) {
            Text("😕")
                .font(.system(size: 44))
            
            Text("Location access needed for live map")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            Spacer()
            
            Circle()
                .fill(appState.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private var notVisitingContent: some View {
        HStack(spacing: 14) {
            Text("🗺️")
                .font(.system(size: 44))
            
            Text("Explore virtually before you visit?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            Spacer()
            
            Circle()
                .fill(appState.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.isVirtualWalkthrough.toggle()
        }
    }

    private var onTheWayContent: some View {
        HStack(spacing: 14) {
            Text("🚶‍♂️")
                .font(.system(size: 44))
            
            Text("On your way? We're getting everything ready!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private var almostThereContent: some View {
        HStack(spacing: 14) {
            Text("🎯")
                .font(.system(size: 44))
            
            Text("Almost there! Your live location will appear soon")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private var nearbyStructuresContent: some View {
    HStack(spacing: 12) {
        // Two-line title with different emphasis
        (Text("Nearby")
            .font(.system(size: 24, weight: .bold))
            + Text("\nStructures")
            .font(.system(size: 20, weight: .medium))
        )
        .foregroundColor(appState.isDarkMode ? .white : .black)
        .multilineTextAlignment(.leading)
        .frame(width: 100, alignment: .leading)
        
        // Structure thumbnails
        HStack(spacing: 10) {
            ForEach(locationService.nearbyStructures) { nearby in
                if let structure = dataStore.structures.first(where: { $0.number == nearby.structureNumber }) {
                    Button {
                        appState.activeFullScreenView = .structInfo
                        appState.structInfoNum = structure.number
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(structure.images[0])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(
                                    width: locationService.nearbyStructures.firstIndex(of: nearby) == 0 ? 75 :
                                        locationService.nearbyStructures.firstIndex(of: nearby) == 2 ? 55 : 65,
                                    height: locationService.nearbyStructures.firstIndex(of: nearby) == 0 ? 75 :
                                            locationService.nearbyStructures.firstIndex(of: nearby) == 2 ? 55 : 65
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                .overlay(
                                    Text("#\(structure.number)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .shadow(color: .black, radius: 2)
                                        .shadow(color: .white.opacity(0.3), radius: 1),
                                    alignment: .bottomTrailing
                                )
                            
                            // Visit status indicators
                            if structure.isVisited {
                                if structure.isOpened {
                                    Image("Check")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .padding(6)
                                } else {
                                    Circle()
                                        .fill(Color.blue.opacity(0.7))
                                        .frame(width: 8, height: 8)
                                        .shadow(color: .white.opacity(1), radius: 1)
                                        .padding(6)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
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

                        
                        // Then combine the final offsets:
                        // - verticalShift (to center the dot)
                        // - zoomClamps (to prevent white space, with reduced X if desired)
                        .offset(
                            x: zoomClamps.width * 0.4,
                            y: verticalShift + zoomClamps.height
                        )
                        
                                                
                        // IMPORTANT: Scale first with anchor so the map zooms *around* the dot
                        .scaleEffect(appState.mapScale, anchor: dotAnchorPoint)
                        // Smooth animations
                        .animation(.easeInOut(duration: 0.4), value: verticalShift)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7),
                                   value: appState.mapScale)
                }
                .clipped()
                
                // Map toolbar (no fullscreen in Virtual Tour)
                MapToolbar(isFullScreen: .constant(false))
                
            }
            .background(appState.isDarkMode ? Color.black : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(StructureMapOverlay(structure: dataStore.structures[appState.currentStructureIndex]))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
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
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.25),
                radius: 10, x: 0, y: 4
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.15),
                radius: 2, x: 0, y: 1
            )
        }
        // ~60% of screen height, minus ~49 if there's a bottom tab bar
        .frame(height: UIScreen.main.bounds.height * 0.6 - 49)
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
    @Environment(\.colorScheme) var colorScheme
    
    // Animation states
    @State private var isImageExpanded = false
    @State private var showLearnMore = false
    
    private var currentStructure: Structure {
        dataStore.structures[appState.currentStructureIndex]
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Main Content Section (80%)
                HStack(spacing: 8) {
                    // Image Container with hover effect
                    Image(currentStructure.images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.35, height: geo.size.height * 0.7)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.3), radius: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(colorScheme == .dark ? 0.3 : 0.6),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 3)
                        .scaleEffect(isImageExpanded ? 1.02 : 1.0)
                        .onHover { hovering in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isImageExpanded = hovering
                            }
                        }
                    

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Spacer()
                            Text(currentStructure.funFact ?? "")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                    }
                    .transition(.opacity) 
                    .animation(.easeInOut(duration: 0.2), value: currentStructure.funFact)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Material.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1, green: 0.84, blue: 0).opacity(0.4),  // Gold
                                                Color(red: 1, green: 0.84, blue: 0).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1, green: 0.84, blue: 0).opacity(0.4),  // Gold
                                                Color(red: 1, green: 0.84, blue: 0).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(
                        color: Color(red: 1, green: 0.84, blue: 0).opacity(0.1),  // Gold glow
                        radius: 12,
                        x: 0,
                        y: 0
                    )
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                
                // Control Bar (20%)
                HStack(spacing: 16) {
                    // Previous Button
                    Button(action: goPrevious) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .glassButtonNoShadow()
                    }

                    Spacer()
                    
                    // Combined Control Button
                    Button(action: {}) { // Empty action as we'll handle touches separately
                        HStack(spacing: 0) {
                            // Close Button Section
                            Button(action: closeVirtualTour) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                                    .frame(width: 44)
                            }
                            
                            // Divider
                            Rectangle()
                                .fill(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.15))
                                .frame(width: 1, height: 24)
                            
                            // Learn More Section
                            Button(action: {
                                appState.activeFullScreenView = .structInfo
                                appState.structInfoNum = currentStructure.number
                            }) {
                                HStack(spacing: 6) {
                                    Text("Learn More")
                                        .font(.system(size: 15, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .frame(height: 44)
                        .glassBackground()
                        //.shadow(color: Color.black.opacity(0.2), radius: 3)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: goNext) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .glassButtonNoShadow()
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassBackground(cornerRadius: 24)
            .shadow(color: Color.black.opacity(0.4), radius: 6)
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.4 - 49 - 24)
        .transition(.move(edge: .bottom))
    }
    
    private func closeVirtualTour() {
        withAnimation {
            appState.isVirtualWalkthrough = false
            appState.configureMapSettings(forWalkthrough: false)
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

struct StructureMapOverlay: View {
    @Environment(\.colorScheme) var colorScheme
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
                                .white.opacity(colorScheme == .dark ? 0.15 : 0.3),
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
        .padding(.bottom, 55)
        .frame(maxWidth: 280, maxHeight: .infinity, alignment: .bottom)
    }
}
