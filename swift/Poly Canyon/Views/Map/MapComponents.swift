/*
 MapComponents provides the supporting UI elements for the map interface. It includes the virtual tour 
 navigation bar, structure visit notifications, nearby structure overlays, and achievement popups. These 
 components adapt to the current theme and provide consistent interaction patterns across the map experience.
*/

import Zoomable
import SwiftUI


struct GlassBackground: ViewModifier {
    @EnvironmentObject var appState: AppState
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.15),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}


struct GlassButton: ViewModifier {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.7) :
            Color(white: 0.90)  // Slightly darker base
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                        Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 1,
                x: 0,
                y: 1
            )
    }
}



struct GlassButtonNoShadow: ViewModifier {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.7) :
            Color(white: 0.90)  
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                        Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

struct MapToolbarButton: ViewModifier {
    @EnvironmentObject var appState: AppState
    let isActive: Bool
    
    var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.7) :
            Color(white: 0.90)
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                        Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                radius: 1,
                x: 0,
                y: 1
            )
    }
}

struct ToolbarBackground: ViewModifier {
    @EnvironmentObject var appState: AppState
    
    func body(content: Content) -> some View {
        content
            .background(
                BottomRoundedRectangle(cornerRadius: 12)
                    .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.93))
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        BottomRoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                Color.white.opacity(appState.isDarkMode ? 0.2 : 0.1),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 22) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
    
    func glassButton(isActive: Bool = false) -> some View {
        modifier(GlassButton(isActive: isActive))
    }
    
    func glassButtonNoShadow(isActive: Bool = false) -> some View {
        modifier(GlassButtonNoShadow(isActive: isActive))
    }
    
    func mapToolbarButton(isActive: Bool = false) -> some View {
        modifier(MapToolbarButton(isActive: isActive))
    }
    
    func toolbarBackground() -> some View {
        modifier(ToolbarBackground())
    }
}
