import Foundation

/**
 A lane on the road approaching an intersection.
 */
@objcMembers
@objc(MBLane)
public class Lane: NSObject, NSSecureCoding {
    /**
     The lane indications specifying the maneuvers that may be executed from the lane.
     */
    #if SWIFT_PACKAGE
    public let indications: LaneIndication
    #else
    @objc public let indications: MBLaneIndication
    #endif
    
    /**
     Initializes a new `Lane` using the given lane indications.
     */
    #if SWIFT_PACKAGE
    public init(indications: LaneIndication) {
        self.indications = indications
    }
    #else
    @objc public init(indications: LaneIndication) {
        self.indications = indications
    }
    #endif
    
    internal convenience init(json: JSONDictionary) {
        let indications = LaneIndication(descriptions: json["indications"] as! [String])
        
        self.init(indications: indications!)
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let descriptions = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "indications") as? [String],
            let indications = LaneIndication(descriptions: descriptions) else {
            return nil
        }
        self.indications = indications
    }
    
    public static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(indications.description.components(separatedBy: ","), forKey: "indications")
    }
}
