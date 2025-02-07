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
    
    let onModeSwitch: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("General Settings")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                
                Spacer()
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.bottom, 5)
            
            VStack(spacing: 15) {
                modeToggleRow
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(appState.isDarkMode ? 
                        Color.gray.opacity(0.15) : 
                        Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                appState.isDarkMode ? 
                                    Color.white.opacity(0.1) : 
                                    Color.black.opacity(0.05),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: appState.isDarkMode ? 
                            .black.opacity(0.3) : 
                            .gray.opacity(0.2),
                        radius: 10, x: 0, y: 5
                    )
            )
            
            // Action buttons row with updated styling
            HStack(spacing: 12) {
                SettingsButton(
                    action: onReset,
                    imageName: appState.adventureModeEnabled ? 
                        "arrow.clockwise" : 
                        "heart.slash.fill",
                    text: appState.adventureModeEnabled ? 
                        "Reset Progress" : 
                        "Reset Liked",
                    imgColor: .red,
                    isDarkMode: appState.isDarkMode
                )
                
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
            Button(action: {
                appState.showAlert(.modePicker(currentMode: appState.adventureModeEnabled))
            }) {
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
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(appState.isDarkMode ? Color.gray.opacity(0.15) : Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(appState.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
                .shadow(color: appState.isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.65),
                       radius: 6, x: 0, y: 3)
        )
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
            HStack {
                Text("Statistics")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.top, 10)
            .padding(.bottom, -5)
            
            HStack(spacing: 12) {
                StatBox(
                    title: "Visited",
                    value: dataStore.totalVisitedCount,
                    iconName: "checkmark.circle.fill"
                )
                
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
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                Text("Credits")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
            }
            
            // Attribution list
            VStack(spacing: 15) {
                CreditItem(title: "Developer", name: "Parker Jones")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                CreditItem(title: "Institution", name: "Cal Poly SLO")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                CreditItem(title: "Department", name: "CAED College")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                
                Image("CAEDLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.top, 10)
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

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(appState.isDarkMode ? Color.gray.opacity(0.15) : Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(appState.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
                .shadow(color: appState.isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.65),
                       radius: 6, x: 0, y: 3)
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
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isDarkMode ? Color.gray.opacity(0.15) : Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    )
                    .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.65),
                           radius: 6, x: 0, y: 3)
            )
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
        VStack(spacing: 12) {
            Text("\(value)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(appState.isDarkMode ? .white : .black)
            
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
            
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(appState.isDarkMode ? Color.gray.opacity(0.15) : Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(appState.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
                .shadow(color: appState.isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.65),
                       radius: 6, x: 0, y: 3)
        )
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
