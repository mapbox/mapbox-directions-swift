import Foundation


#if os(Linux)

public let kCLLocationCoordinate2DInvalid = CLLocationCoordinate2D(latitude: -180, longitude: -180)
public func CLLocationCoordinate2DIsValid(_ coord: CLLocationCoordinate2D) -> Bool {
    // TODO: this should probably be within -90,90,-180,180
    return coord.latitude != kCLLocationCoordinate2DInvalid.latitude &&
            coord.longitude != kCLLocationCoordinate2DInvalid.longitude
}

public typealias CLLocationDegrees = Double
public typealias CLLocationSpeed = Double
public typealias CLLocationDirection = Double
public typealias CLLocationDistance = Double
public typealias CLLocationAccuracy = Double

public struct CLLocationCoordinate2D {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
}

public struct CLLocation {
    public let coordinate: CLLocationCoordinate2D
    public let altitude: CLLocationDistance
    public let horizontalAccuracy: CLLocationAccuracy
    public let verticalAccuracy: CLLocationAccuracy
    public let speed: CLLocationSpeed
    public let course: CLLocationDirection
    public let timestamp: Date

    public init(coordinate: CLLocationCoordinate2D,
                altitude: CLLocationDistance,
                horizontalAccuracy: CLLocationAccuracy,
                verticalAccuracy: CLLocationAccuracy,
                course: CLLocationDirection,
                speed: CLLocationSpeed,
                timestamp: Date) {
                    self.coordinate = coordinate
                    self.altitude = altitude
                    self.horizontalAccuracy = horizontalAccuracy
                    self.verticalAccuracy = verticalAccuracy
                    self.course = course
                    self.speed = speed
                    self.timestamp = timestamp
                }
    
    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
}

public class CLHeading: NSObject {
    public let magneticHeading: CLLocationDirection
    public let trueHeading: CLLocationDirection
    public let headingAccuracy: CLLocationDirection
    public let timestamp: Date

    public init(magneticHeading: CLLocationDirection, trueHeading: CLLocationDirection, headingAccuracy: CLLocationDirection, timestamp: Date) {
        self.magneticHeading = magneticHeading
        self.trueHeading = trueHeading
        self.headingAccuracy = headingAccuracy
        self.timestamp = timestamp
    }
}

#endif
