import Foundation

/**
 A `TransportType` specifies the mode of transportation used for part of a route.
 */
@objc(MBTransportType)
public enum TransportType: Int, CustomStringConvertible, Codable {
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`
    
    /**
     The route requires the user to drive or ride a car, truck, or motorcycle.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`.
     */
    case automobile // automobile
    
    /**
     The route requires the user to board a ferry.
     
     The user should verify that the ferry is in operation. For driving and cycling directions, the user should also verify that his or her vehicle is permitted onboard the ferry.
     */
    case ferry // automobile, walking, cycling
    
    /**
     The route requires the user to cross a movable bridge.
     
     The user may need to wait for the movable bridge to become passable before continuing.
     */
    case movableBridge // automobile, cycling
    
    /**
     The route becomes impassable at this point.
     
     You should not encounter this transport type under normal circumstances.
     */
    case inaccessible // automobile, walking, cycling
    
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierWalking`
    
    /**
     The route requires the user to walk.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierWalking`. For cycling directions, this value indicates that the user is expected to dismount.
     */
    case walking // walking, cycling
    
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierCycling`
    
    /**
     The route requires the user to ride a bicycle.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierCycling`.
     */
    case cycling // cycling
    
    /**
     The route requires the user to board a train.
     
     The user should consult the train’s timetable. For cycling directions, the user should also verify that bicycles are permitted onboard the train.
     */
    case train // cycling
    
    public init?(description: String) {
        let type: TransportType
        switch description {
        case "driving":
            type = .automobile
        case "ferry":
            type = .ferry
        case "moveable bridge":
            type = .movableBridge
        case "unaccessible":
            type = .inaccessible
        case "walking":
            type = .walking
        case "cycling":
            type = .cycling
        case "train":
            type = .train
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .automobile:
            return "driving"
        case .ferry:
            return "ferry"
        case .movableBridge:
            return "moveable bridge"
        case .inaccessible:
            return "unaccessible"
        case .walking:
            return "walking"
        case .cycling:
            return "cycling"
        case .train:
            return "train"
        }
    }
}
