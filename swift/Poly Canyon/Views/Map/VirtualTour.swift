import SwiftUI

/// A photographic journey tied to the original map's calibrated positions.
struct VirtualWalkthrough: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var story = false
    @State private var usePhotoTransition = false
    @Namespace private var photos
    var showOnMap: (Int) -> Void = { _ in }
    private var structure: Structure? {
        dataStore.structures.indices.contains(appState.currentStructureIndex)
            ? dataStore.structures[appState.currentStructureIndex] : dataStore.structures.first
    }
    var body: some View {
        GeometryReader { geometry in
            if let structure {
                ScrollView {
                    VStack(spacing: 0) {
                        photograph(width: geometry.size.width, height: photoHeight(available: geometry.size.height))
                        heading(structure)
                        Button { showOnMap(structure.number) } label: {
                            TourMapCanvas(number: structure.number)
                                .frame(height: 160)
                                .overlay(alignment: .bottomTrailing) {
                                    Label("Canyon map", systemImage: "map")
                                        .font(.caption.weight(.semibold)).padding(10)
                                        .background(.white, in: Capsule()).padding(12)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Show \(structure.title) on the canyon map")
                    }
                }
                .scrollIndicators(.hidden)
                .sheet(isPresented: $story) {
                    NavigationStack {
                        StructureStory(structure: structure)
                            .modifier(StructureZoomDestination(id: structure.number, namespace: photos, isEnabled: usePhotoTransition))
                            .toolbar { ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { story = false }
                            } }
                    }.tint(CanyonStyle.ink)
                }
            }
        }
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !dataStore.structures.indices.contains(appState.currentStructureIndex) { appState.currentStructureIndex = 0 }
        }
    }
    private func photoHeight(available: CGFloat) -> CGFloat {
        if typeSize.isAccessibilitySize { return max(180, available * 0.38) }
        // Leave room for the title, controls, and locator on compact phones.
        return max(220, min(available * 0.60, available - 300))
    }
    private func photograph(width: CGFloat, height: CGFloat) -> some View {
        TabView(selection: $appState.currentStructureIndex) {
            ForEach(dataStore.structures.indices, id: \.self) { index in
                let item = dataStore.structures[index]
                Button { usePhotoTransition = true; story = true } label: {
                    Image(item.images.first ?? "M-1")
                        .resizable().scaledToFill().frame(width: width, height: height).clipped()
                        .modifier(StructureZoomSource(id: item.number, namespace: photos))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Explore \(item.title)")
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: width, height: height)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: appState.currentStructureIndex)
    }
    private func heading(_ structure: Structure) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("\(appState.currentStructureIndex + 1) / \(dataStore.structures.count)")
                    .font(.caption.monospaced().weight(.medium)).tracking(1).foregroundStyle(.secondary)
                Spacer(minLength: 8)
                Button { move(-1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                    .accessibilityLabel("Previous structure")
                Button { move(1) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                    .accessibilityLabel("Next structure")
            }
            Button { usePhotoTransition = false; story = true } label: {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(structure.title).font(typeSize.isAccessibilitySize ? .title2 : .largeTitle).fontWeight(.medium)
                        .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").font(.body.weight(.medium)).foregroundStyle(.secondary)
                }.foregroundStyle(CanyonStyle.ink)
            }.buttonStyle(.plain).accessibilityLabel("Read the story of \(structure.title)")
        }.padding(.horizontal, 22).padding(.top, 6).padding(.bottom, 24)
    }
    private func move(_ offset: Int) {
        guard !dataStore.structures.isEmpty else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.45)) {
            appState.currentStructureIndex = (appState.currentStructureIndex + offset + dataStore.structures.count) % dataStore.structures.count
        }
    }
}

/// The camera moves over one continuous map; no route or walking directions are invented.
struct TourMapCanvas: View {
    @EnvironmentObject private var locationService: LocationService
    let number: Int
    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width * 0.9 / 2000
            let point = locationService.getMapPointForStructure(number)?.pixelPosition
            let x = (point?.x ?? 1000) * 1.09 * scale
            let y = (point?.y ?? 2200) * 1.09 * scale
            ZStack(alignment: .topLeading) {
                Color.white
                Image("LightMapNN").resizable()
                    .frame(width: 2000 * scale, height: 4519 * scale)
                    .offset(x: geometry.size.width / 2 - x, y: geometry.size.height / 2 - y)
                Text(String(number)).font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white).frame(width: 30, height: 30)
                    .background(CanyonStyle.ink, in: Circle())
                    .overlay { Circle().stroke(.white, lineWidth: 3) }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }.clipped()
        }.clipped().accessibilityElement(children: .ignore).accessibilityLabel("Map position of structure \(number)")
    }
}
