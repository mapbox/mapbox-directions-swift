import Foundation
#if canImport(CoreLocation)
import CoreLocation
#else
import Turf
#endif

#if canImport(CoreLocation)
/**
 The velocity (measured in meters per second) at which the device is moving.
 
 This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationSpeed` anywhere you see this type.
 */
public typealias LocationSpeed = CLLocationSpeed

/**
 The accuracy of a geographical coordinate.
 
 This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationAccuracy` anywhere you see this type.
 */
public typealias LocationAccuracy = CLLocationAccuracy
#else
/**
 The velocity (measured in meters per second) at which the device is moving.
 */
public typealias LocationSpeed = Double

/**
 The accuracy of a geographical coordinate.
 */
public typealias LocationAccuracy = Double
#endif

extension CLLocationCoordinate2D {
    internal var requestDescription: String {
        return "\(longitude.rounded(to: 1e6)),\(latitude.rounded(to: 1e6))"
    }
}

#if canImport(CoreLocation)
extension CLLocation {
    /**
     Initializes a CLLocation object with the given coordinate pair.
     */
    internal convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
#endif

