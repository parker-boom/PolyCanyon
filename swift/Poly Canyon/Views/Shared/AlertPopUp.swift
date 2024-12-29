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
        }
    }
}