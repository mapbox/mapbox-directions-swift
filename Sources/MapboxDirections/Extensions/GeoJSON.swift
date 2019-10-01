import Foundation
import CoreLocation

struct Geometry: Codable {
    enum GeometryType: String, CustomStringConvertible, Codable {
        case point = "Point"
        case lineString = "LineString"
        
        var description: String {
            switch self {
            case .point:
                return "Point"
            case .lineString:
                return "LineString"
            }
        }
    }
    
    let coordinates: [CLLocationCoordinate2D]
    let type: GeometryType
    
    private enum CodingKeys: String, CodingKey {
        case coordinates
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(GeometryType.self, forKey: .type)
        switch type {
        case .lineString:
            coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
        case .point:
            coordinates = [try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        switch type {
        case .lineString:
            try container.encode(coordinates, forKey: .coordinates)
        case .point:
            try container.encode(coordinates.first!, forKey: .coordinates)
        }
    }
}
