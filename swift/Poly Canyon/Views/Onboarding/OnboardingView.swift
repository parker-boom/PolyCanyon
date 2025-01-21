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

enum OnboardingLocationState {
    case noLocation
    case notComing    // > 30 miles
    case notVisiting  // < 30 miles
    case visiting     // In canyon
}

private struct LocationStateKey: EnvironmentKey {
    static let defaultValue: OnboardingLocationState = .noLocation
}

extension EnvironmentValues {
    var locationState: OnboardingLocationState {
        get { self[LocationStateKey.self] }
        set { self[LocationStateKey.self] = newValue }
    }
}

struct OnboardingView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - View State
    @State private var currentPage = 0
    private let totalPages = 5
    
    @State private var locationState: OnboardingLocationState = .noLocation
    
    // MARK: - Theme Colors
    private let adventureModeColor = Color.green
    private let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)

    // MARK: - 4 Stages Indicator Icons
    // (Feel free to choose whatever SF Symbols you want for each stage)
    private let stageIcons = [
        "hand.wave.fill",       // Page 0
        "location.fill",   // Page 1
        "switch.2",     // Page 2
        "magnifyingglass"        // Page 3
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // The TabView - we're disabling the default paging/swipe with a do-nothing gesture
            TabView(selection: $currentPage) {
                // PAGE 0: Welcome Slide
                WelcomeSlide(onNext: goToNextSlide)
                    .tag(0)
                
                // PAGE 1: Location Request
                LocationRequestSlide(
                    onNext: goToNextSlide,
                    locationState: $locationState
                )
                .tag(1)
                
                // PAGE 2: Mode Selection
                ModeSelectionSlide(
                    onNext: goToNextSlide,
                    adventureModeColor: adventureModeColor,
                    virtualTourColor: virtualTourColor,
                    locationState: $locationState
                )
                .tag(2)
                
                // PAGE 3: Mode Follow-Up
                ModeFollowUpSlide(onNext: goToNextSlide)
                    .tag(3)
                
                // PAGE 4: Final Slide
                FinalSlide()
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            // CHANGES: disable swipe
            .gesture(DragGesture().onChanged { _ in }.onEnded { _ in })
            
            // CHANGES: Add custom stage indicator for pages 0..3
            if currentPage < 4 {
                OnboardingIndicator(
                    totalStages: 4,
                    currentStage: currentPage,
                    stageIcons: stageIcons
                )
                .padding(.top, 20)
            }
        }
        .onChange(of: currentPage) { page in
            print("📄 OnboardingView: Navigated to page \(page)")
        }
        .onChange(of: locationState) { newState in
            print("📍 OnboardingView: Location state updated to \(newState)")
        }
    }
    
    // Advance to next onboarding slide
    private func goToNextSlide() {
        print("➡️ Moving to slide \(currentPage + 1)")
        print("📱 Current mode: \(appState.adventureModeEnabled ? "Adventure" : "Virtual Tour")")
        print("📍 Location state: \(locationState)")
        
        withAnimation {
            currentPage += 1
        }
    }
    

}

// MARK: - A Reusable Stage Indicator

