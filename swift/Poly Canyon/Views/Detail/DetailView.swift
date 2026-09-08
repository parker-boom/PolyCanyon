import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.dynamicTypeSize) private var typeSize
    @Binding var searchText: String
    @Binding var onlyUnvisited: Bool
    var searching = false
    @Namespace private var photos
    private var structures: [Structure] { dataStore.structures.filter(matches).sorted { $0.number < $1.number } }
    private var historical: [Structure] { dataStore.ghostStructures.map(dataStore.ghostStructureToDisplayStructure).filter(matches) }
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: typeSize.isAccessibilitySize ? 1 : 2)
    }
    private func matches(_ structure: Structure) -> Bool {
        let query = searching ? searchText.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        return (!onlyUnvisited || !structure.isVisited) && (query.isEmpty || structure.title.localizedCaseInsensitiveContains(query) || String(structure.number).contains(query))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                photoGrid(structures)
                if !historical.isEmpty {
                    Text("Traces of the past").font(.title2.weight(.semibold)).foregroundStyle(StoryPalette.ink).padding(.top, 8)
                    photoGrid(historical)
                }
                if structures.isEmpty && historical.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No structures found").font(.title2.bold())
                        Text(onlyUnvisited ? "Try showing all structures or searching for another name." : "Try a name or a number from the map.").foregroundStyle(.secondary)
                    }.padding(.vertical, 24)
                }
            }.padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 28)
        }
        .background(StoryPalette.paper)
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu { Toggle("Not yet visited", isOn: $onlyUnvisited) } label: {
                    Label(onlyUnvisited ? "Showing unvisited structures" : "Filter structures", systemImage: onlyUnvisited ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .modifier(CollectionSearch(text: $searchText, enabled: searching))
        .scrollDismissesKeyboard(.interactively)
        .tint(StoryPalette.ink)
    }
    private func photoGrid(_ items: [Structure]) -> some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
            ForEach(items) { structure in
                NavigationLink {
                    StructureStory(structure: structure).modifier(StructureZoomDestination(id: structure.number, namespace: photos))
                } label: {
                    StructurePhotoTile(structure: structure, photoNamespace: photos)
                }.buttonStyle(.plain)
            }
        }
    }
}
struct StructurePhotoTile: View {
    let structure: Structure
    let photoNamespace: Namespace.ID
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear.aspectRatio(0.88, contentMode: .fit)
                .overlay {
                    GeometryReader { geometry in
                        if let image = structure.images.first {
                            Image(image).resizable().scaledToFill().frame(width: geometry.size.width, height: geometry.size.height).clipped()
                        }
                    }
                }.clipShape(RoundedRectangle(cornerRadius: 8))
                .modifier(StructureZoomSource(id: structure.number, namespace: photoNamespace))
                .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(structure.number >= 100 ? "ARCHIVE" : String(format: "%02d", structure.number)).font(.caption.monospaced().weight(.medium)).foregroundStyle(.secondary)
                Spacer(minLength: 0)
                if structure.isVisited { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(StoryPalette.ink).accessibilityHidden(true) }
            }
            Text(structure.title).font(.headline.weight(.medium)).foregroundStyle(StoryPalette.ink).fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(structure.title), \(structure.number >= 100 ? "historical structure" : "map number \(structure.number)")\(structure.isVisited ? ", visited" : "")")
    }
}

private struct CollectionSearch: ViewModifier {
    @Binding var text: String
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled { content.searchable(text: $text, prompt: "Name or map number") }
        else { content }
    }
}
struct StructureZoomSource: ViewModifier {
    let id: Int
    let namespace: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), !reduceMotion { content.matchedTransitionSource(id: id, in: namespace) }
        else { content }
    }
}
struct StructureZoomDestination: ViewModifier {
    let id: Int
    let namespace: Namespace.ID
    var isEnabled = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), !reduceMotion, isEnabled { content.navigationTransition(.zoom(sourceID: id, in: namespace)) }
        else { content }
    }
}
