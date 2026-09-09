import SwiftUI
import UIKit

@MainActor
final class CirclePositionStore: ObservableObject {
    @Published var circleY: CGFloat?
    @Published var circleX: CGFloat?
    @Published var isDotVisible = false
}
struct MapView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject private var dataStore: DataStore
    @StateObject private var position = CirclePositionStore()
    @State private var canvasID = UUID()
    @State private var locationFocus: CGPoint?
    @State private var locationMessage = false
    @State private var isMapZoomed = false
    var onInfo: () -> Void = {}
    @Binding var focusStructure: Int?
    let focusRequest: UUID
    var body: some View {
        GeometryReader { geometry in
            let point = locationFocus ?? focusStructure.flatMap { locationService.getMapPointForStructure($0)?.pixelPosition }
            let layout = CanyonMapGeometry(size: geometry.size)
            CanyonMapViewport(request: canvasID, focus: point.map(layout.position), zoomChanged: { zoomed in
                if isMapZoomed != zoomed { isMapZoomed = zoomed }
            }, select: { tap in
                let candidates = dataStore.structures.compactMap { item -> (Int, CGFloat)? in
                    guard let point = locationService.getMapPointForStructure(item.number)?.pixelPosition else { return nil }
                    let position = layout.position(point)
                    return (item.number, hypot(position.x - tap.x, position.y - tap.y))
                }
                if let closest = candidates.min(by: { $0.1 < $1.1 }), closest.1 <= 22 {
                    appState.structInfoNum = closest.0
                    appState.activeFullScreenView = .structInfo
                }
            }) {
                MapWithLocationDot(mapImage: mapImage, geometry: geometry,
                                   currentWalkthroughMapPoint: nil, circlePositionStore: position)
                    .overlay { MapStructureTargets(size: geometry.size).allowsHitTesting(false) }
                    .environmentObject(appState).environmentObject(locationService)
            }.clipped()


        }
        .background(Color.white)
        .modifier(MapBackgroundExtension())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            HStack(alignment: .top) {
                if appState.exploresInPerson {
                Button(action: onInfo) { Image(systemName: "info.circle").frame(width: 48, height: 48).canyonControl() }
                    .accessibilityLabel("Location and visits")
                }
                Spacer()
                VStack(spacing: 12) {
                    Menu {
                        Picker("Map appearance", selection: $appState.mapIsSatellite) {
                            Text("Illustrated map").tag(false)
                            Text("Satellite imagery").tag(true)
                        }
                        Toggle("Show map numbers", isOn: $appState.mapShowNumbers)
                    } label: { Image(systemName: "square.3.layers.3d").frame(width: 48, height: 48).canyonControl() }
                        .accessibilityLabel("Map options")
                    if isMapZoomed {
                    Button(action: reset) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right").frame(width: 48, height: 48).canyonControl()
                    }.accessibilityLabel("Fit map").accessibilityHint("Zoom out to show the entire map")
                    }
                    if appState.exploresInPerson {
                    Button {
                        if let fix = locationService.lastLocation,
                           locationService.hasLocationPermission,
                           LocationSamplePolicy.isUsable(fix, now: Date()),
                           locationService.isWithinCanyon(fix),
                           let point = locationService.findNearestMapPoint(to: fix.coordinate) {
                            focusStructure = nil
                            locationFocus = point.pixelPosition
                            canvasID = UUID()
                        } else { locationMessage = true }
                    } label: { Image(systemName: "location").frame(width: 48, height: 48).canyonControl() }
                        .accessibilityLabel("Center on my location")
                        .disabled(!locationService.canUseLocation)
                    }
                }
            }.padding(16)
        }
        .alert("Your position isn’t available on this map", isPresented: $locationMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You’ll need a current location in Poly Canyon. You can still explore every structure on the map.")
        }
        .onChange(of: focusRequest) { _ in locationFocus = nil; canvasID = UUID() }
        .onAppear { appState.configureMapSettings() }
        .onChange(of: locationService.isInPolyCanyonArea) { nearby in
            if appState.exploresInPerson { appState.configureMapSettings(inCanyon: nearby) }
        }
    }
    private func reset() { focusStructure = nil; locationFocus = nil; canvasID = UUID() }
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
        let layout = CanyonMapGeometry(size: size)
        ZStack {
            ForEach(dataStore.structures) { structure in
                if let point = locationService.getMapPointForStructure(structure.number) {
                    Button {
                        appState.structInfoNum = structure.number
                        appState.activeFullScreenView = .structInfo
                    } label: { Color.clear.frame(width: 44, height: 44).contentShape(Rectangle()) }
                    .accessibilityLabel("\(structure.number), \(structure.title)\(appState.exploresInPerson && structure.isVisited ? ", visited" : "")")
                    .position(layout.position(point.pixelPosition))
                }
            }
        }
    }
}

/// Extend only the background under glass; fitting the interactive canvas into
/// the safe area keeps Entry Arch reachable above the floating tab bar.
private struct MapBackgroundExtension: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) { content.backgroundExtensionEffect() }
        else { content }
    }
}
