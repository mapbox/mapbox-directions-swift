import Foundation

/**
 :nodoc:
 Encompasses all information necessary for creating a visual queue about a given `RouteStep`.
 */
@objc(MBVisualInstruction)
public class VisualInstruction: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Distance in meters from the beginning of the step at which the visual instruction should be visible.
     */
    public let distanceAlongStep: CLLocationDistance
    

    /**
     :nodoc:
     Most important visual content to convey to the user about the `RouteStep`.
     */
    public let primaryContent: VisualInstructionComponent
    
    
    /**
     :nodoc:
     Ancillary visual information about the `RouteStep`.
     */
    public let secondaryContent: VisualInstructionComponent?
    
    
    internal init(json: JSONDictionary) {
        distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        self.primaryContent = VisualInstructionComponent(json: json["primary"] as! JSONDictionary)
        
        if let secondaryTextDict = json["secondary"] as? JSONDictionary {
            self.secondaryContent = VisualInstructionComponent(json: secondaryTextDict)
        } else {
            self.secondaryContent = nil
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        primaryContent = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "primaryContent") as! VisualInstructionComponent
        secondaryContent = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "secondaryContent") as? VisualInstructionComponent
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryContent, forKey: "primaryContent")
        coder.encode(secondaryContent, forKey: "secondaryContent")
    }
}
