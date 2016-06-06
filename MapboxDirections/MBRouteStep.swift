import Polyline

/**
 A `TransportType` specifies the mode of transportation used for part of a route.
 */
@objc(MBTransportType)
public enum TransportType: Int, CustomStringConvertible {
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile`
    
    /**
     The route requires the user to drive or ride a car, truck, or motorcycle.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile`.
     */
    case Automobile // automobile
    
    /**
     The route requires the user to board a ferry.
     
     The user should verify that the ferry is in operation. For driving and cycling directions, the user should also verify that his or her vehicle is permitted onboard the ferry.
     */
    case Ferry // automobile, walking, cycling
    
    /**
     The route requires the user to cross a movable bridge.
     
     The user may need to wait for the movable bridge to become passable before continuing.
     */
    case MovableBridge // automobile, cycling
    
    /**
     The route becomes impassable at this point.
     
     You should not encounter this transport type under normal circumstances.
     */
    case Inaccessible // automobile, walking, cycling
    
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierWalking`
    
    /**
     The route requires the user to walk.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierWalking`. For cycling directions, this value indicates that the user is expected to dismount.
     */
    case Walking // walking, cycling
    
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierCycling`
    
    /**
     The route requires the user to ride a bicycle.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierCycling`.
     */
    case Cycling // cycling
    
    /**
     The route requires the user to board a train.
     
     The user should consult the train’s timetable. For cycling directions, the user should also verify that bicycles are permitted onboard the train.
     */
    case Train // cycling
    
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

/**
 A `ManeuverType` specifies the type of maneuver required to complete the route step. You can pair a maneuver type with a `ManeuverDirection` to choose an appropriate visual or voice prompt to present the user.
 
 In Swift, you can use pattern matching with a single switch statement on a tuple containing the maneuver type and maneuver direction to avoid a complex series of if-else-if statements or switch statements.
 */
@objc(MBManeuverType)
public enum ManeuverType: Int, CustomStringConvertible {
    /**
     The step requires the user to depart from a waypoint.
     
     If the waypoint is some distance away from the nearest road, the maneuver direction indicates the direction the user must turn upon reaching the road.
     */
    case Depart
    
    /**
     The step requires the user to turn.
     
     The maneuver direction indicates the direction in which the user must turn relative to the current direction of travel. The exit index indicates the number of intersections, large or small, from the previous maneuver up to and including the intersection at which the user must turn.
     */
    case Turn
    
    /**
     The step requires the user to continue after a turn.
     */
    case Continue
    
    /**
     The step requires the user to continue on the current road as it changes names.
     
     The step’s name contains the road’s new name. To get the road’s old name, use the previous step’s name.
     */
    case PassNameChange
    
    /**
     The step requires the user to merge onto another road.
     
     The maneuver direction indicates the side from which the other road approaches the intersection relative to the user.
     */
    case Merge
    
    /**
     The step requires the user to take a entrance ramp (slip road) onto a highway.
     */
    case TakeOnRamp
    
    /**
     The step requires the user to take an exit ramp (slip road) off a highway.
     
     The maneuver direction indicates the side of the highway from which the user must exit. The exit index indicates the number of highway exits from the previous maneuver up to and including the exit that the user must take.
     */
    case TakeOffRamp
    
    /**
     The step requires the user to choose a fork at a Y-shaped fork in the road.
     
     The maneuver direction indicates which fork to take.
     */
    case ReachFork
    
    /**
     The step requires the user to turn at either a T-shaped three-way intersection or a sharp bend in the road where the road also changes names.
     
     This maneuver type is called out separately so that the user may be able to proceed more confidently, without fear of having overshot the turn. If this distinction is unimportant to you, you may treat the maneuver as an ordinary `Turn`.
     */
    case ReachEnd
    
    /**
     The step requires the user to enter, traverse, and exit a roundabout (traffic circle or rotary).
     
     The exit index indicates the number of roundabout exits up to and including the exit that the user must take.
     */
    case TakeRoundabout
    
