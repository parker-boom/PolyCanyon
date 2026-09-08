import SwiftUI

enum FullScreenView: String, Identifiable {
    case structInfo, settings, ghostStructInfo
    var id: String { rawValue }
}
private enum CanyonDestination: Hashable { case map, tour, collection, search }

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @State private var destination = CanyonDestination.map
    @State private var searchText = ""
    @State private var onlyUnvisited = false
    @State private var showInfo = false
    @State private var mapFocus: Int?
    @State private var mapRequest = UUID()
    var body: some View {
        destinations
            .tint(CanyonStyle.ink)
            .onAppear {
                // Migrate a restored modal tour into the stable Tour destination.
                if appState.isVirtualWalkthrough {
                    destination = .tour
                    appState.isVirtualWalkthrough = false
                }
            }
            .sheet(isPresented: $showInfo) {
                NavigationStack { SettingsView() }.presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
            }
            .fullScreenCover(item: $appState.activeFullScreenView) { view in
                switch view {
                case .structInfo: StructInfo()
                case .ghostStructInfo:
                    GhostInfo(initialGhostIndex: dataStore.ghostStructures.firstIndex { Int($0.number) == appState.ghostStructInfoNum })
                case .settings: NavigationStack { SettingsView() }
                }
            }
            .overlay(alignment: .top) {
                if dataStore.lastVisitedStructure != nil || dataStore.lastVisitedGhostStructure != nil {
                    VisitNotificationView().padding(.horizontal, 16).padding(.top, 8)
                }
            }
    }
    @ViewBuilder private var destinations: some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $destination) {
                Tab(value: .map) { map } label: { Image(systemName: "map") }.accessibilityLabel("Map")
                Tab(value: .tour) { tour } label: { Image(systemName: "figure.walk") }.accessibilityLabel("Tour")
                Tab(value: .collection) { collection(searching: false) } label: {
                    Image(systemName: "square.grid.2x2")
                }.accessibilityLabel("Collection")
                Tab(value: .search, role: .search) { collection(searching: true) }
            }
            .tabViewSearchActivation(.searchTabSelection)
        } else {
            TabView(selection: $destination) {
                map.tag(CanyonDestination.map).tabItem { Label("Map", systemImage: "map") }
                tour.tag(CanyonDestination.tour).tabItem { Label("Tour", systemImage: "figure.walk") }
                collection(searching: true).tag(CanyonDestination.collection).tabItem { Label("Collection", systemImage: "square.grid.2x2") }
            }
        }
    }
    private var map: some View {
        NavigationStack {
            MapView(focusStructure: $mapFocus, focusRequest: mapRequest)
                .toolbar { ToolbarItem(placement: .navigationBarLeading) { infoButton } }
        }
    }
    private var tour: some View {
        NavigationStack {
            VirtualWalkthrough { number in
                mapFocus = number
                mapRequest = UUID()
                destination = .map
            }
        }
    }
    private func collection(searching: Bool) -> some View {
        NavigationStack {
            DetailView(searchText: $searchText, onlyUnvisited: $onlyUnvisited, searching: searching)
                .toolbar { ToolbarItem(placement: .navigationBarLeading) { infoButton } }
        }
    }
    private var infoButton: some View {
        Button { showInfo = true } label: { Image(systemName: "info.circle") }
            .accessibilityLabel("About Poly Canyon and location settings")
    }
}
enum CanyonStyle {
    static let paper = Color.white
    static let ink = Color(red: 0.15, green: 0.27, blue: 0.21)
}
/// Glass is reserved for controls floating above the content.
struct CanyonControl: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var opaque
    func body(content: Content) -> some View {
        if opaque { content.background(CanyonStyle.paper, in: Capsule()) }
        else if #available(iOS 26.0, *) { content.glassEffect(.regular.interactive(), in: Capsule()) }
        else { content.background(.regularMaterial, in: Capsule()) }
    }
}
extension View {
    func canyonControl() -> some View { modifier(CanyonControl()) }
}
