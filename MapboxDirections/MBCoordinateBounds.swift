import Foundation
import CoreLocation

/**
 A bounding box represents a geographic region.
 */
@objc(MBCoordinateBounds)
public class CoordinateBounds: NSObject, Codable {
    let southWest: CLLocationCoordinate2D
    let northEast: CLLocationCoordinate2D
    
    /**
     Initializes a `BoundingBox` with known bounds.
     */
    @objc
    public init(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
        super.init()
    }
    
    /**
     Initializes a `BoundingBox` with known bounds.
     */
    @objc
    public init(northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
        self.southWest = CLLocationCoordinate2D(latitude: southEast.latitude, longitude: northWest.longitude)
        self.northEast = CLLocationCoordinate2D(latitude: northWest.latitude, longitude: southEast.longitude)
        super.init()
    }
    
    /**
     Initializes a `BoundingBox` from an array of `CLLocationCoordinate2D`’s.
     */
    @objc
    convenience public init(coordinates: [CLLocationCoordinate2D]) {
        assert(coordinates.count >= 2, "coordinates must consist of at least two coordinates")
        
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
    
    public override var description: String {
        return "\(southWest.longitude),\(southWest.latitude);\(northEast.longitude),\(northEast.latitude)"
    }
}


extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