    /**
     The step requires the user to enter and exit a roundabout (traffic circle or rotary) that is compact enough to constitute a single intersection.
     
     This maneuver type is called out separately because the user may perceive the roundabout as an ordinary intersection with an island in the middle. If this distinction is unimportant to you, you may treat the maneuver as either an ordinary `Turn` or as a `TakeRoundabout`.
     */
    case TurnAtRoundabout
    
    /**
     The step requires the user to respond to a change in travel conditions.
     
     This maneuver type may occur for example when driving directions require the user to board a ferry, or when cycling directions require the user to dismount. The step’s transport type and instructions contains important contextual details that should be presented to the user at the maneuver location.
     
     Similar changes can occur simultaneously with other maneuvers, such as when the road changes its name at the site of a movable bridge. In such cases, `HeedWarning` is suppressed in favor of another maneuver type.
     */
    case HeedWarning
    
    /**
     The step requires the user to arrive at a waypoint.
     
     The distance and expected travel time for this step are set to zero, indicating that the route or route leg is complete. The maneuver direction indicates the side of the road on which the waypoint can be found (or whether it is straight ahead).
     */
    case Arrive
    
    /**
     The step requires the user to arrive at an intermediate waypoint.
     
     This maneuver type is only used by version 4 of the Mapbox Directions API.
     */
    case PassWaypoint // v4
    
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
        case "waypoint": // v4
            type = .PassWaypoint
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
        case .PassWaypoint: // v4
            return "waypoint"
        }
    }
}

/**
 A `ManeuverDirection` clarifies a `ManeuverType` with directional information. The exact meaning of the maneuver direction for a given step depends on the step’s maneuver type; see the `ManeuverType` documentation for details.
 */
@objc(MBManeuverDirection)
public enum ManeuverDirection: Int, CustomStringConvertible {
    /**
     The maneuver requires a sharp turn to the right.
     */
    case SharpRight
    
    /**
     The maneuver requires a turn to the right, a merge to the right, or an exit on the right, or the destination is on the right.
     */
    case Right
    
    /**
     The maneuver requires a slight turn to the right.
     */
    case SlightRight
    
    /**
     The maneuver requires no notable change in direction, or the destination is straight ahead.
     */
    case StraightAhead
    
    /**
     The maneuver requires a slight turn to the left.
     */
    case SlightLeft
    
    /**
     The maneuver requires a turn to the left, a merge to the left, or an exit on the left, or the destination is on the right.
     */
    case Left
    
    /**
     The maneuver requires a sharp turn to the left.
     */
    case SharpLeft
    
    /**
     The maneuver requires a U-turn when possible.
     
     Use the difference between the step’s initial and final headings to distinguish between a U-turn to the left (typical in countries that drive on the right) and a U-turn on the right (typical in countries that drive on the left). If the difference in headings is greater than 180 degrees, the maneuver requires a U-turn to the left. If the difference in headings is less than 180 degrees, the maneuver requires a U-turn to the right.
     */
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

/**
 A `RouteStep` object represents a single distinct maneuver along a route and the approach to the next maneuver. The route step object corresponds to a single instruction the user must follow to complete a portion of the route. For example, a step might require the user to turn then follow a road.
 
 You do not create instances of this class directly. Instead, you receive route step objects as part of route objects when you request directions using the `Directions.calculateDirections(options:completionHandler:)` method, setting the `includesSteps` option to `true` in the `RouteOptions` object that you pass into that method.
 */
@objc(MBRouteStep)
public class RouteStep: NSObject {
    // MARK: Getting the Step Geometry
    
    /**
     An array of geographic coordinates defining the path of the route step from the location of the maneuver to the location of the next step’s maneuver.
     
     The value of this property may be `nil`, for example when the maneuver type is `Arrive`.
     
     Using the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [Mapbox OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx/), you can create an `MGLPolyline` object using these coordinates to display a portion of a route on an `MGLMapView`.
     */
    public let coordinates: [CLLocationCoordinate2D]?
    
