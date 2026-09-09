import SwiftUI

/// A presentation owns its initial selection and order, including filtered searches.
struct StructurePresentation: Identifiable {
    let id = UUID()
    let numbers: [Int]
    let selected: Int
}

struct StructureExperience: View {
    let numbers: [Int]
    let namespace: Namespace.ID?
    var recordsOpening = true
    var selectionChanged: (Int) -> Void = { _ in }
    @EnvironmentObject private var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selected: Int

    init(numbers: [Int], selected: Int, namespace: Namespace.ID? = nil, recordsOpening: Bool = true, selectionChanged: @escaping (Int) -> Void = { _ in }) {
        self.numbers = numbers
        self.namespace = namespace
        self.recordsOpening = recordsOpening
        self.selectionChanged = selectionChanged
        _selected = State(initialValue: selected)
    }

    private var items: [Structure] {
        let all = dataStore.structures + dataStore.ghostStructures.map(dataStore.ghostStructureToDisplayStructure)
        return numbers.compactMap { number in all.first { $0.number == number } }
    }
    var body: some View {
        NavigationStack {
            TabView(selection: $selected) {
                ForEach(items) { item in
                    StructureStory(structure: item) { delta in
                        // Native paging may already have completed this gesture.
                        guard selected == item.number else { return }
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) { step(delta) }
                    }.tag(item.number)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Close structure")
                }
            }
            .accessibilityAction(named: "Next structure") { step(1) }
            .accessibilityAction(named: "Previous structure") { step(-1) }
        }
        .interactiveDismissDisabled()
        .preferredColorScheme(.light)
        .tint(StoryPalette.ink)
        .modifier(OptionalStructureTransition(id: selected, namespace: namespace))
        .onAppear { markSelectedAsOpened() }
        .onChange(of: selected) { selectionChanged($0); markSelectedAsOpened() }
    }
    private func markSelectedAsOpened() {
        // Onboarding previews must not mutate saved progress.
        guard recordsOpening else { return }
        // Page preloading must not mark neighboring structures as opened.
        if let item = dataStore.structures.first(where: { $0.number == selected }), item.isVisited, !item.isOpened {
            dataStore.markStructureAsOpened(item.number)
        }
    }
    private func step(_ delta: Int) {
        guard let index = numbers.firstIndex(of: selected), numbers.indices.contains(index + delta) else { return }
        selected = numbers[index + delta]
    }
}

private struct OptionalStructureTransition: ViewModifier {
    let id: Int
    let namespace: Namespace.ID?
    func body(content: Content) -> some View {
        if let namespace { content.modifier(StructureZoomDestination(id: id, namespace: namespace)) }
        else { content }
    }
}

struct CanyonCardSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var opaque
    func body(content: Content) -> some View {
        if opaque {
            content.background(.white, in: RoundedRectangle(cornerRadius: 24))
        } else if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 24))
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }
}
