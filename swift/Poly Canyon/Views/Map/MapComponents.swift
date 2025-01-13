/*
 MapComponents provides the supporting UI elements for the map interface. It includes the virtual tour 
 navigation bar, structure visit notifications, nearby structure overlays, and achievement popups. These 
 components adapt to the current theme and provide consistent interaction patterns across the map experience.
*/

import SwiftUI

// Add these modifiers at the top level of MapComponents.swift

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
    
    func mapToolbarButton(isActive: Bool = false) -> some View {
        modifier(MapToolbarButton(isActive: isActive))
    }
    
    func toolbarBackground() -> some View {
        modifier(ToolbarBackground())
    }
}

// MARK: - Virtual Tour Navigation
struct VirtualWalkThroughBar: View {
    @EnvironmentObject var appState: AppState
    let structure: Structure
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            // Single container with glass effect
            RoundedRectangle(cornerRadius: 15)
                .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.93))
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
                    // Content overlay
                    HStack(spacing: 16) {
                        // Previous button
                        Button(action: onPrevious) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .black))
                                .frame(width: 36, height: 36)
                                .foregroundColor(appState.isDarkMode ? .white : .black)
                        }
                        
                        // Structure info (tappable)
                        Button(action: onTap) {
                            HStack(spacing: 14) {
                                // Image with overlaid number
                                Image(structure.images[0])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 75, height: 75)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        Text("#\(structure.number)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .shadow(color: .black, radius: 2)
                                            .shadow(color: .white.opacity(0.3), radius: 1),
                                        alignment: .bottomTrailing
                                    )
                                
                                Text(structure.title)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(appState.isDarkMode ? .white : .black)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Next button
                        Button(action: onNext) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .black))
                                .frame(width: 36, height: 36)
                                .foregroundColor(appState.isDarkMode ? .white : .black)
                        }
                    }
                    .padding(.horizontal, 16)
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
                .shadow(
                    color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.15),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }
        .frame(maxHeight: .infinity)
    }
}


struct MapStatusOverlay: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Spacer()
            if locationService.isLocationPermissionDenied {
                BottomMessage(text: "Enable location services", geometry: geometry)
            } else if locationService.isOutOfRange {
                BottomMessage(text: "To use the live map, you must be in Poly Canyon", geometry: geometry)
            } else if locationService.isNearby {
                BottomMessage(text: "You're nearby! The live map will start soon", geometry: geometry)
            }
            // No message if isInPolyCanyonArea (showing pulsing circle instead)
        }
    }
}

struct StatusMessage: View {
    @EnvironmentObject var appState: AppState
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .padding()
            .background(appState.isDarkMode ? Color.black : Color.white)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .cornerRadius(10)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8),
                    radius: 5, x: 0, y: 0)
    }
}

struct BottomMessage: View {
    @EnvironmentObject var appState: AppState
    let text: String
    let geometry: GeometryProxy
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .padding()
            .background(appState.isDarkMode ? Color.black : Color.white)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .cornerRadius(10)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8),
                    radius: 5, x: 0, y: 0)
            .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
    }
}

