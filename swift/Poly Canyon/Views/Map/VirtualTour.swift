import SwiftUI
import Zoomable
import Glur

struct VirtualWalkthrough: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @StateObject private var position = CirclePositionStore()
    @State private var story = false
    private var structure: Structure? {
        dataStore.structures.indices.contains(appState.currentStructureIndex)
            ? dataStore.structures[appState.currentStructureIndex] : dataStore.structures.first
    }
    var body: some View {
        Group {
            if let structure {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 0) {
                            ZStack(alignment: .bottomLeading) {
                                Image(structure.images.first ?? "M-1").resizable().scaledToFill()
                                    .frame(width: geometry.size.width, height: max(320, geometry.size.height * 0.52))
                                    .glur(radius: reduceTransparency ? 0 : 6, offset: 0.7, interpolation: 0.3)
                                    .clipped()
                                LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .center, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(structure.number) / \(dataStore.structures.count)").font(.subheadline.monospacedDigit())
                                    Text(structure.title).font(.largeTitle.weight(.semibold))

                                }.foregroundStyle(.white).padding(24)
                            }.accessibilityElement(children: .combine)
                            GeometryReader { map in
                                let point = locationService.getMapPointForStructure(structure.number)
                                let scale = min(map.size.width / 2000, map.size.height / 4519)
                                let x = (point?.pixelPosition.x ?? 1000) * scale * 1.09 + (map.size.width - 2000 * scale) / 2
                                let y = (point?.pixelPosition.y ?? 2200) * scale * 1.09 + (map.size.height - 4519 * scale) / 2
                                MapWithLocationDot(mapImage: "LightMap", geometry: map,
                                    currentWalkthroughMapPoint: point, markerScale: 1 / 2.4, circlePositionStore: position)
                                    .scaleEffect(2.4, anchor: .topLeading)
                                    .offset(x: map.size.width / 2 - x * 2.4, y: map.size.height / 2 - y * 2.4)
                                    .frame(width: map.size.width, height: map.size.height)
                                    .zoomable(minZoomScale: 1, doubleTapZoomScale: 2)
                                    .id(structure.number)

                            }
                            .frame(height: max(260, geometry.size.height * 0.48)).clipped()
                            .accessibilityLabel("Map showing \(structure.title)")
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: 12) {
                        Button { move(-1) } label: { Image(systemName: "chevron.left").frame(width: 48, height: 48) }
                            .accessibilityLabel("Previous structure").canyonControl()
                        Button("Explore this structure") { story = true }
                            .font(.headline).frame(maxWidth: .infinity, minHeight: 48).canyonControl()
                        Button { move(1) } label: { Image(systemName: "chevron.right").frame(width: 48, height: 48) }
                            .accessibilityLabel("Next structure").canyonControl()
                    }.padding(.horizontal, 16).padding(.vertical, 8)
                }
                .sheet(isPresented: $story) {
                    NavigationStack {
                        StructureStory(structure: structure)
                            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { story = false } } }
                    }
                }
            } else { Text("No structures are available.") }
        }
        .background(CanyonStyle.paper)
        .navigationTitle("Walkthrough").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { appState.isVirtualWalkthrough = false } } }
        .onAppear {
            if !dataStore.structures.indices.contains(appState.currentStructureIndex) { appState.currentStructureIndex = 0 }
        }
    }
    private func move(_ offset: Int) {
        guard !dataStore.structures.isEmpty else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            appState.currentStructureIndex = (appState.currentStructureIndex + offset + dataStore.structures.count) % dataStore.structures.count
        }
    }
}
struct RoundedCorner2: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
             cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
