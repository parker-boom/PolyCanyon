import SwiftUI
import Zoomable

@MainActor
final class CirclePositionStore: ObservableObject {
    @Published var circleY: CGFloat?
    @Published var circleX: CGFloat?
    @Published var isDotVisible = false
}
struct MapView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @StateObject private var position = CirclePositionStore()
    @State private var canvasID = UUID()
    var body: some View {
        GeometryReader { geometry in
            MapWithLocationDot(mapImage: mapImage, geometry: geometry,
                               currentWalkthroughMapPoint: nil, circlePositionStore: position)
                .overlay { MapStructureTargets(size: geometry.size) }
                .zoomable(minZoomScale: 1, doubleTapZoomScale: 2)
                .id(canvasID).clipped()

        }
        .background(Color.white)
        .navigationTitle("Poly Canyon").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { appState.isVirtualWalkthrough = true } label: { Label("Tour", systemImage: "play.fill") }
                    .accessibilityLabel("Take a walkthrough")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Map appearance", selection: $appState.mapIsSatellite) {
                        Text("Illustrated").tag(false)
                        Text("Satellite").tag(true)
                    }
                    Toggle("Structure numbers", isOn: $appState.mapShowNumbers)
                    Button("Reset zoom") { canvasID = UUID() }
                } label: { Label("Map options", systemImage: "square.3.layers.3d") }
            }
        }
        .fullScreenCover(isPresented: $appState.isVirtualWalkthrough) {
            NavigationStack { VirtualWalkthrough() }
        }
        .onAppear { appState.configureMapSettings() }
        .onChange(of: locationService.isInPolyCanyonArea) { nearby in
            if appState.adventureModeEnabled { appState.configureMapSettings(inCanyon: nearby) }
        }
    }
    private var mapImage: String {
        (appState.mapIsSatellite ? "SatelliteMap" : "LightMap") + (appState.mapShowNumbers ? "" : "NN")
    }
}
/// Uses the renderer's existing calibration; never changes discovery coordinates.
struct MapStructureTargets: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    let size: CGSize
    var body: some View {
        let scale = min(size.width / 2000, size.height / 4519)
        let offset = CGSize(width: (size.width - 2000 * scale) / 2, height: (size.height - 4519 * scale) / 2)
        ZStack {
            ForEach(dataStore.structures) { structure in
                if let point = locationService.getMapPointForStructure(structure.number) {
                    Button {
                        appState.structInfoNum = structure.number
                        appState.activeFullScreenView = .structInfo
                    } label: { Color.clear.frame(width: 44, height: 44).contentShape(Rectangle()) }
                    .accessibilityLabel("\(structure.number), \(structure.title)\(structure.isVisited ? ", visited" : "")")
                    .position(x: point.pixelPosition.x * scale * 1.09 + offset.width,
                              y: point.pixelPosition.y * scale * 1.09 + offset.height)
                }
            }
        }
    }
}
