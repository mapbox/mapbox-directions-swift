import Foundation

/**
 :nodoc:
 Encompasses all information necessary for creating a visual cue about a given `RouteStep`.
 */
@objc(MBVisualInstruction)
public class VisualInstruction: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Distance in meters from the beginning of the step at which the visual instruction should be visible.
     */
    public let distanceAlongStep: CLLocationDistance
    
    /**
     A plain text representation of `primaryTextComponents`.
     */
    public let primaryText: String

    /**
     :nodoc:
     Most important visual content to convey to the user about the `RouteStep`.
     */
    public let primaryTextComponents: [VisualInstructionComponent]
    
    
    /**
     A plain text representation of `secondaryTextComponents`.
     */
    public let secondaryText: String?
    
    /**
     :nodoc:
     Ancillary visual information about the `RouteStep`.
     */
    public let secondaryTextComponents: [VisualInstructionComponent]?
    
    
    internal init(json: JSONDictionary) {
        distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        let primaryTextComponent = json["primary"] as! JSONDictionary
        primaryText = primaryTextComponent["text"] as! String
        primaryTextComponents = (primaryTextComponent["components"] as! [JSONDictionary]).map {
            VisualInstructionComponent(json: $0)
        }
        
        if let secondaryTextComponent = json["secondary"] as? JSONDictionary {
            secondaryText = secondaryTextComponent["text"] as? String
            secondaryTextComponents = (secondaryTextComponent["components"] as! [JSONDictionary]).map {
                VisualInstructionComponent(json: $0)
            }
        } else {
            secondaryText = nil
            secondaryTextComponents = nil
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        
        guard let primaryText = decoder.decodeObject(of: NSString.self, forKey: "primaryText") as String? else {
            return nil
        }
        self.primaryText = primaryText
        
        primaryTextComponents = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "primaryTextComponents") as? [VisualInstructionComponent] ?? []
        
        guard let secondaryText = decoder.decodeObject(of: NSString.self, forKey: "primarysecondaryTextText") as String? else {
            return nil
        }
        self.secondaryText = secondaryText
        
        secondaryTextComponents = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "primaryTextComponents") as? [VisualInstructionComponent]
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryText, forKey: "primaryText")
        coder.encode(primaryTextComponents, forKey: "primaryTextComponents")
        coder.encode(secondaryText, forKey: "secondaryText")
        coder.encode(secondaryTextComponents, forKey: "secondaryTextComponents")
    }
}
