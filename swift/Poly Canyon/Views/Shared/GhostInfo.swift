import SwiftUI

struct GhostInfo: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dataStore: DataStore
    @State private var currentGhostIndex = 0
    var initialGhostIndex: Int?

    var body: some View {
        NavigationStack {
            if dataStore.ghostStructures.indices.contains(currentGhostIndex) {
                StructureStory(structure: dataStore.ghostStructureToDisplayStructure(dataStore.ghostStructures[currentGhostIndex]))
                    .id(currentGhostIndex)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Menu {
                                ForEach(Array(dataStore.ghostStructures.enumerated()), id: \.element.id) { index, ghost in
                                    Button(ghost.name) { currentGhostIndex = index }
                                }
                            } label: { Label("Historical structures", systemImage: "clock.arrow.circlepath") }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button { appState.activeFullScreenView = nil } label: { Image(systemName: "xmark") }
                                .accessibilityLabel("Close historical structure")
                        }
                    }
            } else { UnavailableStructureView() }
        }
        .tint(StoryPalette.ink)
        .onAppear {
            if let initialGhostIndex, dataStore.ghostStructures.indices.contains(initialGhostIndex) {
                currentGhostIndex = initialGhostIndex
            }
        }
    }
}
