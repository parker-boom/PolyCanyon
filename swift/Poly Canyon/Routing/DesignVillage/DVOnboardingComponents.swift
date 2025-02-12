import SwiftUI

struct DVNavigationButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil
    var isDisabled: Bool = false

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
            .background(isDisabled ? Color.gray : Color.black.opacity(0.8))
            .foregroundColor(isDisabled ? Color.white.opacity(0.7) : .white)
            .cornerRadius(25)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.7 : 1.0)
    }
}

struct DVBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Back")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .underline()
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
        ZStack {
            VStack {
                content
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 150)
                
                Spacer()
                
                VStack(spacing: 16) {
                    DVNavigationButton(
                        text: buttonText,
                        action: buttonAction,
                        iconName: buttonIcon,
                        isDisabled: buttonDisabled
                    )
                    
                    if showBackButton, let onBack = onBack {
                        DVBackButton(action: onBack)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct DVOnboardingIndicator: View {
    let totalStages: Int
    let currentStage: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalStages, id: \.self) { index in
                Circle()
                    .fill(index == currentStage ? Color.black : Color.gray.opacity(0.5))
                    .frame(width: index == currentStage ? 12 : 8, height: index == currentStage ? 12 : 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 40)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct DVFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .bold))
                .frame(width: 40)
                .foregroundColor(.black)
            
            Text(text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

struct DVRoleButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(isSelected ? .white : .black)
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.black : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .black)
        }
    }
}

struct DVSettingsPrompt: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 24, weight: .bold))
            Text(text)
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
    }
} 