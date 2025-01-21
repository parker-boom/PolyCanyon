/*
 OnboardingComponents provides the UI components used across the onboarding experience. It includes custom 
 buttons, animations, and mode selection controls. These components maintain consistent styling while 
 adapting to the selected mode colors. The components focus on providing clear visual feedback and smooth 
 transitions during the onboarding flow.
*/

import SwiftUI

/*
 NavigationButton provides a consistent styled button for onboarding navigation. It includes
 a chevron icon and maintains the app's visual language.
*/
struct NavigationButton: View {
    let text: String
    let action: () -> Void
    var iconName: String? = nil // Optional icon name
    var isDisabled: Bool = false // Button state

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
        .disabled(isDisabled) // Disable button if isDisabled is true
        .opacity(isDisabled ? 0.7 : 1.0) // Visually indicate disabled state
    }
}

/*
 PulsingLocationDot creates an animated location indicator with a pulsing effect.
 Used during location permission requests to provide visual feedback.
*/
struct PulsingLocationDot: View {
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Outer pulsing circle
            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .animation(
                    Animation.easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                    value: scale
                )
            
            // Inner solid circle
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
        }
        .onAppear {
            self.scale = 1.2
        }
    }
}

struct PulsingAdvDot: View {
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Outer pulsing circle
            Circle()
                .fill(Color.green.opacity(0.25))
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .animation(
                    Animation.easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                    value: scale
                )
            
            // Inner solid circle
            Circle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
        }
        .onAppear {
            self.scale = 1.2
        }
    }
}

/*
 ModeIcon displays the icon for either adventure or virtual tour mode with
 appropriate styling and animations.
*/
struct ModeIcon: View {
    let imageName: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Animated background for selected state
            if isSelected {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .modifier(PulseAnimation())
            }
            
            // Mode icon circle
            Circle()
                .fill(color)
                .frame(width: 100, height: 100)
            
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(Color.white.opacity(0.8))
        }
    }
}

/*
 CustomModePicker provides the mode selection interface with smooth animations
 and visual feedback for the selected mode.
*/
struct CustomModePicker: View {
    @Binding var isAdventureModeEnabled: Bool
    let adventureModeColor: Color
    let virtualTourColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            // Virtual tour option
            ModeButton(
                title: "Virtual Tour",
                isSelected: !isAdventureModeEnabled,
                color: virtualTourColor,
                action: { withAnimation { isAdventureModeEnabled = false } }
            )
            
            // Adventure mode option
            ModeButton(
                title: "Adventure",
                isSelected: isAdventureModeEnabled,
                color: adventureModeColor,
                action: { withAnimation { isAdventureModeEnabled = true } }
            )
        }
        .background(Capsule().fill(Color.gray.opacity(0.2)))
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Components

struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.clear)
                        .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear,
                               radius: 5, x: 0, y: 2)
                )
                .foregroundColor(isSelected ? color : .gray)
        }
    }
}

struct RecommendationLabel: View {
    let isRecommended: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isRecommended ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isRecommended ? .green : .red)
            Text(isRecommended ? "Recommended" : "Not Recommended")
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - Animations

struct PulseAnimation: ViewModifier {
    @State private var animationAmount: CGFloat = 1
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(animationAmount)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: animationAmount
            )
            .onAppear {
                self.animationAmount = 1.05
            }
    }
}
