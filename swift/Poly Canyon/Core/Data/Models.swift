import Foundation
import CoreLocation
import SwiftUI

enum SortState {
    case all
    case favorites
    case visited
    case unvisited
}

struct Structure: Codable, Identifiable {
    let id: Int
    let number: Int
    let title: String
    let year: String
    let builders: String
    let funFact: String?
    let description: String
    var mainPhoto: String
    var closeUp: String
    
    var isVisited: Bool
    var isOpened: Bool
    var recentlyVisited: Int
    var isLiked: Bool
}

struct MapPoint: Codable {
    let coordinate: CLLocationCoordinate2D
    let pixelPosition: CGPoint
    let landmark: Int
    var isVisited: Bool
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
