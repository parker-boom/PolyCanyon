// MARK: SettingsView.swift

import SwiftUI

/**
 * SettingsView
 *
 * Provides a settings interface for the Poly Canyon app, allowing users to:
 * - Toggle Dark Mode and Adventure Mode.
 * - Reset visited structures or favorites.
 * - View user statistics such as visited structures and days visited.
 * - Access additional information and credits.
 * - Receive confirmations for critical actions like resetting structures.
 */
struct SettingsView: View {
    // MARK: - Observed Objects
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @ObservedObject var locationManager: LocationManager
    
    // MARK: - Binding Properties
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    // MARK: - State Properties
    @State private var showAlert = false
    @State private var alertType: AlertType?
    @State private var showModePopUp = false
    @State private var showStructureSwipingView = false
    @State private var showHowToGetThereGuide = false
    @State private var showResetAlert = false
    @State private var resetAlertType: ResetAlertType?
    
    // MARK: - App Storage
    @AppStorage("visitedCount") private var visitedCount: Int = 0
    
    // MARK: - Enums
    
    /**
     * AlertType
     *
     * Defines the type of alert to display based on user actions.
     */
    enum AlertType {
        case resetVisited, resetFavorites, toggleAdventureModeOff
    }
    
    /**
     * ResetAlertType
     *
     * Specifies the type of reset action the user is attempting.
     */
    enum ResetAlertType {
        case structures
        case favorites
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                generalSettingsSection
                informationSection
                if isAdventureModeEnabled {
                    statisticsSection
                }
                creditsSection
            }
            .padding()
        }
        .background(isDarkMode ? Color.black : Color.white)
        .overlay(
            Group {
                // Mode Picker Popup
                if showModePopUp {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showModePopUp = false
                        }
                    
                    CustomModePopUp(
                        isAdventureModeEnabled: $isAdventureModeEnabled,
                        isPresented: $showModePopUp,
                        isDarkMode: $isDarkMode,
                        structureData: structureData,
                        mapPointManager: mapPointManager,
                        locationManager: locationManager
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                }
                
                // How to Get There Guide
                if showHowToGetThereGuide {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showHowToGetThereGuide = false
                        }
                    
                    HowToGetThereGuide(
                        isPresented: $showHowToGetThereGuide,
                        isDarkMode: $isDarkMode
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                    .zIndex(1)
                }
                
                // Reset Alerts
                if showResetAlert {
                    resetAlertView
                }
            }
        )
    }
    
    // MARK: - Sections
    
    /**
     * generalSettingsSection
     *
     * Contains toggles for Dark Mode and Adventure Mode, as well as buttons to reset structures or favorites.
     */
    private var generalSettingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.bottom, -5)
            
            VStack(spacing: 10) {
                // Dark Mode Toggle
                HStack {
                    Text("Dark Mode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white : .black)
                    Spacer()
                    DarkModeToggle(isOn: $isDarkMode)
                }
                .padding()
                .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Adventure Mode Toggle and Information
                VStack(spacing: 10) {
                    // Mode Icon
                    Image(systemName: isAdventureModeEnabled ? "figure.walk" : "binoculars")
                        .font(.system(size: 40))
                        .foregroundColor(isAdventureModeEnabled ? .green : Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0))
                    
                    // Mode Title
                    Text(isAdventureModeEnabled ? "Adventure Mode" : "Virtual Tour Mode")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    // Mode Description
                    Text(isAdventureModeEnabled ? "Explore structures in person" : "Browse structures remotely")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // Switch Button
                    Button(action: {
                        showModePopUp = true
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
                .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Reset and Location Settings Buttons
                HStack(spacing: 10) {
                    // Reset Button
                    SettingsButton(
                        action: {
                            if isAdventureModeEnabled {
                                showResetStructuresAlert()
                            } else {
                                showResetFavoritesAlert()
                            }
                        },
                        imageName: isAdventureModeEnabled ? "arrow.clockwise" : "heart.slash.fill",
                        text: isAdventureModeEnabled ? "Reset Structures" : "Reset Favorites",
                        imgColor: .red,
                        isDarkMode: isDarkMode
                    )
                    
                    // Location Settings Button
                    SettingsButton(
                        action: {
                            openSettings()
                        },
                        imageName: "location.fill",
                        text: "Location Settings",
                        imgColor: .green,
                        isDarkMode: isDarkMode
                    )
                }
            }
        }
    }
    
    /**
     * statisticsSection
     *
     * Displays user statistics such as the number of visited structures and days visited.
     */
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Statistics")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.top, 10)
                .padding(.bottom, -5)
            
            HStack(spacing: 10) {
                StatBox(
                    title: "Visited",
                    value: visitedCount,
                    iconName: "checkmark.circle.fill",
                    isDarkMode: isDarkMode
                )
                StatBox(
                    title: "Days",
                    value: locationManager.dayCount,
                    iconName: "calendar",
                    isDarkMode: isDarkMode
                )
            }
        }
    }
    
    /**
     * informationSection
     *
     * Provides additional information buttons such as "How to get there" or "Pick your favorites" based on Adventure Mode.
     */
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Information")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.bottom, -5)

            if isAdventureModeEnabled {
                // How to Get There Button
                InformationButton(
                    action: { showHowToGetThereGuide = true },
                    title: "How to get there",
                    icon: AnyView(
                        HStack(spacing: 15) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 28))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 22))
                            Image(systemName: "figure.walk")
                                .font(.system(size: 28))
                        }
                    ),
                    gradientColors: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)],
                    isDarkMode: isDarkMode
                )
            } else {
                // Pick Your Favorites Button
                InformationButton(
                    action: { showStructureSwipingView = true },
                    title: "Pick your favorites",
                    icon: AnyView(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 54))
                            .foregroundColor(.white)
                    ),
                    gradientColors: isDarkMode
                        ? [Color.red.opacity(0.9), Color.red.opacity(0.4)]
                        : [Color.red.opacity(0.8), Color.red.opacity(0.3)],
                    isDarkMode: isDarkMode
                )
                .sheet(isPresented: $showStructureSwipingView) {
                    StructureSwipingView(structureData: structureData, isDarkMode: $isDarkMode)
                }
            }
        }
    }
    
    /**
     * creditsSection
     *
     * Displays credits information including developer name, institution, department, and contact information.
     */
    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Credits")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
            
            VStack(spacing: 15) {
                CreditItem(title: "Developer", name: "Parker Jones")
                    .foregroundColor(isDarkMode ? .white : .black)
                CreditItem(title: "Institution", name: "Cal Poly SLO")
                    .foregroundColor(isDarkMode ? .white : .black)
                CreditItem(title: "Department", name: "CAED College")
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Report Issues")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white : .black)
                
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
        .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    // MARK: - Alert Views
    
    /**
     * resetAlertView
     *
     * Displays a confirmation alert when the user attempts to reset structures or favorites.
     */
    private var resetAlertView: some View {
        Group {
            if let alertType = resetAlertType {
                CustomAlert(
                    icon: alertType == .structures ? "arrow.counterclockwise" : "heart.slash.fill",
                    iconColor: alertType == .structures ? .orange : .red,
                    title: alertType == .structures ? "Reset Visited Structures" : "Reset Favorites",
                    subtitle: alertType == .structures ?
                        "Are you sure you want to reset all visited structures? This action cannot be undone." :
                        "Are you sure you want to reset all favorite structures? This action cannot be undone.",
                    primaryButton: .init(title: "Reset") {
                        if alertType == .structures {
                            structureData.resetVisitedStructures()
                            mapPointManager.resetVisitedMapPoints()
                        } else {
                            structureData.resetFavorites()
                        }
                    },
                    secondaryButton: .init(title: "Cancel") {
                        // Handle cancellation if needed
                    },
                    isPresented: $showResetAlert,
                    isDarkMode: $isDarkMode
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /**
     * Shows the alert for resetting visited structures.
     */
    private func showResetStructuresAlert() {
        resetAlertType = .structures
        showResetAlert = true
    }

    /**
     * Shows the alert for resetting favorite structures.
     */
    private func showResetFavoritesAlert() {
        resetAlertType = .favorites
        showResetAlert = true
    }
    
    /**
     * Opens the app's settings page in the device settings.
     */
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - Subviews

/**
 * InformationButton
 *
 * A customizable button used in the information section to navigate to different guides or actions.
 */
struct InformationButton: View {
    let action: () -> Void
    let title: String
    let icon: AnyView
    let gradientColors: [Color]
    let isDarkMode: Bool

    var body: some View {
        Button(action: action) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        icon
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        Text(title)
                            .font(.system(size: 26, weight: .bold))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding()
            }
        }
        .frame(height: 120)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

/**
 * DarkModeToggle
 *
 * A custom toggle switch for enabling or disabling Dark Mode, accompanied by sun and moon icons.
 */
struct DarkModeToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(isOn ? .gray : .yellow)
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Image(systemName: "moon.fill")
                .foregroundColor(isOn ? .blue : .gray)
        }
    }
}

/**
 * CreditItem
 *
 * Displays a single credit item with a title and name.
 */
struct CreditItem: View {
    let title: String
    let name: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 0)
            
            Spacer()
            
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading, 15)
                .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity)
    }
}

