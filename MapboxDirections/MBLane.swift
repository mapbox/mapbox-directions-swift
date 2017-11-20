import Foundation

/**
 A lane on the road approaching an intersection.
 */
@objc(MBLane)
public class Lane: NSObject, NSSecureCoding {
    /**
     The lane indications specifying the maneuvers that may be executed from the lane.
     */
    @objc public let indications: LaneIndication
    
    internal init(indications: LaneIndication) {
        self.indications = indications
    }
    
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
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(indications.description.components(separatedBy: ","), forKey: "indications")
    }
}
