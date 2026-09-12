import SwiftUI

/// A discovery is a quiet invitation; it never blocks continued map exploration.
struct VisitNotificationView: View {
    @EnvironmentObject private var dataStore: DataStore
    @State private var presentation: StructurePresentation?
    @State private var presentingSource: Structure?
    @Namespace private var discovery

    private var latest: Structure? {
        dataStore.lastVisitedStructure ?? dataStore.lastVisitedGhostStructure.map(dataStore.ghostStructureToDisplayStructure)
    }

    var body: some View {
        Group {
            if let structure = presentingSource ?? latest {
                DiscoveryBanner(structure: structure, open: {
                    presentingSource = structure
                    dataStore.dismissLastVisitedStructure()
                    let numbers = structure.number >= 100
                        ? dataStore.ghostStructures.map(dataStore.ghostStructureToDisplayStructure).map(\.number)
                        : dataStore.structures.map(\.number)
                    presentation = StructurePresentation(numbers: numbers, selected: structure.number)
                }, dismiss: { dataStore.dismissLastVisitedStructure() })
                .modifier(StructureZoomSource(id: structure.number, namespace: discovery))
            }
        }
        .fullScreenCover(item: $presentation, onDismiss: {
            presentingSource = nil
        }) { selection in
            StructureExperience(numbers: selection.numbers, selected: selection.selected, namespace: discovery, transitionSourceNumber: selection.selected)
        }
    }
}

/// Shared presentation; the caller owns actual discovery or illustrative preview state.
struct DiscoveryBanner: View {
    let structure: Structure
    let open: () -> Void
    let dismiss: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Button(action: open) {
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
            Button(action: dismiss) {
                Image(systemName: "xmark").font(.body).frame(width: 44, height: 44)
            }.accessibilityLabel("Dismiss discovery")
        }
        .padding(12).foregroundStyle(CanyonStyle.ink)
        .modifier(CanyonCardSurface())
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }
}
