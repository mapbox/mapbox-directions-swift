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
    
    public enum IncidentType: String {
        case Accident = "accident"
        case Congestion = "congestion"
        case Construction = "construction"
        case DisabledVehicle = "disabled_vehicle"
        case LaneRestriction = "lane_restriction"
        case MassTransit = "mass_transit"
        case Miscellaneous = "miscellaneous"
        case OtherNews = "other_news"
        case PlannedEvent = "planned_event"
        case RoadClosure = "road_closure"
        case RoadHazard = "road_hazard"
        case Weather = "weather"
        
        case Unknown = "<<unknown type>>"
    }
    
    /// Incident identifier
    public var identifier: String
    /// The kind of an incident
    public var type: IncidentType
    var rawType: String
    /// Short description of an incident. May be used as an additional info.
    public var description: String
    /// Date when incident item was created. Uses ISO8601 format
    public var creationTime: Date
    /// Date when incident happened. Uses ISO8601 format
    public var startTime: Date
    /// Date when incident shall end. Uses ISO8601 format
    public var endTime: Date
    /// Shows severity of an incident. May be not available for all incident types.
    public var impact: String?
    /// Provides additional classification of an incident. May be not available for all incident types.
    public var subtype: String?
    /// Breif description of the subtype. May be not available for all incident types and is not available if `subtype` is `nil`
    public var subtypeDescription: String?
    /// Contains list of ISO 14819-2:2013 codes
    ///
    /// See https://www.iso.org/standard/59231.html for details
    public var alertCodes: [Int]
    /// A list of lane indices, affected by the incident
    public var lanesBlocked: [Int]
    /// The range of segments within the overall leg, where the incident spans.
    public var shapeIndexRange: Range<Int>
    
    public init(identifier: String,
                type: IncidentType,
                description: String,
                creationTime: Date,
                startTime: Date,
                endTime: Date,
                impact: String?,
                subtype: String?,
                subtypeDescription: String?,
                alertCodes: [Int],
                lanesBlocked: [Int],
                shapeIndexRange: Range<Int>) {
        self.identifier = identifier
        self.type = type
        self.rawType = type.rawValue
        self.description = description
        self.creationTime = creationTime
        self.startTime = startTime
        self.endTime = endTime
        self.impact = impact
        self.subtype = subtype
        self.subtypeDescription = subtypeDescription
        self.alertCodes = alertCodes
        self.lanesBlocked = lanesBlocked
        self.shapeIndexRange = shapeIndexRange
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let formatter = ISO8601DateFormatter()
        
        identifier = try container.decode(String.self, forKey: .identifier)
        rawType = try container.decode(String.self, forKey: .type)
        if let incidentType = IncidentType(rawValue: rawType) {
            type = incidentType
        } else {
            type = .Unknown
        }
        description = try container.decode(String.self, forKey: .description)
        
        if let date = formatter.date(from: try container.decode(String.self, forKey: .creationTime)) {
            creationTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationTime,
                                                   in: container,
                                                   debugDescription: "`Intersection.creationTime` is encoded with invalid format.")
        }
        if let date = formatter.date(from: try container.decode(String.self, forKey: .startTime)) {
            startTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .startTime,
                                                   in: container,
                                                   debugDescription: "`Intersection.startTime` is encoded with invalid format.")
        }
        if let date = formatter.date(from: try container.decode(String.self, forKey: .endTime)) {
            endTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .endTime,
                                                   in: container,
                                                   debugDescription: "`Intersection.endTime` is encoded with invalid format.")
        }
        
        impact = try container.decodeIfPresent(String.self, forKey: .impact)
        subtype = try container.decodeIfPresent(String.self, forKey: .subtype)
        subtypeDescription = try container.decodeIfPresent(String.self, forKey: .subtypeDescription)
        alertCodes = try container.decode([Int].self, forKey: .alertCodes)
        lanesBlocked = try container.decode([Int].self, forKey: .lanesBlocked)
        
        let geometryIndexStart = try container.decode(Int.self, forKey: .geometryIndexStart)
        let geometryIndexEnd = try container.decode(Int.self, forKey: .geometryIndexEnd)
        shapeIndexRange = geometryIndexStart..<geometryIndexEnd
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = ISO8601DateFormatter()
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(rawType, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(formatter.string(from: creationTime), forKey: .creationTime)
        try container.encode(formatter.string(from: startTime), forKey: .startTime)
        try container.encode(formatter.string(from: endTime), forKey: .endTime)
        try container.encodeIfPresent(impact, forKey: .impact)
        try container.encodeIfPresent(subtype, forKey: .subtype)
        try container.encodeIfPresent(subtypeDescription, forKey: .subtypeDescription)
        try container.encode(alertCodes, forKey: .alertCodes)
        try container.encode(lanesBlocked, forKey: .lanesBlocked)
        try container.encode(shapeIndexRange.lowerBound, forKey: .geometryIndexStart)
        try container.encode(shapeIndexRange.upperBound, forKey: .geometryIndexEnd)
    }
}
