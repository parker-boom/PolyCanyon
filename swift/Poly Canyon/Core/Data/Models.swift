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
    let advisors: [String]
    let builders: [String]
    let description: String
    let funFact: String?
    let images: [String]  
    
    // Dynamic properties
    var isVisited: Bool
    var isOpened: Bool
    var recentlyVisited: Int
    var isLiked: Bool
    
    // Conform to Identifiable
    var id: Int { number }
    
    private enum CodingKeys: String, CodingKey {
        case number = "Number"
        case title = "Name"
        case year = "Year"
        case advisors = "Advisors"
        case builders = "Builders"
        case description = "Description"
        case funFact = "Fun Fact"
        case images = "Images"
        case isVisited, isOpened, recentlyVisited, isLiked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode static properties
        number = try container.decode(Int.self, forKey: .number)
        title = try container.decode(String.self, forKey: .title)
        year = try container.decode(String.self, forKey: .year)
        advisors = try container.decode([String].self, forKey: .advisors)
        builders = try container.decode([String].self, forKey: .builders)
        description = try container.decode(String.self, forKey: .description)
        funFact = try container.decodeIfPresent(String.self, forKey: .funFact)
        images = try container.decode([String].self, forKey: .images)
        
        // Set dynamic properties with defaults
        isVisited = try container.decodeIfPresent(Bool.self, forKey: .isVisited) ?? false
        isOpened = try container.decodeIfPresent(Bool.self, forKey: .isOpened) ?? false
        recentlyVisited = try container.decodeIfPresent(Int.self, forKey: .recentlyVisited) ?? -1
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
    }
    
    // Conform to Equatable
    static func == (lhs: Structure, rhs: Structure) -> Bool {
        return lhs.number == rhs.number
    }
}

/// IMPORTANT NOTE: Ghost structures have int values of 101,102... because this is how we will manage their pings from map point marking as visited
struct GhostStructure: Codable, Identifiable, Equatable {
    // Static properties from JSON
    let number: Int
    let name: String
    let year: String
    let advisors: [String]
    let builders: [String]
    let description: String
    let images: [String]
    
    // Only dynamic property needed
    var isVisited: Bool
    
    // Conform to Identifiable
    var id: Int { number }
    
    // Conform to Equatable
    static func == (lhs: GhostStructure, rhs: GhostStructure) -> Bool {
        return lhs.number == rhs.number
    }
    
    private enum CodingKeys: String, CodingKey {
        case number = "Number"
        case name = "Name"
        case year = "Year"
        case advisors = "Advisors"
        case builders = "Builders"
        case description = "Description"
        case images = "Images"
        case isVisited
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let numberString = try container.decode(String.self, forKey: .number)
        number = Int(numberString) ?? 0
        name = try container.decode(String.self, forKey: .name)
        year = try container.decode(String.self, forKey: .year)
        advisors = try container.decode([String].self, forKey: .advisors)
        builders = try container.decode([String].self, forKey: .builders)
        description = try container.decode(String.self, forKey: .description)
        images = try container.decode([String].self, forKey: .images)
        
        // Set dynamic property with default
        isVisited = try container.decodeIfPresent(Bool.self, forKey: .isVisited) ?? false
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
