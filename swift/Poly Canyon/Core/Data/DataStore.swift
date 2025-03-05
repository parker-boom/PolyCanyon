/*
 DataStore manages the app's core data structures and persistence layer. It handles loading and saving of 
 structure data and user statistics. The store is accessible app-wide as a shared singleton
 through environment objects (@EnvironmentObject). It provides a comprehensive API for querying and 
 updating structure data, managing visit states, and tracking user progress statistics.
*/

import Foundation
import CoreLocation

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    // MARK: - Published Properties
    @Published private(set) var structures: [Structure] = []
    @Published private(set) var ghostStructures: [GhostStructure] = []
    @Published private(set) var lastVisitedStructure: Structure?
    @Published private(set) var lastVisitedGhostStructure: GhostStructure?
    
    // MARK: - Statistics Properties
    @Published private(set) var totalVisitedCount: Int {
        didSet {
            UserDefaults.standard.set(totalVisitedCount, forKey: "totalVisitedCount")
        }
    }
    
    @Published private(set) var dayCount: Int {
        didSet {
            UserDefaults.standard.set(dayCount, forKey: "dayCount")
        }
    }
    
    private var previousDayVisited: String? {
        didSet {
            UserDefaults.standard.set(previousDayVisited, forKey: "previousDayVisited")
        }
    }
    
    // MARK: - File Management
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let currentBundleVersion = "2.4"
    
    private var storedVersion: String {
        get { UserDefaults.standard.string(forKey: "dataVersion") ?? "0" }
        set { UserDefaults.standard.set(newValue, forKey: "dataVersion") }
    }
    
    // MARK: - Initialization
    init() {
        print("📚 Initializing DataStore")
        // Load persisted stats
        self.totalVisitedCount = UserDefaults.standard.integer(forKey: "totalVisitedCount")
        self.dayCount = UserDefaults.standard.integer(forKey: "dayCount")
        self.previousDayVisited = UserDefaults.standard.string(forKey: "previousDayVisited")
        print("📚 Loaded stats - Visited: \(totalVisitedCount), Days: \(dayCount)")
        
        loadInitialData()
        setupNotifications()
        print("📚 DataStore initialization complete")
        
        printCurrentState()
    }
    
    private func setupNotifications() {
        // Listen for structure visits from LocationService
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStructureVisit),
            name: .structureVisited,
            object: nil
        )
    }
    
    @objc private func handleStructureVisit(_ notification: Notification) {
        guard let number = notification.userInfo?["structureNumber"] as? Int else {
            print("❌ Invalid structure number in visit notification")
            return
        }
        print("📚 Received visit notification for structure \(number)")
        
        // Check if this is a regular structure or ghost structure based on number
        if number >= 100 {
            // This is a ghost structure (numbers 101+)
            markGhostStructureAsVisited(number)
        } else {
            // This is a regular structure (numbers 1-31)
            markStructureAsVisited(number)
        }
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        print("📚 Checking data version - Stored: \(storedVersion), Current: \(currentBundleVersion)")
        if storedVersion != currentBundleVersion {
            print("📚 Version mismatch - Loading fresh data from bundle")
            loadAndSaveInitialData()
        } else {
            print("📚 Version match - Loading persisted data")
            loadPersistedData()
            
            // If ghost structures array is empty after loading from documents, try loading from bundle
            if ghostStructures.isEmpty {
                print("📚 Ghost structures array is empty - attempting to load from bundle")
                forceReloadGhostStructures()
            }
        }
    }
    
    private func loadAndSaveInitialData() {
        if let structures = loadStructuresFromBundle() {
            self.structures = structures
            saveStructures()
            print("📚 Loaded and saved \(structures.count) regular structures from bundle")
        } else {
            print("❌ Failed to load regular structures from bundle")
        }
        
        print("📚 About to load ghost structures from bundle...")
        if let ghostStructures = loadGhostStructuresFromBundle() {
            print("📚 Successfully loaded \(ghostStructures.count) ghost structures from bundle")
            self.ghostStructures = ghostStructures
            saveGhostStructures()
            print("📚 Ghost structures saved to documents")
        } else {
            print("❌ Failed to load ghost structures from bundle")
        }
        
        storedVersion = currentBundleVersion
    }
    
    private func loadPersistedData() {
        if let structures = loadStructuresFromDocuments() {
            self.structures = structures
        }
        
        if let ghostStructures = loadGhostStructuresFromDocuments() {
            self.ghostStructures = ghostStructures
        }
    }
    
    // MARK: - Structure Management
    private func loadStructuresFromBundle() -> [Structure]? {
        print("📚 Loading structures from bundle...")
        guard let url = Bundle.main.url(forResource: "structuresList", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to find or read structuresList.json")
            return nil
        }
        
        do {
            let structures = try JSONDecoder().decode([Structure].self, from: data)
            print("📚 Successfully decoded \(structures.count) structures")
            return structures
        } catch {
            print("❌ Error decoding structures: \(error)")
            return nil
        }
    }
    
    // Saves structures to documents
    private func saveStructures() {
        let url = documentsPath.appendingPathComponent("structures.json")
        if let data = try? JSONEncoder().encode(structures) {
            try? data.write(to: url)
        }
    }
    
    // Loads persisted structures from documents
    private func loadStructuresFromDocuments() -> [Structure]? {
        let url = documentsPath.appendingPathComponent("structures.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Structure].self, from: data)
    }
    
    // MARK: - Structure Public Functions
    
    // Sets a structure as visited (UI reacts), updates stats, and saves
    func markStructureAsVisited(_ number: Int) {
        guard let index = structures.firstIndex(where: { $0.number == number }) else {
            print("❌ Structure \(number) not found")
            return
        }
        
        if structures[index].isVisited {
            print("📚 Structure \(number) already visited")
            return
        }
        
        print("📚 Marking structure \(number) as visited")
        structures[index].isVisited = true
        structures[index].recentlyVisited = Int(Date().timeIntervalSince1970)
        lastVisitedStructure = structures[index]
        totalVisitedCount += 1
        
        // Update day tracking
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        if let lastVisited = previousDayVisited {
            if lastVisited != todayString {
                dayCount += 1
                previousDayVisited = todayString
                print("📚 New day visit - Total days: \(dayCount)")
            }
        } else {
            dayCount += 1
            previousDayVisited = todayString
            print("📚 First day visit recorded")
        }
        
        saveStructures()
        print("📚 Structure visit processed and saved")
    }
    
    // Sets a structure as opened (UI reacts), and saves
    func markStructureAsOpened(_ number: Int) {
        if let index = structures.firstIndex(where: { $0.number == number }) {
            structures[index].isOpened = true
            saveStructures()
            objectWillChange.send()
        }
    }
    
    // Toggles a structure as liked (UI reacts), and saves
    func toggleLike(for structureId: Int) {
        if let index = structures.firstIndex(where: { $0.id == structureId }) {
            structures[index].isLiked.toggle()
            saveStructures()
            objectWillChange.send()
        }
    }
    
    func isLiked(for structureId: Int) -> Bool {
        return structures.first(where: { $0.id == structureId })?.isLiked ?? false
    }

    // Resets all structures to default state
    func resetLikes() {
        // Reset regular structures
        for index in structures.indices {
            structures[index].isLiked = false
        }
        saveStructures()

        objectWillChange.send()
    }
    
    // Resets all structures to default state
    func resetStructures() {
        // Reset regular structures
        for index in structures.indices {
            structures[index].isVisited = false
            structures[index].isOpened = false
            structures[index].recentlyVisited = -1
            structures[index].isLiked = false
        }
        totalVisitedCount = 0
        saveStructures()
        
        // Reset ghost structures
        for index in ghostStructures.indices {
            ghostStructures[index].isVisited = false
        }
        saveGhostStructures()
        
        objectWillChange.send()
    }
    
    // MARK: - Ghost Structure Management
    private func loadGhostStructuresFromBundle() -> [GhostStructure]? {
        print("📚 Loading ghost structures from bundle...")
        
        // Debug: List all json files in the bundle to verify inclusion
        debugPrintBundleJSONFiles()
        
        // Check if the file exists in the bundle
        let fileExists = Bundle.main.url(forResource: "ghostStructures", withExtension: "json") != nil
        print("📚 Ghost structures file exists in bundle: \(fileExists)")
        
        guard let url = Bundle.main.url(forResource: "ghostStructures", withExtension: "json") else {
            print("❌ Failed to find ghostStructures.json in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("📚 Successfully read ghostStructures.json data: \(data.count) bytes")
            
            // Print a sample of the JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                let preview = String(jsonString.prefix(200))
                print("📚 JSON content sample: \(preview)...")
            }
            
            let structures = try JSONDecoder().decode([GhostStructure].self, from: data)
            print("📚 Successfully decoded \(structures.count) ghost structures")
            return structures
        } catch let readError as NSError {
            print("❌ Error reading ghostStructures.json: \(readError.localizedDescription)")
            return nil
        } catch let decodeError {
            print("❌ Error decoding ghost structures: \(decodeError)")
            
            // Try to validate the JSON
            if let data = try? Data(contentsOf: url) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let array = json as? [[String: Any]] {
                        print("📚 JSON is valid with \(array.count) items")
                        
                        // Print some keys from the first item to help debug
                        if let firstItem = array.first {
                            print("📚 First item keys: \(firstItem.keys.joined(separator: ", "))")
                        }
                    }
                } catch {
                    print("❌ JSON is invalid: \(error)")
                }
            }
            
            return nil
        }
    }
    
    func forceReloadGhostStructures() {
        print("📚 Forcing reload of ghost structures from bundle...")
        if let ghostStructures = loadGhostStructuresFromBundle() {
            self.ghostStructures = ghostStructures
            saveGhostStructures()
            print("📚 Successfully reloaded \(ghostStructures.count) ghost structures from bundle")
            objectWillChange.send()
        } else {
            print("❌ Failed to force reload ghost structures from bundle")
        }
    }
    
    private func saveGhostStructures() {
        let url = documentsPath.appendingPathComponent("ghostStructures.json")
        if let data = try? JSONEncoder().encode(ghostStructures) {
            try? data.write(to: url)
        }
    }
    
    private func loadGhostStructuresFromDocuments() -> [GhostStructure]? {
        let url = documentsPath.appendingPathComponent("ghostStructures.json")
        print("📚 Attempting to load ghost structures from: \(url.path)")
        
        let fileExists = FileManager.default.fileExists(atPath: url.path)
        print("📚 Ghost structures file exists in documents: \(fileExists)")
        
        guard let data = try? Data(contentsOf: url) else { 
            print("❌ Failed to read ghostStructures.json from documents")
            return nil 
        }
        
        do {
            let structures = try JSONDecoder().decode([GhostStructure].self, from: data)
            print("📚 Successfully decoded \(structures.count) ghost structures from documents")
            return structures
        } catch {
            print("❌ Error decoding ghost structures from documents: \(error)")
            return nil
        }
    }
    
    // MARK: - Ghost Structure Functions

    // Sets a ghost structure as visited, updates stats, and saves
    func markGhostStructureAsVisited(_ number: Int) {
        // Find the ghost structure with this number
        guard let index = ghostStructures.firstIndex(where: { $0.number == String(number) }) else {
            print("❌ Ghost structure \(number) not found")
            return
        }
        
        if ghostStructures[index].isVisited {
            print("📚 Ghost structure \(number) already visited")
            return
        }
        
        print("📚 Marking ghost structure \(number) as visited")
        ghostStructures[index].isVisited = true
        lastVisitedGhostStructure = ghostStructures[index]
        totalVisitedCount += 1  // Add to total visited count just like regular structures
        
        // Update day tracking (same logic as regular structures)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        if let lastVisited = previousDayVisited {
            if lastVisited != todayString {
                dayCount += 1
                previousDayVisited = todayString
                print("📚 New day visit - Total days: \(dayCount)")
            }
        } else {
            dayCount += 1
            previousDayVisited = todayString
            print("📚 First day visit recorded")
        }
        
        saveGhostStructures()
        print("📚 Ghost structure visit processed and saved")
        
        // Trigger notification UI with the same mechanism as regular structures
        objectWillChange.send()
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
            recentlyVisited: Int(Date().timeIntervalSince1970),
            isLiked: false
        )
    }
    
    // MARK: - Structure Filtering
    func getFilteredStructures(searchText: String = "", sortState: SortState) -> [Structure] {
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
            if LocationService.shared.isInPolyCanyonArea {
                filteredStructures = searchFiltered.sorted { s1, s2 in
                    LocationService.shared.getDistance(to: s1) < LocationService.shared.getDistance(to: s2)
                }
            } else {
                filteredStructures = searchFiltered.sorted { $0.number < $1.number }
            }
            
            // Only add ghost structures representation when showing all structures
            if !ghostStructures.isEmpty {
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
            .prefix(limit)
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
        objectWillChange.send()
    }
    
    func forceVersionMismatchOnNextLaunch() {
        print("📚 Forcing version mismatch for next launch")
        storedVersion = "0"
        print("📚 Set stored version to 0, next launch will reload all data from bundle")
    }
    
    private func printCurrentState() {
        print("\n📚 ====== DataStore State ======")
        print("📚 Version Info:")
        print("  • Stored Version: \(storedVersion)")
        print("  • Current Version: \(currentBundleVersion)")
        
        print("\n📚 Statistics:")
        print("  • Visited Count: \(totalVisitedCount)")
        print("  • Days Active: \(dayCount)")
        print("  • Last Visit Date: \(previousDayVisited ?? "None")")
        
        print("\n📚 Structures (\(structures.count) total):")
        print("  • Visited: \(structures.filter { $0.isVisited }.count)")
        print("  • Unopened: \(structures.filter { !$0.isOpened }.count)")
        print("  • Liked: \(structures.filter { $0.isLiked }.count)")
        
        print("\n📚 Ghost Structures (\(ghostStructures.count) total):")
        print("  • Visited: \(ghostStructures.filter { $0.isVisited }.count)")
        
        if let lastVisited = lastVisitedStructure {
            print("\n📚 Last Visited Structure:")
            print("  • Number: \(lastVisited.number)")
            print("  • Title: \(lastVisited.title)")
            print("  • Timestamp: \(lastVisited.recentlyVisited)")
        }
        print("============================\n")
    }
    
    private func debugPrintBundleJSONFiles() {
        let bundle = Bundle.main
        if let resourceURL = bundle.resourceURL {
            print("📚 Bundle resource path: \(resourceURL.path)")
            
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)
                let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
                
                print("📚 JSON files in bundle:")
                for file in jsonFiles {
                    print("  • \(file.lastPathComponent)")
                }
                
                if jsonFiles.isEmpty {
                    print("📚 No JSON files found in the main bundle directory")
                }
            } catch {
                print("❌ Error listing bundle contents: \(error)")
            }
        } else {
            print("❌ Could not access bundle resource URL")
        }
    }
}
