import SwiftUI
import CoreLocation
import Shiny


struct OnboardingView: View {
    @Binding var isNewOnboardingCompleted: Bool
    @Binding var isAdventureModeEnabled: Bool
    @StateObject private var locationManager = OnboardingLocationManager()
    @State private var currentPage = 0
    @State private var hasAskedForLocation = false

    private let totalPages = 3
    let adventureModeColor = Color.green
    let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)

    var body: some View {
        TabView(selection: $currentPage) {
            welcomeSlide
                .tag(0)
            locationRequestSlide
                .tag(1)
            modeSelectionSlide
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentPage)
        .preferredColorScheme(.light)
    }

    var welcomeSlide: some View {
        VStack {
            Spacer()
            
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(40)
                    .padding(.bottom, 30)
                    .shadow(color: .black.opacity(0.4), radius: 15)
                    .shiny()


            Text("Welcome to")
                .font(.system(size: 36))
                .foregroundColor(.black.opacity(1))
                .fontWeight(.bold)
            Text("Poly Canyon")
                .font(.system(size: 42))
                .foregroundColor(.green.opacity(1))
                .fontWeight(.bold)
                .padding(.bottom, 5)
            Text("Explore and learn about Cal Poly's famous architectural structures")
                .font(.system(size: 22))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            NavigationButton(text: "Next", action: {
                withAnimation {
                    currentPage = 1
                }
            })
            .padding(.bottom, 40)
        }
        .padding()
    }

    var locationRequestSlide: some View {
        VStack {
            Spacer()
            PulsingLocationDot()
                .frame(width: 100, height: 100)
                .padding(.bottom, 40)
            Text("Enable")
                .font(.system(size: 36))
                .foregroundColor(.black.opacity(1))
                .fontWeight(.bold)
            Text("Location Services")
                .font(.system(size: 38))
                .foregroundColor(.blue.opacity(1))
                .fontWeight(.bold)
                .padding(.bottom, 5)
            Text("We need your location to enhance your experience")
                .font(.system(size: 22))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            NavigationButton(text: locationManager.hasRequestedLocation ? "Next" : "Allow Location Access", action: {
                if !locationManager.hasRequestedLocation {
                    locationManager.requestLocation()
                } else {
                    withAnimation {
                        currentPage = 2
                    }
                }
            })
            .padding(.bottom, 40)
        }
        .padding()
    }

    var modeSelectionSlide: some View {
        VStack(spacing: 20) {
            Text("Choose Your Experience")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.black.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            ModeIcon(
                imageName: isAdventureModeEnabled ? "figure.walk" : "binoculars",
                color: isAdventureModeEnabled ? adventureModeColor : virtualTourColor,
                isSelected: true
            )
            .padding(.vertical, 30)

            CustomModePicker(
                isAdventureModeEnabled: $isAdventureModeEnabled,
                adventureModeColor: adventureModeColor,
                virtualTourColor: virtualTourColor
            )
            .padding(.horizontal)

            RecommendationLabel(isRecommended: isAdventureModeEnabled == locationManager.isNearCalPoly)

            VStack(alignment: .leading, spacing: 10) {
                if isAdventureModeEnabled {
                    Text("• Explore structures in person")
                        .font(.system(size: 24, weight: .semibold))
                    Text("• Track your progress")
                        .font(.system(size: 24, weight: .semibold))
                    Text("• Use live location")
                        .font(.system(size: 24, weight: .semibold))
                } else {
                    Text("• Browse remotely")
                        .font(.system(size: 24, weight: .semibold))
                    Text("• Learn about all structures")
                        .font(.system(size: 24, weight: .semibold))
                    Text("• No location needed")
                        .font(.system(size: 24, weight: .semibold))
                }
            }
            .font(.system(size: 18))
            .foregroundColor(.black.opacity(0.8))
            .padding(.vertical)

            Spacer()

            Button("Let's Go!") {
                isNewOnboardingCompleted = true
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 150)
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(isAdventureModeEnabled ? adventureModeColor : virtualTourColor)
            .cornerRadius(25)
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color.white)
        .onAppear {
            isAdventureModeEnabled = locationManager.isNearCalPoly
        }
    }
}
struct ModeIcon: View {
    let imageName: String
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .scaleEffect(1.05)
                    .animate()
            }
            
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

struct CustomModePicker: View {
    @Binding var isAdventureModeEnabled: Bool
    let adventureModeColor: Color
    let virtualTourColor: Color

    var body: some View {
        HStack(spacing: 0) {
            ModeButton(
                title: "Virtual Tour",
                isSelected: !isAdventureModeEnabled,
                color: virtualTourColor
            ) {
                withAnimation(.spring()) {
                    isAdventureModeEnabled = false
                }
            }

            ModeButton(
                title: "Adventure",
                isSelected: isAdventureModeEnabled,
                color: adventureModeColor
            ) {
                withAnimation(.spring()) {
                    isAdventureModeEnabled = true
                }
            }
        }
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.2))
        )
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.clear)
                        .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
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

struct PulsingLocationDot: View {
    @State private var scale: CGFloat = 1

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .animation(
                    Animation.easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                    value: scale
                )
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
        }
        .onAppear {
            self.scale = 1.2
        }
    }
}

struct NavigationButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 18, weight: .bold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(25)
        }
    }
}

extension View {
    func animate() -> some View {
        self.modifier(PulseAnimation())
    }
}

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
                self.animationAmount = 1.2
            }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            isNewOnboardingCompleted: .constant(false),
            isAdventureModeEnabled: .constant(false)
        )
    }
}
