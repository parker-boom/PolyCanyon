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
    @Binding var focusStructure: Int?
    let focusRequest: UUID
    var body: some View {
        GeometryReader { geometry in
            let point = focusStructure.flatMap { locationService.getMapPointForStructure($0) }
            let scale = min(geometry.size.width / 2000, geometry.size.height / 4519)
            let x = (point?.pixelPosition.x ?? 0) * scale * 1.09 + (geometry.size.width - 2000 * scale) / 2
            let y = (point?.pixelPosition.y ?? 0) * scale * 1.09 + (geometry.size.height - 4519 * scale) / 2
            MapWithLocationDot(mapImage: mapImage, geometry: geometry,
                               currentWalkthroughMapPoint: nil, circlePositionStore: position)
                .overlay { MapStructureTargets(size: geometry.size) }
                .overlay(alignment: .topLeading) {
                    if let number = focusStructure, point != nil {
                        Text(String(number)).font(.caption.bold().monospacedDigit())
                            .foregroundStyle(.white).frame(width: 32, height: 32)
                            .background(CanyonStyle.ink, in: Circle())
                            .overlay { Circle().stroke(.white, lineWidth: 3) }
                            .scaleEffect(1 / 2.4).position(x: x, y: y)
                            .allowsHitTesting(false).accessibilityHidden(true)
                    }
                }
                .scaleEffect(point == nil ? 1 : 2.4, anchor: .topLeading)
                .offset(x: point == nil ? 0 : geometry.size.width / 2 - x * 2.4,
                        y: point == nil ? 0 : geometry.size.height / 2 - y * 2.4)
                .zoomable(minZoomScale: 1, doubleTapZoomScale: 2)
                .id(canvasID).clipped()

        }
        .background(Color.white)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if focusStructure != nil {
                ToolbarItem(placement: .principal) {
                    Button("Whole canyon") { focusStructure = nil; canvasID = UUID() }
                        .font(.subheadline.weight(.medium))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Map appearance", selection: $appState.mapIsSatellite) {
                        Text("Illustrated").tag(false)
                        Text("Satellite").tag(true)
                    }
                    Toggle("Structure numbers", isOn: $appState.mapShowNumbers)
                    Button("Show whole canyon") { focusStructure = nil; canvasID = UUID() }
                } label: { Label("Map options", systemImage: "square.3.layers.3d") }
            }
        }
.onChange(of: focusRequest) { _ in canvasID = UUID() }
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
