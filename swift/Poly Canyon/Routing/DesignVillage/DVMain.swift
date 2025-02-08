import SwiftUI

struct DVMain: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Switcher for the 5 main views.
            Group {
                switch selectedTab {
                case 0:
                    DVInfo()
                case 1:
                    DVMap()
                case 2:
                    DVPeople()
                case 3:
                    DVSchedule()
                case 4:
                    DVSettings()
                default:
                    DVInfo()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar.
            DVCustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct DVMain_Previews: PreviewProvider {
    static var previews: some View {
        DVMain()
    }
}

// MARK: - Custom Tab Bar

struct DVCustomTabBar: View {
    @Binding var selectedTab: Int
    
    private var backgroundColor: Color {
        Color(white: 0.9)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
            
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }) {
                        DVTabIcon(
                            icon: dvTabIcon(for: index),
                            isSelected: selectedTab == index
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .background(
                ZStack {
                    backgroundColor
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.1),
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
            color: Color.black.opacity(0.25),
            radius: 2,
            x: 0,
            y: -2
        )
    }
    
    private func dvTabIcon(for index: Int) -> String {
        switch index {
        case 0: return "info.circle.fill"
        case 1: return "map.fill"
        case 2: return "person.3.fill"
        case 3: return "clock.fill"
        case 4: return "gearshape.fill"
        default: return ""
        }
    }
}

// MARK: - Tab Icon

private struct DVTabIcon: View {
    let icon: String
    let isSelected: Bool
    
    private var iconColor: Color {
        isSelected ? .black : Color(white: 0.6)
    }
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundStyle(iconColor)
            .shadow(
                color: Color.black.opacity(isSelected ? 0.2 : 0),
                radius: 1,
                x: 0,
                y: 1
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.1 : 0),
                radius: 4,
                x: 0,
                y: 2
            )
            .overlay {
                if isSelected {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.15),
                                    Color.clear,
                                    Color.white.opacity(0.25),
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
