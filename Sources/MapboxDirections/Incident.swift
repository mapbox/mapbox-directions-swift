import Foundation

/**
 `Incident` describes any corresponding event, used for annotating the route.
 */
public struct Incident: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case description = "description"
        case creationDate = "creation_time"
        case startDate = "start_time"
        case endDate = "end_time"
        case impact = "impact"
        case subtype = "sub_type"
        case subtypeDescription = "sub_type_description"
        case alertCodes = "alertc_codes"
        case lanesBlocked = "lanes_blocked"
        case geometryIndexStart = "geometry_index_start"
        case geometryIndexEnd = "geometry_index_end"
    }
    
    /// Defines known types of incidents.
    ///
    /// Each incident may or may not have specific set of data, depending on it's `kind`
    public enum Kind: String {
        /// Accident
        case accident = "accident"
        /// Congestion
        case congestion = "congestion"
        /// Construction
        case construction = "construction"
        /// Disabled vehicle
        case disabledVehicle = "disabled_vehicle"
        /// Lane restriction
        case laneRestriction = "lane_restriction"
        /// Mass transit
        case massTransit = "mass_transit"
        /// Miscellaneous
        case miscellaneous = "miscellaneous"
        /// Other news
        case otherNews = "other_news"
        /// Planned event
        case plannedEvent = "planned_event"
        /// Road closure
        case roadClosure = "road_closure"
        /// Road hazard
        case roadHazard = "road_hazard"
        /// Weather
        case weather = "weather"
    }

    /// Represents the impact of the incident on local traffic.
    public enum Impact: String, Codable {
        /// Unknown impact
        case unknown
        /// Critical impact
        case critical
        /// Major impact
        case major
        /// Minor impact
        case minor
        /// Low impact
        case low
    }

    /// Incident identifier
    public var identifier: String
    /// The kind of an incident
    ///
    /// This value is set to `nil` if `kind` value is not supported.
    public var kind: Kind? {
        return Kind(rawValue: rawKind)
    }
    var rawKind: String
    /// Short description of an incident. May be used as an additional info.
    public var description: String
    /// Date when incident item was created.
    public var creationDate: Date
    /// Date when incident happened.
    public var startDate: Date
    /// Date when incident shall end.
    public var endDate: Date
    /// Shows severity of an incident. May be not available for all incident types.
    public var impact: Impact?
    /// Provides additional classification of an incident. May be not available for all incident types.
    public var subtype: String?
    /// Breif description of the subtype. May be not available for all incident types and is not available if `subtype` is `nil`
    public var subtypeDescription: String?
    /// Contains list of ISO 14819-2:2013 codes
    ///
    /// See https://www.iso.org/standard/59231.html for details
    public var alertCodes: Set<Int>
    /// A list of lanes, affected by the incident
    ///
    /// `nil` value indicates that lanes data is not available
    public var lanesBlocked: BlockedLanes?
    /// The range of segments within the overall leg, where the incident spans.
    public var shapeIndexRange: Range<Int>
    
    public init(identifier: String,
                type: Kind,
                description: String,
                creationDate: Date,
                startDate: Date,
                endDate: Date,
                impact: Impact?,
                subtype: String?,
                subtypeDescription: String?,
                alertCodes: Set<Int>,
                lanesBlocked: BlockedLanes?,
                shapeIndexRange: Range<Int>) {
        self.identifier = identifier
        self.rawKind = type.rawValue
        self.description = description
        self.creationDate = creationDate
        self.startDate = startDate
        self.endDate = endDate
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
        rawKind = try container.decode(String.self, forKey: .type)
        
        description = try container.decode(String.self, forKey: .description)
        
        if let date = formatter.date(from: try container.decode(String.self, forKey: .creationDate)) {
            creationDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .creationDate,
                                                   in: container,
                                                   debugDescription: "`Intersection.creationTime` is encoded with invalid format.")
        }
        if let date = formatter.date(from: try container.decode(String.self, forKey: .startDate)) {
            startDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .startDate,
                                                   in: container,
                                                   debugDescription: "`Intersection.startTime` is encoded with invalid format.")
        }
        if let date = formatter.date(from: try container.decode(String.self, forKey: .endDate)) {
            endDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .endDate,
                                                   in: container,
                                                   debugDescription: "`Intersection.endTime` is encoded with invalid format.")
        }
        
        impact = try container.decodeIfPresent(Impact.self, forKey: .impact)
        subtype = try container.decodeIfPresent(String.self, forKey: .subtype)
        subtypeDescription = try container.decodeIfPresent(String.self, forKey: .subtypeDescription)
        alertCodes = try container.decode(Set<Int>.self, forKey: .alertCodes)
        
        lanesBlocked = try container.decodeIfPresent(BlockedLanes.self, forKey: .lanesBlocked)
        
        let geometryIndexStart = try container.decode(Int.self, forKey: .geometryIndexStart)
        let geometryIndexEnd = try container.decode(Int.self, forKey: .geometryIndexEnd)
        shapeIndexRange = geometryIndexStart..<geometryIndexEnd
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = ISO8601DateFormatter()
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(rawKind, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(formatter.string(from: creationDate), forKey: .creationDate)
        try container.encode(formatter.string(from: startDate), forKey: .startDate)
        try container.encode(formatter.string(from: endDate), forKey: .endDate)
        try container.encodeIfPresent(impact, forKey: .impact)
        try container.encodeIfPresent(subtype, forKey: .subtype)
        try container.encodeIfPresent(subtypeDescription, forKey: .subtypeDescription)
        try container.encode(alertCodes, forKey: .alertCodes)
        try container.encodeIfPresent(lanesBlocked, forKey: .lanesBlocked)
        try container.encode(shapeIndexRange.lowerBound, forKey: .geometryIndexStart)
        try container.encode(shapeIndexRange.upperBound, forKey: .geometryIndexEnd)
    }
}
