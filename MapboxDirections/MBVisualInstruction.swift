import Foundation

/**
 The contents of a banner that should be displayed as added visual guidance for a route. The banner instructions are children of the steps during which they should be displayed, but they refer to the maneuver in the following step.
 */
@objc(MBVisualInstruction)
open class VisualInstruction: NSObject, NSSecureCoding {
    
    open static var supportsSecureCoding = true
    
    /**
     A plain text representation of the instruction.
     */
    @objc public let text: String?
    
    /**
     The type of maneuver required for beginning the step described by the visual instruction.
     */
    @objc public var maneuverType: ManeuverType
    
    /**
     Additional directional information to clarify the maneuver type.
     */
    @objc public var maneuverDirection: ManeuverDirection
    
    /**
     A structured representation of the instruction.
     */
    @objc public let textComponents: [VisualInstructionComponent]
    
    /**
     The heading at which the user exits a roundabout (traffic circle or rotary).
     
     This property is measured in degrees clockwise relative to the user’s initial heading. A value of 180° means continuing through the roundabout without changing course, whereas a value of 0° means traversing the entire roundabout back to the entry point.
     
     This property is only relevant if the `maneuverType` is any of the following values: `ManeuverType.takeRoundabout`, `ManeuverType.takeRotary`, `ManeuverType.turnAtRoundabout`, `ManeuverType.exitRoundabout`, or `ManeuverType.exitRotary`.
     */
    @objc public var finalHeading: CLLocationDegrees = 180
    
    /**
     Initializes a new visual instruction banner object that displays the given information.
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
        
        var maneuverType: ManeuverType = .none
        if let type = json["type"] as? String, let derivedType = ManeuverType(description: type) {
            maneuverType = derivedType
        }
        
        var maneuverDirection: ManeuverDirection = .none
        if let modifier = json["modifier"] as? String,
            let derivedDirection = ManeuverDirection(description: modifier) {
            maneuverDirection = derivedDirection
        }
        
        let textComponents: [VisualInstructionComponent] = (json["components"] as! [JSONDictionary]).map { record in
            let type = VisualInstructionComponentType(description: record["type"] as? String ?? "") ?? .text
            let imageURL = URL(string: (record["imageBaseURL"] as? String) ?? "")
       
            let instructionComponent = VisualInstructionComponent(type: type,
                                                                  text: record["text"] as? String,
                                                              imageURL: imageURL,
                                                          abbreviation: record["abbr"] as? String,
                                                  abbreviationPriority: record["abbr_priority"] as? Int ?? NSNotFound)
            
            if let directions = record["directions"] as? [String], let laneIndication = LaneIndication(descriptions: directions) {
                instructionComponent.indications = laneIndication
            }

            if let active = record["active"] as? Bool  {
                instructionComponent.isActiveLane = active
            }
            
            return instructionComponent
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
        coder.encode(textComponents, forKey: "textComponents")
    }
}
