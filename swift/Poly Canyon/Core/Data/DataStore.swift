import Combine
import Foundation

/// Main-thread view state with one durable snapshot. Bundled research remains authoritative.
@MainActor
final class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published private(set) var structures: [Structure] = []
    @Published private(set) var ghostStructures: [GhostStructure] = []
    @Published private(set) var lastVisitedStructure: Structure?
    @Published private(set) var lastVisitedGhostStructure: GhostStructure?
    @Published private(set) var dayCount = 0
    @Published private(set) var persistenceError: String?
    var totalVisitedCount: Int {
        structures.filter(\.isVisited).count + ghostStructures.filter(\.isVisited).count
    }

    private var previousDayVisited: String?
    private var savingBlockReason: String?
    private var automaticVisitsPaused = false
    private let persistence: CatalogPersistence
    private let bundle: Bundle
    private let now: () -> Date

    init(directory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],
         defaults: UserDefaults = .standard, bundle: Bundle = .main,
         now: @escaping () -> Date = Date.init) {
        persistence = CatalogPersistence(directory: directory)
        self.bundle = bundle
        self.now = now
        let saved: CatalogSnapshot
        if let snapshot = readSaved(CatalogSnapshot.self, "progress.json") {
            saved = snapshot

        } else {
            // Existing installations migrate on their first successful edit. Legacy files stay intact.
            saved = CatalogSnapshot(
                structures: readSaved([Structure].self, "structures.json") ?? [],
                ghosts: readSaved([GhostStructure].self, "ghostStructures.json") ?? [],
                dayCount: max(0, defaults.integer(forKey: "dayCount")),
                previousDayVisited: defaults.string(forKey: "previousDayVisited"))
        }
        structures = CatalogProgress.merge(readBundle([Structure].self, "structuresList") ?? saved.structures,
                                          saved: saved.structures)
        ghostStructures = CatalogProgress.merge(readBundle([GhostStructure].self, "ghostStructures") ?? saved.ghosts,
                                               saved: saved.ghosts)
        dayCount = max(0, saved.dayCount)
        previousDayVisited = saved.previousDayVisited
        NotificationCenter.default.addObserver(self, selector: #selector(handleStructureVisit), name: .structureVisited, object: nil)
    }

    @objc private func handleStructureVisit(_ notification: Notification) {
        guard let number = notification.userInfo?["structureNumber"] as? Int else { return }
        if number >= 100 { markGhostStructureAsVisited(number) }
        else { markStructureAsVisited(number) }
    }

    private func readBundle<Value: Decodable>(_ type: Value.Type, _ name: String) -> Value? {
        do {
            guard let url = bundle.url(forResource: name, withExtension: "json") else { throw CocoaError(.fileNoSuchFile) }
            return try JSONDecoder().decode(type, from: Data(contentsOf: url))
        } catch {
            persistenceError = "Some structure information could not be loaded. Try reopening Poly Canyon."
            return nil
        }
    }

    private func readSaved<Value: Decodable>(_ type: Value.Type, _ filename: String) -> Value? {
        do { return try persistence.load(type, from: filename) }
        catch {
            if error is ProgressReadError {
                savingBlockReason = "This saved progress needs a newer version of Poly Canyon. It has been left unchanged."
            } else if !(error is DecodingError) {
                savingBlockReason = "Saved progress could not be read safely. Reopen the app after checking storage access."
            }
            persistenceError = savingBlockReason ?? "Some saved progress could not be read. Existing files have been kept for recovery, and the bundled structures are still available."
            return nil
        }
    }

    /// Publish only after the complete state is durably written. Failure leaves every visible value intact.
    @discardableResult
    private func update(_ change: (inout CatalogSnapshot) -> Void) -> Bool {
        guard savingBlockReason == nil else {
            persistenceError = savingBlockReason
            return false
        }
        var next = CatalogSnapshot(structures: structures, ghosts: ghostStructures,
                                   dayCount: dayCount, previousDayVisited: previousDayVisited)
        change(&next)
        do { try persistence.save(next, to: "progress.json") }
        catch {
            persistenceError = "Your change could not be saved. Your previous progress is unchanged. Check available storage and try again."
            return false
        }
        automaticVisitsPaused = false
        structures = next.structures
        ghostStructures = next.ghosts
        dayCount = next.dayCount
        previousDayVisited = next.previousDayVisited
        return true
    }

    func dismissPersistenceError() { persistenceError = nil }
    // A full disk must not reopen an alert on every GPS fix. Try automatic saves again on foregrounding.
    func resumeAutomaticVisits() { automaticVisitsPaused = false }

    private func recordVisitDay(in snapshot: inout CatalogSnapshot) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: now())
        if today != snapshot.previousDayVisited {
            snapshot.dayCount += 1
            snapshot.previousDayVisited = today
        }
    }

    func markStructureAsVisited(_ number: Int) {
        guard !automaticVisitsPaused, let index = structures.firstIndex(where: { $0.number == number }), !structures[index].isVisited else { return }
        if update({ next in
            next.structures[index].isVisited = true
            next.structures[index].recentlyVisited = Int(now().timeIntervalSince1970)
            recordVisitDay(in: &next)
        }) { lastVisitedStructure = structures[index] }
        else { automaticVisitsPaused = true }
    }

    func markGhostStructureAsVisited(_ number: Int) {
        guard !automaticVisitsPaused, let index = ghostStructures.firstIndex(where: { $0.number == String(number) }), !ghostStructures[index].isVisited else { return }
        if update({ next in
            next.ghosts[index].isVisited = true
            recordVisitDay(in: &next)
        }) { lastVisitedGhostStructure = ghostStructures[index] }
        else { automaticVisitsPaused = true }
    }

    func markStructureAsOpened(_ number: Int) {
        guard let index = structures.firstIndex(where: { $0.number == number }), !structures[index].isOpened else { return }
        update { $0.structures[index].isOpened = true }
    }

    func toggleLike(for structureId: Int) {
        guard let index = structures.firstIndex(where: { $0.number == structureId }) else { return }
        update { $0.structures[index].isLiked.toggle() }
    }

    func isLiked(for structureId: Int) -> Bool {
        structures.first(where: { $0.number == structureId })?.isLiked ?? false
    }

    func resetLikes() {
        update { next in
            for index in next.structures.indices { next.structures[index].isLiked = false }
        }
    }

    func resetStructures() {
        if update({ next in
            for index in next.structures.indices {
                next.structures[index].isVisited = false
                next.structures[index].isOpened = false
                next.structures[index].recentlyVisited = -1
                next.structures[index].isLiked = false
            }
            for index in next.ghosts.indices { next.ghosts[index].isVisited = false }
            next.dayCount = 0
            next.previousDayVisited = nil
        }) { dismissLastVisitedStructure() }
    }

    // Convert a GhostStructure to a Structure for display purposes
    func ghostStructureToDisplayStructure(_ ghostStructure: GhostStructure) -> Structure {
        return Structure(
            number: Int(ghostStructure.number) ?? 0,  // Convert string number to Int
            title: ghostStructure.name,
            year: ghostStructure.year,
            advisors: ghostStructure.advisors,
            builders: ghostStructure.builders,
            description: ghostStructure.description,
            funFact: nil,  // Ghost structures don't have fun facts
            images: ghostStructure.images,
            isVisited: ghostStructure.isVisited,
            isOpened: false,
            recentlyVisited: Int(now().timeIntervalSince1970),
            isLiked: false
        )
    }
    
    // MARK: - Structure Filtering
    func getFilteredStructures(searchText: String = "", sortState: SortState, distance: ((Structure) -> Double)? = nil) -> [Structure] {
        // First apply search filter
        let searchFiltered = structures.filter { structure in
            searchText.isEmpty || 
            structure.title.localizedCaseInsensitiveContains(searchText) || 
            String(structure.number).contains(searchText)
        }
        
        // Then apply sort state filter and additional sorting logic
        var filteredStructures: [Structure]
        
        switch sortState {
        case .all:
            // If user is in canyon, sort by distance
            if let distance {
                filteredStructures = searchFiltered.sorted { s1, s2 in
                    distance(s1) < distance(s2)
                }
            } else {
                filteredStructures = searchFiltered.sorted { $0.number < $1.number }
            }
            
            // Only add ghost structures representation when showing all structures
            if !ghostStructures.isEmpty && (searchText.isEmpty || "Ghost Structures".localizedCaseInsensitiveContains(searchText)) {
                filteredStructures.append(getGhostStructuresRepresentation())
            }
            
            return filteredStructures
            
        case .favorites:
            return searchFiltered.filter { $0.isLiked }
            
        case .visited:
            return searchFiltered
                .filter { $0.isVisited }
                .sorted { $0.recentlyVisited > $1.recentlyVisited } // Sort by most recently visited
        }
    }
    
    // Creates a special structure object to represent all ghost structures as a single item
    func getGhostStructuresRepresentation() -> Structure {
        // Use one of the main ghost structure images (G-1 through G-6)
        // Take only the first image from each ghost structure, which should be the main image
        let mainGhostImages = ghostStructures.compactMap { $0.images.first }
        let ghostImage = mainGhostImages.first { $0.hasPrefix("G-") } ?? "G-1"
        
        // Count visited ghost structures
        let visitedCount = ghostStructures.filter { $0.isVisited }.count
        let totalCount = ghostStructures.count
        
        // Create a description with the count of visited ghost structures
        let description = "Discover the lost structures of Poly Canyon's past. These historic projects no longer exist in their original form, but their legacy lives on in the canyon. \(visitedCount) of \(totalCount) ghost structures discovered."
        
        return Structure(
            number: 999, // Special number to identify as ghost structures representation
            title: "Ghost Structures",
            year: "Various",
            advisors: ["Various"],
            builders: ["Various Cal Poly Students"],
            description: description,
            funFact: "Ghost structures were built between the 1950s-1980s but no longer exist in their complete form.",
            images: [ghostImage],
            isVisited: visitedCount > 0,
            isOpened: false,
            recentlyVisited: -1,
            isLiked: false
        )
    }
    
    func getRecentlyVisitedStructures(limit: Int = 3) -> [Structure] {
        return structures
            .filter { $0.recentlyVisited != -1 }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(max(0, limit))
            .map { $0 }
    }

    
    // MARK: - Helper Checks
    var hasVisitedStructures: Bool {
        return structures.contains { $0.isVisited }
    }

    var visitedCount: Int {
        return structures.filter { $0.isVisited }.count
    }
    
    var hasLikedStructures: Bool {
        return structures.contains { $0.isLiked }
    }
    
    func dismissLastVisitedStructure() {
        lastVisitedStructure = nil
        lastVisitedGhostStructure = nil
    }
    
}
