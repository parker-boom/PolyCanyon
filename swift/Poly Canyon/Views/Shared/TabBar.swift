import SwiftUI


// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: Int
    
    private var backgroundColor: Color {
        appState.isDarkMode ? 
            Color.black.opacity(0.9) :
            Color(white: 0.9) // More grey, less white
    }
    
    var body: some View {
        VStack (spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(appState.isDarkMode ? 0.3 : 0.1))
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(0..<3) { index in
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { 
                            selectedTab = index 
                        }
                    }) {
                        TabIcon(
                            icon: tabIcon(for: index),
                            isSelected: selectedTab == index,
                            isDarkMode: appState.isDarkMode
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .background(
                ZStack {
                    // Solid grey base
                    backgroundColor
                    
                    // Inner shadow at top edge
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(appState.isDarkMode ? 0.2 : 0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: UnitPoint(x: 0.5, y: 0.05)
                            )
                        )
                        .frame(height: 8)
                        .blur(radius: 2)
                    
                }
                .ignoresSafeArea(.all, edges: .bottom)
            )
        }
         .shadow(
                color: Color.black.opacity(appState.isDarkMode ? 0.5 : 0.25),
                radius: 2,
                x: 0,
                y: -2
            )
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "map.fill"
        case 1: return "archivebox.fill"
        case 2: return "gearshape.fill"
        default: return ""
        }
    }
}

// MARK: - Tab Icon
private struct TabIcon: View {
    let icon: String
    let isSelected: Bool
    let isDarkMode: Bool
    
    private var iconColor: Color {
        if isSelected {
            return isDarkMode ? .white : .black
        }
        return Color(white: isDarkMode ? 0.5 : 0.6)
    }
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 24))
            // Base icon with center-focused gradient
            .foregroundStyle(iconColor)
            // Multiple shadows for depth
            .shadow(
                color: (isDarkMode ? Color.white : Color.black).opacity(isSelected ? 0.2 : 0),
                radius: 1,
                x: 0,
                y: 1
            )
            .shadow(
                color: (isDarkMode ? Color.white : Color.black).opacity(isSelected ? 0.1 : 0),
                radius: 4,
                x: 0,
                y: 2
            )
            .overlay {
                if isSelected {
                    // Refined emboss effect
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    Color.clear,
                                    Color.white.opacity(isDarkMode ? 0.4 : 0.25),
                                    Color.clear,
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(x: -0.5, y: -0.5)
                        .mask(
                            Image(systemName: icon)
                                .font(.system(size: 24))
                        )
                }
            }
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