private struct OnboardingIndicator: View {
    let totalStages: Int
    let currentStage: Int
    let stageIcons: [String] // e.g. ["hand.wave", "location.fill", "figure.walk", "gearshape"]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalStages, id: \.self) { index in
                if index == currentStage {
                    // show the custom icon for the current stage
                    Image(systemName: stageIcons[index])
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                } else {
                    // show a small "dot"
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(width: 130, height: 40)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

private struct BaseSlide<Content: View>: View {
    // MARK: - Properties
    let content: Content
    let buttonText: String
    let buttonAction: () -> Void
    let buttonDisabled: Bool
    let buttonIcon: String
    
    // Content builder initializer
    init(
        buttonText: String = "Next",
        buttonDisabled: Bool = false,
        buttonAction: @escaping () -> Void,
        buttonIcon: String = "chevron.right",
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.buttonDisabled = buttonDisabled
        self.buttonIcon = buttonIcon
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            // Main content area (customizable per slide)
            content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 10) // Fixed top padding
            
            Spacer() // Flexible space
            
            // Next button
            NavigationButton(
                text: buttonText,
                action: buttonAction,
                iconName: buttonIcon,
                isDisabled: buttonDisabled
            )
            .padding(.bottom, 60) // Fixed bottom padding
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}


// MARK: - Slide 1: WelcomeSlide
// Shows welcome message and app logo
private struct WelcomeSlide: View {
    let onNext: () -> Void
    
    var body: some View {
        BaseSlide(buttonText: "Next", buttonAction: onNext) {
            VStack {
                Text("Time to discover")
                    .font(.system(size: 32))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                Text("Poly Canyon")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#3a7130"), Color(hex: "#295033")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .fontWeight(.bold)
                    .padding(.bottom, 15)

                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(40)
                    .shiny()
                    .padding(.bottom, 30)
                    .shadow(color: .black.opacity(0.4), radius: 15)
                    
                
                Text("Before you start exploring, let's get things ready.")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
    }
}

// MARK: - Slide 2: LocationRequestSlide
// Requests location permission and recommends mode based on location (shown next slide)
private struct LocationRequestSlide: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    let onNext: () -> Void
    @Binding var locationState: OnboardingLocationState
    @State private var hasGrantedPermission = false
    
    private enum LocationState {
        case unrequested
        case accepted
        case denied
    }
    
    private var currentState: LocationState {
        switch locationService.locationStatus {
        case .notDetermined:
            return .unrequested
        case .authorizedWhenInUse, .authorizedAlways:
            return .accepted
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
    
    var body: some View {
        BaseSlide(
            buttonText: "Next",
            buttonDisabled: currentState == .unrequested,
            buttonAction: {
                determineLocationState()
                onNext()
            }
        ) {
            VStack {
                switch currentState {
                case .unrequested:
                    UnrequestedView {
                        Task {
                            let granted = await locationService.requestInitialPermission()
                            if granted {
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                determineLocationState()
                                hasGrantedPermission = true
                            }
                        }
                    }
                    
                case .accepted:
                    VStack(spacing: 0) {
                        Text("We've got")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        
                        Text("your location")
                            .font(.system(size: 45))
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                            .padding(.top, 0)
                        
                        Text("✅")
                            .font(.system(size: 100))
                            .padding(.top, 10)
                            
                        
                        Text("Let's keep going.")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                    }
                    
                case .denied:
                    VStack(spacing: 0) {
                        Text("We can't access")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        
                        Text("your location")
                            .font(.system(size: 45))
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .padding(.top, -5)
                        
                        Text("❌")
                            .font(.system(size: 100))
                            .padding(.top, 20)
                        
                        Text("You can still explore the app virtually")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "gear")
                                Text("Open Settings")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(Color.gray)
                            .cornerRadius(25)
                        }
                        .padding(.top, 30)
                    }
                }
            }
        }
        .onChange(of: currentState) { newState in
            if newState != .unrequested {
                determineLocationState()
            }
        }
    }
    
    private func determineLocationState() {
        if locationService.isLocationPermissionDenied {
            locationState = .noLocation
            appState.adventureModeEnabled = false
            return
        }
        
        // Default to adventure mode unless explicitly determined otherwise
        if let location = locationService.lastLocation {
            if locationService.isInPolyCanyonArea {
                locationState = .visiting
                appState.adventureModeEnabled = true
            } else if locationService.getRecommendedMode(location) {
                locationState = .notVisiting
                appState.adventureModeEnabled = true
            } else {
                locationState = .notComing
                appState.adventureModeEnabled = false
            }
        } else {
            // No location yet, but permissions granted
            locationState = .notVisiting // Default to adventure mode
            appState.adventureModeEnabled = true
        }
    }
}

// Helper view for unrequested state
private struct UnrequestedView: View {
    let requestLocation: () -> Void
    
    var body: some View {
        VStack {
            Text("First, we need")
                .font(.system(size: 32))
                .foregroundColor(.black)
                .fontWeight(.bold)

            
            Text("your location")
                .font(.system(size: 45))
                .foregroundColor(.blue)
                .fontWeight(.bold)
                .padding(.top, -5)
                .padding(.bottom, 35)
            
            PulsingLocationDot()
                .frame(width: 100, height: 100)
                .padding(.bottom, 40)
            
            Text("This helps us know if you're visiting the canyon")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Button(action: requestLocation) {
                HStack {
                    Image(systemName: "location")
                    Text("Enable Location")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Slide 3: ModeSelectionSlide
// Shows recommended mode and allows user to select and complete onboarding
private struct ModeSelectionSlide: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    let onNext: () -> Void
    let adventureModeColor: Color
    let virtualTourColor: Color
    @Binding var locationState: OnboardingLocationState
    
    private var isVirtualTourGroup: Bool {
        [.noLocation, .notComing].contains(locationState)
    }
    
    private var currentModeColor: Color {
        isVirtualTourGroup ? virtualTourColor : adventureModeColor
    }
    
    var body: some View {
        BaseSlide(
            buttonText: "Next",
            buttonAction: completeModeSelection
        ) {
            VStack(spacing: 10) {

                    Text(isVirtualTourGroup ? "Let's do a" : "It's time for")
                        .font(.system(size: 32))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.bottom, -10)
                    
                    Text(isVirtualTourGroup ? "Virtual Visit" : "An Adventure")
                        .font(.system(size: 42))
                        .foregroundColor(currentModeColor)
                        .fontWeight(.bold)
                        .padding(.bottom, 15)

                
                // Mode Icon Container
                VStack {
                    Image(systemName: isVirtualTourGroup ? "binoculars" : "figure.walk")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .foregroundColor(currentModeColor)
                        .padding(30)
                }
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.25), radius: 10)
                )
                
                // Mode Description
                Text(titleText)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 20)
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Ensure mode is set correctly when slide appears
            appState.adventureModeEnabled = !isVirtualTourGroup
        }
    }
    
    private func completeModeSelection() {
        let isAdventureMode = !isVirtualTourGroup
        appState.adventureModeEnabled = isAdventureMode
        locationService.setMode(isAdventureMode ? .adventure : .virtualTour)
        onNext()
    }
    
    private var titleText: String {
        switch locationState {
        case .noLocation: return "With no location,\nyou'll need to be virtual"
        case .notComing: return "Looks like you aren't\ngoing to visit the canyon"
        case .notVisiting: return "I see a canyon visit\nin your near future"
        case .visiting: return "You're here! Let's\nget you started ASAP."
        }
    }
}

// MARK: - Slide 4: ModeFollowUpSlide
private struct ModeFollowUpSlide: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    let onNext: () -> Void
    
    private let adventureModeColor = Color.green
    private let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)
    
    @State private var hasRequestedAlways = false
    
    private var isVirtualTour: Bool {
        !appState.adventureModeEnabled
    }
    
    private func requestAlwaysAuthorization() {
        locationService.requestAlwaysAuthorization()
        // Give UI time to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasRequestedAlways = true
        }
    }
    
