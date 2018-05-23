/**
A component of a `VisualInstruction` that represents a collection of lane(s) representation of the instruction.
 */
@objc(MBLaneIndicationComponent)
open class LaneIndicationComponent: Component {
    
    /**
     An array indicating which directions you can go from a lane (left, right, or straight).
     
     If the value is `[LaneIndication.left", LaneIndication.straightAhead]`, the driver can go left or straight ahead from that lane. This is only set when the `component` is a `lane`.
     */
    @objc public var indications: LaneIndication = LaneIndication()
    
    /**
     The boolean that indicates whether the component is a lane and can be used to complete the upcoming maneuver.
     
     If multiple lanes are active, then they can all be used to complete the upcoming maneuver. This value is set to `false` by default.
     */
    @objc public var isActiveLane: Bool = false
    
    /**
     Initializes a new visual instruction component object that displays the given information.
     
     - parameter type: The type of visual instruction component.
     - parameter text: The plain text representation of this component.
     - parameter indications: The directions to go from a lane component.
     - parameter isLaneActive: The flag to indicate that the upcoming maneuver can be completed with a lane component.
     */
    @objc public init(text: String?, type: VisualInstructionComponentType, indications: LaneIndication, isActiveLane: Bool) {
        self.indications = indications
        self.isActiveLane = isActiveLane
        super.init(text: text, type: type)
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        guard let directions = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "directions") as? [String], let indications = LaneIndication(descriptions: directions) else {
            return nil
        }
        self.indications = indications
        
        guard let active = decoder.decodeObject(forKey: "active") as? Bool else {
            return nil
        }
        self.isActiveLane = active
    }
    
    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(indications, forKey: "directions")
        coder.encode(isActiveLane, forKey: "active")
    }
}
