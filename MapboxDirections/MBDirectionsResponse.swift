import Polyline

internal protocol MBResponse {
    var source: MBNamedLocation { get }
    var waypoints: [MBNamedLocation] { get }
    var destination: MBNamedLocation { get }
}

public class MBDirectionsResponse: MBResponse {
    public let source: MBNamedLocation
    public let waypoints: [MBNamedLocation]
    public let destination: MBNamedLocation
    public let routes: [MBRoute]

    internal init(source: MBNamedLocation, waypoints: [MBNamedLocation] = [], destination: MBNamedLocation, routes: [MBRoute]) {
        self.source = source
        self.waypoints = waypoints
        self.destination = destination
        self.routes = routes
    }
}

public class MBRoute {
//    var polyline: MKPolyline! { get }
    public let legs: [MBRouteLeg]
//    public let name: String
//    var advisoryNotices: [AnyObject]! { get }
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public var transportType: MBDirectionsRequest.TransportType {
        return MBDirectionsRequest.TransportType(rawValue: profileIdentifier) ?? .Automobile
    }
    public let profileIdentifier: String

    // Mapbox-specific stuff
    public let geometry: [CLLocationCoordinate2D]

    public let source: MBNamedLocation
    public let waypoints: [MBNamedLocation]
    public let destination: MBNamedLocation

    internal init(source: MBNamedLocation, waypoints: [MBNamedLocation] = [], destination: MBNamedLocation, json: JSONDictionary, profileIdentifier: String, version: MBDirectionsRequest.APIVersion) {
        self.source = source
        self.waypoints = waypoints
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        
        let precision: Double
        switch version {
        case .Four:
            legs = [MBRouteLeg(source: source, destination: destination, json: json, profileIdentifier: profileIdentifier, version: version)]
            precision = 1e6
        case .Five:
            // Associate each leg JSON with an origin and destination. The sequence
            // of destinations is offset by one from the sequence of origins.
            let legInfo = zip(zip([source] + waypoints, waypoints + [destination]),
                              json["legs"] as? [JSONDictionary] ?? [])
            legs = legInfo.map { (endpoints, json) -> MBRouteLeg in
                MBRouteLeg(source: endpoints.0, destination: endpoints.1, json: json, profileIdentifier: profileIdentifier, version: version)
            }
            precision = 1e5
        }
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        geometry = decodePolyline(json["geometry"] as! String, precision: precision)!
    }
}

public class MBRouteLeg {
//    var polyline: MKPolyline! { get }
    public let steps: [MBRouteStep]
    public let name: String
//    var advisoryNotices: [AnyObject]! { get }
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public var transportType: MBDirectionsRequest.TransportType {
        return MBDirectionsRequest.TransportType(rawValue: profileIdentifier) ?? .Automobile
    }
    public let profileIdentifier: String

    public let source: MBNamedLocation
    public let destination: MBNamedLocation

    internal init(source: MBNamedLocation, destination: MBNamedLocation, json: JSONDictionary, profileIdentifier: String, version: MBDirectionsRequest.APIVersion) {
        self.source = source
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        let name = json["summary"] as? String
        var stepNamesByDistance: [String: CLLocationDistance] = [:]
        steps = (json["steps"] as? [JSONDictionary] ?? []).map { json in
            let step = MBRouteStep(json: json, profileIdentifier: profileIdentifier, version: version)
            // If no summary is provided for some reason, synthesize one out of the two names that make up the longest cumulative distance along the route.
            if name == nil || name!.isEmpty {
                if let stepName = step.name where !stepName.isEmpty {
                    stepNamesByDistance[stepName] = (stepNamesByDistance[stepName] ?? 0) + step.distance
                }
            }
            return step
        }
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        let longestNames = Array(stepNamesByDistance.sort { $0.1 > $1.1 }.prefix(2))
        self.name = name ?? longestNames.map { $0.0 }.joinWithSeparator(" – ")
    }
}

public class MBRouteStep {
    public enum TransportType: String {
        // mapbox/driving
        case Automobile = "driving"
        case Ferry = "ferry"
        case MovableBridge = "moveable bridge"
        case Inaccessible = "unaccessible"
        
        // mapbox/walking
        case Walking = "walking"
        // case Ferry = "ferry"
        // case Inaccessible = "unaccessible"
        
        // mapbox/cycling
        case Cycling = "cycling"
        // case Walking = "walking"
        // case Ferry = "ferry"
        case Train = "train"
        // case MovableBridge = "moveable bridge"
        // case Inaccessible = "unaccessible"
    }
    