    var body: some View {
        BaseSlide(
            buttonText: "Next",
            buttonDisabled: !isVirtualTour && !hasRequestedAlways,
            buttonAction: onNext
        ) {
            VStack(spacing: 25) {
                if isVirtualTour {
                    // Virtual Tour Content
                    VStack{
                        Text("Best ways to")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                        Text("Virtually Explore:")
                            .font(.system(size: 38))
                            .foregroundColor(virtualTourColor)
                            .fontWeight(.bold)
                    }

                    
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(icon: "map", text: "Take a virtual tour\nof the canyon")
                        FeatureRow(icon: "doc.text", text: "Uncover key details\nabout structures")
                        FeatureRow(icon: "heart", text: "Mark your favorites\nas you explore")
                    }
                    .padding(.top, 20)
                    
                } else {

                    VStack{
                        Text("Let's auto track")
                            .font(.system(size: 32))
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                        Text("Your Adventure:")
                            .font(.system(size: 38))
                            .foregroundColor(adventureModeColor)
                            .fontWeight(.bold)
                    }

                    
                    ZStack {
                        PulsingAdvDot()
                            .frame(width: 120, height: 120)
                            .foregroundColor(adventureModeColor)
                        
                        Image(systemName: "figure.walk")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 15)
                    
                    Text("Background tracking will mark the structures you visit")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        requestAlwaysAuthorization()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Enable Location")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal)
        }
    }
}

// Helper view for Virtual Tour features
private struct FeatureRow: View {
    let icon: String
    let text: String
    
    private let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .bold))
                .frame(width: 40)
                .foregroundColor(virtualTourColor)
            
            Text(text)
                .font(.system(size: 24, weight: .medium))
        }
    }
}


// MARK: - Slide 5: FinalSlide
private struct FinalSlide: View {
    @EnvironmentObject var appState: AppState
    
    private let adventureModeColor = Color.green
    private let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)
    
    @State private var isAnimating = false
    @State private var shouldComplete = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                (appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
                    .opacity(0.1)
                    .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
                    .ignoresSafeArea()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Icon with pulsing effect
                    ZStack {
                        // Outer pulse circle
                        Circle()
                            .fill(appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
                            .opacity(0.2)
                            .frame(width: 140, height: 140)
                            .scaleEffect(isAnimating ? 1.2 : 0.9)
                        
                        // Inner circle with icon
                        Circle()
                            .fill(appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: appState.adventureModeEnabled ? "figure.walk" : "binoculars")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                                    .foregroundColor(.white)
                            )
                    }
                    .scaleEffect(shouldComplete ? 12 : 1)
                    .opacity(shouldComplete ? 0 : 1)
                    
                    // Welcome Text
                    VStack(spacing: 15) {
                        Text("You're all set!")
                            .font(.system(size: 36, weight: .bold))
                            .opacity(shouldComplete ? 0 : 1)
                        
                        Text(appState.adventureModeEnabled ?
                             "Time to explore the canyon" :
                             "Time to learn about the canyon")
                            .font(.system(size: 24, weight: .medium))
                            .multilineTextAlignment(.center)
                            .opacity(shouldComplete ? 0 : 1)
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Start Button
                    Button {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            shouldComplete = true
                        }
                        
                        // Delay to allow animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            appState.isOnboardingCompleted = true
                        }
                    } label: {
                        Text("Begin")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
                            )
                    }
                    .opacity(shouldComplete ? 0 : 1)
                    .padding(.bottom, 50)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
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

