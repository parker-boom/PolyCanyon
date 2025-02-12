import SwiftUI

struct DVOnboarding: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @State private var currentSlide: Int = 0
    @State private var selectedRole: DVRole = .visitor
    
    private let totalSlides = 5
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentSlide) {
                DVWelcomeSlide(onNext: goToNextSlide)
                    .tag(0)
                
                DVOverviewSlide(onNext: goToNextSlide, onBack: goToPreviousSlide)
                    .tag(1)
                
                DVRulesSlide(
                    selectedRole: $selectedRole,
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

enum DVRole {
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
                    .frame(width: 200, height: 200)
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
                    DVFeatureRow(icon: "map", text: "A Map of the area")
                    DVFeatureRow(icon: "calendar", text: "Schedule for events")
                    DVFeatureRow(icon: "info.circle", text: "Info on the history")
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
                        DVRoleButton(
                            title: "Competitor",
                            icon: "figure.walk",
                            isSelected: selectedRole == .competitor
                        ) {
                            selectedRole = .competitor
                            hasSelectedRole = true
                        }
                        
                        DVRoleButton(
                            title: "Visitor",
                            icon: "person.2",
                            isSelected: selectedRole == .visitor
                        ) {
                            selectedRole = .visitor
                            hasSelectedRole = true
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("As a \(selectedRole == .competitor ? "Competitor" : "Visitor")")
                        .font(.system(size: 38))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.bottom, 40)
                    
                    VStack(alignment: .leading, spacing: 30) {
                        if selectedRole == .competitor {
                            DVFeatureRow(icon: "exclamationmark.triangle", text: "Follow safety guidelines")
                            DVFeatureRow(icon: "clock", text: "Check in on time")
                            DVFeatureRow(icon: "person.2", text: "Stay with your team")
                        } else {
                            DVFeatureRow(icon: "hand.raised", text: "Respect structures")
                            DVFeatureRow(icon: "camera", text: "Photos welcome")
                            DVFeatureRow(icon: "figure.walk", text: "Stay on paths")
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
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
                
                Image("M-25")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
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
        DVOnboarding()
    }
}
