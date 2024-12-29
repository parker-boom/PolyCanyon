/**
 * OnboardingView
 *
 * Guides new users through the onboarding process of the Poly Canyon app. It consists of three main slides:
 * 1. WelcomeSlide
 * 2. LocationRequestSlide
 * 3. ModeSelectionSlide
 *
 * Each slide is a private sub-struct below, contained in this same file for simplicity.
 * The parent OnboardingView orchestrates the TabView and environment objects.
 */
import SwiftUI
import CoreLocation
import Shiny



// MARK: - OnboardingView (Top-Level)

struct OnboardingView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - View State
    @State private var currentPage = 0
    private let totalPages = 3
    
    // MARK: - Theme Colors
    private let adventureModeColor = Color.green
    private let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)
    
    var body: some View {
        TabView(selection: $currentPage) {
            // App introduction and welcome
            WelcomeSlide(onNext: goToNextSlide)
                .tag(0)
            
            // Location permissions and mode recommendation
            LocationRequestSlide(
                onNext: goToNextSlide,
                adventureModeColor: adventureModeColor,
                virtualTourColor: virtualTourColor
            )
            .tag(1)
            
            // Final mode selection and setup
            ModeSelectionSlide(
                adventureModeColor: adventureModeColor,
                virtualTourColor: virtualTourColor
            )
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentPage)
    }
    
    // Advance to next onboarding slide
    private func goToNextSlide() {
        withAnimation {
            currentPage += 1
        }
    }
}

// MARK: - Slide 1: WelcomeSlide
// Shows welcome message and app logo
private struct WelcomeSlide: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // Animated app icon
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(40)
                .padding(.bottom, 30)
                .shadow(color: .black.opacity(0.4), radius: 15)
                .shiny()
            
            // Welcome text
            Text("Welcome to")
                .font(.system(size: 36))
                .foregroundColor(.black)
                .fontWeight(.bold)
            Text("Poly Canyon")
                .font(.system(size: 42))
                .foregroundColor(.green)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            Text("Explore and learn about Cal Poly's famous architectural structures.")
                .font(.system(size: 22))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Next button
            NavigationButton(text: "Next", action: onNext)
                .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Slide 2: LocationRequestSlide
// Requests location permission and recommends mode based on location (shown next slide)
private struct LocationRequestSlide: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    let onNext: () -> Void
    let adventureModeColor: Color
    let virtualTourColor: Color
    
    var body: some View {
        VStack {
            Spacer()
            
            // Animated location indicator
            PulsingLocationDot()
                .frame(width: 100, height: 100)
                .padding(.bottom, 40)
            
            // Permission request text
            Text("Enable")
                .font(.system(size: 36))
                .foregroundColor(.black)
                .fontWeight(.bold)
            Text("Location Services")
                .font(.system(size: 38))
                .foregroundColor(.blue)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            Text("We need your location to enhance your experience")
                .font(.system(size: 22))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Show permission button or continue based on status
            if locationService.locationStatus == .notDetermined {
                NavigationButton(text: "Allow Location Access") {
                    Task {
                        let granted = await locationService.requestInitialPermission()
                        if granted {
                            // Set recommended mode based on location
                            if let loc = locationService.lastLocation {
                                appState.adventureModeEnabled = locationService.getRecommendedMode(loc)
                            } else {
                                appState.adventureModeEnabled = false
                            }
                            onNext()
                        } else {
                            appState.adventureModeEnabled = false
                            onNext()
                        }
                    }
                }
            } else {
                NavigationButton(text: "Next") {
                    onNext()
                }
            }
        }
        .padding()
    }
}

// MARK: - Slide 3: ModeSelectionSlide
// Shows recommended mode and allows user to select and complete onboarding
private struct ModeSelectionSlide: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    let adventureModeColor: Color
    let virtualTourColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Experience")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.black.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            ModeIcon(
                imageName: appState.adventureModeEnabled ? "figure.walk" : "binoculars",
                color: appState.adventureModeEnabled ? adventureModeColor : virtualTourColor,
                isSelected: true
            )
            .padding(.vertical, 30)
            
            CustomModePicker(
                isAdventureModeEnabled: $appState.adventureModeEnabled,
                adventureModeColor: adventureModeColor,
                virtualTourColor: virtualTourColor
            )
            
            RecommendationLabel(
                isRecommended: locationService.lastLocation.map {
                    locationService.getRecommendedMode($0) == appState.adventureModeEnabled
                } ?? false
            )
            
            VStack(alignment: .leading, spacing: 10) {
                if appState.adventureModeEnabled {
                    Text("• Explore structures in person")
                    Text("• Track your progress")
                    Text("• Use live location")
                } else {
                    Text("• Browse remotely")
                    Text("• Learn about all structures")
                    Text("• No location needed")
                }
            }
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.black.opacity(0.8))
            .padding(.vertical)
            
            Spacer()
            
            // Finished navigation button
            Button("Let's Go!") {
                // Mark onboarding complete
                appState.isOnboardingCompleted = true
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 150)
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
            .cornerRadius(25)
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView()
                .environmentObject(AppState())
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
            
            OnboardingView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(LocationService.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}