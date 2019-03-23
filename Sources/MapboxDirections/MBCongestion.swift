import Foundation

/**
 A `CongestionLevel` indicates the level of traffic congestion along a road segment relative to the normal flow of traffic along that segment. You can color-code a route line according to the congestion level along each segment of the route.
 */
@objc(MBCongestionLevel)
public enum CongestionLevel: Int, CustomStringConvertible {
    /**
     There is not enough data to determine the level of congestion along the road segment.
     */
    case unknown
    
    /**
     The road segment has little or no congestion. Traffic is flowing smoothly.
     
     Low congestion levels are conventionally highlighted in green or not highlighted at all.
     */
    case low
    
    /**
     The road segment has moderate, stop-and-go congestion. Traffic is flowing but speed is impeded.
     
     Moderate congestion levels are conventionally highlighted in yellow.
     */
    case moderate
    
    /**
     The road segment has heavy, bumper-to-bumper congestion. Traffic is barely moving.
     
     Heavy congestion levels are conventionally highlighted in orange.
     */
    case heavy
    
    /**
     The road segment has severe congestion. Traffic may be completely stopped.
     
     Severe congestion levels are conventionally highlighted in red.
     */
    case severe
    
    public init?(description: String) {
        let level: CongestionLevel
        switch description {
        case "unknown":
            level = .unknown
        case "low":
            level = .low
        case "moderate":
            level = .moderate
        case "heavy":
            level = .heavy
        case "severe":
            level = .severe
        default:
            return nil
        }
        self.init(rawValue: level.rawValue)
    }
    
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .low:
            return "low"
        case .moderate:
            return "moderate"
        case .heavy:
            return "heavy"
        case .severe:
            return "severe"
        }
    }
}
