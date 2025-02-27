import SwiftUI

struct DVOnboarding: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @State private var currentSlide: Int = 0
    @Binding var userRole: DVRole
    
    var body: some View {
        ZStack {
            // Content slides
            if currentSlide == 0 {
                DVWelcomeSlide {
                    currentSlide = 1
                }
            } else if currentSlide == 1 {
                DVOverviewSlide(
                    onNext: { currentSlide = 2 },
                    onBack: { currentSlide = 0 }
                )
            } else if currentSlide == 2 {
                DVRulesSlide(
                    selectedRole: $userRole,
                    onNext: { currentSlide = 3 },
                    onBack: { currentSlide = 1 }
                )
            } else if currentSlide == 3 {
                DVPolyCanyonSlide(
                    onNext: { currentSlide = 4 },
                    onBack: { currentSlide = 2 }
                )
            } else if currentSlide == 4 {
                DVFinalSlide(onComplete: completeOnboarding)
            }
            
            // Progress indicator
            if currentSlide < 4 {
                VStack {
                    DVOnboardingIndicator(
                        totalStages: 5,
                        currentStage: currentSlide
                    )
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        .animation(.easeInOut, value: currentSlide)
        .transition(.opacity)
        .nexusStyle()
    }
    
    private func completeOnboarding() {
        withAnimation {
            onboardingComplete = true
        }
    }
}

enum DVRole: String {
    case visitor
    case competitor
}

struct DVWelcomeSlide: View {
    let onNext: () -> Void
    
    var body: some View {
        DVBaseSlide(
            buttonText: "Next",
            buttonAction: onNext,
            showBackButton: false
        ) {
            VStack {
                Text("Welcome to")
                    .font(.system(size: 32))
                    .foregroundColor(DVDesignSystem.Colors.text)
                    .fontWeight(.bold)
                
                Text("Design Village!")
                    .font(.system(size: 40, weight: .black))
                    .tracking(1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DVDesignSystem.Colors.text, DVDesignSystem.Colors.textSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .padding(.bottom, 15)
                
                Image("DVLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 150)
                    .cornerRadius(20)
                    .padding(.bottom, 0)
                    .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 15)
                
                VStack(spacing: 15) {
                    Text("NEXUS")
                        .font(.system(size: 34, weight: .black))
                        .tracking(8)
                        .foregroundColor(DVDesignSystem.Colors.text)
                    
                    DVDesignSystem.Effects.accentLine()
                        .frame(width: 200)
                }
                .padding(.bottom, 30)
                
                Text("Let's get you oriented.")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(DVDesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
    }
}

struct DVOverviewSlide: View {
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        DVBaseSlide(
            buttonText: "Next",
            buttonAction: onNext,
            onBack: onBack
        ) {
            VStack {
                DVTitleWithShadow(
                    text: "The DV app has:",
                    font: .system(size: 38, weight: .bold)
                )
                .padding(.bottom, 50)
                
                VStack(alignment: .leading, spacing: 30) {
                    DVIconFeatureRow(icon: "map.fill", text: "A Map of the area")
                    DVIconFeatureRow(icon: "calendar", text: "Schedule for events")
                    DVIconFeatureRow(icon: "info.circle.fill", text: "Info on the history")
                }
                .padding(.horizontal)
            }
        }
    }
}

struct DVRulesSlide: View {
    @Binding var selectedRole: DVRole
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var hasSelectedRole = false
    
    private func competitorRules() -> [(emoji: String, text: String)] {
        [
            (emoji: "🏠", text: "Build a stable shelter"),
            (emoji: "🌿", text: "Preserve the site"),
            (emoji: "📝", text: "Submit documentation"),
            (emoji: "🌙", text: "Stay overnight"),
            (emoji: "⚠️", text: "Follow safety rules")
        ]
    }
    
    private func visitorRules() -> [(emoji: String, text: String)] {
        [
            (emoji: "👥", text: "Follow staff guidance"),
            (emoji: "🚶‍♂️", text: "Stay in visitor areas"),
            (emoji: "🏗️", text: "Respect competitor spaces"),
            (emoji: "✨", text: "Keep a safe distance")
        ]
    }
    
    private func welcomeMessage(for role: DVRole) -> String {
        switch role {
        case .competitor:
            return "Time to build something amazing!"
        case .visitor:
            return "Get ready to be inspired!"
        }
    }
    
    var body: some View {
        DVBaseSlide(
            buttonText: "Next",
            buttonDisabled: !hasSelectedRole,
            buttonAction: onNext,
            onBack: onBack
        ) {
            VStack(spacing: 30) {
                if !hasSelectedRole {
                    DVTitleWithShadow(
                        text: "How are you experiencing Design Village?",
                        font: .system(size: 32, weight: .bold)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                    
                    HStack(spacing: 20) {
                        DVRoleButton(
                            title: "Competitor",
                            emoji: "🏃‍♂️",
                            isSelected: selectedRole == .competitor
                        ) {
                            withAnimation {
                                selectedRole = .competitor
                                hasSelectedRole = true
                            }
                        }
                        
                        DVRoleButton(
                            title: "Visitor",
                            emoji: "👥",
                            isSelected: selectedRole == .visitor
                        ) {
                            withAnimation {
                                selectedRole = .visitor
                                hasSelectedRole = true
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        DVTitleWithShadow(
                            text: selectedRole == .competitor ? "Competitor Rules" : "Visitor Guidelines",
                            font: .system(size: 38, weight: .bold)
                        )
                        
                        Text(welcomeMessage(for: selectedRole))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(DVDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                    
                    if selectedRole == .competitor {
                        VStack(spacing: 16) {
                            ForEach(competitorRules(), id: \.text) { rule in
                                OnboardingCompactRuleRow(emoji: rule.emoji, text: rule.text)
                            }
                            
                            OnboardingCallout(text: "Visit Rules tab for complete guidelines.")
                                .padding(.top, 20)
                        }
                    } else {
                        VStack(spacing: 24) {
                            ForEach(visitorRules(), id: \.text) { rule in
                                DVFeatureRow(emoji: rule.emoji, text: rule.text)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Onboarding-specific Components

private struct OnboardingCompactRuleRow: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))
                .frame(width: 32)
            
            Text(text)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DVDesignSystem.Colors.text)
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DVDesignSystem.Colors.surface)
                .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(DVDesignSystem.Colors.divider, lineWidth: 1)
        )
    }
}

private struct OnboardingCallout: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(DVDesignSystem.Colors.text)
            .multilineTextAlignment(.center)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DVDesignSystem.Colors.yellow.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(DVDesignSystem.Colors.yellow.opacity(0.5), lineWidth: 1)
            )
    }
}

struct DVPolyCanyonSlide: View {
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        DVBaseSlide(
            buttonText: "Next",
            buttonAction: onNext,
            onBack: onBack
        ) {
            VStack {
                DVTitleWithShadow(
                    text: "Curious about\nthe canyon?",
                    font: .system(size: 38, weight: .bold)
                )
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.bottom, 10)
                
                Image("PCOverview")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 200)
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                    .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 8, x: 0, y: 4)
                
                DVSettingsPrompt(text: "Switch to 'Poly Canyon' to explore the structures!")
                    .padding(.horizontal)
            }
        }
    }
}

struct DVFinalSlide: View {
    let onComplete: () -> Void
    @State private var isAnimating = false
    @State private var shouldComplete = false
    @State private var isButtonPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DVDesignSystem.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image("DVNexus")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 350)
                        .scaleEffect(shouldComplete ? 12 : 1)
                        .opacity(shouldComplete ? 0 : 1)
                    
                    VStack(spacing: 0) {
                        DVTitleWithShadow(
                            text: "It takes a village.",
                            font: .system(size: 36, weight: .bold)
                        )
                        .padding(.top, 15)
                        
                        Text("Welcome to the nexus\n of creative connections!")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(DVDesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                    }
                    .opacity(shouldComplete ? 0 : 1)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            shouldComplete = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            onComplete()
                        }
                    } label: {
                        Text("Enter Design Village")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(DVDesignSystem.Colors.text)
                            .frame(width: 250)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(DVDesignSystem.Colors.yellow)
                                    
                                    // Pulsing animation
                                    if !shouldComplete {
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        DVDesignSystem.Colors.orange,
                                                        DVDesignSystem.Colors.teal
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                                            .opacity(isAnimating ? 0.5 : 1.0)
                                    }
                                }
                            )
                            .scaleEffect(isButtonPressed ? 0.96 : 1.0)
                            .shadow(color: DVDesignSystem.Colors.shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .pressAction {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            isButtonPressed = true
                        }
                    } onRelease: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            isButtonPressed = false
                        }
                    }
                    .opacity(shouldComplete ? 0 : 1)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

struct DVOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        DVOnboarding(userRole: .constant(.visitor))
    }
}
