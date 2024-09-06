// MARK: Overview
/*
    MapPointManager.swift

    This file defines the MapPoint and MapPointManager classes, which handle the management and persistence of map points used in the app.

    Key Components:
    - MapPoint: Represents a map point with coordinates, pixel position, landmark ID, and visited status.
    - MapPointLoader: Loads map points from a CSV file.
    - MapPointManager: Manages the collection of map points, including loading, saving, and resetting visited statuses.

    Functionality:
    - saveVisitedStatus(): Saves the visited status of map points to UserDefaults.
    - loadVisitedStatus(): Loads the visited status of map points from UserDefaults.
    - resetVisitedMapPoints(): Resets the visited status of all map points except those with landmark ID -1.
    - loadMapPoints(): Loads map points from a CSV file using MapPointLoader.
*/



// MARK: Code
import Foundation
import CoreLocation
import CoreGraphics

// Create the map point object
class MapPoint: Equatable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    var pixelPosition: CGPoint
    var landmark: Int
    var isVisited: Bool

    init(coordinate: CLLocationCoordinate2D, pixelPosition: CGPoint, landmark: Int, isVisited: Bool) {
        self.id = UUID()
        self.coordinate = coordinate
        self.pixelPosition = pixelPosition
        self.landmark = landmark
        self.isVisited = isVisited
    }

    static func == (lhs: MapPoint, rhs: MapPoint) -> Bool {
        return lhs.id == rhs.id
    }
}


// Load in the map points from CSV file
class MapPointLoader {
    static func loadMapPoints(from url: URL) -> [MapPoint] {
        do {
            let csvData = try Data(contentsOf: url)
            let csvString = String(data: csvData, encoding: .utf8) ?? ""
            let lines = csvString.components(separatedBy: .newlines)
            
            var loadedMapPoints: [MapPoint] = []
            
            for line in lines.dropFirst() {
                let values = line.components(separatedBy: ",")
                
                if values.count >= 5 {
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

// Create the class of mapPoints loaded in
class MapPointManager: ObservableObject {
    @Published var mapPoints: [MapPoint] = []

    init() {
        loadMapPoints()
        loadVisitedStatus()  // Ensure this is called after loading map points
    }

    func saveVisitedStatus() {
        let visitedStatuses = mapPoints.map { $0.isVisited }
        UserDefaults.standard.set(visitedStatuses, forKey: "mapPointsVisitedStatuses")
        UserDefaults.standard.synchronize()  // Force UserDefaults to save immediately

        
    }

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

    private func loadMapPoints() {
        guard let url = Bundle.main.url(forResource: "mapPoints", withExtension: "csv") else {
            print("Failed to find mapPoints CSV file.")
            return
        }
        mapPoints = MapPointLoader.loadMapPoints(from: url)
        loadVisitedStatus()
    }

    func resetVisitedMapPoints() {
        for mapPoint in mapPoints {
            if mapPoint.landmark != -1 {
                mapPoint.isVisited = false
            }
        }
        saveVisitedStatus()
        objectWillChange.send()
    }
}
