import SwiftUI
import UIKit

// Map selections still enter through the existing route. Catalog links push the story directly.
struct StructInfo: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dataStore: DataStore
    var body: some View {
        StructureExperience(numbers: dataStore.structures.map(\.number), selected: appState.structInfoNum)

    }
}

struct UnavailableStructureView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        VStack(spacing: 20) {
            Text("This structure is unavailable.").font(.title2)
            Button("Back to Poly Canyon") { appState.activeFullScreenView = nil }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StoryPalette.paper)
    }
}

enum StoryPalette {
    static let paper = Color.white
    static let ink = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(red: 0.83, green: 0.90, blue: 0.81, alpha: 1) : UIColor(red: 0.13, green: 0.23, blue: 0.18, alpha: 1)
    })
}

struct StructureStory: View {
    let structure: Structure
    var onPageSwipe: (Int) -> Void = { _ in }
    @EnvironmentObject private var dataStore: DataStore
    @State private var gallery: GallerySelection?
    @State private var showResearch = false
    @Namespace private var photoNamespace
    @State private var visiblePhotoIndices: Set<Int> = []
    @State private var gallerySourceIndices: Set<Int> = []

    private var introduction: String {
        if let summary = Self.introductions[structure.number] { return summary }
        var sentences: [String] = []
        structure.description.enumerateSubstrings(in: structure.description.startIndex..<structure.description.endIndex, options: .bySentences) { sentence, _, _, stop in
            if let sentence { sentences.append(sentence.trimmingCharacters(in: .whitespacesAndNewlines)) }
            if sentences.count == 2 { stop = true }
        }
        return sentences.isEmpty ? structure.description : sentences.joined(separator: " ")
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !structure.images.isEmpty {
                        photo(0, height: min(480, max(300, geometry.size.height * 0.6)), width: geometry.size.width)
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        Text(structure.number >= 100 ? "FROM THE ARCHIVE" : "STRUCTURE \(String(format: "%02d", structure.number))")
                            .font(.caption.weight(.semibold)).tracking(2).foregroundStyle(FieldPalette.gold)
                        VStack(alignment: .leading, spacing: 10) {
                            Text(structure.title).font(.largeTitle.weight(.semibold))
                                .foregroundStyle(StoryPalette.ink).accessibilityAddTraits(.isHeader)
                            if let dates = structure.catalogDates {
                                Text(dates).font(.title2).foregroundStyle(FieldPalette.gold)
                                    .accessibilityLabel("Catalog dates, \(dates)")
                            }
                        }.fixedSize(horizontal: false, vertical: true)
                        Text(introduction)
                            .font(.title3)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(24)
                    .padding(.bottom, 12)
                    .contentShape(Rectangle())
                    .modifier(StoryPagingGesture(page: onPageSwipe))

                    if structure.images.count > 1 {
                        photo(1, height: 300, width: geometry.size.width)
                    }
                    if let observation = Self.observations[structure.number] {
                        Text(observation)
                            .font(.body).italic().lineSpacing(4)
                            .foregroundStyle(.secondary)
                            .padding(24)
                    }
                    if structure.images.count > 2 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(2..<structure.images.count, id: \.self) { index in
                                    photo(index, height: 160, width: 220)
                                }
                            }.padding(.horizontal, 24)
                        }.padding(.vertical, 24)
                    }
                    VStack(alignment: .leading, spacing: 24) {
                        Divider()
                        DisclosureGroup(isExpanded: $showResearch) {
                            VStack(alignment: .leading, spacing: 24) {
                                Text(structure.description).lineSpacing(5)
                                if let fact = structure.funFact, !fact.isEmpty {
                                    Text(fact).font(.body).italic().foregroundStyle(.secondary)
                                }
                                if !structure.builders.isEmpty { attribution("Builders", names: structure.builders) }
                                if !structure.advisors.isEmpty { attribution("Advisors", names: structure.advisors) }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)
                        } label: {
                            Text("The full story").font(.title2.weight(.semibold)).padding(.vertical, 10)
                        }
                        .tint(StoryPalette.ink)
                        Link(destination: URL(string: "https://polycanyon.com")!) {
                            HStack {
                                Text("More at polycanyon.com")
                                Image(systemName: "arrow.up.right").font(.caption)
                            }
                        }
                        .font(.subheadline)
                        .accessibilityHint("Opens the website; requires an internet connection")
                    }
                    .padding(24)
                    .padding(.bottom, 24)
                }
            }
            .background(StoryPalette.paper)
            .coordinateSpace(name: photoNamespace)
            .onPreferenceChange(StoryPhotoFrames.self) { frames in
                guard gallery == nil else { return }
                let viewport = CGRect(origin: .zero, size: geometry.size)
                visiblePhotoIndices = Set(frames.compactMap { index, frame in
                    let intersection = viewport.intersection(frame)
                    return !intersection.isNull && intersection.width > 1 && intersection.height > 1 ? index : nil
                })
            }
            .onChange(of: geometry.size) { _ in
                // A presentation-time resize invalidates the saved return viewport.
                if gallery != nil { gallerySourceIndices = [] }
            }
        }
        .modifier(StoryCanvasNavigation())
        .navigationBarTitleDisplayMode(.inline)
        .tint(StoryPalette.ink)
        .fullScreenCover(item: $gallery) { selection in
            StructureGallery(structure: structure, initialIndex: selection.index, transitionNamespace: photoNamespace, visibleSourceIndices: gallerySourceIndices) { gallery = nil }
                .id(selection.id)
        }

    }

    private func photo(_ index: Int, height: CGFloat, width: CGFloat) -> some View {
        Button {
            gallerySourceIndices = visiblePhotoIndices.union([index])
            gallery = GallerySelection(index: index)
        } label: {
            Image(structure.images[index]).resizable().scaledToFill()
                .frame(width: width, height: height).clipped()

        }
        .buttonStyle(.plain)
        .modifier(StoryPagingGesture(enabled: index < 2, page: onPageSwipe))
        .modifier(StoryPhotoSource(id: StoryPhotoID(structure: structure.number, index: index), namespace: photoNamespace))
        .background {
            GeometryReader { photoGeometry in
                Color.clear.preference(key: StoryPhotoFrames.self, value: [index: photoGeometry.frame(in: .named(photoNamespace))])
            }
        }
        .accessibilityLabel("View \(structure.title), photo \(index + 1) of \(structure.images.count)")
    }

    private func attribution(_ title: String, names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(names.joined(separator: ", ")).font(.body).foregroundStyle(.secondary)
        }
    }

    // Only observations that add something distinct to the introduction accompany photographs.
    private static let observations: [Int: String] = [
        1: "Recessed joints in the stonework channel rain through the arch.",
        3: "The original Blade was also called the Concrete Flower.",
        12: "The team used nylon stockings to model the bridge’s final shape.",
        24: "The Shell House once contained a hot tub, a fish tank, and a waterfall.",
        27: "The dome’s design was inspired by a succulent."
    ]

    // Short introductions drawn only from the bundled research. Full source text remains below.
    private static let introductions: [Int: String] = [
        1: "A steel frame wrapped in serpentinite stone marks the canyon’s entrance. Its three-fingered walls guide visitors while keeping cattle out. Look for the builders’ terracotta faces tucked into the stonework.",
        2: "This 46-foot bridge explores an unexpected structural material: plastic pipe. Fiber-reinforced tubes contain steel rebar anchored in concrete, creating a lightweight crossing.",
        3: "The Blade began in 1963 as an experiment in post-tensioned concrete. After the original collapsed, students rebuilt its petal-shaped form as a catenary arch, using compression to hold it together.",
        4: "Wooden boat-building techniques shaped this triangular experiment. Assembled in a single day from prefabricated pieces, its curves and open frame cast changing shadows across the canyon.",
        5: "Two fourth-year students built this kinetic sculpture during late nights in the metal shop. Its metal sails rotate on ball bearings and originally wore temperature-sensitive paint.",
        6: "Twelve underground anchors hold the Tensile Pavilion’s sweeping fabric in tension. Students raised donations, sourced specialized fabric, and spent a year creating this shade structure.",
        7: "Hundreds of students built this dome in 1957 from surplus boiler pipes and 19,000 bolts. Originally near the architecture building, it moved to the canyon piece by piece in 1963.",
        8: "Supported at one end, this steel-and-cable deck projects above the canyon floor. A 2024 restoration replaced weathered parts with Alaskan yellow cedar and reduced the deck’s bounce.",
        9: "These curved concrete shells began as a mound of earth. Students sprayed concrete over the hill, then dug the dirt out from beneath it.",
        10: "Started in 1982, this hillside house explored natural cooling and passive solar design. Its wire-mesh-and-concrete dome remained unfinished when funding ran out.",
        11: "Parabolic concrete ribs and tensioned steel cables turn this hillside into a sundial. Its brass hour markers have disappeared, but sunlight still moves across the structure.",
        12: "A thin shell of spray-applied concrete spans the creek. Tension cables held the steel frame during construction; once the concrete cured, the cables were cut and the bridge settled into compression.",
        13: "Simple wooden trusses carry this crossing. Canyon volunteers restored it in 2015, including first-year architecture student Keigen Langholff, whose contribution became part of its story.",
        14: "Designed in 1976 as a building that students could take apart and rebuild, this structure explores how frames carry loads. A 2009 reconstruction replaced its plywood panels with steel and added a truss system.",
        15: "Four poles form the Pyramid’s spare outline. Its shape invites interpretation, though its construction began with the practical challenge of digging into canyon clay.",
        16: "The Bridge House began in 1964 as a test of eight-by-eight-foot glass panels. It later became a home before students stripped it back to a bridge in 2019.",
        17: "Polyvinyl tanks wrapped in corrugated metal expanded the canyon’s water system in 1998. Their foundations, interlocking rings, and overflow basins were designed for this hillside setting.",
        18: "A twelve-by-twelve-foot redwood deck rests on concrete piers in the hillside. Created as a rest stop and viewpoint, it followed fifteen years without a new canyon structure.",
        19: "Three forty-foot concrete arches trace the inverted curve of a hanging chain. Inspired by engineer Heinz Isler, students precast the pieces and lifted them into place with a crane.",
        20: "Weathered redwood planks stand on serpentine rock bases, framing a canyon view. The wall forms part of a meditation space with a direction marker and bench.",
        21: "Hay bales, reinforcing stakes, wire mesh, and stucco form this double-barrel arch. The students rebuilt their first collapsed attempt with stronger stakes and a revised plan.",
        22: "Three precast concrete legs and tension cables support an observation deck. Built on an older structure’s foundation, the tower honors architectural engineering educator Paul Fratessa.",
        23: "Inverted wooden pyramids and slender steel rods balance tension against compression. Two years of design and fabrication produced a canopy that appears to hover.",
        24: "A concrete canopy rests on just three points. Students later enclosed the shell, adding windows and living spaces that served caretakers and visiting professors.",
        25: "This hillside greenhouse explored ways to regulate its own climate. Stone walls, solar chimneys, rotating vents, and a water wall captured and redistributed heat.",
        26: "An eight-by-eight-by-eight-foot steel grid began as the Space Module in 1965. Wood and Plexiglas later transformed the prefabrication experiment into a caretaker’s home.",
        27: "Eighty-four identical timber pieces form a sixteen-foot dome that can be dismantled and rebuilt. Originally used at a Descanso Gardens music festival, it later found a home in the canyon.",
        28: "Timber poles anchored in bedrock support the Pole House above the hillside. The building provides storage and a practical base for work in the canyon.",
        29: "This transformer station helped bring electricity to the canyon. Underground cables once carried power to its experimental houses and other structures.",
        30: "A sturdy barbecue pit anchors a gathering area of concrete counters, seating, and small bridges. Its surrounding additions record years of student use.",
        31: "Six steel frames on a circular concrete platform demonstrate different ways buildings respond to earthquakes. Each frame makes a structural connection visible, including weakened sections and replaceable links designed to absorb movement."
    ]
}

