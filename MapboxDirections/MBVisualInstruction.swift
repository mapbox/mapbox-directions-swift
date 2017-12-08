import Foundation

/**
 :nodoc:
 Encompasses all information necessary for creating a visual cue about a given `RouteStep`.
 */

@objc(MBVisualInstruction)
open class VisualInstruction: NSObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case distanceAlongStep = "distanceAlongGeometry"
        case primary
        case secondary
    }
    
    private enum InstructionCodingKeys: String, CodingKey {
        case text
        case components
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(distanceAlongStep, forKey: .distanceAlongStep)
        
        var primary = container.nestedContainer(keyedBy: InstructionCodingKeys.self, forKey: .primary)
        try primary.encode(primaryText, forKey: .text)
        try primary.encode(primaryTextComponents, forKey: .components)
        
        var secondary = container.nestedContainer(keyedBy: InstructionCodingKeys.self, forKey: .secondary)
        try secondary.encodeIfPresent(secondaryText, forKey: .text)
        try secondary.encodeIfPresent(secondaryTextComponents, forKey: .components)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distanceAlongStep = try container.decode(CLLocationDistance.self, forKey: .distanceAlongStep)
        
        let primary = try container.nestedContainer(keyedBy: InstructionCodingKeys.self, forKey: .primary)
        primaryText = try primary.decode(String.self, forKey: .text)
        primaryTextComponents = try primary.decode([VisualInstructionComponent].self, forKey: .components)
        
        let secondary = try? container.nestedContainer(keyedBy: InstructionCodingKeys.self, forKey: .secondary)
        secondaryText = try secondary?.decodeIfPresent(String.self, forKey: .text)
        secondaryTextComponents = try secondary?.decodeIfPresent([VisualInstructionComponent].self, forKey: .components)
    }
    
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
     Initialize a `VisualInstruction`.
     */
    @objc public init(distanceAlongStep: CLLocationDistance, primaryText: String, primaryTextComponents: [VisualInstructionComponent], secondaryText: String?, secondaryTextComponents: [VisualInstructionComponent]?) {
        self.distanceAlongStep = distanceAlongStep
        self.primaryText = primaryText
        self.primaryTextComponents = primaryTextComponents
        self.secondaryText = secondaryText
        self.secondaryTextComponents = secondaryTextComponents
    }
}
