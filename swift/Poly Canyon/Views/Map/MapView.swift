import SwiftUI
import CoreLocation
import Zoomable

class CirclePositionStore: ObservableObject {
    @Published var circleY: CGFloat? = nil
    @Published var circleX: CGFloat? = nil
    @Published var isDotVisible: Bool = false
}

struct MapView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - View State
    @State private var selectedStructure: Structure?
    @State private var nearbyUnvisitedMapPoints: [MapPoint] = []
    @State private var showVisitedStructurePopup = false
    @State private var showAllVisitedPopup = false
    @State private var showStructPopup = false
    @State private var showNearbyUnvisitedView = false
    @State private var showStructureSwipingView = false
    
    // Holds the current map point for the structure being "walked through" in Virtual mode
    @State private var currentWalkthroughMapPoint: MapPoint?
    
    // Fullscreen toggling
    @State private var isFullScreen: Bool = false
    @State private var opacity: Double = 1.0
    
    // Matched geometry for smooth transitions
    @Namespace private var mapTransition
    
    // Circle position store for controlling map offset
    @StateObject private var circlePositionStore = CirclePositionStore()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if appState.isVirtualWalkthrough {
                    // MARK: - Virtual Tour Layout
                    VirtualTour(geometry: geometry)
                }
                else if isFullScreen {
                    // MARK: - Fullscreen Adventure
                    FullScreenMapView(
                        mapImage: currentMapImage(),
                        geometry: geometry,
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                opacity = 0
                                isFullScreen = false
                            }
                        },
                        circlePositionStore: circlePositionStore
                    )
                    .matchedGeometryEffect(id: "mapContainer", in: mapTransition)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.1)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        )
                    )
                    .opacity(opacity)
                    
                } else {
                    // MARK: - Regular Map Layout (Adventure / Non-fullscreen)
                    VStack(spacing: 12) {
                        MapContainerView(
                            isSatelliteView: Binding(
                                get: { appState.mapIsSatellite },
                                set: { appState.mapIsSatellite = $0 }
                            ),
                            hideNumbers: Binding(
                                get: { !appState.mapShowNumbers },
                                set: { appState.mapShowNumbers = !$0 }
                            ),
                            isFullScreen: $isFullScreen,
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
                        
                        // The shared bottom bar (handles modes, including starting virtual tour)
                        MapBottomBar(currentStructureIndex: $appState.currentStructureIndex)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 5)
                    .padding(.bottom, 12)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 1.1))
                        )
                    )
                    .opacity(opacity)
                }
            }
            .onChange(of: isFullScreen) { _ in
                withAnimation(.easeInOut(duration: 0.6)) {
                    opacity = 1.0
                }
            }
            // Whenever user enters or leaves the canyon
            .onChange(of: locationService.isInPolyCanyonArea) { inCanyon in
                if appState.adventureModeEnabled {
                    appState.configureMapSettings(inCanyon: inCanyon)
                }
            }
            // Whenever user toggles adventure mode
            .onChange(of: appState.adventureModeEnabled) { isEnabled in
                if isEnabled {
                    appState.configureMapSettings(inCanyon: locationService.isInPolyCanyonArea)
                }
            }
            // Whenever the current structure changes, update walk point
            .onChange(of: appState.currentStructureIndex) { _ in
                if appState.isVirtualWalkthrough {
                    let newStructure = dataStore.structures[appState.currentStructureIndex]
                    currentWalkthroughMapPoint = locationService.getMapPointForStructure(newStructure.number)
                } else {
                    currentWalkthroughMapPoint = nil
                }
            }
            .onChange(of: appState.currentStructureIndex) { _ in
                if appState.isVirtualWalkthrough {
                    let newStructure = dataStore.structures[appState.currentStructureIndex]
                    currentWalkthroughMapPoint = locationService.getMapPointForStructure(newStructure.number)
                } else {
                    currentWalkthroughMapPoint = nil
                }
            }
        }
        .onAppear {
            appState.configureMapSettings()
            if appState.adventureModeEnabled {
                appState.configureMapSettings(inCanyon: locationService.isInPolyCanyonArea)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func currentMapImage() -> String {
        let baseImage = appState.mapIsSatellite
            ? "SatelliteMap"
            : (appState.isDarkMode ? "DarkMap" : "LightMap")
        return !appState.mapShowNumbers ? baseImage + "NN" : baseImage
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode
            MapView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode
            MapView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}
