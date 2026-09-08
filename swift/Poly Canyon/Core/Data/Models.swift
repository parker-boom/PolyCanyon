import Foundation
import CoreLocation
import SwiftUI

enum SortState {
    case all
    case favorites
    case visited
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
    
}

/// IMPORTANT NOTE: Ghost structures have int values of 101,102... because this is how we will manage their pings from map point marking as visited
struct GhostStructure: Codable, Identifiable, Equatable {
    // Static properties from JSON
    let number: String
    let name: String
    let year: String
    let advisors: [String]
    let builders: [String]
    let description: String
    let images: [String]
    
    // Only dynamic property needed
    var isVisited: Bool = false
    
    // Conform to Identifiable
    var id: Int { 
        return Int(number) ?? 0
    }
    
    
    mutating func markAsVisited() {
        isVisited = true
    }
    
    private enum CodingKeys: String, CodingKey {
        case number
        case name
        case year
        case advisors
        case builders
        case description
        case images
        case isVisited
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let numberString = try container.decode(String.self, forKey: .number)
        number = numberString
        name = try container.decode(String.self, forKey: .name)
        year = try container.decode(String.self, forKey: .year)
        advisors = try container.decode([String].self, forKey: .advisors)
        builders = try container.decode([String].self, forKey: .builders)
        description = try container.decode(String.self, forKey: .description)
        images = try container.decode([String].self, forKey: .images)
        isVisited = try container.decodeIfPresent(Bool.self, forKey: .isVisited) ?? false
    }
}


struct MapPoint {
    let coordinate: CLLocationCoordinate2D
    let pixelPosition: CGPoint
    let structure: Int
}

// For decoding the JSON format
struct MapPointData: Codable {
    let name: Int
    let latitude: Double
    let longitude: Double
    let pixelX: Int
    let pixelY: Int
    let structure: Int
}

// Keep our existing MapPoint model but update init from MapPointData
extension MapPoint {
    init(from data: MapPointData) {
        self.coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
        self.pixelPosition = CGPoint(x: Double(data.pixelX), y: Double(data.pixelY))
        self.structure = data.structure
    }
}

extension Structure {
    init(
        number: Int,
        title: String,
        year: String,
        advisors: [String],
        builders: [String],
        description: String,
        funFact: String?,
        images: [String],
        isVisited: Bool = false,
        isOpened: Bool = false,
        recentlyVisited: Int = -1,
        isLiked: Bool = false
    ) {
        self.number = number
        self.title = title
        self.year = year
        self.advisors = advisors
        self.builders = builders
        self.description = description
        self.funFact = funFact
        self.images = images
        self.isVisited = isVisited
        self.isOpened = isOpened
        self.recentlyVisited = recentlyVisited
        self.isLiked = isLiked
    }
}
