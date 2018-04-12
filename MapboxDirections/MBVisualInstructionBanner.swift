import Foundation

/**
 :nodoc:
 Encompasses all information necessary for creating a visual cue about a given `RouteStep`.
 */
@objc(MBVisualInstructionBanner)
open class VisualInstructionBanner: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Distance in meters from the beginning of the step at which the visual instruction should be visible.
     */
    @objc public let distanceAlongStep: CLLocationDistance

    /**
     :nodoc:
     Most important visual content to convey to the user about the `RouteStep`.
     */
    @objc public let primaryInstruction: VisualInstruction
    
    /**
     :nodoc:
     Ancillary visual information about the `RouteStep`.
     */
    @objc public let secondaryInstruction: VisualInstruction?
    
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
        
        let primary = json["primary"] as! JSONDictionary
        let secondary = json["secondary"] as? JSONDictionary
        
        let primaryInstruction = VisualInstruction(json: primary)
        var secondaryInstruction: VisualInstruction? = nil
        if let secondary = secondary {
            secondaryInstruction = VisualInstruction(json: secondary)
        }
        
        self.init(distanceAlongStep: distanceAlongStep, primaryInstruction: primaryInstruction, secondaryInstruction: secondaryInstruction, drivingSide: drivingSide)
    }
    
    /**
     :nodoc:
     Initialize a `VisualInstruction`.
     */
    @objc public init(distanceAlongStep: CLLocationDistance, primaryInstruction: VisualInstruction, secondaryInstruction: VisualInstruction?, drivingSide: DrivingSide) {
        self.distanceAlongStep = distanceAlongStep
        self.primaryInstruction = primaryInstruction
        self.secondaryInstruction = secondaryInstruction
        self.drivingSide = drivingSide
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        
        if let drivingSideDescription = decoder.decodeObject(of: NSString.self, forKey: "drivingSide") as String?, let drivingSide = DrivingSide(description: drivingSideDescription) {
            self.drivingSide = drivingSide
        } else {
            self.drivingSide = .right
        }
        
        guard let primaryInstruction = decoder.decodeObject(of: VisualInstruction.self, forKey: "primary") else {
            return nil
        }
        self.primaryInstruction = primaryInstruction
        self.secondaryInstruction = decoder.decodeObject(of: VisualInstruction.self, forKey: "secondary")
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryInstruction, forKey: "primary")
        coder.encode(secondaryInstruction, forKey: "secondary")
        coder.encode(drivingSide, forKey: "drivingSide")
    }
}
