@objc(MBTransportType)
public enum TransportType: Int, CustomStringConvertible {
    // mapbox/driving
    case Automobile
    case Ferry
    case MovableBridge
    case Inaccessible
    
    // mapbox/walking
    case Walking
    // case Ferry
    // case Inaccessible
    
    // mapbox/cycling
    case Cycling
    // case Walking
    // case Ferry
    case Train
    // case MovableBridge
    // case Inaccessible
    
    public init?(description: String) {
        let type: TransportType
        switch description {
        case "driving":
            type = .Automobile
        case "ferry":
            type = .Ferry
        case "moveable bridge":
            type = .MovableBridge
        case "unaccessible":
            type = .Inaccessible
        case "walking":
            type = .Walking
        case "cycling":
            type = .Cycling
        case "train":
            type = .Train
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .Automobile:
            return "driving"
        case .Ferry:
            return "ferry"
        case .MovableBridge:
            return "moveable bridge"
        case .Inaccessible:
            return "unaccessible"
        case .Walking:
            return "walking"
        case .Cycling:
            return "cycling"
        case .Train:
            return "train"
        }
    }
}

@objc(MBManeuverType)
public enum ManeuverType: Int, CustomStringConvertible {
    case Depart
    case Turn
    case Continue
    case PassNameChange
    case Merge
    case TakeOnRamp
    case TakeOffRamp
    case ReachFork
    case ReachEnd
    case TakeRoundabout
    case TurnAtRoundabout
    case HeedWarning
    case Arrive
    
    public init?(description: String) {
        let type: ManeuverType
        switch description {
        case "depart":
            type = .Depart
        case "turn":
            type = .Turn
        case "continue":
            type = .Continue
        case "new name":
            type = .PassNameChange
        case "merge":
            type = .Merge
        case "on ramp":
            type = .TakeOnRamp
        case "off ramp":
            type = .TakeOffRamp
        case "fork":
            type = .ReachFork
        case "end of road":
            type = .ReachEnd
        case "roundabout":
            type = .TakeRoundabout
        case "roundabout turn":
            type = .TurnAtRoundabout
        case "notification":
            type = .HeedWarning
        case "arrive":
            type = .Arrive
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .Depart:
            return "depart"
        case .Turn:
            return "turn"
        case .Continue:
            return "continue"
        case .PassNameChange:
            return "new name"
        case .Merge:
            return "merge"
        case .TakeOnRamp:
            return "on ramp"
        case .TakeOffRamp:
            return "off ramp"
        case .ReachFork:
            return "fork"
        case .ReachEnd:
            return "end of road"
        case .TakeRoundabout:
            return "roundabout"
        case .TurnAtRoundabout:
            return "roundabout turn"
        case .HeedWarning:
            return "notification"
        case .Arrive:
            return "arrive"
        }
    }
}

@objc(MBManeuverDirection)
public enum ManeuverDirection: Int, CustomStringConvertible {
    case SharpRight
    case Right
    case SlightRight
    case StraightAhead
    case SlightLeft
    case Left
    case SharpLeft
    case UTurn
    
    public init?(description: String) {
        let direction: ManeuverDirection
        switch description {
        case "sharp right":
            direction = .SharpRight
        case "right":
            direction = .Right
        case "slight right":
            direction = .SlightRight
        case "straight":
            direction = .StraightAhead
        case "slight left":
            direction = .SlightLeft
        case "left":
            direction = .Left
        case "sharp left":
            direction = .SharpLeft
        case "uturn":
            direction = .UTurn
        default:
            return nil
        }
        self.init(rawValue: direction.rawValue)
    }
    
    public var description: String {
        switch self {
        case .SharpRight:
            return "sharp right"
        case .Right:
            return "right"
        case .SlightRight:
            return "slight right"
        case .StraightAhead:
            return "straight"
        case .SlightLeft:
            return "slight left"
        case .Left:
            return "left"
        case .SharpLeft:
            return "sharp left"
        case .UTurn:
            return "uturn"
        }
    }
}

@objc(MBRouteStep)
public class RouteStep: NSObject {
    // MARK: Getting the Step Geometry
    
    public let coordinates: [CLLocationCoordinate2D]?
    
    // MARK: Getting Details About the Maneuver
    
    public let instructions: String
    public let initialHeading: CLLocationDirection?
    public let finalHeading: CLLocationDirection?
    public let maneuverType: ManeuverType?
    public let maneuverDirection: ManeuverDirection?
    public let maneuverLocation: CLLocationCoordinate2D
    public let exitIndex: NSInteger?
    
    // MARK: Getting Details About the Approach
    
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public let name: String?
    
    // MARK: Getting Additional Step Details
    
    public let transportType: TransportType?
    
    // MARK: Creating a Step
    
    internal init(json: JSONDictionary) {
        transportType = TransportType(description: json["mode"] as! String)
        
        let maneuver = json["maneuver"] as! JSONDictionary
        instructions = maneuver["instruction"] as! String
        
        distance = json["distance"] as? Double ?? 0
        expectedTravelTime = json["duration"] as? Double ?? 0
        
        initialHeading = maneuver["bearing_before"] as? Double
        finalHeading = maneuver["bearing_after"] as? Double
        maneuverType = ManeuverType(description: maneuver["type"] as! String)
        maneuverDirection = ManeuverDirection(description: maneuver["modifier"] as? String ?? "")
        exitIndex = maneuver["exit"] as? Int
        
        name = json["name"] as? String
        
        let location = maneuver["location"] as! [Double]
        maneuverLocation = CLLocationCoordinate2D(geoJSON: location)
        
        let jsonGeometry = json["geometry"] as? JSONDictionary
        let coordinates = jsonGeometry?["coordinates"] as? [[Double]] ?? []
        self.coordinates = coordinates.map(CLLocationCoordinate2D.init(geoJSON:))
    }
}
