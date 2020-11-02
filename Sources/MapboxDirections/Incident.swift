import Foundation

/**
 :nodoc:
 `Incident` describes any corresponding event, used for annotating the route.
 */
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
    var impact: String?
    var subtype: String?
    var subtypeDescription: String?
    var alertCodes: [Int]
    var lanesBlocked: [Int]
    var geometryIndexStart: Int
    var geometryIndexEnd: Int
    
    public init(identifier: String,
                type: String,
                description: String,
                creationTime: String,
                startTime: String,
                endTime: String,
                impact: String?,
                subtype: String?,
                subtypeDescription: String?,
                alertCodes: [Int],
                lanesBlocked: [Int],
                geometryIndexStart: Int,
                geometryIndexEnd: Int) {
        self.identifier = identifier
        self.type = type
        self.description = description
        self.creationTime = creationTime
        self.startTime = startTime
        self.endTime = endTime
        self.impact = impact
        self.subtype = subtype
        self.subtypeDescription = subtypeDescription
        self.alertCodes = alertCodes
        self.lanesBlocked = lanesBlocked
        self.geometryIndexStart = geometryIndexStart
        self.geometryIndexEnd = geometryIndexEnd
    }
}
