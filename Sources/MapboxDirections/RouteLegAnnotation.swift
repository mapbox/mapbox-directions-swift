
import Foundation

struct RouteLegAnnotation {
    var segmentDistances: [CLLocationDistance]?
    var expectedSegmentTravelTimes: [TimeInterval]?
    var segmentSpeeds: [CLLocationSpeed]?
    var segmentCongestionLevels: [CongestionLevel]?
    var segmentMaximumSpeedLimits: [Measurement<UnitSpeed>?]?
}

extension RouteLegAnnotation: Codable {
    private enum CodingKeys: String, CodingKey {
        case segmentDistances = "distance"
        case expectedSegmentTravelTimes = "duration"
        case segmentSpeeds = "speed"
        case segmentCongestionLevels = "congestion"
        case segmentMaximumSpeedLimits = "maxspeed"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        segmentDistances = try container.decodeIfPresent([CLLocationDistance].self, forKey: .segmentDistances)
        expectedSegmentTravelTimes = try container.decodeIfPresent([TimeInterval].self, forKey: .expectedSegmentTravelTimes)
        segmentSpeeds = try container.decodeIfPresent([CLLocationSpeed].self, forKey: .segmentSpeeds)
        segmentCongestionLevels = try container.decodeIfPresent([CongestionLevel].self, forKey: .segmentCongestionLevels)
        
        if let speedLimitDescriptors = try container.decodeIfPresent([SpeedLimitDescriptor].self, forKey: .segmentMaximumSpeedLimits) {
            segmentMaximumSpeedLimits = speedLimitDescriptors.map { Measurement<UnitSpeed>(speedLimitDescriptor: $0) }
        } else {
            segmentMaximumSpeedLimits = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(segmentDistances, forKey: .segmentDistances)
        try container.encodeIfPresent(expectedSegmentTravelTimes, forKey: .expectedSegmentTravelTimes)
        try container.encodeIfPresent(segmentSpeeds, forKey: .segmentSpeeds)
        try container.encodeIfPresent(segmentCongestionLevels, forKey: .segmentCongestionLevels)
        
        if let speedLimitDescriptors = segmentMaximumSpeedLimits?.map({ SpeedLimitDescriptor(speed: $0) }) {
            try container.encode(speedLimitDescriptors, forKey: .segmentMaximumSpeedLimits)
        }
    }
}
