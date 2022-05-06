import Foundation
import Turf

/**
 A [rest stop](https://wiki.openstreetmap.org/wiki/Tag:highway%3Drest_area) along the route.
 */
public struct RestStop: Codable, Equatable, ForeignMemberContainer {
    public var foreignMembers: JSONObject = [:]

    /// A kind of rest stop.
    public enum StopType: String, Codable {
        /// A primitive rest stop that provides parking but no additional services.
        case serviceArea = "service_area"
        /// A major rest stop that provides amenities such as fuel and food.
        case restArea = "rest_area"
    }

    /**
     The kind of the rest stop.
     */
    public let type: StopType
    
    /// The name of the rest stop, if available.
    public let name: String?

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
    
    /**
     Initializes an unnamed rest stop of a certain kind.
     
     - parameter type: The kind of rest stop.
     */
    public init(type: StopType) {
        self.type = type
        self.name = nil
    }
    
    /**
     Initializes an optionally named rest stop of a certain kind.
     
     - parameter type: The kind of rest stop.
     - parameter name: The name of the rest stop.
     */
    public init(type: StopType, name: String?) {
        self.type = type
        self.name = name
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(StopType.self, forKey: .type)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(name, forKey: .name)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type && lhs.name == rhs.name
    }
}
