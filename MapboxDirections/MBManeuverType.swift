import Foundation

/**
 A `ManeuverType` specifies the type of maneuver required to complete the route step. You can pair a maneuver type with a `ManeuverDirection` to choose an appropriate visual or voice prompt to present the user.
 
 In Swift, you can use pattern matching with a single switch statement on a tuple containing the maneuver type and maneuver direction to avoid a complex series of if-else-if statements or switch statements.
 */
@objc(MBManeuverType)
public enum ManeuverType: Int, CustomStringConvertible, Codable {
    /**
     The step requires the user to depart from a waypoint.
     
     If the waypoint is some distance away from the nearest road, the maneuver direction indicates the direction the user must turn upon reaching the road.
     */
    case depart
    
    /**
     The step requires the user to turn.
     
     The maneuver direction indicates the direction in which the user must turn relative to the current direction of travel. The exit index indicates the number of intersections, large or small, from the previous maneuver up to and including the intersection at which the user must turn.
     */
    case turn
    
    /**
     The step requires the user to continue after a turn.
     */
    case `continue`
    
    /**
     The step requires the user to continue on the current road as it changes names.
     
     The step’s name contains the road’s new name. To get the road’s old name, use the previous step’s name.
     */
    case passNameChange
    
    /**
     The step requires the user to merge onto another road.
     
     The maneuver direction indicates the side from which the other road approaches the intersection relative to the user.
     */
    case merge
    
    /**
     The step requires the user to take a entrance ramp (slip road) onto a highway.
     */
    case takeOnRamp
    
    /**
     The step requires the user to take an exit ramp (slip road) off a highway.
     
     The maneuver direction indicates the side of the highway from which the user must exit. The exit index indicates the number of highway exits from the previous maneuver up to and including the exit that the user must take.
     */
    case takeOffRamp
    
    /**
     The step requires the user to choose a fork at a Y-shaped fork in the road.
     
     The maneuver direction indicates which fork to take.
     */
    case reachFork
    
    /**
     The step requires the user to turn at either a T-shaped three-way intersection or a sharp bend in the road where the road also changes names.
     
     This maneuver type is called out separately so that the user may be able to proceed more confidently, without fear of having overshot the turn. If this distinction is unimportant to you, you may treat the maneuver as an ordinary `turn`.
     */
    case reachEnd
    
    /**
     The step requires the user to get into a specific lane in order to continue along the current road.
     
     The maneuver direction is set to `straightAhead`. Each of the first intersection’s usable approach lanes also has an indication of `straightAhead`. A maneuver in a different direction would instead have a maneuver type of `turn`.
     
     This maneuver type is called out separately so that the application can present the user with lane guidance based on the first element in the `intersections` property. If lane guidance is unimportant to you, you may treat the maneuver as an ordinary `continue` or ignore it.
     */
    case useLane
    
    /**
     The step requires the user to enter and traverse a roundabout (traffic circle or rotary).
     
     The step has no name, but the exit name is the name of the road to take to exit the roundabout. The exit index indicates the number of roundabout exits up to and including the exit to take.
     
     If `RouteOptions.includesExitRoundaboutManeuver` is set to `true`, this step is followed by an `.exitRoundabout` maneuver. Otherwise, this step represents the entire roundabout maneuver, from the entrance to the exit.
     */
    case takeRoundabout
    
    /**
     The step requires the user to enter and traverse a large, named roundabout (traffic circle or rotary).
     
     The step’s name is the name of the roundabout. The exit name is the name of the road to take to exit the roundabout. The exit index indicates the number of rotary exits up to and including the exit that the user must take.
     
     If `RouteOptions.includesExitRoundaboutManeuver` is set to `true`, this step is followed by an `.exitRotary` maneuver. Otherwise, this step represents the entire roundabout maneuver, from the entrance to the exit.
     */
    case takeRotary
    
