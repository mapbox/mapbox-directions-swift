import Foundation

public struct Incident: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case description = "description"
        case creationTime = "creation_time"
        case startTime = "start_time"
        case endTime = "end_time"
        case impact = "impact"
        case subtype = "sub_type"
        case subtypeDescription = "sub_type_description"
        case alertCodes = "alertc_codes"
        case lanesBlocked = "lanes_blocked"
        case geometryIndexStart = "geometry_index_start"
        case geometryIndexEnd = "geometry_index_end"
    }

    var identifier: String
    var type: String
    var description: String
    var creationTime: String
    var startTime: String
    var endTime: String
    var impact: String
    var subtype: String?
    var subtypeDescription: String?
    var alertCodes: [Int]
    var lanesBlocked: [Int]
    var geometryIndexStart: Int
    var geometryIndexEnd: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.description = try container.decode(String.self, forKey: .description)
        self.creationTime = try container.decode(String.self, forKey: .creationTime)
        self.startTime = try container.decode(String.self, forKey: .startTime)
        self.endTime = try container.decode(String.self, forKey: .endTime)
        self.impact = try container.decode(String.self, forKey: .impact)
        self.subtype = try container.decodeIfPresent(String.self, forKey: .subtype)
        self.subtypeDescription = try container.decodeIfPresent(String.self, forKey: .subtypeDescription)
        self.alertCodes = try container.decode([Int].self, forKey: .alertCodes)
        self.lanesBlocked = try container.decode([Int].self, forKey: .lanesBlocked)
        self.geometryIndexStart = try container.decode(Int.self, forKey: .geometryIndexStart)
        self.geometryIndexEnd = try container.decode(Int.self, forKey: .geometryIndexEnd)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(description, forKey: .description)
        try container.encode(creationTime, forKey: .creationTime)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encodeIfPresent(subtype, forKey: .subtype)
        try container.encodeIfPresent(subtypeDescription, forKey: .subtypeDescription)
        try container.encode(alertCodes, forKey: .alertCodes)
        try container.encode(lanesBlocked, forKey: .lanesBlocked)
        try container.encode(geometryIndexStart, forKey: .geometryIndexStart)
        try container.encode(geometryIndexEnd, forKey: .geometryIndexEnd)
    }
}
