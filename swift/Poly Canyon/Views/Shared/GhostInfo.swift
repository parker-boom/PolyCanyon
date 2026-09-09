import SwiftUI

struct GhostInfo: View {
    @EnvironmentObject private var dataStore: DataStore
    var initialGhostIndex: Int?
    var body: some View {
        let items = dataStore.ghostStructures.map(dataStore.ghostStructureToDisplayStructure)
        if !items.isEmpty {
            let index = min(max(initialGhostIndex ?? 0, 0), items.count - 1)
            StructureExperience(numbers: items.map(\.number), selected: items[index].number)
        } else { UnavailableStructureView() }
    }
}