    /**
     The number of coordinates.
     
     The value of this property may be zero, for example when the maneuver type is `Arrive`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates.count` property.
     */
    public var coordinateCount: UInt {
        return UInt(coordinates?.count ?? 0)
    }
    
    /**
     Retrieves the coordinates.
     
     The array may be empty, for example when the maneuver type is `Arrive`.
     
     Using the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [Mapbox OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx/), you can create an `MGLPolyline` object using these coordinates to display a portion of a route on an `MGLMapView`.
     
     - parameter coordinates: A pointer to a C array of `CLLocationCoordinate2D` instances. On output, this array contains all the vertices of the overlay.
     - returns: True if the step has coordinates and `coordinates` has been populated, or false if the step has no coordinates and `coordinates` has not been modified.
     
     - precondition: `coordinates` must be large enough to hold `coordinateCount` instances of `CLLocationCoordinate2D`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates` property.
     */
    public func getCoordinates(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>) -> Bool {
        guard let stepCoordinates = self.coordinates else {
            return false
        }
        
        for i in 0..<stepCoordinates.count {
            coordinates.advancedBy(i).memory = stepCoordinates[i]
        }
        return true
    }
    
    // MARK: Getting Details About the Maneuver
    
    /**
     A string with instructions in English explaining how to perform the step’s maneuver.
     
     You can display this string or read it aloud to the user. The string does not include the distance to or from the maneuver. If you need to localize or otherwise customize the instructions, you can construct the instructions yourself using the step’s other properties.
     */
    public let instructions: String
    
    public override var description: String {
        return instructions
    }
    
    /**
     The user’s heading immediately before performing the maneuver.
     */
    public let initialHeading: CLLocationDirection?
    
    /**
     The user’s heading immediately after performing the maneuver.
     
     The value of this property may differ from the user’s heading after traveling along the road past the maneuver.
     */
    public let finalHeading: CLLocationDirection?
    
    /**
     The type of maneuver required for beginning this step.
     */
    public let maneuverType: ManeuverType?
    
    /**
     Additional directional information to clarify the maneuver type.
     */
    public let maneuverDirection: ManeuverDirection?
    
    /**
     The location of the maneuver at the beginning of this step.
     */
    public let maneuverLocation: CLLocationCoordinate2D
    
    /**
     The number of exits from the previous maneuver up to and including this step’s maneuver.
     
     If the maneuver takes place on a surface street, this property counts intersections. The number of intersections does not necessarily correspond to the number of blocks. If the maneuver takes place on a grade-separated highway (freeway or motorway), this property counts highway exits but not highway entrances.
     
     In some cases, the number of exits leading to a maneuver may be more useful to the user than the distance to the maneuver.
     */
    public let exitIndex: NSInteger?
    
    // MARK: Getting Details About the Approach to the Next Maneuver
    
    /**
     The step’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to go from this step’s maneuver location to the next step’s maneuver location. It is not the sum of the direct distances between the route’s waypoints, nor should you assume that the user would travel along this distance at a fixed speed.
     */
    public let distance: CLLocationDistance
    
    /**
     The step’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to go from this step’s maneuver location to the next step’s maneuver location under ideal conditions. You should not assume that the user would travel along the step at a fixed speed. The actual travel time may vary based on the weather, traffic conditions, road construction, and other variables. If the step makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     */
    public let expectedTravelTime: NSTimeInterval
    
    /**
     The name of the road or path leading from this step’s maneuver to the next step’s maneuver.
     
     If the maneuver is a turning maneuver, the step’s name is the name of the road or path onto which the user turns. The name includes any route designations assigned to the road. If you display the name to the user, you may need to abbreviate common words like “East” or “Boulevard” to ensure that it fits in the allotted space.
     */
    public let name: String?
    
