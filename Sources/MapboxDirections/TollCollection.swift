import Foundation
import Turf

/**
 `TollCollection` describes corresponding object on the route.
 */
public struct TollCollection: Codable, Equatable, ForeignMemberContainer {
    public var foreignMembers: JSONObject = [:]

    public enum CollectionType: String, Codable {
        case booth = "toll_booth"
        case gantry = "toll_gantry"
    }

    /**
     The type of the toll collection point.
     */
    public let type: CollectionType

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(type: CollectionType) {
        self.type = type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(CollectionType.self, forKey: .type)
        
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
