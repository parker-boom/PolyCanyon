import SwiftUI

struct DVOnboarding: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @State private var currentSlide: Int = 0
    @Binding var userRole: DVRole
    
    private let totalSlides = 5
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentSlide) {
                DVWelcomeSlide(onNext: goToNextSlide)
                    .tag(0)
                
                DVOverviewSlide(onNext: goToNextSlide, onBack: goToPreviousSlide)
                    .tag(1)
                
                DVRulesSlide(
                    selectedRole: $userRole,
                    onNext: goToNextSlide,
                    onBack: goToPreviousSlide
                )
                .tag(2)
                
                DVPolyCanyonSlide(onNext: goToNextSlide, onBack: goToPreviousSlide)
                    .tag(3)
                
                DVFinalSlide(onComplete: completeOnboarding)
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentSlide)
            .gesture(DragGesture().onChanged { _ in }.onEnded { _ in })
            
            if currentSlide < 4 {
                DVOnboardingIndicator(
                    totalStages: 5,
                    currentStage: currentSlide
                )
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea()
    }
    
    private func goToNextSlide() {
        withAnimation {
            currentSlide += 1
        }
    }
    
    private func goToPreviousSlide() {
        withAnimation {
            currentSlide -= 1
        }
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
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                
                Text("Design Village!")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.gray]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .fontWeight(.bold)
                    .padding(.bottom, 15)
                
                Image("DVLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 150)
                    .cornerRadius(40)
                    .padding(.bottom, 30)
                    .shadow(color: .black.opacity(0.4), radius: 15)
                
                Text("Let's get you oriented.")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black.opacity(0.8))
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
                Text("The DV app has:")
                    .font(.system(size: 38))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
                
                VStack(alignment: .leading, spacing: 30) {
                    OnboardingOverviewRow(icon: "map", text: "A Map of the area")
                    OnboardingOverviewRow(icon: "calendar", text: "Schedule for events")
                    OnboardingOverviewRow(icon: "info.circle", text: "Info on the history")
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct OnboardingOverviewRow: View {
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
                    Text("How are you experiencing Design Village?")
                        .font(.system(size: 32))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 20) {
                        OnboardingRoleButton(
                            title: "Competitor",
                            emoji: "🏃‍♂️",
                            isSelected: selectedRole == .competitor
                        ) {
                            withAnimation {
                                selectedRole = .competitor
                                hasSelectedRole = true
                            }
                        }
                        
                        OnboardingRoleButton(
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
                        Text(selectedRole == .competitor ? "Competitor Rules" : "Visitor Guidelines")
                            .font(.system(size: 38))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        
                        Text(welcomeMessage(for: selectedRole))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.gray)
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
                                OnboardingFeatureRow(emoji: rule.emoji, text: rule.text)
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

private struct OnboardingRoleButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
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
                    .fill(isSelected ? Color.black : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .black)
        }
    }
}

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
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

private struct OnboardingFeatureRow: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 40)
            
            Text(text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

private struct OnboardingCallout: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.2))
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
                Text("Curious about\nthe canyon?")
                    .font(.system(size: 38))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.bottom, 10)
                
                Image("PCOverview")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 200)
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image("DVNexus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .scaleEffect(shouldComplete ? 12 : 1)
                        .opacity(shouldComplete ? 0 : 1)
                    
                    VStack(spacing: 15) {
                        Text("It takes a village.")
                            .font(.system(size: 36, weight: .bold))
                        Text("Welcome to the nexus of creative connections!")
                            .font(.system(size: 24, weight: .medium))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(shouldComplete ? 0 : 1)
                    .foregroundColor(.black)
                    
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
                            .foregroundColor(.white)
                            .frame(width: 250)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.black)
                            )
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