/**
 * SettingsButton
 *
 * A reusable button component for settings actions, displaying an icon and text.
 */
struct SettingsButton: View {
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

/**
 * StatBox
 *
 * Displays a statistical metric with a title, value, and accompanying icon.
 */
struct StatBox: View {
    let title: String
    let value: Int
    let iconName: String
    let isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(isDarkMode ? .white : .black)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
            
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

/**
 * CustomModePopUp
 *
 * A popup view allowing users to switch between Adventure Mode and Virtual Tour Mode, displaying relevant information.
 */
struct CustomModePopUp: View {
    @Binding var isAdventureModeEnabled: Bool
    @Binding var isPresented: Bool
    @Binding var isDarkMode: Bool
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @ObservedObject var locationManager: LocationManager
    
    let adventureModeColor = Color.green
    let virtualTourColor = Color(red: 255/255, green: 104/255, blue: 3/255, opacity: 1.0)
    
    var body: some View {
        VStack(spacing: 20) {
            // Mode Picker
            CustomModePicker(
                isAdventureModeEnabled: $isAdventureModeEnabled,
                adventureModeColor: adventureModeColor,
                virtualTourColor: virtualTourColor
            )
            .padding(.horizontal)
            .padding(.bottom, 15)
            
            // Mode Icon
            ModeIcon(
                imageName: isAdventureModeEnabled ? "figure.walk" : "binoculars",
                color: isAdventureModeEnabled ? adventureModeColor : virtualTourColor,
                isSelected: true
            )
            .frame(width: 60, height: 60)
            .padding(.vertical, 10)
            
            // Mode Features
            VStack(alignment: .leading, spacing: 10) {
                if isAdventureModeEnabled {
                    BulletPoint(text: "Explore structures in person", isDarkMode: isDarkMode)
                    BulletPoint(text: "Track your progress", isDarkMode: isDarkMode)
                    BulletPoint(text: "Use live location", isDarkMode: isDarkMode)
                } else {
                    BulletPoint(text: "Browse remotely", isDarkMode: isDarkMode)
                    BulletPoint(text: "Learn about all structures", isDarkMode: isDarkMode)
                    BulletPoint(text: "No location needed", isDarkMode: isDarkMode)
                }
            }
            .padding(.vertical)
            
            // Recommended Usage
            Text("Better for: \(isAdventureModeEnabled ? "In-person visits" : "Remote exploration")")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                .padding(.top, 15)
                .padding(.bottom, -10)
            
            // Confirm Button
            Button("Confirm Choice") {
                locationManager.isAdventureModeEnabled = isAdventureModeEnabled
                isPresented = false
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(minWidth: 150)
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(isAdventureModeEnabled ? adventureModeColor : virtualTourColor)
            .cornerRadius(25)
        }
        .padding()
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

/**
 * BulletPoint
 *
 * Represents a single bullet point in a list, used for displaying features or information.
 */
struct BulletPoint: View {
    let text: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.system(size: 18, weight: .bold))
            Text(text)
                .font(.system(size: 18))
        }
        .foregroundColor(isDarkMode ? .white : .black)
    }
}

/**
 * HowToGetThereGuide
 *
 * A multi-page guide providing users with instructions on how to reach Poly Canyon.
 */
struct HowToGetThereGuide: View {
    @Binding var isPresented: Bool
    @Binding var isDarkMode: Bool
    @State private var currentPage = 0
    @AppStorage("howToGetThereGuideIndex") private var savedIndex = 0

