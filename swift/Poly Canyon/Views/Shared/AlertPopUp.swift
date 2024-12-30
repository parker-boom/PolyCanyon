/*
 AlertPopUp provides reusable alert dialogs for consistent messaging across the app. It implements a 
 customizable alert with icon, title, subtitle, and two action buttons. The component adapts to the app's 
 theme and provides a dimmed background overlay. It's designed to be used as a modal presentation for 
 important user interactions.
*/

import SwiftUI

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