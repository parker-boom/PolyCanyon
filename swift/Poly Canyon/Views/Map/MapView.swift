/*
 MapView provides the primary map interface for structure exploration. It handles two distinct modes: 
 adventure mode with live location tracking and virtual tour mode for remote browsing. The view manages 
 multiple overlays including structure popups, alerts, and mode-specific UI elements. It coordinates with 
 LocationService for tracking and DataStore for structure management.
*/

import SwiftUI
import CoreLocation
import Zoomable

struct MapView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - Persistent State
    @AppStorage("virtualTourCurrentStructure") private var currentStructureIndex: Int = 0
    
    // MARK: - View State
    @State private var selectedStructure: Structure?
    @State private var nearbyUnvisitedMapPoints: [MapPoint] = []
    @State private var showVisitedStructurePopup = false
    @State private var showAllVisitedPopup = false
    @State private var showStructPopup = false
    @State private var showNearbyUnvisitedView = false
    @State private var showStructureSwipingView = false
    @State private var isSatelliteView: Bool = false
    @State private var isVirtualWalkthroughActive: Bool = false
    @State private var currentWalkthroughMapPoint: MapPoint?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var hideNumbers: Bool = false
    @State private var isFullScreen: Bool = false
    @State private var opacity: Double = 1.0
    @Namespace private var mapTransition
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isFullScreen {
                    FullScreenMapView(
                        hideNumbers: $hideNumbers,
                        isSatelliteView: $isSatelliteView,
                        mapImage: currentMapImage(),
                        geometry: geometry,
                        isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                        currentStructureIndex: currentStructureIndex,
                        currentWalkthroughMapPoint: currentWalkthroughMapPoint,
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.6)) { 
                                opacity = 0
                                isFullScreen = false 
                            }
                        }
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
                    // Regular container view
                    VStack(spacing: 12) {
                        MapContainerView(
                            isSatelliteView: $isSatelliteView,
                            hideNumbers: $hideNumbers,
                            isFullScreen: $isFullScreen
                        ) {
                            MapWithLocationDot(
                                mapImage: currentMapImage(),
                                isSatelliteView: isSatelliteView,
                                geometry: geometry,
                                isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                                currentStructureIndex: currentStructureIndex,
                                currentWalkthroughMapPoint: currentWalkthroughMapPoint
                            )
                            .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)
                            .matchedGeometryEffect(id: "mapContainer", in: mapTransition)
                        }

                        MapBottomBar(
                            isVirtualWalkthroughActive: $isVirtualWalkthroughActive,
                            currentStructureIndex: $currentStructureIndex
                        )
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
            .onChange(of: isFullScreen) { newValue in
                withAnimation(.easeInOut(duration: 0.6)) {
                    opacity = 1.0
                }
            }
            .onChange(of: isVirtualWalkthroughActive) { isActive in
                if isActive {
                    updateCurrentMapPoint()
                }
            }
            .onChange(of: currentStructureIndex) { _ in
                if isVirtualWalkthroughActive {
                    updateCurrentMapPoint()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func currentMapImage() -> String {
        let baseImage = isSatelliteView ? "SatelliteMap" : (appState.isDarkMode ? "DarkMap" : "LightMap")
        return hideNumbers ? baseImage + "NN" : baseImage
    }
    
    private func handleOnAppear() {
        if appState.adventureModeEnabled && !appState.hasShownBackgroundLocationAlert {
            appState.showAlert(.backgroundLocation)
        } 
    }
    
    private func updateCurrentMapPoint() {
        let currentStructure = dataStore.structures[currentStructureIndex]
        currentWalkthroughMapPoint = locationService.getMapPointForStructure(currentStructure.number)
    }
    
    private func moveToNextStructure() {
        currentStructureIndex = (currentStructureIndex + 1) % dataStore.structures.count
        updateCurrentMapPoint()
    }
    
    private func moveToPreviousStructure() {
        currentStructureIndex = (currentStructureIndex - 1 + dataStore.structures.count) % dataStore.structures.count
        updateCurrentMapPoint()
    }
    
}

// MARK: - Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            MapView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode Preview
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
