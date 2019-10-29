import Foundation


/**
A component that represents a lane  representation of an instruction.
 */


open class LaneIndicationComponent: Equatable {

    /**
     An array indicating which directions you can go from a lane (left, right, or straight).
     
     If the value is `[LaneIndication.left", LaneIndication.straightAhead]`, the driver can go left or straight ahead from that lane. This is only set when the `component` is a `lane`.
     */
    public var indications: LaneIndication
    
    /**
     The boolean that indicates whether the lane can be used to complete the maneuver.
     
     If multiple lanes are active, then they can all be used to complete the upcoming maneuver. This value is set to `false` by default.
     */
    public var isUsable: Bool = false
    
    /**
     Initializes a new visual instruction component object that displays the given information.
     
     - parameter indications: The directions to go from a lane component.
     - parameter isUsable: The flag to indicate that the upcoming maneuver can be completed with a lane component.
     */
    public init(indications: LaneIndication, isUsable: Bool) {
        self.indications = indications
        self.isUsable = isUsable
    }
    
    // MARK: - Codable
    public static func == (lhs: LaneIndicationComponent, rhs: LaneIndicationComponent) -> Bool {
        return lhs.indications == rhs.indications &&
            lhs.isUsable == rhs.isUsable
    }
}
