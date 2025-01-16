/*
 PopUps provides reusable alert dialogs for consistent messaging across the app. It implements a 
 customizable alert with icon, title, subtitle, and two action buttons. The component adapts to the app's 
 theme and provides a dimmed background overlay. It's designed to be used as a modal presentation for 
 important user interactions.
*/

import SwiftUI


// MARK: - Alert Container
struct AlertContainer: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataStore: DataStore
    let alert: AppState.AlertType
    
    var body: some View {
        switch alert {
        case .resetConfirmation(let type):
            CustomAlert(
                icon: type == .structures ? "arrow.counterclockwise" : "heart.slash.fill",
                iconColor: type == .structures ? .orange : .red,
                title: type == .structures ? "Reset Visited Structures" : "Reset Favorites",
                subtitle: type == .structures
                ? "Are you sure you want to reset all visited structures? This action cannot be undone."
                : "Are you sure you want to reset all favorite structures? This action cannot be undone.",
                primaryButton: .init(title: "Reset") {
                    dataStore.resetStructures()
                    appState.dismissAlert()
                },
                secondaryButton: .init(title: "Cancel") {
                    appState.dismissAlert()
                },
                isPresented: .constant(true)
            )
            
        case .modePicker:
            ModePickerAlert(
                isPresented: .constant(true),
                onDismiss: { appState.dismissAlert() }
            )
        }
    }
}

struct CustomAlert: View {
    // MARK: - Properties
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    // MARK: - Buttons
    let primaryButton: AlertButton
    let secondaryButton: AlertButton
    
    // MARK: - Presentation
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState
    
    struct AlertButton {
        let title: String
        let action: () -> Void
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            // Alert container
            VStack(spacing: 0) {
                // Floating icon circle
                Circle()
                    .fill(appState.isDarkMode ? Color.black : Color.white)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 60))
                            .foregroundColor(iconColor)
                    )
                    .offset(y: 60)
                    .zIndex(1)
                
                // Alert content
                VStack(spacing: 15) {
                    // Title and subtitle
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                        .padding(.top, 70)
                    
                    Text(subtitle)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                    
                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            isPresented = false
                            primaryButton.action()
                        }) {
                            Text(primaryButton.title)
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isPresented = false
                            secondaryButton.action()
                        }) {
                            Text(secondaryButton.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                                .underline()
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .background(appState.isDarkMode ? Color.black : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(appState.isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(width: 300)
            .shadow(color: appState.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.2),
                    radius: 10, x: 0, y: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -UIScreen.main.bounds.height * 0.1)
        }
    }
}

struct ModePickerAlert: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    @State private var selectedMode: Bool = false // Default value
    
    init(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: onDismiss)
            
            // Alert content
            VStack(spacing: 25) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                
                // Mode icons
                HStack(spacing: 40) {
                    ModeOption(
                        isSelected: selectedMode == false,
                        icon: "binoculars",
                        title: "Virtual Tour",
                        color: .orange
                    )
                    .onTapGesture { selectedMode = false }
                    
                    ModeOption(
                        isSelected: selectedMode == true,
                        icon: "figure.walk",
                        title: "Adventure",
                        color: .green
                    )
                    .onTapGesture { selectedMode = true }
                }
                
                // Description
                Text(selectedMode ? 
                    "Explore structures in person with live location tracking" :
                    "Browse and learn about structures from anywhere"
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
                
                // Confirm button (only if mode changed)
                if selectedMode != appState.adventureModeEnabled {
                    Button(action: {
                        locationService.setMode(selectedMode ? .adventure : .virtualTour)
                        appState.adventureModeEnabled = selectedMode
                        onDismiss()
                    }) {
                        Text("Confirm Change")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding()
                            .background(selectedMode ? Color.green : Color.orange)
                            .cornerRadius(15)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(30)
        }
        .onAppear {
            selectedMode = appState.adventureModeEnabled
        }
    }
}

private struct ModeOption: View {
    let isSelected: Bool
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(isSelected ? color : .gray)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? color : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
}

struct WelcomeToCanyonAlert: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    appState.hasVisitedCanyon = true
                }
            
            // Alert content
            VStack(spacing: 28) {
                // Header
                HStack(spacing: 20) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 55, height: 55)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text("Welcome to")
                            .font(.system(size: 18))
                        Text("Poly Canyon!")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Here's what you can do:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(appState.isDarkMode ? .white.opacity(0.9) : .black.opacity(0.9))
                        .padding(.leading, 4)
                        .padding(.bottom, -4)
                    
                    ForEach([
                        (emoji: "📍", text: "See your live location"),
                        (emoji: "📚", text: "View info on structures"),
                        (emoji: "✅", text: "Auto track your progress"),
                    ], id: \.text) { bullet in
                        HStack(spacing: 14) {
                            Text(bullet.emoji)
                                .font(.system(size: 24))
                            Text(bullet.text)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .frame(width: 260)  // Fixed width for all bullets
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(appState.isDarkMode ?
                                    Color(white: 0.15) :  // Solid dark gray
                                    Color(white: 0.97)    // Solid light gray
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(appState.isDarkMode ? 0.2 : 0.5),
                                            Color.white.opacity(0.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                }
                
                // Action button
                Button {
                    appState.hasVisitedCanyon = true
                } label: {
                    Text("Get Exploring")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 160)
                        .padding(.vertical, 14)
                        .background(Color(hex: "59903e"))
                        .cornerRadius(14)
                        .shadow(color: Color(hex: "59903e").opacity(0.3), radius: 8, y: 4)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(appState.isDarkMode ?
                        Color(white: 0.1) :     // Solid dark background
                        Color(white: 0.95)       // Solid light background
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(appState.isDarkMode ? 0.07 : 0.7),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(appState.isDarkMode ? 0.3 : 0.6),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 20)
            .padding(30)
        }
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ZStack {
        // Simulate main app background
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        // Simulate some app content
        VStack {
            Text("Map View")
                .font(.largeTitle)
            Spacer()
        }
        
        // Our alert
        WelcomeToCanyonAlert()
    }
    .environmentObject({
        let state = AppState()
        state.isDarkMode = false
        return state
    }())
}

#Preview("Dark Mode") {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        VStack {
            Text("Map View")
                .font(.largeTitle)
                .foregroundColor(.white)
            Spacer()
        }
        
        WelcomeToCanyonAlert()
    }
    .environmentObject({
        let state = AppState()
        state.isDarkMode = true
        return state
    }())
}
