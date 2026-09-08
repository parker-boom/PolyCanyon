import SwiftUI

// Each isolated candidate selects a different working composition at build time.
enum CanyonEdition { case fieldGuide, ramble, archive
    static let selected: CanyonEdition = .fieldGuide
}

enum FieldPalette {
    static let green = CanyonStyle.ink
    static let gold = Color(red: 0.62, green: 0.43, blue: 0.12)
    static let wash = Color(red: 0.98, green: 0.97, blue: 0.94)
}

struct VirtualWalkthrough: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var overview = true
    @State private var story = false
    @Namespace private var photos
    var showOnMap: (Int) -> Void = { _ in }
    private var index: Int { min(max(0, appState.currentStructureIndex), max(0, dataStore.structures.count - 1)) }
    private var structure: Structure? { dataStore.structures.indices.contains(index) ? dataStore.structures[index] : nil }
    private var movement: Animation? { reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.92) }

    var body: some View {
        Group {
            if let structure {
                switch CanyonEdition.selected {
                case .fieldGuide: fieldGuide(structure)
                case .ramble: ramble(structure)
                case .archive: archive(structure)
                }
            }
        }
        .background(FieldPalette.wash)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $story) {
            if let structure {
                NavigationStack {
                    StructureStory(structure: structure)
                        .modifier(StructureZoomDestination(id: structure.number, namespace: photos))
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { story = false } } }
                }.tint(FieldPalette.green)
            }
        }
        .onAppear { appState.currentStructureIndex = index }
    }

    private func fieldGuide(_ item: Structure) -> some View {
        VStack(spacing: 0) {
            SpatialAtlas(selected: item.number, overview: overview, select: select)
                .overlay(alignment: .topTrailing) { overviewControl.padding(14) }
            inspector(item).padding(18).background(.white)
            navigation.padding(.horizontal, 18).padding(.bottom, 12).background(.white)
        }
    }

    private func ramble(_ item: Structure) -> some View {
        VStack(spacing: 0) {
            ScrollViewReader { reader in
                ScrollView {
                    SpatialAtlas(selected: item.number, overview: true, scrollAnchors: true, select: select)
                        .frame(height: 1550)
                }
                .onAppear { reader.scrollTo(item.number, anchor: .center) }
                .onChange(of: item.number) { number in
                    withAnimation(movement) { reader.scrollTo(number, anchor: .center) }
                }
            }
            if typeSize.isAccessibilitySize {
                inspector(item).padding(18)
            } else {
                TabView(selection: $appState.currentStructureIndex) {
                    ForEach(dataStore.structures.indices, id: \.self) { position in
                        inspector(dataStore.structures[position]).padding(18).tag(position)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never)).frame(height: 130)
            }
            navigation.padding(.horizontal, 18).padding(.bottom, 12)
        }.background(.white)
    }

    private func archive(_ item: Structure) -> some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                SpatialAtlas(selected: item.number, overview: false, select: select)
                    .overlay(alignment: .bottom) {
                        if !typeSize.isAccessibilitySize {
                            Button { story = true } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(item.images.first ?? "M-1").resizable().scaledToFill()
                                        .frame(width: 210, height: min(135, geometry.size.height * 0.24)).clipped()
                                        .modifier(StructureZoomSource(id: item.number, namespace: photos))
                                    Text(item.title).font(.headline).foregroundStyle(FieldPalette.green)
                                    Text(item.year).font(.caption.monospaced()).foregroundStyle(FieldPalette.gold)
                                }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 12))
                                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(FieldPalette.gold.opacity(0.4), lineWidth: 1) }
                                    .shadow(color: .black.opacity(0.1), radius: 10, y: 3)
                            }.buttonStyle(.plain).padding(16).accessibilityLabel("Read \(item.title), \(item.year)")
                        }
                    }
            }
            if typeSize.isAccessibilitySize { inspector(item).padding(18) }
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dataStore.structures, id: \.number) { stop in
                            Button { select(stop.number) } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(stop.title).font(.callout.weight(.medium))
                                    Rectangle().fill(stop.number == item.number ? FieldPalette.gold : .clear).frame(height: 3)
                                }.fixedSize().padding(.horizontal, 10).padding(.top, 10)
                            }.id(stop.number).buttonStyle(.plain).foregroundStyle(FieldPalette.green)
                                .accessibilityAddTraits(stop.number == item.number ? .isSelected : [])
                        }
                    }.padding(.horizontal, 12)
                }.onChange(of: item.number) { number in withAnimation(movement) { reader.scrollTo(number, anchor: .center) } }
            }
            navigation.padding(.horizontal, 18).padding(.vertical, 12)
        }
    }

    private func inspector(_ item: Structure) -> some View {
        Button { story = true } label: {
            HStack(alignment: .center, spacing: 16) {
                if !typeSize.isAccessibilitySize {
                    Image(item.images.first ?? "M-1").resizable().scaledToFill().frame(width: 88, height: 84).clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .modifier(StructureZoomSource(id: item.number, namespace: photos))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title).font(.title2.weight(.medium)).foregroundStyle(FieldPalette.green)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(item.year) · Photos & story").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }.frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
        }.buttonStyle(.plain).accessibilityLabel("Read the story of \(item.title)")
    }

    private var overviewControl: some View {
        Button { withAnimation(movement) { overview.toggle() } } label: {
            Image(systemName: overview ? "scope" : "arrow.up.left.and.arrow.down.right")
                .font(.body.weight(.medium)).frame(width: 46, height: 46)
        }.canyonControl().foregroundStyle(FieldPalette.green)
            .accessibilityLabel(overview ? "Focus selected structure" : "Show whole canyon")
    }

    private var navigation: some View {
        HStack {
            Button { step(-1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                .accessibilityLabel("Previous place")
            Spacer()
            Menu {
                ForEach(dataStore.structures, id: \.number) { item in
                    Button(item.title) { select(item.number) }
                }
            } label: { Image(systemName: "list.bullet").frame(width: 44, height: 44) }
                .accessibilityLabel("Choose a structure")
            Spacer()
            Button("Next place") { step(1) }.font(.callout.weight(.semibold)).frame(minHeight: 44)
        }.foregroundStyle(FieldPalette.green)
    }
    private func step(_ delta: Int) {
        guard !dataStore.structures.isEmpty else { return }
        withAnimation(movement) { appState.currentStructureIndex = (index + delta + dataStore.structures.count) % dataStore.structures.count; overview = false }
    }
    private func select(_ number: Int) {
        guard let position = dataStore.structures.firstIndex(where: { $0.number == number }) else { return }
        withAnimation(movement) { appState.currentStructureIndex = position; overview = false }
    }
}

/// Uses the original map and calibrated points. No suggested walking route is invented.
struct SpatialAtlas: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let selected: Int
    let overview: Bool
    var scrollAnchors = false
    var select: (Int) -> Void = { _ in }
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let scale: CGFloat = overview ? min(size.width / 2000.0, size.height / 4519.0) * 0.93 : size.width / 2000.0 * 1.4
            let focus = locationService.getMapPointForStructure(selected)?.pixelPosition ?? CGPoint(x: 1000, y: 2200)
            let focusedX: CGFloat = size.width / 2.0 - focus.x * (1.09 * scale)
            let focusedY: CGFloat = size.height * 0.40 - focus.y * (1.09 * scale)
            let originX: CGFloat = overview ? (size.width - 2000.0 * scale) / 2.0 : focusedX
            let originY: CGFloat = overview ? (size.height - 4519.0 * scale) / 2.0 : focusedY
            let origin = CGPoint(x: originX, y: originY)
            ZStack(alignment: .topLeading) {
                FieldPalette.wash
                Image("LightMapNN").resizable().frame(width: 2000 * scale, height: 4519 * scale)
                    .offset(x: origin.x, y: origin.y).accessibilityHidden(true)
                ForEach(dataStore.structures, id: \.number) { item in
                    if let point = locationService.getMapPointForStructure(item.number)?.pixelPosition {
                        Button { select(item.number) } label: {
                            Text(String(item.number)).font(.system(size: item.number == selected ? 16 : 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(item.number == selected ? .white : FieldPalette.green)
                                .frame(width: item.number == selected ? 36 : 23, height: item.number == selected ? 36 : 23)
                                .background(item.number == selected ? FieldPalette.green : .white, in: Circle())
                                .overlay { Circle().stroke(FieldPalette.gold, lineWidth: item.number == selected ? 3 : 1) }
                                .frame(width: 44, height: 44)
                        }.buttonStyle(.plain)
                            .accessibilityLabel("\(item.title), map number \(item.number)")
                            .accessibilityAddTraits(item.number == selected ? .isSelected : [])
                            .id(item.number)
                            .position(x: origin.x + point.x * 1.09 * scale, y: origin.y + point.y * 1.09 * scale)
                    }
                }
            }.clipped()
                .animation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.92), value: selected)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: overview)
        }
    }
}