private struct StoryCanvasNavigation: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.overlay(alignment: .top) {
                    LinearGradient(colors: [.white.opacity(0.96), .white.opacity(0.65), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 100).allowsHitTesting(false).accessibilityHidden(true)
                }
                .ignoresSafeArea(.container, edges: .top)
                .toolbarBackground(.hidden, for: .navigationBar)
        } else {
            content
        }
    }
}

private struct StoryPhotoFrames: PreferenceKey {
    static var defaultValue: [Int: CGRect] { [:] }
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct StoryPhotoSource: ViewModifier {
    let id: StoryPhotoID
    let namespace: Namespace.ID
    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.matchedTransitionSource(id: id, in: namespace)
        } else { content }
    }
}

private struct GallerySelection: Identifiable {
    let id = UUID()
    let index: Int
}

/// The fallback is restricted to the title and two full-width photos. The photo
/// rail retains its own horizontal gesture. Reject vertical motion before the
/// recognizer begins so the story's scroll view remains responsive.
private struct StoryPagingGesture: ViewModifier {
    var enabled = true
    let page: (Int) -> Void
    func body(content: Content) -> some View {
        if #available(iOS 18, *), enabled {
            content.gesture(StoryHorizontalPan(page: page))
        } else { content }
    }
}

@available(iOS 18, *)
private struct StoryHorizontalPan: UIGestureRecognizerRepresentable {
    let page: (Int) -> Void
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator { Coordinator() }
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer()
        pan.maximumNumberOfTouches = 1
        pan.delegate = context.coordinator
        return pan
    }
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        guard recognizer.state == .ended else { return }
        let translation = recognizer.translation(in: recognizer.view)
        guard abs(translation.x) >= 60, abs(translation.x) > abs(translation.y) * 1.5 else { return }
        page(translation.x < 0 ? 1 : -1)
    }
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y) * 1.5
        }
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
    }
}
