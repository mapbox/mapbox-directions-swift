import Foundation

/**
 :nodoc:
 Encompasses all information necessary for creating a visual cue about a given `RouteStep`.
 */
@objc(MBVisualInstruction)
open class VisualInstruction: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Distance in meters from the beginning of the step at which the visual instruction should be visible.
     */
    @objc public let distanceAlongStep: CLLocationDistance
    
    /**
     :nodoc:
     A plain text representation of `primaryTextComponents`.
     */
    @objc public let primaryText: String

    /**
     :nodoc:
     Most important visual content to convey to the user about the `RouteStep`.
     
     This is the structured representation of `primaryText`.
     */
    @objc public let primaryTextComponents: [VisualInstructionComponent]
    
    /**
     :nodoc:
     A plain text representation of `secondaryTextComponents`.
     */
    @objc public let secondaryText: String?
    
    /**
     :nodoc:
     Ancillary visual information about the `RouteStep`.
     
     This is the structured representation of `secondaryText`.
     */
    @objc public let secondaryTextComponents: [VisualInstructionComponent]?
    
    
    /**
     :nodoc:
     Indicates what side of a bidirectional road the driver must be driving on. Also referred to as the rule of the road.
     */
    @objc public var drivingSide: DrivingSide
    
    /**
     :nodoc:
     Initialize a `VisualInstruction` from a dictionary given a `DrivingSide`.
     */
    @objc public convenience init(json: [String: Any], drivingSide: DrivingSide) {
        let distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        let primaryTextComponent = json["primary"] as! JSONDictionary
        let primaryText = primaryTextComponent["text"] as! String
        let primaryManeuverType = ManeuverType(description: primaryTextComponent["type"] as! String) ?? .none
        let primaryManeuverDirection = ManeuverDirection(description: primaryTextComponent["modifier"] as! String)  ?? .none
        let primaryTextComponents = (primaryTextComponent["components"] as! [JSONDictionary]).map {
            VisualInstructionComponent(maneuverType: primaryManeuverType, maneuverDirection: primaryManeuverDirection, json: $0)
        }
        
        var secondaryText: String?
        var secondaryTextComponents: [VisualInstructionComponent]?
        if let secondaryTextComponent = json["secondary"] as? JSONDictionary {
            secondaryText = secondaryTextComponent["text"] as? String
            let secondaryManeuverType = ManeuverType(description: secondaryTextComponent["type"] as! String) ?? .none
            let secondaryManeuverDirection = ManeuverDirection(description: secondaryTextComponent["modifier"] as! String)  ?? .none
            secondaryTextComponents = (secondaryTextComponent["components"] as! [JSONDictionary]).map {
                VisualInstructionComponent(maneuverType: secondaryManeuverType, maneuverDirection: secondaryManeuverDirection, json: $0)
            }
        }
        
        self.init(distanceAlongStep: distanceAlongStep, primaryText: primaryText, primaryTextComponents: primaryTextComponents, secondaryText: secondaryText, secondaryTextComponents: secondaryTextComponents, drivingSide: drivingSide)
    }
    
    /**
     :nodoc:
     Initialize a `VisualInstruction`.
     */
    @objc public init(distanceAlongStep: CLLocationDistance, primaryText: String, primaryTextComponents: [VisualInstructionComponent], secondaryText: String?, secondaryTextComponents: [VisualInstructionComponent]?, drivingSide: DrivingSide) {
        self.distanceAlongStep = distanceAlongStep
        self.primaryText = primaryText
        self.primaryTextComponents = primaryTextComponents
        self.secondaryText = secondaryText
        self.secondaryTextComponents = secondaryTextComponents
        self.drivingSide = drivingSide
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
        
        
        if let drivingSideDescription = decoder.decodeObject(of: NSString.self, forKey: "drivingSide") as String?, let drivingSide = DrivingSide(description: drivingSideDescription) {
            self.drivingSide = drivingSide
        } else {
            self.drivingSide = .right
        }
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryText, forKey: "primaryText")
        coder.encode(primaryTextComponents, forKey: "primaryTextComponents")
        coder.encode(secondaryText, forKey: "secondaryText")
        coder.encode(secondaryTextComponents, forKey: "secondaryTextComponents")
        coder.encode(drivingSide, forKey: "drivingSide")
    }
}
