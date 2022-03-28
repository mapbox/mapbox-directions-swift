import Foundation
import Turf

/**
 `RestStop` describes corresponding object on the route.
 */
public struct RestStop: Codable, Equatable, ForeignMemberContainer {
    public var foreignMembers: JSONObject = [:]

    public enum StopType: String, Codable {
        case serviceArea = "service_area"
        case restArea = "rest_area"
    }

    /**
     The kind of the rest stop.
     */
    public let type: StopType

    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(type: StopType) {
        self.type = type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(StopType.self, forKey: .type)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type
    }
}
