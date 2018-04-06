import Foundation

/**
 Indicate how a route considers from which side of the road to approach a waypoint.
 */
@objc(MBApproachType)
public enum ApproachType: UInt, CustomStringConvertible {
    /**
     Approaches a waypoint from either side of road.
     */
    case unrestricted

    /**
     Approaches a waypoint from the same side of the road as the waypoint falls.
     */
    case curb
    
    public init?(description: String) {
        let approach: ApproachType
        switch description {
        case "unrestricted":
            approach = .unrestricted
        case "curb":
            approach = .curb
        default:
            return nil
        }
        self.init(rawValue: approach.rawValue)
    }
    
    public var description: String {
        switch self {
        case .unrestricted:
            return "unrestricted"
        case .curb:
            return "curb"
        }
    }
}
