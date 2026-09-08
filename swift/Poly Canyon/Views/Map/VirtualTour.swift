import SwiftUI
import UIKit

// Each isolated candidate selects a different working composition at build time.
enum CanyonEdition { case fieldGuide, ramble, archive, remix
    static var selected: CanyonEdition {
        #if DEBUG
        // Launch-only comparison switch; no settings or test controls enter the visitor UI.
        if let value = UserDefaults.standard.string(forKey: "CanyonEdition") {
            if value == "fieldGuide" { return .fieldGuide }
            if value == "ramble" { return .ramble }
            if value == "archive" { return .archive }
        }
        #endif
        return .remix
    }
}

enum FieldPalette {
    static let green = CanyonStyle.ink
    static let gold = Color(red: 0.55, green: 0.36, blue: 0.08)
    static let wash = Color(red: 0.98, green: 0.97, blue: 0.94)
}

struct VirtualWalkthrough: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title2) private var cardHeight = 130.0
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
                if typeSize.isAccessibilitySize {
                    ScrollView {
                        SpatialAtlas(selected: structure.number, overview: false, showAllMarkers: false, select: select).frame(height: 230)
                        inspector(structure).padding(20)
                        navigation.padding(.horizontal, 20)
                    }
                } else {
                    switch CanyonEdition.selected {
                    case .fieldGuide: fieldGuide(structure)
                    case .ramble, .remix: ramble(structure)
                    case .archive: archive(structure)
                    }
                }
            }
        }
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $story) {
            if let structure {
                NavigationStack {
                    StructureStory(structure: structure)
                        .modifier(StructureZoomDestination(id: structure.number, namespace: photos, isEnabled: !typeSize.isAccessibilitySize))
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
            CanyonMapScroll(selected: item.number, showAllMarkers: CanyonEdition.selected != .remix, select: select)
                .clipped()
                .padding(.top, 8)
            if typeSize.isAccessibilitySize {
                inspector(item).padding(18)
            } else {
                TabView(selection: $appState.currentStructureIndex) {
                    ForEach(dataStore.structures.indices, id: \.self) { position in
                        inspector(dataStore.structures[position]).padding(18).tag(position)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never)).frame(height: cardHeight)
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
    var showAllMarkers = true
    var showsMarkers = true
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
                Color.white
                Image("LightMapNN").resizable().frame(width: 2000 * scale, height: 4519 * scale)
                    .offset(x: origin.x, y: origin.y).accessibilityHidden(true)
                ForEach(showsMarkers ? dataStore.structures : [], id: \.number) { item in
                    if let point = locationService.getMapPointForStructure(item.number)?.pixelPosition {
                        Button { select(item.number) } label: {
                            Text(showAllMarkers || item.number == selected ? String(item.number) : "").font(.system(size: item.number == selected ? 16 : 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(item.number == selected ? .white : FieldPalette.green)
                                .frame(width: item.number == selected ? 36 : (showAllMarkers ? 23 : 6), height: item.number == selected ? 36 : (showAllMarkers ? 23 : 6))
                                .background(item.number == selected ? FieldPalette.green : .white, in: Circle())
                                .overlay { Circle().stroke(FieldPalette.gold, lineWidth: item.number == selected ? 3 : 1) }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                            .accessibilityLabel("\(item.title), map number \(item.number)")
                            .accessibilityAddTraits(item.number == selected ? .isSelected : [])
                            .id(item.number)
                            .position(x: origin.x + point.x * 1.09 * scale, y: origin.y + point.y * 1.09 * scale)
                    }
                }
            }.frame(width: size.width, height: size.height, alignment: .topLeading).clipped()
                .animation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.92), value: selected)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: overview)
        }
    }
}

/// A real scroll surface: recenter using calibrated map coordinates, rather than
/// ScrollViewReader IDs on positioned children (which resolve to their parent rect).
private struct CanyonMapScroll: UIViewRepresentable {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let selected: Int
    let showAllMarkers: Bool
    let select: (Int) -> Void

    func makeUIView(context: Context) -> AtlasScrollView {
        let view = AtlasScrollView()
        view.backgroundColor = .white
        view.contentInsetAdjustmentBehavior = .never
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }

    func updateUIView(_ view: AtlasScrollView, context: Context) {
        let atlas = SpatialAtlas(selected: selected, overview: true, showAllMarkers: showAllMarkers, select: select)
            .environmentObject(locationService).environmentObject(dataStore)
        view.host.rootView = AnyView(atlas)
        view.focus = locationService.getMapPointForStructure(selected)?.pixelPosition
        view.animateSelection = !reduceMotion
        if view.selected != selected {
            view.selected = selected
            view.needsCentering = true
        }
        view.setNeedsLayout()
    }
}

private final class AtlasScrollView: UIScrollView {
    let host = UIHostingController(rootView: AnyView(EmptyView()))
    var selected: Int?
    var focus: CGPoint?
    var needsCentering = true
    var animateSelection = false
    private var previousSize = CGSize.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        host.view.backgroundColor = .white
        addSubview(host.view)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        guard size.width > 0, size.height > 0 else { return }
        let resized = size != previousSize
        let height = size.width * 4519 / 2000
        host.view.frame = CGRect(x: 0, y: 0, width: size.width, height: height)
        contentSize = CGSize(width: size.width, height: height)
        // Keep end stops visible without scrolling into half a screen of blank canvas.
        contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        if needsCentering || resized {
            needsCentering = false
            previousSize = size
            let scale = size.width / 2000 * 0.93
            let y = height * 0.035 + (focus?.y ?? 2200) * 1.09 * scale
            let offset = min(max(y - size.height / 2, -contentInset.top), height - size.height + contentInset.bottom)
            setContentOffset(CGPoint(x: 0, y: offset), animated: animateSelection && !resized && window != nil)
        }
    }
}