    let pages = [
        GuidePage(
            emoji: "🚗",
            title: "Parking",
            description: "Park at the H-1 or H-4 parking lot with a valid Cal Poly parking pass.",
            buttonText: "Maps",
            buttonIcon: "map",
            buttonAction: {
                UIApplication.shared.open(URL(string: "https://maps.apple.com/?address=San%20Luis%20Obispo,%20CA%2093405,%20United%20States&auid=11145378343369333363&ll=35.303104,-120.659140&lsp=9902&q=Poly%20Canyon%20Trail&t=h")!)
            },
            color: .blue
        ),
        GuidePage(
            emoji: "🚶",
            title: "Follow AllTrails",
            description: "Use AllTrails for the best navigation to Poly Canyon.",
            buttonText: "AllTrails",
            buttonIcon: "map.fill",
            buttonAction: {
                UIApplication.shared.open(URL(string: "https://www.alltrails.com/trail/us/california/architecture-graveyard-hike-private-property?sh=rvw6ps")!)
            },
            color: .green
        ),
        GuidePage(
            emoji: "🏞️",
            title: "Final Steps",
            description: "1. From campus or parking, walk until you reach the yellow gate.\n2. Stay on the gravel road until you see the Poly Canyon arch.",
            buttonText: "Done",
            buttonIcon: nil,
            buttonAction: nil,
            color: .orange
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            HStack {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(currentPage == index ? pages[index].color : Color.black.opacity(0.3))
                        .frame(height: 3)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Close Button
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                    savedIndex = currentPage
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.system(size: 24))
                }
            }
            .padding(.trailing)
            .padding(.top, 5)

