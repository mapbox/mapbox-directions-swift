import Foundation

@objc(MBVisualInstruction)
public class VisualInstruction: NSObject, NSSecureCoding {
    
    public let distanceAlongStep: CLLocationDistance

    public let primaryContent: VisualInstructionComponent?
    
    public let secondaryContent: [VisualInstructionComponent]?
    
    internal init(json: JSONDictionary) {
        distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        if let primaryTextDict = json["primary"] as? JSONDictionary {
            self.primaryContent = VisualInstructionComponent(json: primaryTextDict)
        } else {
            self.primaryContent = nil
        }
        
        secondaryContent = (json["secondary"] as? [JSONDictionary])?.map {
            VisualInstructionComponent(json: $0)
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        primaryContent = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "primaryContent") as? VisualInstructionComponent
        secondaryContent = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "secondaryContent") as? [VisualInstructionComponent]
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryContent, forKey: "primaryContent")
        coder.encode(secondaryContent, forKey: "secondaryContent")
    }
}
