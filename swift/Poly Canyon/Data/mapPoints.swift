// MARK: MapPointManager.swift

import Foundation
import CoreLocation
import CoreGraphics

/**
 * MapPoint
 *
 * Represents a specific point on the map within the Poly Canyon app. Each MapPoint includes
 * geographical coordinates, pixel positions for map rendering, an associated landmark ID,
 * and a flag indicating whether the point has been visited by the user.
 */
class MapPoint: Equatable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    var pixelPosition: CGPoint
    var landmark: Int
    var isVisited: Bool

    /**
     * Initializes a new MapPoint with the provided parameters.
     *
     * - Parameters:
     *   - coordinate: The geographical coordinates of the map point.
     *   - pixelPosition: The pixel position on the map image.
     *   - landmark: The associated landmark ID.
     *   - isVisited: A Boolean indicating if the map point has been visited.
     */
    init(coordinate: CLLocationCoordinate2D, pixelPosition: CGPoint, landmark: Int, isVisited: Bool) {
        self.id = UUID()
        self.coordinate = coordinate
        self.pixelPosition = pixelPosition
        self.landmark = landmark
        self.isVisited = isVisited
    }

    /**
     * Equatable protocol conformance to compare two MapPoint instances.
     *
     * - Parameters:
     *   - lhs: The first MapPoint instance.
     *   - rhs: The second MapPoint instance.
     * - Returns: A Boolean indicating whether the two MapPoints are equal based on their UUIDs.
     */
    static func == (lhs: MapPoint, rhs: MapPoint) -> Bool {
        return lhs.id == rhs.id
    }
}

/**
 * MapPointLoader
 *
 * Responsible for loading map points from a CSV file. Parses each line of the CSV to create
 * MapPoint instances, handling any necessary data transformations.
 */
class MapPointLoader {
    /**
     * Loads map points from the specified CSV file URL.
     *
     * - Parameter url: The URL of the CSV file containing map point data.
     * - Returns: An array of MapPoint objects parsed from the CSV.
     */
    static func loadMapPoints(from url: URL) -> [MapPoint] {
        do {
            let csvData = try Data(contentsOf: url)
            let csvString = String(data: csvData, encoding: .utf8) ?? ""
            let lines = csvString.components(separatedBy: .newlines)
            
            var loadedMapPoints: [MapPoint] = []
            
            for line in lines.dropFirst() {
                let values = line.components(separatedBy: ",")
                
                if values.count >= 6 {
                    let latitude = Double(values[1]) ?? 0.0
                    let longitude = Double(values[2]) ?? 0.0
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let pixelXString = values[3].replacingOccurrences(of: " px", with: "")
                    let pixelYString = values[4].replacingOccurrences(of: " px", with: "")
                    let pixelX = Double(pixelXString) ?? 0.0
                    let pixelY = Double(pixelYString) ?? 0.0
                    let pixelPosition = CGPoint(x: pixelX, y: pixelY)
                    
                    let landmark = Int(values[5]) ?? -1
                    let isVisited = (landmark == -1)
                    
                    let mapPoint = MapPoint(coordinate: coordinate, pixelPosition: pixelPosition, landmark: landmark, isVisited: isVisited)
                    loadedMapPoints.append(mapPoint)
                }
            }
            
            return loadedMapPoints
        } catch {
            print("Error loading map points: \(error)")
            return []
        }
    }
}

/**
 * MapPointManager
 *
 * Manages the collection of MapPoint instances within the Poly Canyon app. This class handles
 * loading map points from a CSV file, persisting visited statuses using UserDefaults, and providing
 * functionalities to reset or update the visited status of map points.
 */
class MapPointManager: ObservableObject {
    @Published var mapPoints: [MapPoint] = []

    /**
     * Initializes the MapPointManager and loads map points and their visited statuses.
     */
    init() {
        loadMapPoints()
        loadVisitedStatus()  // Ensure this is called after loading map points
    }

    /**
     * Saves the visited status of all map points to UserDefaults for persistence.
     */
    func saveVisitedStatus() {
        let visitedStatuses = mapPoints.map { $0.isVisited }
        UserDefaults.standard.set(visitedStatuses, forKey: "mapPointsVisitedStatuses")
        UserDefaults.standard.synchronize()  // Force UserDefaults to save immediately
    }

    /**
     * Loads the visited status of map points from UserDefaults and updates the mapPoints array.
     */
    func loadVisitedStatus() {
        guard let visitedStatuses = UserDefaults.standard.array(forKey: "mapPointsVisitedStatuses") as? [Bool] else {
            return
        }

        for (index, isVisited) in visitedStatuses.enumerated() {
            if index < mapPoints.count {
                mapPoints[index].isVisited = isVisited
            }
        }
    }

    /**
     * Loads map points from the CSV file and initializes the mapPoints array.
     */
    private func loadMapPoints() {
        guard let url = Bundle.main.url(forResource: "mapPoints", withExtension: "csv") else {
            print("Failed to find mapPoints CSV file.")
            return
        }
        mapPoints = MapPointLoader.loadMapPoints(from: url)
        loadVisitedStatus()
    }

    /**
     * Resets the visited status of all map points to false.
     */
    func resetVisitedMapPoints() {
        for mapPoint in mapPoints {
            mapPoint.isVisited = false
        }
        saveVisitedStatus()
        objectWillChange.send()
    }
}
