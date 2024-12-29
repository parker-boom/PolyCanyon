/*
 SettingsComponents provides the UI components for the settings interface. It includes sections for general 
 settings (theme, mode, resets), statistics display, and app information. Components adapt to the current 
 theme and app mode, providing appropriate options and visual feedback. The components maintain consistent 
 styling while supporting both adventure and virtual tour modes.
*/

import SwiftUI

// MARK: - General Settings Section
struct GeneralSettingsSection: View {
    @EnvironmentObject var appState: AppState
    
    @Binding var showModePopUp: Bool
    @Binding var showResetAlert: Bool
    @Binding var resetAlertType: SettingsView.ResetAlertType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            Text("General Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.bottom, -5)
            
            VStack(spacing: 10) {
                // Theme selection
                darkModeRow
                
                // App mode selection
                modeToggleRow
                
                // Action buttons row
                HStack(spacing: 10) {
                    // Reset data based on current mode
                    SettingsButton(
                        action: {
                            resetAlertType = appState.adventureModeEnabled 
                                ? .structures 
                                : .favorites
                            showResetAlert = true
                        },
                        imageName: appState.adventureModeEnabled 
                            ? "arrow.clockwise" 
                            : "heart.slash.fill",
                        text: appState.adventureModeEnabled 
                            ? "Reset Structures" 
                            : "Reset Favorites",
                        imgColor: .red,
                        isDarkMode: appState.isDarkMode
                    )
                    
                    // Location permissions access
                    SettingsButton(
                        action: { openSystemSettings() },
                        imageName: "location.fill",
                        text: "Location Settings",
                        imgColor: .green,
                        isDarkMode: appState.isDarkMode
                    )
                }
            }
        }
    }
    
    // Dark mode toggle with icons
    private var darkModeRow: some View {
        HStack {
            Text("Dark Mode")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            Spacer()
            DarkModeToggle()
        }
        .padding()
        .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    // Mode selection with description
    private var modeToggleRow: some View {
        VStack(spacing: 10) {
            // Mode indicator icon
            Image(systemName: appState.adventureModeEnabled ? "figure.walk" : "binoculars")
                .font(.system(size: 40))
                .foregroundColor(appState.adventureModeEnabled ? .green : 
                    Color(red: 255/255, green: 104/255, blue: 3/255))
            
            // Current mode title
            Text(appState.adventureModeEnabled ? "Adventure Mode" : "Virtual Tour Mode")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            // Mode description
            Text(appState.adventureModeEnabled 
                 ? "Explore structures in person" 
                 : "Browse structures remotely")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Mode switch trigger
            Button(action: { showModePopUp = true }) {
                Text("Switch")
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    // Open system settings for location permissions
    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Statistics Section
struct StatisticsSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            Text("Statistics")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.top, 10)
                .padding(.bottom, -5)
            
            HStack(spacing: 10) {
                // Total structures visited
                StatBox(
                    title: "Visited",
                    value: dataStore.visitedCount,
                    iconName: "checkmark.circle.fill"
                )
                
                // Total active days
                StatBox(
                    title: "Days",
                    value: dataStore.dayCount,
                    iconName: "calendar"
                )
            }
        }
    }
}

// MARK: - Credits Section
struct CreditsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            Text("Credits")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            // Attribution list
            VStack(spacing: 15) {
                CreditItem(title: "Developer", name: "Parker Jones")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                CreditItem(title: "Institution", name: "Cal Poly SLO")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                CreditItem(title: "Department", name: "CAED College")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
            }
            
            // Support contact info
            VStack(alignment: .leading, spacing: 10) {
                Text("Report Issues")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                
                Button(action: {
                    if let url = URL(string: "mailto:pjones15@calpoly.edu") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("pjones15@calpoly.edu")
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.top, 10)
            
            Text("Thank you for using the Poly Canyon app!")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - CustomModePopUp
/**
 * Popup for switching between Adventure Mode and Virtual Tour Mode.
 * If you want, you can unify this with other popups in SharedAlerts—but it’s unique enough to keep here.
 */
struct CustomModePopUp: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    @Binding var isPresented: Bool
    
    // Theme colors
    let adventureModeColor = Color.green
    let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)
    
    var body: some View {
        VStack(spacing: 20) {
            // Mode title
            Text(appState.adventureModeEnabled ? "Adventure Mode" : "Virtual Tour")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 10)
            
            // Mode description
            Text(appState.adventureModeEnabled
                 ? "Explore structures in person.\nLocation tracking is used to mark visits."
                 : "Browse structures remotely.\nNo location needed.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Confirmation button
            Button("Confirm Choice") {
                let newMode = appState.adventureModeEnabled
                isPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    locationService.handleModeChange(newMode)
                }
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 150)
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
            .cornerRadius(25)
            
            Spacer()
        }
        .frame(width: 300, height: 300)
        .padding()
        .background(appState.isDarkMode ? Color.black : Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            // Mode icon overlay
            Image(systemName: appState.adventureModeEnabled ? "figure.walk" : "binoculars")
                .font(.system(size: 44))
                .foregroundColor(appState.adventureModeEnabled ? adventureModeColor : virtualTourColor)
                .offset(y: -120)
        )
    }
}

// MARK: - Supporting Components

struct DarkModeToggle: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            // Light mode icon
            Image(systemName: "sun.max.fill")
                .foregroundColor(appState.isDarkMode ? .gray : .yellow)
            
            // Theme toggle
            Toggle("", isOn: $appState.isDarkMode)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            // Dark mode icon
            Image(systemName: "moon.fill")
                .foregroundColor(appState.isDarkMode ? .blue : .gray)
        }
    }
}

// Basic button for settings actions
struct SettingsButton: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    let imageName: String
    let text: String
    let imgColor: Color
    let isDarkMode: Bool
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                    .foregroundColor(imgColor)
                    .padding(.bottom, 5)
                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// Box for displaying statistics
struct StatBox: View {
    @EnvironmentObject var appState: AppState
    let title: String
    let value: Int
    let iconName: String
    
    var body: some View {
        VStack(spacing: 5) {
            // Stat value
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            // Stat label
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
            
            // Stat icon
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// Credit item for attribution list
struct CreditItem: View {
    let title: String
    let name: String
    
    var body: some View {
        HStack {
            // Credit category
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 0)
            
            Spacer()
            
            // Credit value
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading, 15)
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
}