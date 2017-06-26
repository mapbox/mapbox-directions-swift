import Foundation

@objc(MBCongestionLevel)
public enum CongestionLevel: Int, CustomStringConvertible {
    case unknown
    case low
    case moderate
    case heavy
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
