/*
 MapComponents provides the supporting UI elements for the map interface. It includes the virtual tour 
 navigation bar, structure visit notifications, nearby structure overlays, and achievement popups. These 
 components adapt to the current theme and provide consistent interaction patterns across the map experience.
*/

import SwiftUI

// MARK: - Virtual Tour Navigation
struct VirtualWalkThroughBar: View {
    @EnvironmentObject var appState: AppState
    
    let structure: Structure
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 25)
                    .fill(appState.isDarkMode ? Color.black : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                
                // Navigation controls
                HStack(spacing: 0) {
                    arrowButton(direction: .previous)
                    
                    Spacer()
                    
                    structureInfo
                    
                    Spacer()
                    
                    arrowButton(direction: .next)
                }
                .padding(.horizontal, 15)
            }
            .frame(width: geometry.size.width, height: 120)
        }
        .frame(height: 120)
        .padding(.bottom, 10)
    }
    
    // Structure preview with title
    private var structureInfo: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Structure thumbnail
                Image(structure.images[0])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Structure details
                VStack(alignment: .leading, spacing: 5) {
                    Text("#\(structure.number)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                    
                    Text(structure.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
    
    // Navigation arrow button
    private func arrowButton(direction: ArrowDirection) -> some View {
        Button(action: direction == .next ? onNext : onPrevious) {
            Image(systemName: direction == .next ? "chevron.right" : "chevron.left")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .frame(width: 40, height: 40)
                .background(appState.isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    private enum ArrowDirection {
        case next, previous
    }
}

struct MapControlButtons: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    @Binding var isSatelliteView: Bool
    @Binding var isVirtualWalkthroughActive: Bool
    @Binding var showNearbyUnvisitedView: Bool
    
    let onUpdateMapPoint: () -> Void
    
    var body: some View {
        HStack {
            // Left side buttons
            HStack(spacing: 10) {
                // Adventure mode controls
                if appState.adventureModeEnabled && locationService.isInPolyCanyonArea {
                    Button(action: {
                        withAnimation {
                            showNearbyUnvisitedView.toggle()
                        }
                    }) {
                        MapControlButton(
                            systemName: showNearbyUnvisitedView ? "xmark.circle.fill" : "mappin.circle.fill"
                        )
                    }
                }
                
                // Virtual tour controls
                if !appState.adventureModeEnabled {
                    Button(action: {
                        withAnimation {
                            isVirtualWalkthroughActive.toggle()
                            if isVirtualWalkthroughActive {
                                onUpdateMapPoint()
                            }
                        }
                    }) {
                        MapControlButton(
                            systemName: isVirtualWalkthroughActive ? "xmark.circle.fill" : "figure.walk.circle.fill"
                        )
                    }
                }
            }
            Spacer()
            // Right side satellite button
            Button(action: { isSatelliteView.toggle() }) {
                MapControlButton(
                    systemName: isSatelliteView ? "map.fill" : "globe.americas.fill"
                )
            }
        }
        .position(x: UIScreen.main.bounds.width/2, y: 50)
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

struct MapStructureOverlays: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    @Binding var selectedStructure: Structure?
    @Binding var showStructPopup: Bool
    let showNearbyUnvisitedView: Bool
    let nearbyUnvisitedMapPoints: [MapPoint]
    let isVirtualWalkthroughActive: Bool
    let currentStructureIndex: Int
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        ZStack {
            
            // Virtual walkthrough interface
            if isVirtualWalkthroughActive {
                VStack {
                    Spacer()
                    VirtualWalkThroughBar(
                        structure: dataStore.structures[currentStructureIndex],
                        onNext: onNext,
                        onPrevious: onPrevious,
                        onTap: {
                            selectedStructure = dataStore.structures[currentStructureIndex]
                            showStructPopup = true
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    private func mapPointsToStructures(_ mapPoints: [MapPoint]) -> [Structure] {
        mapPoints.compactMap { mp in
            dataStore.structures.first { $0.number == mp.structure }
        }
    }
}

struct MapControlButton: View {
    @EnvironmentObject var appState: AppState
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 24))
            .frame(width: 50, height: 50)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(15)
            .padding()
            .shadow(color: appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8),
                    radius: 5, x: 0, y: 0)
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
                    HStack(spacing: 8) {  // Add spacing between the two controls
                        // Existing map type picker
                        HStack(spacing: 0) {
                            Button(action: { isSatelliteView.toggle() }) {
                                HStack (spacing: 0) {
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
                                .background(Color(white: 0.90))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(appState.isDarkMode ? Color.black : Color(white: 0.90))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
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
                                                .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4),
                                                        radius: 3, x: 0, y: 0)
                                        )
                                }
                            }
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(appState.isDarkMode ? Color.black : Color(white: 0.90))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Fullscreen button
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.3)) { 
                            isFullScreen.toggle() 
                        }
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(appState.isDarkMode ? Color.black : Color(white: 0.90))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(
                    Rectangle()
                        .fill(appState.isDarkMode ? Color.black : Color(white: 0.95))
                        .overlay(Divider(), alignment: .top)
                )
            }
            .background(appState.isDarkMode ? Color.black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.gray.opacity(0.3))
            )
            .shadow(radius: 5)
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
                
                // Fixed bottom bar
                HStack {
                    // Tools button with expanding overlay
                    Button(action: { withAnimation(.spring()) { showTools.toggle() }}) {
                        Image(systemName: showTools ? "xmark" : "gearshape.fill")
                            .font(.system(size: showTools ? 16 : 22, weight: showTools ? .bold : .semibold))
                            .foregroundColor(.black)
                            .frame(width: showTools ? 32 : 44, height: showTools ? 32 : 44)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                    }
                    .overlay(alignment: .top) {
                        if showTools {
                            VStack(spacing: 12) {
                                Button(action: { isSatelliteView.toggle() }) {
                                    Image(systemName: isSatelliteView ? "map.fill" : "globe.americas.fill")
                                }
                                
                                Button(action: { hideNumbers.toggle() }) {
                                    Group {
                                        if hideNumbers {
                                            Image(systemName: "number")
                                        } else {
                                            Text("13").overlay(Line().stroke(.black, lineWidth: 2))
                                        }
                                    }
                                }
                            }
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .frame(width: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                            .offset(y: -90)
                        }
                    }
                    
                    Spacer()
                    
                    // Minimize button
                    Button(action: onClose) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 44, height: 44)
                            .foregroundColor(.black)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
