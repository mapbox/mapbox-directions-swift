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
    }
    
    /// Defines a lane affected by the `Incident`
    ///
    /// Each `Incident` may have arbitrary of affected lanes
    public enum BlockedLane: String, Codable {
        /// Left lane
        case left = "LEFT"
        /// Left and center lanes
        case leftCenter = "LEFT CENTER"
        /// Left turn lane
        case leftTurnLane = "LEFT TURN LANE"
        /// Center lane
        case center = "CENTER"
        /// Right lane
        case right = "RIGHT"
        /// Right and center lanes
        case rightCenter = "RIGHT CENTER"
        /// Right turn lane
        case rightTurnLane = "RIGHT TURN LANE"
        /// High occupancy vehicle lane
        case highOccupancyVehicle = "HOV"
        /// Side lane
        case side = "SIDE"
        /// Shoulder lane
        case shoulder = "SHOULDER"
        /// Median lane
        case median = "MEDIAN"
        /// 1st Lane.
        ///
        /// Mind the driving side.
        case lane1 = "1"
        /// 2nd Lane.
        ///
        /// Mind the driving side.
        case lane2 = "2"
        /// 3rd Lane.
        ///
        /// Mind the driving side.
        case lane3 = "3"
        /// 4th Lane.
        ///
        /// Mind the driving side.
        case lane4 = "4"
        /// 5th Lane.
        ///
        /// Mind the driving side.
        case lane5 = "5"
        /// 6th Lane.
        ///
        /// Mind the driving side.
        case lane6 = "6"
        /// 7th Lane.
        ///
        /// Mind the driving side.
        case lane7 = "7"
        /// 8th Lane.
        ///
        /// Mind the driving side.
        case lane8 = "8"
        /// 9th Lane.
        ///
        /// Mind the driving side.
        case lane9 = "9"
        /// 10th Lane.
        ///
        /// Mind the driving side.
        case lane10 = "10"
    }
    
    /// Incident identifier
    public var identifier: String
    /// The kind of an incident
    ///
    /// This value is set to `nil` if `kind` value is not supported.
    public var kind: Kind?
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
    public var impact: String?
    /// Provides additional classification of an incident. May be not available for all incident types.
    public var subtype: String?
    /// Breif description of the subtype. May be not available for all incident types and is not available if `subtype` is `nil`
    public var subtypeDescription: String?
    /// Contains list of ISO 14819-2:2013 codes
    ///
    /// See https://www.iso.org/standard/59231.html for details
    public var alertCodes: Set<Int>
    /// A list of lanes indices, affected by the incident
    ///
    /// `nil` value indicates that such lane identifier is not supported
    public var lanesBlocked: Set<BlockedLane?>
    var rawLanesBlocked: Set<String>
    /// The range of segments within the overall leg, where the incident spans.
    public var shapeIndexRange: Range<Int>
    
    public init(identifier: String,
                type: Kind,
                description: String,
                creationDate: Date,
                startDate: Date,
                endDate: Date,
                impact: String?,
                subtype: String?,
                subtypeDescription: String?,
                alertCodes: Set<Int>,
                lanesBlocked: Set<BlockedLane>,
                shapeIndexRange: Range<Int>) {
        self.identifier = identifier
        self.kind = type
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
        self.rawLanesBlocked = Set(lanesBlocked.map { $0.rawValue })
        self.shapeIndexRange = shapeIndexRange
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let formatter = ISO8601DateFormatter()
        
        identifier = try container.decode(String.self, forKey: .identifier)
        rawKind = try container.decode(String.self, forKey: .type)
        kind = Kind(rawValue: rawKind)
        
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
        
        impact = try container.decodeIfPresent(String.self, forKey: .impact)
        subtype = try container.decodeIfPresent(String.self, forKey: .subtype)
        subtypeDescription = try container.decodeIfPresent(String.self, forKey: .subtypeDescription)
        alertCodes = try container.decode(Set<Int>.self, forKey: .alertCodes)
        
        rawLanesBlocked = try container.decode(Set<String>.self, forKey: .lanesBlocked)
        lanesBlocked = rawLanesBlocked.reduce(into: Set<BlockedLane?>()) { $0.insert(BlockedLane(rawValue: $1)) }
        
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
        try container.encode(rawLanesBlocked, forKey: .lanesBlocked)
        try container.encode(shapeIndexRange.lowerBound, forKey: .geometryIndexStart)
        try container.encode(shapeIndexRange.upperBound, forKey: .geometryIndexEnd)
    }
}
