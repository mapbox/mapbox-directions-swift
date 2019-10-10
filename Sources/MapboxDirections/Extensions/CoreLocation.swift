import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Codable, Equatable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: [longitude, latitude])
    }

    public init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.unkeyedContainer()
        longitude = try container.decode(CLLocationDegrees.self)
        latitude = try container.decode(CLLocationDegrees.self)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    internal var requestDescription: String {
        return "\(longitude.rounded(to: 1e6)),\(latitude.rounded(to: 1e6))"
    }
}

extension CLLocation {
    /**
     Initializes a CLLocation object with the given coordinate pair.
     */
    internal convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
