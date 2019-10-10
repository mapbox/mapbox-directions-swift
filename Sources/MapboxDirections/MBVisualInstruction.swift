import Foundation
import CoreLocation


/**
 The contents of a banner that should be displayed as added visual guidance for a route. The banner instructions are children of the steps during which they should be displayed, but they refer to the maneuver in the following step.
 */


open class VisualInstruction: Codable {

    /**
     A plain text representation of the instruction.
     */
    public let text: String?

    /**
     The type of maneuver required for beginning the step described by the visual instruction.
     */
    public var maneuverType: ManeuverType

    /**
     Additional directional information to clarify the maneuver type.
     */
    public dynamic var maneuverDirection: ManeuverDirection

    /**
     A structured representation of the instruction.
     */
    public let components: [ComponentRepresentable]

    /**
     The heading at which the user exits a roundabout (traffic circle or rotary).

     This property is measured in degrees clockwise relative to the user’s initial heading. A value of 180° means continuing through the roundabout without changing course, whereas a value of 0° means traversing the entire roundabout back to the entry point.

     This property is only relevant if the `maneuverType` is any of the following values: `ManeuverType.takeRoundabout`, `ManeuverType.takeRotary`, `ManeuverType.turnAtRoundabout`, `ManeuverType.exitRoundabout`, or `ManeuverType.exitRotary`.
     */
    public var finalHeading: CLLocationDegrees?

    /**
     Initializes a new visual instruction banner object that displays the given information.
     */
    public init(text: String?, maneuverType: ManeuverType, maneuverDirection: ManeuverDirection, components: [ComponentRepresentable], degrees: CLLocationDegrees = 180) {
        self.text = text
        self.maneuverType = maneuverType
        self.maneuverDirection = maneuverDirection
        self.components = components
        self.finalHeading = degrees
    }
    
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case text
        case maneuverType = "type"
        case maneuverDirection = "modifier"
        case components
        case finalHeading = "degrees"
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(maneuverType, forKey: .maneuverType)
        try container.encode(maneuverDirection, forKey: .maneuverDirection)
        
        let wrappedComponents = components.map(ComponentCoder.init(component:))
        try container.encode(wrappedComponents, forKey: .components)
        
        try container.encodeIfPresent(finalHeading, forKey: .finalHeading)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        maneuverType = try container.decode(ManeuverType.self, forKey: .maneuverType)
        maneuverDirection = try container.decode(ManeuverDirection.self, forKey: .maneuverDirection)

        let componentsWrapped = try container.decode([ComponentCoder].self, forKey: .components)
        components = componentsWrapped.map { $0.component }
        
        finalHeading = try container.decodeIfPresent(CLLocationDegrees.self, forKey: .finalHeading)
    }
}
