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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full screen background
                if isSatelliteView {
                    Image("BlurredBG")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Rest of your map content
                ZStack(alignment: .topLeading) {
                    // Base map layers
                    
                    MapWithLocationDot(
                        mapImage: currentMapImage(),
                        isSatelliteView: isSatelliteView,
                        geometry: geometry,
                        isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                        currentStructureIndex: currentStructureIndex,
                        currentWalkthroughMapPoint: currentWalkthroughMapPoint,
                        scale: scale,
                        offset: offset
                    )
                    .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)
                    
                    
                    // Map controls
                    MapControlButtons(
                        isSatelliteView: $isSatelliteView,
                        isVirtualWalkthroughActive: $isVirtualWalkthroughActive,
                        showNearbyUnvisitedView: $showNearbyUnvisitedView,
                        onUpdateMapPoint: updateCurrentMapPoint
                    )
                    
                    // Status messages
                    if appState.adventureModeEnabled {
                        MapStatusOverlay(geometry: geometry)
                    }
                    
                    // Structure overlays
                    MapStructureOverlays(
                        selectedStructure: $selectedStructure,
                        showStructPopup: $showStructPopup,
                        showNearbyUnvisitedView: showNearbyUnvisitedView,
                        nearbyUnvisitedMapPoints: nearbyUnvisitedMapPoints,
                        isVirtualWalkthroughActive: isVirtualWalkthroughActive,
                        currentStructureIndex: currentStructureIndex,
                        onNext: moveToNextStructure,
                        onPrevious: moveToPreviousStructure
                    )
                }
            }
            .onAppear(perform: handleOnAppear)
            .sheet(isPresented: $showStructureSwipingView) {
                StructureSwipingView()
            }
            .onChange(of: dataStore.lastVisitedStructure) { _ in
                if dataStore.lastVisitedStructure != nil {
                    showVisitedStructurePopup = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func currentMapImage() -> String {
        isSatelliteView ? "SatelliteMap" : (appState.isDarkMode ? "DarkMap" : "LightMap")
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
                .environmentObject(AppState())
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