struct MapContainerView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @Binding var isSatelliteView: Bool
    @Binding var hideNumbers: Bool
    @Binding var isFullScreen: Bool
    let content: Content
    
    // ADDED: We bring in the CirclePositionStore
    @ObservedObject var circlePositionStore: CirclePositionStore
    
    // This was your static container height (70%).
    // We'll still show the container at 70% overall height
    // but shift contents internally.
    
    @State private var visualScale: CGFloat = 1.0
    @State private var targetScale: CGFloat = 1.0
    
    init(isSatelliteView: Binding<Bool>,
         hideNumbers: Binding<Bool>,
         isFullScreen: Binding<Bool>,
         circlePositionStore: CirclePositionStore,  // ADDED
         @ViewBuilder content: () -> Content) {
        
        self._isSatelliteView = isSatelliteView
        self._hideNumbers = hideNumbers
        self._isFullScreen = isFullScreen
        self.circlePositionStore = circlePositionStore // ADDED
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
                let maxOffset = containerGeometry.size.height * 0.15  // ±10% is max shift
                let defaultOffset = containerGeometry.size.height * -0.15  // always want 10% down if no dot
                
                let baseOffset: CGFloat = {
                    if let circleY = circlePositionStore.circleY,
                       circlePositionStore.isDotVisible
                    {
                        let delta = circleY - midY
                        let normalized = delta / midY
                        let clamped = max(-1, min(1, normalized))
                        return -clamped * maxOffset
                    } else {
                        return defaultOffset
                    }
                }()
                
                let anchorPoint = calculateAnchorPoint(in: containerGeometry)
                let zoomOffset = calculateZoomOffset(for: visualScale, in: containerGeometry, anchorPoint: anchorPoint)
                let xAdjusted = zoomOffset.width * 0.65
                
                // Our actual scrollable content
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    content
                        .frame(width: containerGeometry.size.width,
                               height: mapHeight)
                        .offset(y: baseOffset)
                        .scaleEffect(
                            visualScale,
                            anchor: anchorPoint
                        )
                        .offset(x: xAdjusted, y: zoomOffset.height)
                        .animation(.easeInOut(duration: 0.4), value: baseOffset)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: visualScale)
                }
                .clipped()
                
                // The bottom toolbar (unchanged)
                MapToolbar(
                    isSatelliteView: $isSatelliteView,
                    hideNumbers: $hideNumbers,
                    isFullScreen: $isFullScreen,
                    visualScale: $visualScale,
                    targetScale: $targetScale
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
    @Binding var value: CGFloat
    @Binding var targetValue: CGFloat
    
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
                                Text("×\(String(format: "%.1f", value))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(appState.isDarkMode ? .white : .black)
                            )
                            .offset(x: (geometry.size.width - 20) * (value - 1.0))  // Adjusted from -37 to -53 to account for padding
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { gesture in
                                        let oldValue = value
                                        let newValue = 1.0 + gesture.location.x / (geometry.size.width - 20)
                                        value = max(1.0, min(2.0, newValue))
                                        
                                        // Haptic feedback when crossing snap points
                                        if snapPoints.contains(where: { point in
                                            (oldValue < point && newValue >= point) || 
                                            (oldValue > point && newValue <= point)
                                        }) {
                                            lightFeedback.impactOccurred()
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            targetValue = snapPoints.min(by: { abs($0 - value) < abs($1 - value) }) ?? 1.0
                                            value = targetValue
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
    @Binding var isSatelliteView: Bool
    @Binding var hideNumbers: Bool
    @Binding var isFullScreen: Bool
    @Binding var visualScale: CGFloat
    @Binding var targetScale: CGFloat
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: { isSatelliteView.toggle() }) {
                        HStack(spacing: 0) {
                            Image(systemName: "map.fill")
                                .frame(width: 44)
                                .foregroundColor(!isSatelliteView ? .black : .gray)
                                .scaleEffect(!isSatelliteView ? 1.1 : 1.0)
                            
                            Image(systemName: "globe.americas.fill")
                                .frame(width: 44)
                                .foregroundColor(isSatelliteView ? .black : .gray)
                                .scaleEffect(isSatelliteView ? 1.1 : 1.0)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(height: 32)
                        .mapToolbarButton()
                    }
                }
                
                Button(action: { hideNumbers.toggle() }) {
                    Group {
                        if hideNumbers {
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
                    .mapToolbarButton(isActive: hideNumbers)
                }
            }
            
            Spacer()
            
            // Scale slider
            ScaleSlider(value: $visualScale, targetValue: $targetScale)
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
    @Binding var hideNumbers: Bool
    @Binding var isSatelliteView: Bool
    let mapImage: String
    let geometry: GeometryProxy
    let isVirtualWalkthroughActive: Bool
    let currentStructureIndex: Int
    let currentWalkthroughMapPoint: MapPoint?
    let onClose: () -> Void
    
    @ObservedObject var circlePositionStore: CirclePositionStore
    
    @State private var showTools: Bool = false
    
    private let glassBackground = Color.white.opacity(0.8)
    
    var body: some View {
        ZStack {
            // Base map layer
            MapWithLocationDot(
                mapImage: mapImage,
                isSatelliteView: isSatelliteView,
                geometry: geometry,
                isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                currentStructureIndex: currentStructureIndex,
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
                                Button(action: { isSatelliteView.toggle() }) {
                                    Image(systemName: isSatelliteView ? "map.fill" : "globe.americas.fill")
                                        .font(.system(size: 22))
                                        .frame(width: 44, height: 44)
                                        .glassButton()
                                }
                                
                                Button(action: { hideNumbers.toggle() }) {
                                    Group {
                                        if hideNumbers {
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
    @Binding var isVirtualWalkthroughActive: Bool
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
            if isVirtualWalkthroughActive {
                VirtualWalkThroughBar(
                    structure: dataStore.structures[currentStructureIndex],
                    onNext: moveToNextStructure,
                    onPrevious: moveToPreviousStructure,
                    onTap: {
                        // We'll handle structure info popup next
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
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
            isVirtualWalkthroughActive.toggle()
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
            isVirtualWalkthroughActive.toggle()
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
                        // Handle structure selection (we can add this later)
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
