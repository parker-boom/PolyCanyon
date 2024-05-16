// MARK: SettingsView.swift
// This file defines the SettingsView for the "Arch Graveyard" app, allowing users to customize their app experience through toggles and informational links. It provides settings for appearance, adventure mode, and access to external resources.

// Notable features include:
// - Toggles for enabling dark mode and adventure mode, directly impacting the user interface and interaction.
// - Buttons for resetting visited structures and setting conditions based on adventure mode.
// - Sections with links to external resources for more in-depth information about the architectural graveyard and directions to the location.
// - Credits section acknowledging contributors and providing context about the app's development.

// This view plays a crucial role in personalizing the app to suit individual preferences and enhancing user engagement through additional informational resources.





// MARK: Code
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @ObservedObject var structureData: StructureData
    @ObservedObject var mapPointManager: MapPointManager
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    
    @State private var buttonPressed = false
    
    // MARK: - Body
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
            
            Section(header: Text("Adventure Mode")) {
                // Button to reset all visited structures
                Button(action: {
                    structureData.resetVisitedStructures()
                    mapPointManager.resetVisitedMapPoints()
                                        
                    buttonPressed = true
                    
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }) {
                    Text("Reset All Visited Structures")
                }
                .tint(.blue)
                .scaleEffect(buttonPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: buttonPressed)
                .onChange(of: buttonPressed) { pressed in
                    if pressed {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            buttonPressed = false
                        }
                    }
                }
                
                // Toggle to enable/disable adventure mode
                Toggle("Adventure Mode", isOn: $isAdventureModeEnabled)
                    .onChange(of: isAdventureModeEnabled) { isEnabled in
                        if !isEnabled {
                            structureData.setAllStructuresAsVisited()
                        }
                    }
                
                Text("Adventure mode automatically tracks your visited structures using your location.")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .gray : Color.black.opacity(0.6))
            }
            
            Section(header: Text("More")) {
                Link("In-depth Information", destination: URL(string: "https://caed.calpoly.edu/history-structures")!)
                Link("How to Get There", destination: URL(string: "https://maps.apple.com/?address=Poly%20Canyon%20Rd,%20San%20Luis%20Obispo,%20CA%20%2093405,%20United%20States&auid=7360445136973306817&ll=35.314999,-120.652923&lsp=9902&q=Poly%20Canyon")!)
            }
            
            Section(header: Text("Credits")) {
                Text("Parker Jones")
                Text("Cal Poly University - San Luis Obispo ")
                Text("CAED College & Department")
                Text("Please email bug reports or issues to pjones15@calpoly.edu, thanks in advance!")
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .gray : Color.black.opacity(0.6))
                
                
            }

        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(structureData: StructureData(), mapPointManager: MapPointManager(), isDarkMode: .constant(false), isAdventureModeEnabled: .constant(false))
    }
}
