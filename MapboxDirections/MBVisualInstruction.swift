import Foundation

/**
 :nodoc:
 The contents of a banner that should be displayed as added visual guidance for a route. The banner instructions are children of the steps during which they should be displayed, but they refer to the maneuver in the following step.
 */
@objc(MBVisualInstruction)
open class VisualInstruction: NSObject, NSSecureCoding {
    
    open static var supportsSecureCoding = true
    
    /**
     :nodoc:
     The plain text representation of this component.
     
     Use this property if `imageURLs` is an empty dictionary or if the URLs contained in that property are not yet available.
     */
    @objc public let text: String?
    
    /**
     :nodoc:
     The maneuver type for the `VisualInstruction`.
     */
    @objc public var maneuverType: ManeuverType
    
    /**
     :nodoc:
     The modifier type for the `VisualInstruction`.
     */
    @objc public var maneuverDirection: ManeuverDirection
    
    /**
     :nodoc:
     Most important visual content to convey to the user about the `RouteStep`.
     
     This is the structured representation of `text`.
     */
    @objc public let textComponents: [VisualInstructionComponent]
    
    /**
     :nodoc:
     The heading at which you will be exiting a roundabout, assuming 180 indicates going straight through the roundabout.
     
     Note that this property is only relevant if the `maneuverType` is any of
     [`ManeuverType.takeRoundabout`, `ManeuverType.takeRotary`, `ManeuverType.turnAtRoundabout`, `ManeuverType.exitRoundabout`, `ManeuverType.exitRotary`]
     */
    @objc public var finalHeading: CLLocationDegrees = 180
    
    /**
     :nodoc:
     Initialize A `VisualInstructionBanner`.
     */
    @objc public init(text: String?, maneuverType: ManeuverType, maneuverDirection: ManeuverDirection, textComponents: [VisualInstructionComponent], degrees: CLLocationDegrees = 180) {
        self.text = text
        self.maneuverType = maneuverType
        self.maneuverDirection = maneuverDirection
        self.textComponents = textComponents
        self.finalHeading = degrees
    }
    
    /**
     Initializes a new visual instruction object based on the given JSON dictionary representation.
     
     - parameter json: A JSON object that conforms to the [banner instruction](https://www.mapbox.com/api-documentation/#banner-instruction-object) format described in the Directions API documentation.
     */
    @objc(initWithJSON:)
    public convenience init(json: [String: Any]) {
        let text = json["text"] as? String
        let maneuverType = ManeuverType(description: json["type"] as! String) ?? .none
        let maneuverDirection = ManeuverDirection(description: json["modifier"] as! String)  ?? .none
        let textComponents = (json["components"] as! [JSONDictionary]).map {
            VisualInstructionComponent(json: $0)
        }
        
        let degrees = json["degrees"] as? CLLocationDegrees ?? 180
        
        self.init(text: text, maneuverType: maneuverType, maneuverDirection: maneuverDirection, textComponents: textComponents, degrees: degrees)
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        guard let maneuverTypeString = decoder.decodeObject(of: NSString.self, forKey: "maneuverType") as String?, let maneuverType = ManeuverType(description: maneuverTypeString) else {
            return nil
        }
        self.maneuverType = maneuverType
        
        guard let direction = decoder.decodeObject(of: NSString.self, forKey: "maneuverDirection") as String?, let maneuverDirection = ManeuverDirection(description: direction) else {
            return nil
        }
        self.maneuverDirection = maneuverDirection
        
        guard let textComponents = decoder.decodeObject(of: [NSArray.self, VisualInstructionComponent.self], forKey: "textComponents") as? [VisualInstructionComponent] else {
            return nil
        }
        
        self.textComponents = textComponents
        
        self.finalHeading = decoder.decodeDouble(forKey: "degrees")
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(maneuverType, forKey: "maneuverType")
        coder.encode(maneuverDirection, forKey: "maneuverDirection")
        coder.encode(finalHeading, forKey: "degrees")
    }
}

