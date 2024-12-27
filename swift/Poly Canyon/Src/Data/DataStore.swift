import Foundation
import CoreLocation

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    // MARK: - Published Data
    @Published private(set) var structures: [Structure] = []
    @Published private(set) var mapPoints: [MapPoint] = []
    
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
        loadInitialData()
    }
    
    // MARK: - Shared Data Management
    
    private func loadInitialData() {
        if needsDataRefresh() {
            loadAndSaveInitialData()
        } else {
            loadPersistedData()
        }
    }
    
    private func needsDataRefresh() -> Bool {
        return storedVersion != currentBundleVersion
    }
    
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
    
    private func loadPersistedData() {
        if let structures = loadStructuresFromDocuments() {
            self.structures = structures
        }
        
        if let mapPoints = loadMapPointsFromDocuments() {
            self.mapPoints = mapPoints
        }
    }
    
    // MARK: - Structure Data Management
    
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
    
    private func saveStructures() {
        let url = documentsPath.appendingPathComponent("structures.json")
        if let data = try? JSONEncoder().encode(structures) {
            try? data.write(to: url)
        }
    }
    
    private func loadStructuresFromDocuments() -> [Structure]? {
        let url = documentsPath.appendingPathComponent("structures.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Structure].self, from: data)
    }
    
    // MARK: - Structure Public Functions
    
    func markStructureAsVisited(_ number: Int, recentlyVisitedCount: Int) {
        if let index = structures.firstIndex(where: { $0.number == number }) {
            structures[index].isVisited = true
            if structures[index].recentlyVisited == -1 {
                structures[index].recentlyVisited = recentlyVisitedCount
            }
            saveStructures()
            objectWillChange.send()
        }
    }
    
    func markStructureAsOpened(_ number: Int) {
        if let index = structures.firstIndex(where: { $0.number == number }) {
            structures[index].isOpened = true
            saveStructures()
            objectWillChange.send()
        }
    }
    
    func toggleLike(for structureId: Int) {
        if let index = structures.firstIndex(where: { $0.id == structureId }) {
            structures[index].isLiked.toggle()
            saveStructures()
            objectWillChange.send()
        }
    }
    
    func getLikedStructures() -> [Structure] {
        return structures.filter { $0.isLiked }
    }
    
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
    
    // MARK: - MapPoint Data Management
    
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
    
    private func saveMapPoints() {
        let url = documentsPath.appendingPathComponent("mapPoints.json")
        if let data = try? JSONEncoder().encode(mapPoints) {
            try? data.write(to: url)
        }
    }
    
    private func loadMapPointsFromDocuments() -> [MapPoint]? {
        let url = documentsPath.appendingPathComponent("mapPoints.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([MapPoint].self, from: data)
    }
    
    // MARK: - MapPoint Public Functions
    
    func markPointAsVisited(_ point: MapPoint) {
        if let index = mapPoints.firstIndex(where: { $0.id == point.id }) {
            mapPoints[index].isVisited = true
            saveMapPoints()
            objectWillChange.send()
        }
    }
    
    func resetMapPoints() {
        for index in mapPoints.indices {
            mapPoints[index].isVisited = false
        }
        saveMapPoints()
        objectWillChange.send()
    }
    
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