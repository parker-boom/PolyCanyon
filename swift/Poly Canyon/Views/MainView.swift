import SwiftUI

enum FullScreenView: String, Identifiable {
    case structInfo, settings, ghostStructInfo
    var id: String { rawValue }
}
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    var body: some View {
        TabView {
            NavigationStack { MapView() }.tabItem { Label("Map", systemImage: "map") }
            NavigationStack { DetailView() }.tabItem { Label("Structures", systemImage: "square.grid.2x2") }
            NavigationStack { SettingsView() }.tabItem { Label("Your visit", systemImage: "figure.walk") }
        }
        .tint(CanyonStyle.ink)
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
}
enum CanyonStyle {
    static let paper = Color(red: 0.97, green: 0.965, blue: 0.945)
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
