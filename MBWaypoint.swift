@objc(MBWaypoint)
public class Waypoint: NSObject, NSCopying, NSSecureCoding {
    public let coordinate: CLLocationCoordinate2D
    public var coordinateAccuracy: CLLocationAccuracy = -1
    public var heading: CLLocationDirection = -1
    public var headingAccuracy: CLLocationDirection = -1
    public var name: String?
    
    public init(coordinate: CLLocationCoordinate2D, coordinateAccuracy: CLLocationAccuracy = -1, name: String? = nil) {
        self.coordinate = coordinate
        self.coordinateAccuracy = coordinateAccuracy
        self.name = name
    }
    
    public init(location: CLLocation, heading: CLHeading? = nil, name: String? = nil) {
        coordinate = location.coordinate
        coordinateAccuracy = location.horizontalAccuracy
        if let heading = heading {
            self.heading = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
        }
        self.name = name
    }
    
    public required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDoubleForKey("latitude")
        let longitude = decoder.decodeDoubleForKey("longitude")
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        coordinateAccuracy = decoder.decodeDoubleForKey("coordinateAccuracy")
        heading = decoder.decodeDoubleForKey("heading")
        headingAccuracy = decoder.decodeDoubleForKey("headingAccuracy")
        name = decoder.decodeObjectForKey("name") as? String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(coordinate.latitude, forKey: "latitude")
        coder.encodeDouble(coordinate.longitude, forKey: "longitude")
        coder.encodeDouble(coordinateAccuracy, forKey: "coordinateAccuracy")
        coder.encodeDouble(heading, forKey: "heading")
        coder.encodeDouble(headingAccuracy, forKey: "headingAccuracy")
        coder.encodeObject(name, forKey: "name")
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Waypoint(coordinate: coordinate, coordinateAccuracy: coordinateAccuracy, name: name)
        copy.heading = heading
        copy.headingAccuracy = headingAccuracy
        return copy
    }
    
    internal var headingDescription: String {
        guard heading >= 0 else {
            return ""
        }
        let accuracy = headingAccuracy >= 0 ? String(headingAccuracy) : ""
        return "\(heading),\(accuracy)"
    }
}
