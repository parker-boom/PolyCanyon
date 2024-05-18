// MARK: mapPoints.swift
// This file defines the MapPoint structure and an array of map points for the "Arch Graveyard" app. Each MapPoint contains geographic coordinates, a pixel position on the map, and a landmark identifier for referencing specific architectural structures within Cal Poly's architecture graveyard.



// MARK: Declaration
import Foundation
import CoreLocation
import CoreGraphics

class MapPoint {
    var coordinate: CLLocationCoordinate2D
    var pixelPosition: CGPoint
    var landmark: Int
    var isVisited: Bool
    
    init(coordinate: CLLocationCoordinate2D, pixelPosition: CGPoint, landmark: Int, isVisited: Bool) {
        self.coordinate = coordinate
        self.pixelPosition = pixelPosition
        self.landmark = landmark
        self.isVisited = isVisited
    }
}

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
        loadVisitedStatus()  // Load visited statuses after map points are loaded
    }

    func resetVisitedMapPoints() {
        for mapPoint in mapPoints {
            if mapPoint.landmark != -1 {
                mapPoint.isVisited = false
            }
        }
        saveVisitedStatus()
    }
}
