import Foundation

class DataStore {
    static let shared = DataStore()
    
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // Data version control
    private let currentBundleVersion = "1.0"
    
    private var storedVersion: String {
        get { UserDefaults.standard.string(forKey: "dataVersion") ?? "0" }
        set { UserDefaults.standard.set(newValue, forKey: "dataVersion") }
    }
    
    // MARK: - Structure Data
    func loadStructures() -> [Structure] {
        if needsDataRefresh() {
            if let structures = loadStructuresFromBundle() {
                saveStructuresToDocuments(structures)
                storedVersion = currentBundleVersion
                return structures
            }
        }
        return loadStructuresFromDocuments() ?? loadStructuresFromBundle() ?? []
    }
    
    private func loadStructuresFromBundle() -> [Structure]? {
        guard let url = Bundle.main.url(forResource: "structuresList", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Cannot find structuresList.json in bundle")
            return nil
        }
        
        do {
            var structures = try JSONDecoder().decode([Structure].self, from: data)
            // Initialize user interaction properties
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
    
    // MARK: - Map Points
    func loadMapPoints() -> [MapPoint] {
        if needsDataRefresh() {
            if let mapPoints = loadMapPointsFromBundle() {
                saveMapPointsToDocuments(mapPoints)
                return mapPoints
            }
        }
        return loadMapPointsFromDocuments() ?? loadMapPointsFromBundle() ?? []
    }
    
    // MARK: - Persistence
    private func saveStructuresToDocuments(_ structures: [Structure]) {
        let url = documentsPath.appendingPathComponent("structures.json")
        if let data = try? JSONEncoder().encode(structures) {
            try? data.write(to: url)
        }
    }
    
    private func saveMapPointsToDocuments(_ mapPoints: [MapPoint]) {
        let url = documentsPath.appendingPathComponent("mapPoints.json")
        if let data = try? JSONEncoder().encode(mapPoints) {
            try? data.write(to: url)
        }
    }
    
    private func loadStructuresFromDocuments() -> [Structure]? {
        let url = documentsPath.appendingPathComponent("structures.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Structure].self, from: data)
    }
    
    private func loadMapPointsFromDocuments() -> [MapPoint]? {
        let url = documentsPath.appendingPathComponent("mapPoints.json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([MapPoint].self, from: data)
    }
    
    private func needsDataRefresh() -> Bool {
        return storedVersion != currentBundleVersion
    }
} 