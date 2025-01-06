/*
 DataStore manages the app's core data structures and persistence layer. It handles loading and saving of 
 structure data, map points, and user statistics. The store is accessible app-wide as a shared singleton
 through environment objects (@EnvironmentObject). It provides a comprehensive API for querying and 
 updating structure data, managing visit states, and tracking user progress statistics.
*/

import Foundation
import CoreLocation

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    // MARK: - Published Properties
    @Published private(set) var structures: [Structure] = []
    @Published private(set) var mapPoints: [MapPoint] = []
    @Published private(set) var lastVisitedStructure: Structure?
    
    // MARK: - Statistics Properties
    @Published private(set) var visitedCount: Int {
        didSet {
            UserDefaults.standard.set(visitedCount, forKey: "visitedCount")
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
    private let currentBundleVersion = "2.0"
    
    private var storedVersion: String {
        get { UserDefaults.standard.string(forKey: "dataVersion") ?? "0" }
        set { UserDefaults.standard.set(newValue, forKey: "dataVersion") }
    }
    
    // MARK: - Initialization
    init() {
        print("📚 Initializing DataStore")
        // Load persisted stats
        self.visitedCount = UserDefaults.standard.integer(forKey: "visitedCount")
        self.dayCount = UserDefaults.standard.integer(forKey: "dayCount")
        self.previousDayVisited = UserDefaults.standard.string(forKey: "previousDayVisited")
        print("📚 Loaded stats - Visited: \(visitedCount), Days: \(dayCount)")
        
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
        markStructureAsVisited(number)
    }
    
    /*
    *
    *
    SHARED DATA MANAGEMENT - Loading & Saving
    *
    *
    */
    
    // Decides whether to load in new data (data changed on update)
    private func loadInitialData() {
        print("📚 Checking data version - Stored: \(storedVersion), Current: \(currentBundleVersion)")
        if storedVersion != currentBundleVersion {
            print("📚 Version mismatch - Loading fresh data from bundle")
            loadAndSaveInitialData()
        } else {
            print("📚 Version match - Loading persisted data")
            loadPersistedData()
        }
    }
    
    // Loads in new data from bundle and saves it to documents
    private func loadAndSaveInitialData() {
        if let structures = loadStructuresFromBundle() {
            self.structures = structures
            saveStructures()
        }
        
        if let mapPoints = loadMapPointsFromBundle() {
            self.mapPoints = mapPoints
            saveMapPoints()
        }
        
        storedVersion = currentBundleVersion
    }
    
    // Loads in persisted data from documents (no change)
    private func loadPersistedData() {
        if let structures = loadStructuresFromDocuments() {
            self.structures = structures
        }
        
        if let mapPoints = loadMapPointsFromDocuments() {
            self.mapPoints = mapPoints
        }
    }
    
    /*
    *
    *
    STRUCTURES
    *
    *
    */
    
    // Loads in new data from bundle
    private func loadStructuresFromBundle() -> [Structure]? {
        print("📚 Loading structures from bundle...")
        guard let url = Bundle.main.url(forResource: "structuresList", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to find or read structuresList.json")
            return nil
        }
        
        do {
            var structures = try JSONDecoder().decode([Structure].self, from: data)
            print("📚 Successfully decoded \(structures.count) structures")
            for index in structures.indices {
                structures[index].mainPhoto = "\(structures[index].number)M"
                structures[index].closeUp = "\(structures[index].number)C"
            }
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
        visitedCount += 1
        
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
    
    // Resets all structures to default state
    func resetStructures() {
        for index in structures.indices {
            structures[index].isVisited = false
            structures[index].isOpened = false
            structures[index].recentlyVisited = -1
            structures[index].isLiked = false
        }
        saveStructures()
        objectWillChange.send()
    }
    
    /*
    *
    *
    MAP POINTS
    *
    *
    */
    
    // Loads in new data from bundle
    private func loadMapPointsFromBundle() -> [MapPoint]? {
    print("📚 Loading and sorting map points from bundle...")
    guard let url = Bundle.main.url(forResource: "mapPoints", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        print("❌ Failed to find or read mapPoints.json")
        return nil
    }
    
    do {
        let mapPointData = try JSONDecoder().decode([MapPointData].self, from: data)
        let points = mapPointData.map { MapPoint(from: $0) }
        
        // Sort points by latitude first, then longitude
        let sortedPoints = points.sorted {
            $0.coordinate.latitude == $1.coordinate.latitude
                ? $0.coordinate.longitude < $1.coordinate.longitude
                : $0.coordinate.latitude < $1.coordinate.latitude
        }
        
        print("📚 Successfully loaded and sorted \(sortedPoints.count) map points")
        return sortedPoints
    } catch {
            print("❌ Error decoding map points: \(error)")
            return nil
        }
    }

    
    // Saves map points to documents
    private func saveMapPoints() {
        let url = documentsPath.appendingPathComponent("mapPoints.json")
        if let data = try? JSONEncoder().encode(mapPoints) {
            try? data.write(to: url)
        }
    }
    
    // Loads persisted map points from documents
    private func loadMapPointsFromDocuments() -> [MapPoint]? {
        let url = documentsPath.appendingPathComponent("mapPoints.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([MapPoint].self, from: data)
    }
    
    // MARK: - MapPoint Public Functions
    
    // Finds the nearest map point to a given coordinate
    func findNearestPoint(to coordinate: CLLocationCoordinate2D) -> MapPoint? {
        var nearestPoint: MapPoint?
        var minDistance = Double.infinity
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        for point in mapPoints {
            let pointLocation = CLLocation(
                latitude: point.coordinate.latitude,
                longitude: point.coordinate.longitude
            )
            let distance = location.distance(from: pointLocation)
            if distance < minDistance {
                minDistance = distance
                nearestPoint = point
            }
        }
        
        return nearestPoint
    }
    
    /* Basic Filters: 
    * Liked
    * Visited
    * Unvisited
    * Unopened
    */
    func getFilteredStructures(searchText: String = "", sortState: SortState) -> [Structure] {
        let searchFiltered = structures.filter { structure in
            searchText.isEmpty || 
            structure.title.localizedCaseInsensitiveContains(searchText) || 
            String(structure.number).contains(searchText)
        }
        
        switch sortState {
        case .all:
            return searchFiltered
        case .favorites:
            return searchFiltered.filter { $0.isLiked }
        case .visited:
            return searchFiltered.filter { $0.isVisited }
        case .unvisited:
            return searchFiltered.filter { !$0.isVisited }
        }
    }
    
    // 3 most recently visited structures
    func getRecentlyVisitedStructures(limit: Int = 3) -> [Structure] {
        return structures
            .filter { $0.recentlyVisited != -1 }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(limit)
            .map { $0 }
    }
    
    // 3 most recently unopened (visited) structures
    func getRecentlyUnopenedStructures(limit: Int = 3) -> [Structure] {
        return structures
            .filter { !$0.isOpened && $0.isVisited }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(limit)
            .map { $0 }
    }
    
    // 3 closest unvisited structures
    func getNearbyUnvisitedStructures(limit: Int = 3) -> [Structure] {
        return structures
            .filter { !$0.isVisited }
            .sorted { LocationService.shared.getDistance(to: $0) < LocationService.shared.getDistance(to: $1) }
            .prefix(limit)
            .map { $0 }
    }
    
    // Helper Checks
    var hasUnvisitedStructures: Bool {
        return structures.contains { !$0.isVisited }
    }
    
    var hasVisitedStructures: Bool {
        return structures.contains { $0.isVisited }
    }
    
    var hasUnopenedStructures: Bool {
        return structures.contains { $0.isVisited && !$0.isOpened }
    }
    
    var hasLikedStructures: Bool {
        return structures.contains { $0.isLiked }
    }
    
    private func printCurrentState() {
        print("\n📚 ====== DataStore State ======")
        print("📚 Version Info:")
        print("  • Stored Version: \(storedVersion)")
        print("  • Current Version: \(currentBundleVersion)")
        
        print("\n📚 Statistics:")
        print("  • Visited Count: \(visitedCount)")
        print("  • Days Active: \(dayCount)")
        print("  • Last Visit Date: \(previousDayVisited ?? "None")")
        
        print("\n📚 Structures (\(structures.count) total):")
        print("  • Visited: \(structures.filter { $0.isVisited }.count)")
        print("  • Unopened: \(structures.filter { !$0.isOpened }.count)")
        print("  • Liked: \(structures.filter { $0.isLiked }.count)")
        
        if let lastVisited = lastVisitedStructure {
            print("\n📚 Last Visited Structure:")
            print("  • Number: \(lastVisited.number)")
            print("  • Title: \(lastVisited.title)")
            print("  • Timestamp: \(lastVisited.recentlyVisited)")
        }
        
        print("\n📚 Map Points (\(mapPoints.count) total):")
        let structurePoints = mapPoints.filter { $0.landmark != -1 }
        print("  • Structure Points: \(structurePoints.count)")
        print("  • Path Points: \(mapPoints.count - structurePoints.count)")
        print("============================\n")
    }
}
