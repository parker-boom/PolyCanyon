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

struct SettingsView: View {
    // MARK: - Properties

    // Binding and observed objects
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool

    // Vars
    @State private var showAlert = false
    @State private var alertType: AlertType?
    @State private var pendingAdventureModeState: Bool = false
    @State private var showModePopUp = false

    // App storage data figures
    @AppStorage("visitedCount") private var visitedCount: Int = 0
    @AppStorage("visitedAllCount") private var visitedAllCount: Int = 0
    @AppStorage("dayCount") private var dayCount: Int = 0
    
    enum AlertType {
        case resetVisited, toggleAdventureModeOff
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            // App settings section
            Section(header: Text("Settings")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
                    
                
                HStack {

                    
                    Text(isAdventureModeEnabled ? "Adventure Mode" : "Virtual Tour Mode")
                    
                    Image(systemName: isAdventureModeEnabled ? "figure.walk" : "binoculars")
                        .foregroundColor(isAdventureModeEnabled ? .green : .blue)
                    
                    Spacer()
                    
                    Button("Switch") {
                        showModePopUp = true
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    alertType = .resetVisited
                    showAlert = true
                }) {
                    Text("Reset All Visited Structures")
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    openSettings()
                }) {
                    Text("Open Location Settings")
                        .foregroundColor(.blue)
                }
            }

            // Stats section
            Section(header: Text("Statistics")) {
                HStack {
                    Text("Structures Visited")
                    Spacer()
                    Text("\(visitedCount)")
                }
                HStack {
                    Text("Milestone Visits")
                    Spacer()
                    Text("\(visitedAllCount)")
                }
                HStack {
                    Text("Days Visited")
                    Spacer()
                    Text("\(dayCount)")
                }
            }

            // Information section
            Section(header: Text("Information")) {
                Link("Structures in In-depth", destination: URL(string: "https://caed.calpoly.edu/history-structures")!)
                Link("How to Get to Poly Canyon", destination: URL(string: "https://maps.apple.com/?address=Poly%20Canyon%20Rd,%20San%20Luis%20Obispo,%20CA%20%2093405,%20United%20States&auid=7360445136973306817&ll=35.314999,-120.652923&lsp=9902&q=Poly%20Canyon")!)
            }

            // Credits section
            Section(header: Text("Credits")) {
                Text("Parker Jones")
                Text("Cal Poly SLO")
                Text("CAED College & Department")
                Text("Please email bug reports or issues to pjones15@calpoly.edu, thanks in advance!")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .gray : Color.black.opacity(0.6))
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .overlay(
            Group {
                if showModePopUp {
                    ZStack {
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
            }
        )

        // Alerts to confirm settings changed
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
    
    // MARK: - Open Settings Method
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

struct ModePopUp: View {
    @Binding var isAdventureModeEnabled: Bool
    @Binding var isPresented: Bool
    @Binding var isDarkMode: Bool
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    
    // Add a state variable to track the initial mode
    @State private var initialMode: Bool

    // Initialize the state variable in the initializer
    init(isAdventureModeEnabled: Binding<Bool>, isPresented: Binding<Bool>, isDarkMode: Binding<Bool>, structureData: StructureData, mapPointManager: MapPointManager) {
        self._isAdventureModeEnabled = isAdventureModeEnabled
        self._isPresented = isPresented
        self._isDarkMode = isDarkMode
        self.structureData = structureData
        self.mapPointManager = mapPointManager
        self._initialMode = State(initialValue: isAdventureModeEnabled.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 20) {
            Picker("Mode", selection: $isAdventureModeEnabled) {
                HStack {
                    Text("Virtual Tour Mode")
                }
                .tag(false)
                HStack {
                    Text("Adventure Mode")
                }
                .tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Image(isAdventureModeEnabled ? "AdventureModeImage" : "VirtualTourModeImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
            
            VStack(spacing: 10) {
                Text(isAdventureModeEnabled ? "Adventure Mode:" : "Virtual Tour Mode:")
                    .font(.headline)
                
                BulletPoint(text: isAdventureModeEnabled ? "Uses your location" : "No location needed")
                BulletPoint(text: isAdventureModeEnabled ? "Tracks your progress" : "All structures viewable")
                BulletPoint(text: "Better for: \(isAdventureModeEnabled ? "In-person visits" : "Remote exploration")")
            }
            .multilineTextAlignment(.center)
            
            Button(action: {
                // Only apply changes if the mode has actually changed
                if initialMode != isAdventureModeEnabled {
                    if !isAdventureModeEnabled {
                        // Switching to Virtual Tour Mode
                        structureData.setAllStructuresAsVisited()
                        print("Setting all structures as visited")
                    } else {
                        // Switching to Adventure Mode
                        structureData.resetVisitedStructures()
                        mapPointManager.resetVisitedMapPoints()
                        print("Resetting visited structures")
                    }
                }
                isPresented = false
            }) {
                Text("Confirm Choice")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.44, green: 0.92, blue: 0.25))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding()
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        Text("• \(text)")
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
        SettingsView(structureData: StructureData(), mapPointManager: MapPointManager(), isDarkMode: .constant(false), isAdventureModeEnabled: .constant(false))
    }
}
