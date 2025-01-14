/*
 MapView provides the primary map interface for structure exploration. It handles two distinct modes: 
 adventure mode with live location tracking and virtual tour mode for remote browsing. The view manages 
 multiple overlays including structure popups, alerts, and mode-specific UI elements. It coordinates with 
 LocationService for tracking and DataStore for structure management.
*/

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
    @State private var currentWalkthroughMapPoint: MapPoint?
    @State private var isFullScreen: Bool = false
    @State private var opacity: Double = 1.0
    @Namespace private var mapTransition
    
    // ADDED: Circle position store
    @StateObject private var circlePositionStore = CirclePositionStore()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isFullScreen {
                    FullScreenMapView(
                        mapImage: currentMapImage(),
                        geometry: geometry,
                        currentStructureIndex: appState.currentStructureIndex,
                        currentWalkthroughMapPoint: currentWalkthroughMapPoint,
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
                    // Regular container view
                    VStack(spacing: 12) {
                        // PASS circlePositionStore into MapContainerView
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
                            circlePositionStore: circlePositionStore  // ADDED
                        ) {
                            // PASS circlePositionStore into MapWithLocationDot
                            MapWithLocationDot(
                                mapImage: currentMapImage(),
                                geometry: geometry,
                                currentWalkthroughMapPoint: currentWalkthroughMapPoint,
                                circlePositionStore: circlePositionStore
                            )
                            .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)
                            .matchedGeometryEffect(id: "mapContainer", in: mapTransition)
                        }

                        MapBottomBar(
                            currentStructureIndex: $appState.currentStructureIndex
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
            .onChange(of: locationService.isInPolyCanyonArea) { inCanyon in
                if appState.adventureModeEnabled {
                    appState.configureMapSettings(inCanyon: inCanyon)
                }
            }
            .onChange(of: appState.adventureModeEnabled) { isEnabled in
                if isEnabled {
                    appState.configureMapSettings(inCanyon: locationService.isInPolyCanyonArea)
                }
            }
        }
        .onAppear {
            appState.configureMapSettings()
        }
        .onChange(of: locationService.isInPolyCanyonArea) { inCanyon in
            if appState.adventureModeEnabled {
                appState.configureMapSettings(inCanyon: inCanyon)
            }
        }
        .onChange(of: appState.adventureModeEnabled) { isEnabled in
            if isEnabled {
                appState.configureMapSettings(inCanyon: locationService.isInPolyCanyonArea)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func currentMapImage() -> String {
        let baseImage = appState.mapIsSatellite ? "SatelliteMap" : 
            (appState.isDarkMode ? "DarkMap" : "LightMap")
        return !appState.mapShowNumbers ? baseImage + "NN" : baseImage
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
