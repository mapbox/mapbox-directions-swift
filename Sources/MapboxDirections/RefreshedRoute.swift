import Foundation
import Turf

/**
 A skeletal route containing only the information about the route that has been refreshed.
 */
public struct RefreshedRoute: ForeignMemberContainer {
    public var foreignMembers: JSONObject = [:]
    
    /**
     The legs along the route, starting at the first refreshed leg index.
     */
    public var legs: [RefreshedRouteLeg]
}

extension RefreshedRoute: Codable {
    enum CodingKeys: String, CodingKey {
        case legs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        legs = try container.decode([RefreshedRouteLeg].self, forKey: .legs)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(legs, forKey: .legs)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

/**
 A skeletal route leg containing only the information about the route leg that has been refreshed.
 */
public struct RefreshedRouteLeg: ForeignMemberContainer {
    public var foreignMembers: JSONObject = [:]
    
    public var attributes: RouteLeg.Attributes
}

extension RefreshedRouteLeg: Codable {
    enum CodingKeys: String, CodingKey {
        case attributes = "annotation"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try container.decode(RouteLeg.Attributes.self, forKey: .attributes)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attributes, forKey: .attributes)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
