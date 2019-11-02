import Foundation

/**
 A lane on the road approaching an intersection.
 */
struct Lane: Equatable {
    /**
     The lane indications specifying the maneuvers that may be executed from the lane.
     */
    let indications: LaneIndication
    
    var isValid: Bool
    
    init(indications: LaneIndication, valid: Bool = false) {
        self.indications = indications
        self.isValid = valid
    }
}

extension Lane: Codable {
    private enum CodingKeys: String, CodingKey {
        case indications
        case valid
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(indications, forKey: .indications)
        try container.encode(isValid, forKey: .valid)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        indications = try container.decode(LaneIndication.self, forKey: .indications)
        isValid = try container.decode(Bool.self, forKey: .valid)
    }
}
