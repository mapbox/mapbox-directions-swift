import Foundation
import CoreLocation

#warning("Check this")
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
     A string representation of the coordinate suitable for insertion in a Directions API request URL.
     */
    internal var stringForRequestURL: String? {
        guard CLLocationCoordinate2DIsValid(self) else {
            return nil
        }
        return "\(longitude.rounded(to: 1e6)),\(latitude.rounded(to: 1e6))"
    }
}
