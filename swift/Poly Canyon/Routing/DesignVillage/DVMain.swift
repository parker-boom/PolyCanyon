import SwiftUI

struct DVMain: View {
    @State private var selectedTab: Int = 0
    @Binding var designVillageMode: Bool
    @Binding var userRole: DVRole
    
    var body: some View {
        VStack(spacing: 0) {
            // Shared header for all views
            DVHeader(title: tabTitle())
                .padding(.bottom, 5)
            
            // Switcher for the 5 main views.
            Group {
                switch selectedTab {
                case 0:
                    DVInfo()
                case 1:
                    DVMap()
                case 2:
                    DVSchedule()
                case 3:
                    DVRules(userRole: $userRole)
                case 4:
                    DVSettings(designVillageMode: $designVillageMode)
                default:
                    DVInfo()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar.
            DVCustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
        .nexusStyle()
    }
    
    private func tabTitle() -> String {
        switch selectedTab {
        case 0: return "Info"
        case 1: return "Map"
        case 2: return "Schedule"
        case 3: return "Rules"
        case 4: return "Settings"
        default: return "Info"
        }
    }
}

struct DVMain_Previews: PreviewProvider {
    static var previews: some View {
        DVMain(designVillageMode: .constant(true), userRole: .constant(.visitor))
    }
}

// MARK: - Header Component

struct DVHeader: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            DVTitleWithShadow(
                text: title,
                font: .system(size: 32, weight: .bold)
            )
            .frame(maxWidth: .infinity, alignment: .center)
            
            DVDesignSystem.Effects.accentLine()
                .frame(width: 120)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 5)
        .background(DVDesignSystem.Colors.background)
    }
}

// MARK: - Custom Tab Bar

struct DVCustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            // Background layer
            Color(hex: "FFF4E4")
                .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 8, y: -4)
                .ignoresSafeArea(.all, edges: .bottom)
            
            VStack(spacing: 0) {
                // Divider at the top
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                
                // Tab buttons
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
                .padding(.bottom, 10)
            }
        }
        .frame(height: 70)
    }
    
    private func dvTabIcon(for index: Int) -> String {
        switch index {
        case 0: return isSelected(index) ? "info.circle.fill" : "info.circle"
        case 1: return isSelected(index) ? "map.fill" : "map"
        case 2: return isSelected(index) ? "clock.fill" : "clock"
        case 3: return isSelected(index) ? "list.bullet.clipboard.fill" : "list.bullet.clipboard"
        case 4: return isSelected(index) ? "gearshape.fill" : "gearshape"
        default: return ""
        }
    }
    
    private func isSelected(_ index: Int) -> Bool {
        return selectedTab == index
    }
}

// MARK: - Tab Icon

private struct DVTabIcon: View {
    let icon: String
    let isSelected: Bool
    @State private var isPressed = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundStyle(
                isSelected ? 
                LinearGradient(
                    colors: [
                        DVDesignSystem.Colors.orange,
                        DVDesignSystem.Colors.teal
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) : 
                LinearGradient(
                    colors: [DVDesignSystem.Colors.textSecondary, DVDesignSystem.Colors.textSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(
                color: DVDesignSystem.Colors.shadowColor,
                radius: isSelected ? 2 : 0,
                x: 0,
                y: 1
            )
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .padding(.bottom, 20)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .pressAction {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = true
                }
            } onRelease: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
    }
}
