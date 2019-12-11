import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
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
