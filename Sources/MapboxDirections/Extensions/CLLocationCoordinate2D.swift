import Foundation
import CoreLocation

extension CLLocation {
    /**
     Initializes a CLLocation object with the given coordinate pair.
     */
    internal convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension CLLocationCoordinate2D {
    /**
     Initializes a coordinate pair based on the given GeoJSON coordinates array.
     */
    internal init(geoJSON array: [Double]) {
        assert(array.count == 2)
        self.init(latitude: array[1], longitude: array[0])
    }
    
    /**
     Initializes a coordinate pair based on the given GeoJSON point object.
     */
    internal init(geoJSON point: JSONDictionary) {
        assert(point["type"] as? String == "Point")
        self.init(geoJSON: point["coordinates"] as! [Double])
    }
    
    internal static func coordinates(geoJSON lineString: JSONDictionary) -> [CLLocationCoordinate2D] {
        let type = lineString["type"] as? String
        assert(type == "LineString" || type == "Point")
        let coordinates = lineString["coordinates"] as! [[Double]]
        return coordinates.map { self.init(geoJSON: $0) }
    }
    
    /**
     A string representation of the coordinate suitable for insertion in a Directions API request URL.
     */
    internal var stringForRequestURL: String? {
        guard CLLocationCoordinate2DIsValid(self) else {
            return nil
        }
        return "\(longitude.rounded(to: 1e6)),\(latitude.rounded(to: 1e6))"
    }
}
