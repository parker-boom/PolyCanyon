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
    @State private var presentation: StructurePresentation?
    @State private var cardSelection: Int?
    @Namespace private var photos
    private var index: Int { min(max(0, appState.currentStructureIndex), max(0, dataStore.structures.count - 1)) }
    private var structure: Structure? { dataStore.structures.indices.contains(index) ? dataStore.structures[index] : nil }

    var body: some View {
        GeometryReader { geometry in
            if let structure {
                VStack(spacing: 0) {
                    if typeSize.isAccessibilitySize {
                        SpatialAtlas(selected: structure.number, overview: false, reduceMotion: reduceMotion, select: select)
                            .frame(height: 180)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Map focused on \(structure.title), number \(structure.number)")
                            .accessibilityHint("Use Choose a structure to change the selection.")
                            .accessibilityAddTraits(.isImage)
                        ScrollView { card(structure, width: max(1, geometry.size.width - 48)).padding(24) }
                    } else {
                        CanyonMapScroll(selected: structure.number, select: select).clipped()
                        cards(width: geometry.size.width)
                            .padding(.top, -12).padding(.bottom, 12)
                    }
                }
                .overlay(alignment: .topTrailing) { chooser.padding(16) }
            }
        }
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $presentation) { selection in
            StructureExperience(numbers: selection.numbers, selected: selection.selected, namespace: photos, selectionChanged: select)
        }
        .onAppear { appState.currentStructureIndex = index; cardSelection = structure?.number }
        .onChange(of: appState.currentStructureIndex) { _ in
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) { cardSelection = structure?.number }
        }
        .onChange(of: cardSelection) { number in
            if let number, number != structure?.number { select(number) }
        }
    }

    @ViewBuilder private func cards(width: CGFloat) -> some View {
        let cardWidth = min(310, max(220, width * 0.72))
        if #available(iOS 17, *) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 14) {
                    ForEach(dataStore.structures) { item in card(item, width: cardWidth).id(item.number) }
                }.scrollTargetLayout().padding(.vertical, 6)
            }
            .contentMargins(.horizontal, (width - cardWidth) / 2, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $cardSelection, anchor: .center)
            // Let glass shadows fade into the same white page beneath the tabs;
            // clipping this fitted scroll view cuts them into a horizontal strip.
            .scrollClipDisabled()
            .fixedSize(horizontal: false, vertical: true)
        } else {
            TabView(selection: $appState.currentStructureIndex) {
                ForEach(dataStore.structures.indices, id: \.self) { position in
                    card(dataStore.structures[position], width: cardWidth).tag(position)
                }
            }.tabViewStyle(.page(indexDisplayMode: .never)).frame(height: cardWidth + 115)
        }
    }
    private func card(_ item: Structure, width: CGFloat) -> some View {
        Button {
            select(item.number)
            presentation = StructurePresentation(numbers: dataStore.structures.map(\.number), selected: item.number)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                if !typeSize.isAccessibilitySize {
                    Image(item.images.first ?? "M-1").resizable().scaledToFill()
                        .frame(width: width - 24, height: width - 24).clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .modifier(StructureZoomSource(id: item.number, namespace: photos))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title).font(.title3.weight(.semibold)).foregroundStyle(FieldPalette.green)
                    if let dates = item.catalogDates { Text(dates).font(.subheadline).foregroundStyle(.secondary) }
                }.fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4).padding(.bottom, 6)
            }.padding(12).frame(width: width, alignment: .leading)
                .modifier(CanyonCardSurface())
        }.buttonStyle(.plain)
            .accessibilityLabel("\(item.title), \(item.catalogDates ?? "Date unknown")")
            .accessibilityHint("Open structure; swipe to choose another")
            .accessibilityAction(named: "Next structure") { step(1) }
            .accessibilityAction(named: "Previous structure") { step(-1) }
    }
    private var chooser: some View {
        Menu {
            ForEach(dataStore.structures) { item in
                Button("\(item.number). \(item.title)") { select(item.number) }
            }
        } label: {
            Image(systemName: "list.bullet").font(.body.weight(.semibold)).frame(width: 48, height: 48).canyonControl()
        }.foregroundStyle(FieldPalette.green).accessibilityLabel("Choose a structure")
    }
    private func step(_ delta: Int) {
        guard dataStore.structures.indices.contains(index + delta) else { return }
        select(dataStore.structures[index + delta].number)
    }
    private func select(_ number: Int) {
        guard let position = dataStore.structures.firstIndex(where: { $0.number == number }) else { return }
        appState.currentStructureIndex = position
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
                                .background { if item.number == selected { SelectedMarkerGlow(reduceMotion: reduceMotion) } }
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

private struct SelectedMarkerGlow: View {
    let reduceMotion: Bool
    @Environment(\.colorSchemeContrast) private var contrast
    @State private var expanded = false
    var body: some View {
        Circle().stroke(FieldPalette.gold.opacity(contrast == .increased ? 1 : 0.5), lineWidth: 2)
            .frame(width: 44, height: 44)
            .scaleEffect(expanded && !reduceMotion ? 1.18 : 1)
            .opacity(expanded && !reduceMotion ? 0.25 : 0.7)
            .allowsHitTesting(false).accessibilityHidden(true)
            .task(id: reduceMotion) {
                expanded = false
                if !reduceMotion { withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { expanded = true } }
            }
    }
}