    public enum ManeuverType: String {
        case Depart = "depart"
        case Turn = "turn"
        case Continue = "continue"
        case PassNameChange = "new name"
        case Merge = "merge"
        case TakeOnRamp = "on ramp"
        case TakeOffRamp = "off ramp"
        case ReachFork = "fork"
        case ReachEnd = "end of road"
        case TakeRoundabout = "roundabout"
        case TurnAtRoundabout = "roundabout turn"
        case HeedWarning = "notification"
        case Arrive = "arrive"
        
        // Compatibility with v4
        case PassWaypoint = "waypoint"
        
        init?(v4RawValue: String) {
            let rawValue: String
            switch v4RawValue {
            case "bear right", "turn right", "sharp right", "sharp left", "turn left", "bear left", "u-turn":
                rawValue = "turn"
            case "enter roundabout":
                rawValue = "roundabout"
            default:
                rawValue = v4RawValue
            }
            self.init(rawValue: rawValue)
        }
    }
    
    public enum ManeuverDirection: String {
        case UTurn = "uturn"
        case SharpRight = "sharp right"
        case Right = "right"
        case SlightRight = "slight right"
        case StraightAhead = "straight"
        case SlightLeft = "slight left"
        case Left = "left"
        case SharpLeft = "sharp left"
        
        init?(v4RawValue: String) {
            let rawValue: String
            switch v4RawValue {
            case "bear right", "bear left":
                rawValue = v4RawValue.stringByReplacingOccurrencesOfString("bear", withString: "slight")
            case "turn right", "turn left":
                rawValue = v4RawValue.stringByReplacingOccurrencesOfString("turn ", withString: "")
            case "u-turn":
                rawValue = "uturn"
            default:
                rawValue = v4RawValue
            }
            self.init(rawValue: rawValue)
        }
    }

    //    var polyline: MKPolyline! { get }
    public let instructions: String
    //    var notice: String! { get }
    public let distance: CLLocationDistance
    public let transportType: TransportType?
    public let profileIdentifier: String

    // Mapbox-specific stuff
    public let geometry: [CLLocationCoordinate2D]?
    public let duration: NSTimeInterval
    public let name: String?
    public let initialHeading: CLLocationDirection?
    public let finalHeading: CLLocationDirection?
    public let maneuverType: ManeuverType?
    public let maneuverDirection: ManeuverDirection?
    public let maneuverLocation: CLLocationCoordinate2D
    public let exitIndex: NSInteger?

    internal init(json: JSONDictionary, profileIdentifier: String, version: MBDirectionsRequest.APIVersion) {
        self.profileIdentifier = profileIdentifier
        // v4 supplies no mode in the arrival step.
        transportType = TransportType(rawValue: json["mode"] as? String ?? "")
        
        let maneuver = json["maneuver"] as! JSONDictionary
        instructions = maneuver["instruction"] as! String
        
        distance = json["distance"] as? Double ?? 0
        duration = json["duration"] as? Double ?? 0
        
        switch version {
        case .Four:
            initialHeading = nil
            finalHeading = json["heading"] as? Double
            maneuverType = ManeuverType(v4RawValue: maneuver["type"] as! String)
            maneuverDirection = ManeuverDirection(v4RawValue: maneuver["type"] as! String)
            exitIndex = nil
            
            let location = maneuver["location"] as! JSONDictionary
            let coordinates = location["coordinates"] as! [Double]
            maneuverLocation = CLLocationCoordinate2D(geoJSON: coordinates)
            
            name = json["way_name"] as? String
            
            geometry = nil
        case .Five:
            initialHeading = maneuver["bearing_before"] as? Double
            finalHeading = maneuver["bearing_after"] as? Double
            maneuverType = ManeuverType(rawValue: maneuver["type"] as! String)
            maneuverDirection = ManeuverDirection(rawValue: maneuver["modifier"] as? String ?? "")
            exitIndex = maneuver["exit"] as? Int
            
            name = json["name"] as? String
            
            let location = maneuver["location"] as! [Double]
            maneuverLocation = CLLocationCoordinate2D(geoJSON: location)
            
            let jsonGeometry = json["geometry"] as? JSONDictionary
            let coordinates = jsonGeometry?["coordinates"] as? [[Double]] ?? []
            geometry = coordinates.map(CLLocationCoordinate2D.init(geoJSON:))
        }
    }
}

public class MBETAResponse: MBResponse {
    public let source: MBNamedLocation
    public let waypoints: [MBNamedLocation]
    public let destination: MBNamedLocation
    public let expectedTravelTime: NSTimeInterval

    internal init(source: MBNamedLocation, waypoints: [MBNamedLocation] = [], destination: MBNamedLocation, expectedTravelTime: NSTimeInterval) {
        self.source = source
        self.waypoints = waypoints
        self.destination = destination
        self.expectedTravelTime = expectedTravelTime
    }
}