    /**
     The step requires the user to enter and exit a roundabout (traffic circle or rotary) that is compact enough to constitute a single intersection.
     
     The step’s name is the name of the road to take after exiting the roundabout. This maneuver type is called out separately because the user may perceive the roundabout as an ordinary intersection with an island in the middle. If this distinction is unimportant to you, you may treat the maneuver as either an ordinary `turn` or as a `takeRoundabout`.
     */
    case turnAtRoundabout
    
    /**
     The step requires the user to exit a roundabout (traffic circle or rotary).
     
     This maneuver type follows a `.takeRoundabout` maneuver. It is only used when `RouteOptions.includesExitRoundaboutManeuver` is set to true.
     */
    case exitRoundabout
    
    /**
     The step requires the user to exit a large, named roundabout (traffic circle or rotary).
     
     This maneuver type follows a `.takeRotary` maneuver. It is only used when `RouteOptions.includesExitRoundaboutManeuver` is set to true.
     */
    case exitRotary
    
    /**
     The step requires the user to respond to a change in travel conditions.
     
     This maneuver type may occur for example when driving directions require the user to board a ferry, or when cycling directions require the user to dismount. The step’s transport type and instructions contains important contextual details that should be presented to the user at the maneuver location.
     
     Similar changes can occur simultaneously with other maneuvers, such as when the road changes its name at the site of a movable bridge. In such cases, `heedWarning` is suppressed in favor of another maneuver type.
     */
    case heedWarning
    
    /**
     The step requires the user to arrive at a waypoint.
     
     The distance and expected travel time for this step are set to zero, indicating that the route or route leg is complete. The maneuver direction indicates the side of the road on which the waypoint can be found (or whether it is straight ahead).
     */
    case arrive
    
    /**
     The step requires the user to arrive at an intermediate waypoint.
     
     This maneuver type is only used by version 4 of the Mapbox Directions API.
     */
    case passWaypoint // v4
    
    public init?(description: String) {
        let type: ManeuverType
        switch description {
        case "depart":
            type = .depart
        case "turn":
            type = .turn
        case "continue":
            type = .continue
        case "new name":
            type = .passNameChange
        case "merge":
            type = .merge
        case "on ramp":
            type = .takeOnRamp
        case "off ramp":
            type = .takeOffRamp
        case "fork":
            type = .reachFork
        case "end of road":
            type = .reachEnd
        case "use lane":
            type = .useLane
        case "rotary":
            type = .takeRotary
        case "roundabout":
            type = .takeRoundabout
        case "roundabout turn":
            type = .turnAtRoundabout
        case "exit roundabout":
            type = .exitRoundabout
        case "exit rotary":
            type = .exitRotary
        case "notification":
            type = .heedWarning
        case "arrive":
            type = .arrive
        case "waypoint": // v4
            type = .passWaypoint
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .depart:
            return "depart"
        case .turn:
            return "turn"
        case .continue:
            return "continue"
        case .passNameChange:
            return "new name"
        case .merge:
            return "merge"
        case .takeOnRamp:
            return "on ramp"
        case .takeOffRamp:
            return "off ramp"
        case .reachFork:
            return "fork"
        case .reachEnd:
            return "end of road"
        case .useLane:
            return "use lane"
        case .takeRotary:
            return "rotary"
        case .takeRoundabout:
            return "roundabout"
        case .turnAtRoundabout:
            return "roundabout turn"
        case .exitRoundabout:
            return "exit roundabout"
        case .exitRotary:
            return "exit rotary"
        case .heedWarning:
            return "notification"
        case .arrive:
            return "arrive"
        case .passWaypoint: // v4
            return "waypoint"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let description = try container.decode(String.self)
        
        if let type = ManeuverType(description: description) {
            self = type
        } else {
            self = ManeuverType(v4Description: description)!
        }
    }
}

// MARK: Support for Directions API v4

extension ManeuverType {
    internal init?(v4Description: String) {
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
