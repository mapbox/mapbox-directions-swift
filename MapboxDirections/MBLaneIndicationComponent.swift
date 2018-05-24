/**
A component that represents a lane  representation of an instruction.
 */
open class LaneIndicationComponent: Component {
    
    /**
     An array indicating which directions you can go from a lane (left, right, or straight).
     
     If the value is `[LaneIndication.left", LaneIndication.straightAhead]`, the driver can go left or straight ahead from that lane. This is only set when the `component` is a `lane`.
     */
    @objc public var indications: LaneIndication
    
    /**
     The boolean that indicates whether the component is a lane and can be used to complete the upcoming maneuver.
     
     If multiple lanes are active, then they can all be used to complete the upcoming maneuver. This value is set to `false` by default.
     */
    @objc public var isUsable: Bool = false
    
    // MARK: Component/NSSecureCoding Protocols Variables
    @objc public var text: String?
    
    @objc public var type: VisualInstructionComponentType
    
    public static var supportsSecureCoding: Bool = true
    
    /**
     Initializes a new visual instruction component object that displays the given information.
     
     - parameter type: The type of visual instruction component.
     - parameter text: The plain text representation of this component.
     - parameter indications: The directions to go from a lane component.
     - parameter isLaneActive: The flag to indicate that the upcoming maneuver can be completed with a lane component.
     */
    @objc public init(text: String?, type: VisualInstructionComponentType, indications: LaneIndication, isUsable: Bool) {
        self.text = text
        self.type = type
        self.indications = indications
        self.isUsable = isUsable
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        self.text = decoder.decodeObject(of: NSString.self, forKey: "text") as String?
        
        guard let typeString = decoder.decodeObject(of: NSString.self, forKey: "type") as String?, let type = VisualInstructionComponentType(description: typeString) else {
            return nil
        }
        self.type = type
        
        guard let directions = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "directions") as? [String], let indications = LaneIndication(descriptions: directions) else {
            return nil
        }
        self.indications = indications
        
        guard let active = decoder.decodeObject(forKey: "active") as? Bool else {
            return nil
        }
        self.isUsable = active
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(type, forKey: "type")
        coder.encode(indications, forKey: "directions")
        coder.encode(isUsable, forKey: "active")
    }
}
