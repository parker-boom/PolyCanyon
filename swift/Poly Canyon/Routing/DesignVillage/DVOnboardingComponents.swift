import SwiftUI

struct DVNavigationButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil
    var isDisabled: Bool = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 18, weight: .bold))
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                isDisabled 
                    ? Color.gray.opacity(0.3) 
                    : DVDesignSystem.Colors.yellow
            )
            .foregroundColor(DVDesignSystem.Colors.text)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(
                        LinearGradient(
                            colors: [DVDesignSystem.Colors.orange, DVDesignSystem.Colors.teal],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isPressed ? 2 : 0
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.7 : 1.0)
        .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
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

struct DVBackButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text("Back")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isPressed ? DVDesignSystem.Colors.text : DVDesignSystem.Colors.textSecondary)
                .underline()
        }
        .pressAction {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = false
            }
        }
    }
}

struct DVBaseSlide<Content: View>: View {
    let content: Content
    let buttonText: String
    let buttonAction: () -> Void
    let buttonDisabled: Bool
    let buttonIcon: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    
    init(
        buttonText: String = "Next",
        buttonDisabled: Bool = false,
        buttonAction: @escaping () -> Void,
        buttonIcon: String = "chevron.right",
        showBackButton: Bool = true,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.buttonDisabled = buttonDisabled
        self.buttonIcon = buttonIcon
        self.showBackButton = showBackButton
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    content
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.top, 80)
                }
                .frame(minHeight: UIScreen.main.bounds.height - 200)
            }
            
            Spacer(minLength: 0)
            
            VStack(spacing: 16) {
                DVNavigationButton(
                    text: buttonText,
                    action: buttonAction,
                    iconName: buttonIcon.isEmpty ? nil : buttonIcon,
                    isDisabled: buttonDisabled
                )
                
                if showBackButton, let onBack = onBack {
                    DVBackButton(action: onBack)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .nexusStyle()
        .edgesIgnoringSafeArea(.all)
    }
}

struct DVOnboardingIndicator: View {
    let totalStages: Int
    let currentStage: Int
    
    // Custom blues for the indicator
    private let darkBlue = Color(red: 0.0, green: 0.3, blue: 0.7)
    private let lightBlue = Color(red: 0.7, green: 0.85, blue: 1.0)
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalStages, id: \.self) { index in
                Circle()
                    .fill(index == currentStage ? darkBlue : lightBlue)
                    .frame(width: index == currentStage ? 12 : 8, height: index == currentStage ? 12 : 8)
                    .overlay(
                        Circle()
                            .stroke(
                                index == currentStage ? 
                                    darkBlue.opacity(0.3) : 
                                    lightBlue.opacity(0.3),
                                lineWidth: 2
                            )
                            .scaleEffect(1.5)
                            .opacity(index == currentStage ? 1 : 0)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 40)
        .background(DVDesignSystem.Colors.surface.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
    }
}

struct DVFeatureRow: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 40)
            
            Text(text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(DVDesignSystem.Colors.text)
        }
    }
}

struct DVIconFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DVDesignSystem.Colors.orange.opacity(0.7),
                                DVDesignSystem.Colors.teal.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 3, x: 0, y: 2)
            
            Text(text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(DVDesignSystem.Colors.text)
        }
    }
}

struct DVRoleButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    private var buttonColor: Color {
        if isSelected {
            return title == "Competitor" ? 
                DVDesignSystem.Colors.orange.opacity(0.8) : 
                DVDesignSystem.Colors.teal.opacity(0.8)
        } else {
            return DVDesignSystem.Colors.surface
        }
    }
    
    private var borderColor: Color {
        title == "Competitor" ? 
            DVDesignSystem.Colors.orange : 
            DVDesignSystem.Colors.teal
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                Text(emoji)
                    .font(.system(size: 50))
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(buttonColor)
                    .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 6, x: 0, y: 3)
            )
            .foregroundColor(DVDesignSystem.Colors.text)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        borderColor,
                        lineWidth: 2
                    )
            )
        }
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct DVSettingsPrompt: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DVDesignSystem.Colors.teal.opacity(0.8),
                                DVDesignSystem.Colors.orange.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(DVDesignSystem.Colors.text)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(DVDesignSystem.Colors.surface)
        .cornerRadius(16)
        .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            DVDesignSystem.Colors.teal,
                            DVDesignSystem.Colors.orange
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

struct DVTitleWithShadow: View {
    let text: String
    let font: Font
    
    var body: some View {
        ZStack {
            // Orange shadow
            Text(text)
                .font(font)
                .foregroundColor(DVDesignSystem.Colors.orange.opacity(0.5))
                .offset(x: -3, y: 2)
                .blur(radius: 3)
            
            // Teal shadow
            Text(text)
                .font(font)
                .foregroundColor(DVDesignSystem.Colors.teal.opacity(0.5))
                .offset(x: 3, y: 2)
                .blur(radius: 3)
            
            // Main text
            Text(text)
                .font(font)
                .foregroundColor(DVDesignSystem.Colors.text)
        }
    }
}

// Extension for press animation
struct PressAction: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressAction(onPress: onPress, onRelease: onRelease))
    }
} 