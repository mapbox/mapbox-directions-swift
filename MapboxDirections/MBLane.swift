import Foundation

/**
 A lane on the road approaching an intersection.
 */
@objc(MBLane)
public class Lane: NSObject, NSSecureCoding {
    /**
     The lane indications specifying the maneuvers that may be executed from the lane.
     */
    public let indications: LaneIndication
    
    internal init(indications: LaneIndication) {
        self.indications = indications
    }
    
    internal convenience init(json: JSONDictionary) {
        let indications = LaneIndication(descriptions: json["indications"] as! [String])
        
        self.init(indications: indications!)
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let descriptions = decoder.decodeObjectOfClasses([NSArray.self, NSString.self], forKey: "indications") as? [String],
            let indications = LaneIndication(descriptions: descriptions) else {
            return nil
        }
        self.indications = indications
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(indications.description.componentsSeparatedByString(","), forKey: "indications")
    }
}
