import Foundation

@objc(AnnotationType)
public enum AnnotationType: Int, CustomStringConvertible {

    case congestionLevel
    
    case distance
    
    case expectedTravelTime
    
    case openStreetMapNodeIdentifier
    
    case speed
    
    
    public init?(description: String) {
        let type: AnnotationType
        switch description {
        case "congestionLevel":
            type = .congestionLevel
        case "distance":
            type = .distance
        case "expectedTravelTime":
            type = .expectedTravelTime
        case "openStreetMapNodeIdentifier":
            type = .openStreetMapNodeIdentifier
        case "speed":
            type = .speed
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .congestionLevel:
            return "congestionLevel"
        case .distance:
            return "expectedTravelTime"
        case .expectedTravelTime:
            return "duration"
        case .openStreetMapNodeIdentifier:
            return "openStreetMapNodeIdentifier"
        case .speed:
            return "speed"
        }
    }

}

@objc(MBCongestionLevel)
public enum CongestionType: Int, CustomStringConvertible {
    
    case unknown
    
    case low
    
    case moderate
    
    case heavy
    
    case severe
    
    
    public init?(description: String) {
        let type: CongestionType
        switch description {
        case "unknown":
            type = .unknown
        case "low":
            type = .low
        case "moderate":
            type = .moderate
        case "heavy":
            type = .heavy
        case "severe":
            type = .severe
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
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
