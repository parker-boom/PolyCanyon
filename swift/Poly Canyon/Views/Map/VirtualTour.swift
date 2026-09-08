import SwiftUI
import UIKit

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
    @State private var story = false
    @Namespace private var photos
    private var index: Int { min(max(0, appState.currentStructureIndex), max(0, dataStore.structures.count - 1)) }
    private var structure: Structure? { dataStore.structures.indices.contains(index) ? dataStore.structures[index] : nil }
    private var movement: Animation? { reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.92) }

    var body: some View {
        Group {
            if let structure {
                if typeSize.isAccessibilitySize {
                    ScrollView {
                        SpatialAtlas(selected: structure.number, overview: false, reduceMotion: reduceMotion, select: select).frame(height: 230)
                        inspector(structure).padding(20)
                        navigation.padding(.horizontal, 20)
                    }
                } else {
                    tour(structure)
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

    private func tour(_ item: Structure) -> some View {
        VStack(spacing: 0) {
            CanyonMapScroll(selected: item.number, select: select)
                .clipped()
                .padding(.top, 8)
            TabView(selection: $appState.currentStructureIndex) {
                ForEach(dataStore.structures.indices, id: \.self) { position in
                    inspector(dataStore.structures[position]).padding(18).tag(position)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // The fixed photo is 84 points tall, plus 18 points of padding per side.
            .frame(height: max(120, cardHeight))
            navigation.padding(.horizontal, 18).padding(.bottom, 12)
        }.background(.white)
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
        withAnimation(movement) { appState.currentStructureIndex = (index + delta + dataStore.structures.count) % dataStore.structures.count }
    }
    private func select(_ number: Int) {
        guard let position = dataStore.structures.firstIndex(where: { $0.number == number }) else { return }
        withAnimation(movement) { appState.currentStructureIndex = position }
    }
}

/// Uses the original map and calibrated points. No suggested walking route is invented.
struct SpatialAtlas: View {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var dataStore: DataStore
    let selected: Int
    let overview: Bool
    // Explicit because the scrollable atlas lives in its own hosting controller.
    let reduceMotion: Bool
    var showsMarkers = true
    var select: (Int) -> Void = { _ in }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let focus = locationService.getMapPointForStructure(selected)?.pixelPosition ?? CanyonAtlasGeometry.defaultFocus
            let layout = CanyonAtlasGeometry(size: size, focus: focus, overview: overview)
            ZStack(alignment: .topLeading) {
                Color.white
                Image("LightMapNN").resizable()
                    .frame(width: layout.imageSize.width, height: layout.imageSize.height)
                    .offset(x: layout.origin.x, y: layout.origin.y).accessibilityHidden(true)
                ForEach(showsMarkers ? dataStore.structures : [], id: \.number) { item in
                    if let point = locationService.getMapPointForStructure(item.number)?.pixelPosition {
                        Button { select(item.number) } label: {
                            Text(item.number == selected ? String(item.number) : "")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(item.number == selected ? .white : FieldPalette.green)
                                .frame(width: item.number == selected ? 36 : 6, height: item.number == selected ? 36 : 6)
                                .background(item.number == selected ? FieldPalette.green : .white, in: Circle())
                                .overlay { Circle().stroke(FieldPalette.gold, lineWidth: item.number == selected ? 3 : 1) }
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                            .accessibilityLabel("\(item.title), map number \(item.number)")
                            .accessibilityAddTraits(item.number == selected ? .isSelected : [])
                            .position(layout.position(for: point))
                    }
                }
            }.frame(width: size.width, height: size.height, alignment: .topLeading).clipped()
                .animation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.92), value: selected)
        }
    }
}

/// A real scroll surface: recenter using calibrated map coordinates, rather than
/// ScrollViewReader IDs on positioned children (which resolve to their parent rect).
private struct CanyonMapScroll: UIViewControllerRepresentable {
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let selected: Int
    let select: (Int) -> Void

    func makeUIViewController(context: Context) -> AtlasScrollController {
        let controller = AtlasScrollController()
        controller.loadViewIfNeeded()
        return controller
    }

    func updateUIViewController(_ controller: AtlasScrollController, context: Context) {
        let atlas = SpatialAtlas(selected: selected, overview: true, reduceMotion: reduceMotion, select: select)
            .environmentObject(locationService).environmentObject(dataStore)
        let scroll = controller.scroll
        // The parent clips to its safe area; the map canvas must use its full content rect.
        scroll.host.rootView = AnyView(atlas.ignoresSafeArea())
        let focus = locationService.getMapPointForStructure(selected)?.pixelPosition ?? CanyonAtlasGeometry.defaultFocus
        if scroll.selected != selected || scroll.focus != focus {
            scroll.selected = selected
            scroll.focus = focus
            scroll.needsCentering = true
        }
        if reduceMotion && scroll.animateSelection {
            // Also stop an in-flight camera animation if Reduce Motion changes.
            scroll.setContentOffset(scroll.contentOffset, animated: false)
            scroll.needsCentering = true
        }
        scroll.animateSelection = !reduceMotion
        scroll.setNeedsLayout()
    }

    static func dismantleUIViewController(_ controller: AtlasScrollController, coordinator: ()) {
        controller.detachMap()
    }
}

private final class AtlasScrollController: UIViewController {
    let scroll = AtlasScrollView()

    override func loadView() {
        view = scroll
        addChild(scroll.host)
        scroll.addSubview(scroll.host.view)
        scroll.host.didMove(toParent: self)
    }

    func detachMap() {
        scroll.setContentOffset(scroll.contentOffset, animated: false)
        scroll.host.willMove(toParent: nil)
        scroll.host.view.removeFromSuperview()
        scroll.host.removeFromParent()
        scroll.host.rootView = AnyView(EmptyView())
    }
}

private final class AtlasScrollView: UIScrollView {
    let host = UIHostingController(rootView: AnyView(EmptyView()))
    var selected: Int?
    var focus = CanyonAtlasGeometry.defaultFocus
    var needsCentering = true
    var animateSelection = false
    private var previousSize = CGSize.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = false
        alwaysBounceVertical = true
        host.view.backgroundColor = .white
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        guard size.width > 0, size.height > 0 else { return }
        let resized = size != previousSize
        let canvas = CanyonAtlasGeometry.scrollCanvas(width: size.width)
        host.view.frame = CGRect(origin: .zero, size: canvas)
        contentSize = canvas
        // Keep end stops visible without scrolling into half a screen of blank canvas.
        contentInset = UIEdgeInsets(top: CanyonAtlasGeometry.endInset, left: 0,
                                   bottom: CanyonAtlasGeometry.endInset, right: 0)
        if needsCentering || resized {
            needsCentering = false
            previousSize = size
            let offset = CanyonAtlasGeometry.scrollOffset(focus: focus, viewport: size)
            setContentOffset(CGPoint(x: 0, y: offset), animated: animateSelection && !resized && window != nil)
        }
    }
}
