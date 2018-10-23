import Foundation
import CoreLocation



@objc(MBBoundingBox)
class BoundingBox: NSObject, Codable {
    let northWest: CLLocationCoordinate2D
    let southEast: CLLocationCoordinate2D
    
    @objc
    public init(northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
        self.northWest = northWest
        self.southEast = southEast
        super.init()
    }
    
    @objc
    convenience public init(_ coordinates: [CLLocationCoordinate2D]) {
        assert(coordinates.count >= 2, "coordinates must consist of at least two coordinates")
        
        var maximumLatitude: CLLocationDegrees = -90
        var minimumLatitude: CLLocationDegrees = 90
        var maximumLongitude: CLLocationDegrees = -180
        var minimumLongitude: CLLocationDegrees = 180
        
        for coordinate in coordinates {
            maximumLatitude = Swift.max(maximumLatitude, coordinate.latitude)
            minimumLatitude = Swift.min(minimumLatitude, coordinate.latitude)
            maximumLongitude = Swift.max(maximumLongitude, coordinate.longitude)
            minimumLongitude = Swift.min(minimumLongitude, coordinate.longitude)
        }
        
        let northWest = CLLocationCoordinate2D(latitude: minimumLatitude, longitude: minimumLongitude)
        let southEast = CLLocationCoordinate2D(latitude: maximumLatitude, longitude: maximumLongitude)
        
        self.init(northWest: northWest, southEast: southEast)
    }
    
    var path: String {
        return "\(northWest.longitude),\(northWest.latitude);\(southEast.longitude),\(southEast.latitude)"
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
