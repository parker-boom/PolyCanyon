import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var dataStore: DataStore
    @EnvironmentObject private var appState: AppState
    @Environment(\.dynamicTypeSize) private var typeSize
    @Binding var searchText: String
    @Binding var onlyUnvisited: Bool
    var searching = false
    @State private var showsHistory = false
    @State private var presentation: StructurePresentation?
    @Namespace private var photos
    private var structures: [Structure] { dataStore.structures.filter(matches).sorted { $0.number < $1.number } }
    private var historical: [Structure] { dataStore.ghostStructures.map(dataStore.ghostStructureToDisplayStructure).filter(matches) }
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: typeSize.isAccessibilitySize ? 1 : 2)
    }
    private func matches(_ structure: Structure) -> Bool {
        let query = searching ? searchText.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        return (!appState.exploresInPerson || !onlyUnvisited || !structure.isVisited) && structure.matchesCatalogQuery(query)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                photoGrid(structures)
                if !historical.isEmpty {
                    DisclosureGroup(isExpanded: $showsHistory) {
                        photoGrid(historical).padding(.top, 16)
                    } label: {
                        Text("Traces of the past").font(.title2.weight(.semibold))
                    }.foregroundStyle(StoryPalette.ink).padding(.top, 8)
                }
                if structures.isEmpty && historical.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No structures found").font(.title2.bold())
                        Text(appState.exploresInPerson && onlyUnvisited ? "Try showing all structures or searching for another name, number, or year." : "Try a name, map number, or year.").foregroundStyle(.secondary)
                    }.padding(.vertical, 24)
                }
            }.padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 28)
        }
        .background(StoryPalette.paper)
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if appState.exploresInPerson {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu { Toggle("Not yet visited", isOn: $onlyUnvisited) } label: {
                    Label(onlyUnvisited ? "Showing unvisited structures" : "Filter structures", systemImage: onlyUnvisited ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
            }
            }
        }
        .onChange(of: appState.exploresInPerson) { visiting in if !visiting { onlyUnvisited = false } }
        .modifier(CollectionSearch(text: $searchText, enabled: searching))
        .scrollDismissesKeyboard(.interactively)
        .tint(StoryPalette.ink)
        .fullScreenCover(item: $presentation) { selection in
            StructureExperience(numbers: selection.numbers, selected: selection.selected, namespace: photos)
        }
    }
    private func photoGrid(_ items: [Structure]) -> some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
            ForEach(items) { structure in
                Button {
                    presentation = StructurePresentation(numbers: items.map(\.number), selected: structure.number)
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
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceTransparency) private var opaque
    @Environment(\.colorSchemeContrast) private var contrast
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear.aspectRatio(0.86, contentMode: .fit)
                .overlay {
                    GeometryReader { geometry in
                        if let image = structure.images.first {
                            Image(image).resizable().scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                        }
                    }
                }
                .modifier(StructureZoomSource(id: structure.number, namespace: photoNamespace))
                .accessibilityHidden(true)
            LinearGradient(stops: [.init(color: .clear, location: 0.42),
                                   .init(color: .black.opacity(0.08), location: 0.66),
                                   .init(color: .black.opacity(contrast == .increased ? 0.94 : 0.82), location: 1)],
                           startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
            VStack(alignment: .leading, spacing: 6) {
                Text(structure.title).font(.headline.weight(.semibold))
                if appState.exploresInPerson && structure.isVisited {
                    Label("Visited", systemImage: "checkmark").font(.caption)
                }
            }.foregroundStyle(.white).fixedSize(horizontal: false, vertical: true)
                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(opaque || contrast == .increased ? Color.black.opacity(0.9) : Color.clear)
        }
        .overlay(alignment: .topLeading) {
            Group {
                if structure.number >= 100 {
                    Text("ARCHIVE").font(.caption2.monospaced().weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(.black.opacity(0.7), in: Capsule())
                } else {
                    Text(String(format: "%02d", structure.number))
                        .font(.caption.monospaced().weight(.semibold))
                        .shadow(color: .black, radius: 1.5, y: 1)
                }
            }.foregroundStyle(.white).padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24).strokeBorder(
                LinearGradient(colors: [.white.opacity(0.7), .white.opacity(0.12), .white.opacity(0.3)],
                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(structure.title), \(structure.number >= 100 ? "historical structure" : "map number \(structure.number)")\(appState.exploresInPerson && structure.isVisited ? ", visited" : "")")
    }
}

private struct CollectionSearch: ViewModifier {
    @Binding var text: String
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled { content.searchable(text: $text, prompt: "Name, number, or year") }
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
