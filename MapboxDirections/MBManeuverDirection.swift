import Foundation

/**
 A `ManeuverDirection` clarifies a `ManeuverType` with directional information. The exact meaning of the maneuver direction for a given step depends on the step’s maneuver type; see the `ManeuverType` documentation for details.
 */
@objc(MBManeuverDirection)
public enum ManeuverDirection: Int, CustomStringConvertible, Codable {
    /**
     The step does not have a particular maneuver direction associated with it.
     
     This maneuver direction is used as a workaround for bridging to Objective-C which does not support nullable enumeration-typed values.
     */
    case none
    
    /**
     The maneuver requires a sharp turn to the right.
     */
    case sharpRight
    
    /**
     The maneuver requires a turn to the right, a merge to the right, or an exit on the right, or the destination is on the right.
     */
    case right
    
    /**
     The maneuver requires a slight turn to the right.
     */
    case slightRight
    
    /**
     The maneuver requires no notable change in direction, or the destination is straight ahead.
     */
    case straightAhead
    
    /**
     The maneuver requires a slight turn to the left.
     */
    case slightLeft
    
    /**
     The maneuver requires a turn to the left, a merge to the left, or an exit on the left, or the destination is on the right.
     */
    case left
    
    /**
     The maneuver requires a sharp turn to the left.
     */
    case sharpLeft
    
    /**
     The maneuver requires a U-turn when possible.
     
     Use the difference between the step’s initial and final headings to distinguish between a U-turn to the left (typical in countries that drive on the right) and a U-turn on the right (typical in countries that drive on the left). If the difference in headings is greater than 180 degrees, the maneuver requires a U-turn to the left. If the difference in headings is less than 180 degrees, the maneuver requires a U-turn to the right.
     */
    case uTurn
    
    public init?(description: String) {
        let direction: ManeuverDirection
        switch description {
        case "none":
            direction = .none
        case "sharp right":
            direction = .sharpRight
        case "right":
            direction = .right
        case "slight right":
            direction = .slightRight
        case "straight":
            direction = .straightAhead
        case "slight left":
            direction = .slightLeft
        case "left":
            direction = .left
        case "sharp left":
            direction = .sharpLeft
        case "uturn":
            direction = .uTurn
        default:
            direction = .none
        }
        self.init(rawValue: direction.rawValue)
    }
    
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .sharpRight:
            return "sharp right"
        case .right:
            return "right"
        case .slightRight:
            return "slight right"
        case .straightAhead:
            return "straight"
        case .slightLeft:
            return "slight left"
        case .left:
            return "left"
        case .sharpLeft:
            return "sharp left"
        case .uTurn:
            return "uturn"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let description = try container.decode(String.self)
        
        if let type = ManeuverDirection(description: description) {
            self = type
        } else {
            self = ManeuverDirection(v4TypeDescription: description)!
        }
    }
}

extension ManeuverDirection {
    internal init?(v4TypeDescription: String) {
        let description: String
        switch v4TypeDescription {
        case "bear right", "bear left":
            description = v4TypeDescription.replacingOccurrences(of: "bear", with: "slight")
        case "turn right", "turn left":
            description = v4TypeDescription.replacingOccurrences(of: "turn ", with: "")
        case "u-turn":
            description = "uturn"
        default:
            description = v4TypeDescription
        }
        self.init(description: description)
    }
}
