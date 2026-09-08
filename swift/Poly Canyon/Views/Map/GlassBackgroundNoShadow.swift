import SwiftUI
import Zoomable
struct GlassBackgroundNoShadow: ViewModifier {
    @EnvironmentObject var appState: AppState

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        .white.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
            )
    }
}


extension View {
    func glassBackgroundNoShadow() -> some View {
        modifier(GlassBackgroundNoShadow())
    }
}
