/**
A component that represents a lane  representation of an instruction.
 */
@objc(MBLaneIndicationComponent)
open class LaneIndicationComponent: NSObject, ComponentRepresentable {

    /**
     An array indicating which directions you can go from a lane (left, right, or straight).
     
     If the value is `[LaneIndication.left", LaneIndication.straightAhead]`, the driver can go left or straight ahead from that lane. This is only set when the `component` is a `lane`.
     */
    @objc public var indications: LaneIndication
    
    /**
     The boolean that indicates whether the lane can be used to complete the maneuver.
     
     If multiple lanes are active, then they can all be used to complete the upcoming maneuver. This value is set to `false` by default.
     */
    @objc public var isUsable: Bool = false
    
    public static var supportsSecureCoding: Bool = true
    
    /**
     Initializes a new visual instruction component object that displays the given information.
     
     - parameter indications: The directions to go from a lane component.
     - parameter isLaneActive: The flag to indicate that the upcoming maneuver can be completed with a lane component.
     */
    @objc public init(indications: LaneIndication, isUsable: Bool) {
        self.indications = indications
        self.isUsable = isUsable
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        guard let directions = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "indications") as? [String], let indications = LaneIndication(descriptions: directions) else {
            return nil
        }
        self.indications = indications
        
        guard let isUsable = decoder.decodeObject(forKey: "isUsable") as? Bool else {
            return nil
        }
        self.isUsable = isUsable
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(indications, forKey: "indications")
        coder.encode(isUsable, forKey: "isUsable")
    }
}
