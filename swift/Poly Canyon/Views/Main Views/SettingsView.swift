// MARK: - Overview
/*
    SettingsView.swift

    This file defines the SettingsView structure, which provides a settings interface for the app.

    Key Components:
    - Toggle switches for Dark Mode and Adventure Mode.
    - Buttons to reset visited structures.
    - Displays user statistics (visited structures, milestone visits, days visited).
    - Provides links to additional information and credits.
    - Alerts for confirming actions like resetting structures or disabling Adventure Mode.
*/

// MARK: - Body
import SwiftUI
import Glur

struct SettingsView: View {
    // MARK: - Properties

    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool

    @State private var showAlert = false
    @State private var alertType: AlertType?
    @State private var pendingAdventureModeState: Bool = false
    @State private var showModePopUp = false

    @AppStorage("visitedCount") private var visitedCount: Int = 0
    @AppStorage("visitedAllCount") private var visitedAllCount: Int = 0
    @AppStorage("dayCount") private var dayCount: Int = 0
    
    enum AlertType {
        case resetVisited, toggleAdventureModeOff
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
                if showModePopUp {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showModePopUp = false
                        }
                    
                    ModePopUp(isAdventureModeEnabled: $isAdventureModeEnabled,
                              isPresented: $showModePopUp,
                              isDarkMode: $isDarkMode,
                              structureData: structureData,
                              mapPointManager: mapPointManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                }
            }
        )
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .resetVisited:
                return Alert(
                    title: Text("Reset All Visited Structures"),
                    message: Text("Are you sure you want to reset all visited structures?"),
                    primaryButton: .destructive(Text("Yes")) {
                        structureData.resetVisitedStructures()
                        mapPointManager.resetVisitedMapPoints()
                    },
                    secondaryButton: .cancel()
                )
            case .toggleAdventureModeOff:
                return Alert(
                    title: Text("Toggle Adventure Mode Off"),
                    message: Text("This will mark all structures as visited. Are you sure?"),
                    primaryButton: .destructive(Text("Yes")) {
                        structureData.setAllStructuresAsVisited()
                        isAdventureModeEnabled = pendingAdventureModeState
                    },
                    secondaryButton: .cancel() {
                        isAdventureModeEnabled = true
                    }
                )
            case .none:
                return Alert(title: Text("Error"))
            }
        }
    }
    
    // MARK: - General Settings Section
    var generalSettingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.bottom, -5)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Dark Mode")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    DarkModeToggle(isOn: $isDarkMode)
                }
                .padding()
                .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                VStack(spacing: 10) {
                    Image(systemName: isAdventureModeEnabled ? "figure.walk" : "binoculars")
                        .font(.system(size: 40))
                        .foregroundColor(isAdventureModeEnabled ? .green : .blue)
                    
                    Text(isAdventureModeEnabled ? "Adventure Mode" : "Virtual Tour Mode")
                        .font(.system(size: 22, weight: .bold))
                    
                    Text(isAdventureModeEnabled ? "Explore structures in person" : "Browse structures remotely")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
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
                
                HStack(spacing: 10) {
                    SettingsButton(
                        action: {
                            alertType = .resetVisited
                            showAlert = true
                        },
                        imageName: "arrow.clockwise",
                        text: "Reset Structures",
                        imgColor: .red
                    )
                    
                    SettingsButton(
                        action: {
                            openSettings()
                        },
                        imageName: "location",
                        text: "Location Settings",
                        imgColor: .green
                    )
                }
            }
        }
    }
    
    var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Statistics")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.top, 10)
                .padding(.bottom, -5)
            
            HStack(spacing: 10) {
                StatBox(title: "Visited", value: visitedCount, iconName: "checkmark.circle.fill")
                StatBox(title: "Days", value: dayCount, iconName: "calendar")
            }
        }
    }
    
    var informationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Information")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.bottom, -5)
            
            if isAdventureModeEnabled {
                Button(action: {
                    // Action to open directions
                }) {
                    ZStack {
                        Image("DirectionsBG")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(15)
                            .blur(radius: 4.0)
                        
                        HStack {
                            VStack(spacing: 10) {
                                HStack(spacing: 15) {
                                    Image(systemName: "car.fill")
                                        .font(.system(size: 28))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 22))
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 28))
                                }
                                .shadow(color: .white.opacity(0.9), radius: 2, x: 0, y: 1)
                                Text("How to get there")
                                    .font(.system(size: 26, weight: .bold))
                                    .shadow(color: .white.opacity(0.6), radius: 2, x: 0, y: 1)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.8), radius: 2, x: 0, y: 1)
                                
                        }
                        .padding()
                    }
                }
                .frame(height: 120)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            } else {
                Text("Swiping Mode")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(15)
            }
        }
    }
    
    var creditsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Credits")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isDarkMode ? .white : .black)
            
            VStack(spacing: 15) {
                CreditItem(title: "Developer", name: "Parker Jones")
                CreditItem(title: "Institution", name: "Cal Poly SLO")
                CreditItem(title: "Department", name: "CAED College")
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


    
    // MARK: - Open Settings Method
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

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

struct SettingsButton: View {
    let action: () -> Void
    let imageName: String
    let text: String
    let imgColor: Color
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                    .foregroundColor(imgColor)
                    .padding(.bottom, 5)
                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct CreditItem: View {
    let title: String
    let name: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            Spacer()
            
            Text(name)
                .font(.system(size: 16, weight: .semibold))
                .padding(.leading, 15)
                .padding(.trailing, 10)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatBox: View {
    let title: String
    let value: Int
    let iconName: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.8))
            
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}


struct ModePopUp: View {
    @Binding var isAdventureModeEnabled: Bool
    @Binding var isPresented: Bool
    @Binding var isDarkMode: Bool
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    
    @State private var initialMode: Bool

    init(isAdventureModeEnabled: Binding<Bool>, isPresented: Binding<Bool>, isDarkMode: Binding<Bool>, structureData: StructureData, mapPointManager: MapPointManager) {
        self._isAdventureModeEnabled = isAdventureModeEnabled
        self._isPresented = isPresented
        self._isDarkMode = isDarkMode
        self.structureData = structureData
        self.mapPointManager = mapPointManager
        self._initialMode = State(initialValue: isAdventureModeEnabled.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Image(isAdventureModeEnabled ? "ExplorerBG" : "VirtualBG")
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
                    .glur(radius: 3.0, offset: 0.3, interpolation: 0.2, direction: .up)
                
                Picker("Mode", selection: $isAdventureModeEnabled) {
                    Text("Virtual Tour Mode").tag(false)
                    Text("Adventure Mode").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text(isAdventureModeEnabled ? "Adventure Mode:" : "Virtual Tour Mode:")
                        .font(.headline)
                    
                    BulletPoint(text: isAdventureModeEnabled ? "Uses your location" : "No location needed")
                    BulletPoint(text: isAdventureModeEnabled ? "Tracks your progress" : "All structures viewable")
                    BulletPoint(text: "Better for: \(isAdventureModeEnabled ? "In-person visits" : "Remote exploration")")
                }
                .multilineTextAlignment(.center)
                .padding(.top)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Confirm Choice")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray4))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.horizontal)
            .background(isDarkMode ? Color(.systemBackground) : Color.white)
        }
        .background(isDarkMode ? Color(.systemBackground) : Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
            Text(text)
                .font(.system(size: 14))
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(structureData: StructureData(), mapPointManager: MapPointManager(), isDarkMode: .constant(false), isAdventureModeEnabled: .constant(true))
    }
}
