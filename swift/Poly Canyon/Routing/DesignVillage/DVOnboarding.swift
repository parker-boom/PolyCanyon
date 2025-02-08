import SwiftUI

struct DVOnboarding: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @State private var currentSlide: Int = 0

    var body: some View {
        VStack {
            Spacer()
            Group {
                switch currentSlide {
                case 0:
                    DVOnboardingWelcomeView()
                case 1:
                    DVOnboardingOverviewView()
                case 2:
                    DVOnboardingRulesView()
                case 3:
                    DVOnboardingPolyCanyonNoticeView()
                case 4:
                    DVOnboardingConfirmationView()
                default:
                    DVOnboardingWelcomeView()
                }
            }
            Spacer()
            VStack(spacing: 16) {
                Button("Next") {
                    if currentSlide < 4 {
                        currentSlide += 1
                    } else {
                        onboardingComplete = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                if currentSlide > 0 {
                    Button("Previous") {
                        currentSlide -= 1
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct DVOnboardingWelcomeView: View {
    var body: some View {
        Text("Welcome Slide")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
    }
}

struct DVOnboardingOverviewView: View {
    var body: some View {
        Text("App Overview Slide")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
    }
}

struct DVOnboardingRulesView: View {
    var body: some View {
        Text("Rules Slide")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
    }
}

struct DVOnboardingPolyCanyonNoticeView: View {
    var body: some View {
        Text("Poly Canyon Notice Slide")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
    }
}

struct DVOnboardingConfirmationView: View {
    var body: some View {
        Text("Confirmation Slide")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
    }
}

struct DVOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        DVOnboarding()
    }
}
