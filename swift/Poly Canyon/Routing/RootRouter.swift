// RootRouter.swift
import SwiftUI

struct RootRouter: View {
    @Binding var designVillageMode: Bool?
    let eventStartDate: Date
    let eventEndDate: Date

    var body: some View {
        Group {
            if let dvMode = designVillageMode {
                if dvMode {
                    // DV branch: Show the Design Village static app.
                    DVAppView()
                } else {
                    // Poly Canyon branch: Use the container that instantiates heavy environment objects.
                    PolyCanyonContainerView()
                }
            } else {
                // For existing users during the event: Prompt them for their choice.
                DVDecisionPromptView { userChoice in
                    designVillageMode = userChoice
                    UserDefaults.standard.set(userChoice, forKey: "designVillageModeOverride")
                }
            }
        }
    }
}

struct RootRouter_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the prompt state (designVillageMode == nil)
        RootRouter(designVillageMode: .constant(nil),
                   eventStartDate: Date(),
                   eventEndDate: Date().addingTimeInterval(86400))
    }
}
