import Foundation
import CoreLocation

internal extension CodingUserInfoKey {
    static let drivingSide = CodingUserInfoKey(rawValue: "drivingSide")!
}

/**
 A visual instruction banner contains all the information necessary for creating a visual cue about a given `RouteStep`.
 */
open class VisualInstructionBanner: Codable {
    private enum CodingKeys: String, CodingKey {
        case distanceAlongStep = "distanceAlongGeometry"
        case primaryInstruction = "primary"
        case secondaryInstruction = "secondary"
        case tertiaryInstruction = "sub"
        case drivingSide
    }
    
    // MARK: Creating a Visual Instruction Banner
    
    /**
     Initializes a visual instruction banner with the given instructions.
     */
    public init(distanceAlongStep: CLLocationDistance, primary: VisualInstruction, secondary: VisualInstruction?, tertiary: VisualInstruction?, drivingSide: DrivingSide) {
        self.distanceAlongStep = distanceAlongStep
        primaryInstruction = primary
        secondaryInstruction = secondary
        tertiaryInstruction = tertiary
        self.drivingSide = drivingSide
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(distanceAlongStep, forKey: .distanceAlongStep)
        try container.encode(primaryInstruction, forKey: .primaryInstruction)
        try container.encodeIfPresent(secondaryInstruction, forKey: .secondaryInstruction)
        try container.encodeIfPresent(tertiaryInstruction, forKey: .tertiaryInstruction)
        try container.encode(drivingSide, forKey: .drivingSide)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distanceAlongStep = try container.decode(CLLocationDistance.self, forKey: .distanceAlongStep)
        primaryInstruction = try container.decode(VisualInstruction.self, forKey: .primaryInstruction)
        secondaryInstruction = try container.decodeIfPresent(VisualInstruction.self, forKey: .secondaryInstruction)
        tertiaryInstruction = try container.decodeIfPresent(VisualInstruction.self, forKey: .tertiaryInstruction)
        if let directlyEncoded = try container.decodeIfPresent(DrivingSide.self, forKey: .drivingSide) {
            drivingSide = directlyEncoded
        } else {
            drivingSide = .default
        }
    }
    
    // MARK: Timing When to Display the Banner
    
    /**
     The distance at which the visual instruction should be shown, measured in meters from the beginning of the step.
     */
    public let distanceAlongStep: CLLocationDistance
    
    // MARK: Getting the Instructions to Display
    
    /**
     The most important information to convey to the user about the `RouteStep`.
     */
    public let primaryInstruction: VisualInstruction

    /**
     Less important details about the `RouteStep`.
     */
    public let secondaryInstruction: VisualInstruction?

    /**
     A visual instruction that is presented simultaneously to provide information about an additional maneuver that occurs in rapid succession.

     This instruction could either contain the visual layout information or the lane information about the upcoming maneuver.
     */
    public let tertiaryInstruction: VisualInstruction?
    
    // MARK: Respecting Regional Driving Rules
    
    /**
     Which side of a bidirectional road the driver should drive on, also known as the rule of the road.
     */
    public var drivingSide: DrivingSide
}

extension VisualInstructionBanner: Equatable {
    public static func == (lhs: VisualInstructionBanner, rhs: VisualInstructionBanner) -> Bool {
        return lhs.distanceAlongStep == rhs.distanceAlongStep &&
            lhs.primaryInstruction == rhs.primaryInstruction &&
            lhs.secondaryInstruction == rhs.secondaryInstruction &&
            lhs.tertiaryInstruction == rhs.tertiaryInstruction &&
            lhs.drivingSide == rhs.drivingSide
    }
}
