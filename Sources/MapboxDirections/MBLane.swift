import Foundation

/**
 A lane on the road approaching an intersection.
 */
public struct Lane: Codable, Equatable {
    /**
     The lane indications specifying the maneuvers that may be executed from the lane.
     */
    public let indications: LaneIndication
    
    let isValid: Bool
    
    internal init(indications: LaneIndication, valid: Bool = false) {
        self.indications = indications
        self.isValid = valid
    }
    
    private enum CodingKeys: String, CodingKey {
        case indications
        case valid
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(indications, forKey: .indications)
        try container.encode(isValid, forKey: .valid)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        indications = try container.decode(LaneIndication.self, forKey: .indications)
        isValid = try container.decode(Bool.self, forKey: .valid)
    }
}