    // MARK: Getting Additional Step Details
    
    /**
     The mode of transportation used for the step.
     
     This step may use a different mode of transportation than the overall route.
     */
    public let transportType: TransportType?
    
    // MARK: Creating a Step
    
    internal init(finalHeading: CLLocationDirection?, maneuverType: ManeuverType?, maneuverDirection: ManeuverDirection?, maneuverLocation: CLLocationCoordinate2D, name: String?, coordinates: [CLLocationCoordinate2D]?, json: JSONDictionary) {
        transportType = TransportType(description: json["mode"] as! String)
        
        let maneuver = json["maneuver"] as! JSONDictionary
        instructions = maneuver["instruction"] as! String
        
        distance = json["distance"] as? Double ?? 0
        expectedTravelTime = json["duration"] as? Double ?? 0
        
        initialHeading = maneuver["bearing_before"] as? Double
        self.finalHeading = finalHeading
        self.maneuverType = maneuverType
        self.maneuverDirection = maneuverDirection
        exitIndex = maneuver["exit"] as? Int
        
        self.name = name
        
        self.maneuverLocation = maneuverLocation
        self.coordinates = coordinates
    }
    
    internal convenience init(json: JSONDictionary) {
        let maneuver = json["maneuver"] as! JSONDictionary
        let finalHeading = maneuver["bearing_after"] as? Double
        let maneuverType = ManeuverType(description: maneuver["type"] as! String)
        let maneuverDirection = ManeuverDirection(description: maneuver["modifier"] as? String ?? "")
        let maneuverLocation = CLLocationCoordinate2D(geoJSON: maneuver["location"] as! [Double])
        
        let name = json["name"] as? String
        
        var coordinates: [CLLocationCoordinate2D]?
        switch json["geometry"] {
        case let geometry as JSONDictionary:
            coordinates = CLLocationCoordinate2D.coordinates(geoJSON: geometry)
        case let geometry as String:
            coordinates = decodePolyline(geometry, precision: 1e5)!
        default:
            coordinates = nil
        }
        
        self.init(finalHeading: finalHeading, maneuverType: maneuverType, maneuverDirection: maneuverDirection, maneuverLocation: maneuverLocation, name: name, coordinates: coordinates, json: json)
    }
}

// MARK: Support for Directions API v4

extension ManeuverType {
    private init?(v4Description: String) {
        let description: String
        switch v4Description {
        case "bear right", "turn right", "sharp right", "sharp left", "turn left", "bear left", "u-turn":
            description = "turn"
        case "enter roundabout":
            description = "roundabout"
        default:
            description = v4Description
        }
        self.init(description: description)
    }
}

extension ManeuverDirection {
    private init?(v4TypeDescription: String) {
        let description: String
        switch v4TypeDescription {
        case "bear right", "bear left":
            description = v4TypeDescription.stringByReplacingOccurrencesOfString("bear", withString: "slight")
        case "turn right", "turn left":
            description = v4TypeDescription.stringByReplacingOccurrencesOfString("turn ", withString: "")
        case "u-turn":
            description = "uturn"
        default:
            description = v4TypeDescription
        }
        self.init(description: description)
    }
}

internal class RouteStepV4: RouteStep {
    internal convenience init(json: JSONDictionary) {
        let maneuver = json["maneuver"] as! JSONDictionary
        let heading = maneuver["heading"] as? Double
        let maneuverType = ManeuverType(v4Description: maneuver["type"] as! String)
        let maneuverDirection = ManeuverDirection(v4TypeDescription: maneuver["type"] as! String)
        let maneuverLocation = CLLocationCoordinate2D(geoJSON: maneuver["location"] as! JSONDictionary)
        
        let name = json["way_name"] as? String
        
        self.init(finalHeading: heading, maneuverType: maneuverType, maneuverDirection: maneuverDirection, maneuverLocation: maneuverLocation, name: name, coordinates: nil, json: json)
    }
}
