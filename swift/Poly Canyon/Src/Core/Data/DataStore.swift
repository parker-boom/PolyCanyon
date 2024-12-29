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
    
    // MARK: - Core Data Properties
    @Published private(set) var structures: [Structure] = []
    @Published private(set) var mapPoints: [MapPoint] = []
    @Published private(set) var lastVisitedStructure: Structure? = nil
    
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
    
    @Published private(set) var visitedAllCount: Int {
        didSet {
            UserDefaults.standard.set(visitedAllCount, forKey: "visitedAllCount")
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
    private let currentBundleVersion = "1.0"
    
    private var storedVersion: String {
        get { UserDefaults.standard.string(forKey: "dataVersion") ?? "0" }
        set { UserDefaults.standard.set(newValue, forKey: "dataVersion") }
    }
    
    // MARK: - Initialization
    private init() {
        // Load persisted stats
        self.visitedCount = UserDefaults.standard.integer(forKey: "visitedCount")
        self.dayCount = UserDefaults.standard.integer(forKey: "dayCount")
        self.visitedAllCount = UserDefaults.standard.integer(forKey: "visitedAllCount")
        self.previousDayVisited = UserDefaults.standard.string(forKey: "previousDayVisited")
        
        loadInitialData()
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
        if storedVersion != currentBundleVersion {
            loadAndSaveInitialData()
        } else {
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
        guard let url = Bundle.main.url(forResource: "structuresList", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Cannot find structuresList.json in bundle")
            return nil
        }
        
        do {
            var structures = try JSONDecoder().decode([Structure].self, from: data)
            for index in structures.indices {
                structures[index].isVisited = false
                structures[index].isOpened = false
                structures[index].recentlyVisited = -1
                structures[index].isLiked = false
            }
            return structures
        } catch {
            print("Error decoding structures: \(error)")
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
        guard let index = structures.firstIndex(where: { $0.number == number }),
              !structures[index].isVisited else { return }
        
        structures[index].isVisited = true
        structures[index].recentlyVisited = visitedCount
        visitedCount += 1
        lastVisitedStructure = structures[index]
        
        // Update day count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        if let lastVisited = previousDayVisited {
            if lastVisited != todayString {
                dayCount += 1
                previousDayVisited = todayString
            }
        } else {
            dayCount += 1
            previousDayVisited = todayString
        }
        
        // Check for all structures visited
        if structures.allSatisfy({ $0.isVisited }) {
            visitedAllCount += 1
        }
        
        saveStructures()
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
        guard let url = Bundle.main.url(forResource: "mapPoints", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Cannot find mapPoints.json in bundle")
            return nil
        }
        
        do {
            let mapPointData = try JSONDecoder().decode([MapPointData].self, from: data)
            return mapPointData.map { data in
                MapPoint(
                    coordinate: CLLocationCoordinate2D(
                        latitude: data.latitude,
                        longitude: data.longitude
                    ),
                    pixelPosition: CGPoint(
                        x: Double(data.pixelX.replacingOccurrences(of: " px", with: "")) ?? 0,
                        y: Double(data.pixelY.replacingOccurrences(of: " px", with: "")) ?? 0
                    ),
                    landmark: data.landmark,
                    isVisited: false
                )
            }
        } catch {
            print("Error decoding map points: \(error)")
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
        case .unopened:
            return searchFiltered.filter { $0.isVisited && !$0.isOpened }
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
}

// MARK: - Supporting Types
private struct MapPointData: Codable {
    let number: Int
    let latitude: Double
    let longitude: Double
    let pixelX: String
    let pixelY: String
    let landmark: Int
} 