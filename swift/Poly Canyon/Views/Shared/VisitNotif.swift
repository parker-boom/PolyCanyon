import SwiftUI

/// A discovery is a quiet invitation; it never blocks continued map exploration.
struct VisitNotificationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    private var structure: Structure? {
        dataStore.lastVisitedStructure ?? dataStore.lastVisitedGhostStructure.map(dataStore.ghostStructureToDisplayStructure)
    }
    var body: some View {
        if let structure {
            HStack(spacing: 12) {
                Button {
                    if structure.number >= 100 {
                        appState.ghostStructInfoNum = structure.number
                        appState.activeFullScreenView = .ghostStructInfo
                    } else {
                        appState.structInfoNum = structure.number
                        appState.activeFullScreenView = .structInfo
                    }
                    dataStore.dismissLastVisitedStructure()
                } label: {
                    HStack(spacing: 12) {
                        Image(structure.images.first ?? "M-1").resizable().scaledToFill()
                            .frame(width: 54, height: 60).clipped().clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Discovered", systemImage: "checkmark.circle.fill").font(.caption.weight(.medium))
                            Text(structure.title).font(.headline).multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                    }
                }.buttonStyle(.plain)
                Button { dataStore.dismissLastVisitedStructure() } label: {
                    Image(systemName: "xmark").font(.body).frame(width: 44, height: 44)
                }.accessibilityLabel("Dismiss discovery")
            }
            .padding(12).foregroundStyle(CanyonStyle.ink)
            .background(CanyonStyle.paper, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        }
    }
}