            // Main Content - TabView
            TabView(selection: $currentPage) {
                ForEach(0..<3) { index in
                    pageView(for: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            .transition(.slide)

            // Next/Done Button
            HStack {
                Button(action: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        isPresented = false
                        savedIndex = 0
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Done")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(pages[currentPage].color)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .frame(width: 300, height: 450)
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            currentPage = savedIndex
        }
    }
    
    /**
     * pageView
     *
     * Generates a single page view for the HowToGetThereGuide based on the provided GuidePage.
     *
     * - Parameter page: The GuidePage object containing content for the page.
     * - Returns: A View representing the content of the page.
     */
    func pageView(for page: GuidePage) -> some View {
        VStack(spacing: 20) {
            Text(page.emoji)
                .font(.system(size: 80))
            Text(page.title)
                .font(.title2)
                .fontWeight(.bold)
            Text(page.description)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if let action = page.buttonAction, let icon = page.buttonIcon {
                Button(action: action) {
                    HStack {
                        Image(systemName: icon)
                        Text(page.buttonText)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(page.color)
                    .cornerRadius(10)
                }
            }
            Spacer()
        }
        .foregroundColor(isDarkMode ? .white : .black)
    }
}

/**
 * GuidePage
 *
 * Represents a single page in the HowToGetThereGuide with an emoji, title, description, and optional button.
 */
struct GuidePage {
    let emoji: String
    let title: String
    let description: String
    let buttonText: String
    let buttonIcon: String?
    let buttonAction: (() -> Void)?
    let color: Color
}

/**
 * CustomAlert
 *
 * A customizable alert view that displays an icon, title, subtitle, and two action buttons.
 */
struct CustomAlert: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton
    let isPresented: Binding<Bool>
    @Binding var isDarkMode: Bool

    /**
     * AlertButton
     *
     * Represents a button within the CustomAlert with a title and action.
     */
    struct AlertButton {
        let title: String
        let action: () -> Void
    }

    var body: some View {
        ZStack {
            // Semi-transparent Background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented.wrappedValue = false
                }

            // Alert Content
            VStack(spacing: 0) {
                // Icon with Circle Background
                Circle()
                    .fill(isDarkMode ? Color.black : Color.white)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 60))
                            .foregroundColor(iconColor)
                    )
                    .offset(y: 60)
                    .zIndex(1)

                // Alert Details
                VStack(spacing: 15) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.top, 70)

                    Text(subtitle)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))

                    VStack(spacing: 15) {
                        // Primary Button
                        Button(action: {
                            isPresented.wrappedValue = false
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

                        // Secondary Button
                        Button(action: {
                            isPresented.wrappedValue = false
                            secondaryButton.action()
                        }) {
                            Text(secondaryButton.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                                .underline()
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .background(isDarkMode ? Color.black : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(width: 300)
            .shadow(color: isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            SettingsView(
                structureData: StructureData(),
                mapPointManager: MapPointManager(), 
                locationManager: LocationManager(
                    mapPointManager: MapPointManager(),
                    structureData: StructureData(),
                    isAdventureModeEnabled: true
                ),
                isDarkMode: .constant(false),
                isAdventureModeEnabled: .constant(true)
            )
            .previewDisplayName("Light Mode")
            
            // Dark Mode Preview
            SettingsView(
                structureData: StructureData(),
                mapPointManager: MapPointManager(), 
                locationManager: LocationManager(
                    mapPointManager: MapPointManager(),
                    structureData: StructureData(),
                    isAdventureModeEnabled: true
                ),
                isDarkMode: .constant(true),
                isAdventureModeEnabled: .constant(false)
            )
            .previewDisplayName("Dark Mode")
        }
    }
}
