import Foundation
import CoreLocation

/**
 A bounding box represents a geographic region that is rectangular in the Spherical Mercator projection.
 */
public struct CoordinateBounds {
    /// The southwest corner.
    let southWest: CLLocationCoordinate2D
    
    /// The northeast corner.
    let northEast: CLLocationCoordinate2D
    
    /**
     Initializes a coordinate bounds based on the southwest and northeast corners.
     */
    public init(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
    }
    
    /**
     Initializes a coordinate bounds based on the northwest and southeast corners.
     */
    public init(northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
        self.southWest = CLLocationCoordinate2D(latitude: southEast.latitude, longitude: northWest.longitude)
        self.northEast = CLLocationCoordinate2D(latitude: northWest.latitude, longitude: southEast.longitude)
    }
    
    /**
     Initializes a coordinate bounds that includes all the given coordinates.
     */
    public init(coordinates: [CLLocationCoordinate2D]) {
        precondition(coordinates.count >= 2, "There must be at least two coordinates to create a coordinate bounds.")
        
        var maximumLatitude: CLLocationDegrees = -90
        var minimumLatitude: CLLocationDegrees = 90
        var maximumLongitude: CLLocationDegrees = -180
        var minimumLongitude: CLLocationDegrees = 180
        
        for coordinate in coordinates {
            maximumLatitude = max(maximumLatitude, coordinate.latitude)
            minimumLatitude = min(minimumLatitude, coordinate.latitude)
            maximumLongitude = max(maximumLongitude, coordinate.longitude)
            minimumLongitude = min(minimumLongitude, coordinate.longitude)
        }
        
        let southWest = CLLocationCoordinate2D(latitude: minimumLatitude, longitude: minimumLongitude)
        let northEast = CLLocationCoordinate2D(latitude: maximumLatitude, longitude: maximumLongitude)
        
        self.init(southWest: southWest, northEast: northEast)
    }
}

extension CoordinateBounds: Codable {
    enum CodingKeys: String, CodingKey {
        case southWest, northEast
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        southWest = try container.decode(CLLocationCoordinate2DCodable.self, forKey: .southWest).decodedCoordinates
        northEast = try container.decode(CLLocationCoordinate2DCodable.self, forKey: .northEast).decodedCoordinates
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(southWest.codableCoordinates)
        try container.encode(northEast.codableCoordinates)
    }
}

extension CoordinateBounds: CustomStringConvertible {
    public var description: String {
        return "\(southWest.longitude),\(southWest.latitude);\(northEast.longitude),\(northEast.latitude)"
    }
}

struct CLLocationCoordinate2DCodable: Codable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var decodedCoordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        longitude = try container.decode(CLLocationDegrees.self)
        latitude = try container.decode(CLLocationDegrees.self)
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

extension CLLocationCoordinate2D {
    var codableCoordinates: CLLocationCoordinate2DCodable {
        return CLLocationCoordinate2DCodable(self)
    }
}
