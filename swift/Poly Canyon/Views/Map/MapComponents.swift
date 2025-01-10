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
            HStack(spacing: 16) {
                // Previous button
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 42, height: 42)
                        .glassButton()
                }
                
                // Structure info (tappable)
                Button(action: onTap) {
                    HStack(spacing: 14) {
                        // Image with overlaid number
                        Image(structure.images[0])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 65, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                Text("#\(structure.number)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .shadow(color: .black, radius: 2, x: 0, y: 0)
                                    .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 0),
                                alignment: .bottomTrailing
                            )
                        
                        Text(structure.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: geometry.size.width - 116) // Account for smaller buttons (42*2) and spacing (16*2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.93))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
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
                    )
                    .shadow(
                        color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.25),
                        radius: 4,
                        x: 0,
                        y: 4
                    )
                }
                
                // Next button
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 42, height: 42)
                        .glassButton()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height)
        }
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
    
    // Add computed property for container offset
    private var containerOffset: CGFloat {
        UIScreen.main.bounds.height * 0.10  // 10% offset for bottom alignment
    }
    
    init(isSatelliteView: Binding<Bool>,
         hideNumbers: Binding<Bool>,
         isFullScreen: Binding<Bool>,
         @ViewBuilder content: () -> Content) {
        self._isSatelliteView = isSatelliteView
        self._hideNumbers = hideNumbers
        self._isFullScreen = isFullScreen
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { containerGeometry in
            VStack(spacing: 0) {
                // Map content in scrollable container
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    content
                        .frame(
                            width: containerGeometry.size.width,
                            height: containerGeometry.size.height - 44 // Subtract toolbar height
                        )
                        .offset(y: -containerOffset) // Add offset here
                }
                .clipped() // Ensure content stays within bounds
                
                // Redesigned toolbar
                HStack {
                    // Map type picker with numbers toggle
                    HStack(spacing: 8) {
                        // Map type picker
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
                        
                        // Numbers toggle button
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
                    
                    // Fullscreen button
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
        .frame(height: UIScreen.main.bounds.height * 0.7)
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
                currentWalkthroughMapPoint: currentWalkthroughMapPoint
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
            
            // Simpler glass circle button
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
                //updateCurrentMapPoint()  

        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if !appState.adventureModeEnabled {
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
                        .overlay(virtualTourInactiveContent)
                }
            } else {
                // Adventure mode content
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
                    .overlay(Text("Adventure Mode"))
            }
        }
    }
}
