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
                Toggle("Adventure Mode", isOn: $isAdventureModeEnabled)
                    .onChange(of: isAdventureModeEnabled) { isEnabled in
                        if !isEnabled {
                            pendingAdventureModeState = isEnabled
                            alertType = .toggleAdventureModeOff
                            showAlert = true
                        } else {
                            structureData.resetVisitedStructures()
                            mapPointManager.resetVisitedMapPoints()
                        }
                    }
                
                Text("Adventure mode automatically tracks your visited structures using your location.")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .gray : Color.black.opacity(0.6))
                
                Button(action: {
                    alertType = .resetVisited
                    showAlert = true
                }) {
                    Text("Reset All Visited Structures")
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
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(structureData: StructureData(), mapPointManager: MapPointManager(), isDarkMode: .constant(false), isAdventureModeEnabled: .constant(false))
    }
}
