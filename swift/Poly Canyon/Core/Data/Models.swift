import Foundation
import CoreLocation
import SwiftUI

enum SortState {
    case all
    case favorites
    case visited
    case unvisited
}

struct Structure: Codable, Identifiable, Equatable {
    // Static properties from JSON
    let number: Int
    let title: String
    let year: String
    let builders: String
    let funFact: String?
    let description: String
    
    // Dynamic properties (not in JSON initially, but needed for persistence)
    var isVisited: Bool
    var isOpened: Bool
    var recentlyVisited: Int
    var isLiked: Bool
    var mainPhoto: String
    var closeUp: String
    
    // Conform to Identifiable
    var id: Int { number }
    
    // Custom Codable implementation
    private enum CodingKeys: String, CodingKey {
        case number, title, year, builders, funFact, description
        case isVisited, isOpened, recentlyVisited, isLiked
        case mainPhoto, closeUp
    }
    
    // Default initializer for creating new structures
    init(number: Int, title: String, year: String, builders: String, 
         funFact: String?, description: String) {
        self.number = number
        self.title = title
        self.year = year
        self.builders = builders
        self.funFact = funFact
        self.description = description
        
        // Set defaults for dynamic properties
        self.isVisited = false
        self.isOpened = false
        self.recentlyVisited = -1
        self.isLiked = false
        self.mainPhoto = "\(number)M"
        self.closeUp = "\(number)C"
    }
    
    // Decoder initializer for loading from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required static properties
        number = try container.decode(Int.self, forKey: .number)
        title = try container.decode(String.self, forKey: .title)
        year = try container.decode(String.self, forKey: .year)
        builders = try container.decode(String.self, forKey: .builders)
        funFact = try container.decodeIfPresent(String.self, forKey: .funFact)
        description = try container.decode(String.self, forKey: .description)
        
        // Try to decode dynamic properties, use defaults if not found
        isVisited = try container.decodeIfPresent(Bool.self, forKey: .isVisited) ?? false
        isOpened = try container.decodeIfPresent(Bool.self, forKey: .isOpened) ?? false
        recentlyVisited = try container.decodeIfPresent(Int.self, forKey: .recentlyVisited) ?? -1
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        mainPhoto = try container.decodeIfPresent(String.self, forKey: .mainPhoto) ?? "\(number)M"
        closeUp = try container.decodeIfPresent(String.self, forKey: .closeUp) ?? "\(number)C"
    }
    
    // Conform to Equatable
    static func == (lhs: Structure, rhs: Structure) -> Bool {
        return lhs.number == rhs.number
    }
}

struct MapPoint: Codable {
    let coordinate: CLLocationCoordinate2D
    let pixelPosition: CGPoint
    let landmark: Int
}

// For decoding the JSON format
struct MapPointData: Codable {
    let number: Int
    let latitude: Double
    let longitude: Double
    let pixelX: String
    let pixelY: String
    let landmark: Int
}

// Keep our existing MapPoint model but add init from MapPointData
extension MapPoint {
    init(from data: MapPointData) {
        self.coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        self.pixelPosition = CGPoint(
            x: Double(data.pixelX.replacingOccurrences(of: " px", with: "")) ?? 0,
            y: Double(data.pixelY.replacingOccurrences(of: " px", with: "")) ?? 0
        )
        self.landmark = data.landmark
    }
}

// MARK: - CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

// MARK: - CGPoint Codable
extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Double.self, forKey: .x)
        let y = try container.decode(Double.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}
