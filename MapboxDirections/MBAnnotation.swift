import Foundation

@objc(AnnotationType)
public enum SegmentAttribute: Int, CustomStringConvertible {
    
    case distance
    
    case expectedTravelTime
    
    case openStreetMapNodeIdentifier
    
    case speed
    
    
    public init?(description: String) {
        let type: SegmentAttribute
        switch description {
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
        case .distance:
            return "distance"
        case .expectedTravelTime:
            return "duration"
        case .openStreetMapNodeIdentifier:
            return "nodes"
        case .speed:
            return "speed"
        }
    }

}
