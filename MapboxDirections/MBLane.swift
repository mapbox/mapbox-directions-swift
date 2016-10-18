import Foundation

public enum LaneIndicationType: Int, CustomStringConvertible {
    case Left
    
    case Right
    
    case SharpLeft
    
    case SharpRight
    
    case SlightLeft
    
    case SlightRight
    
    case Straight
    
    case Uturn
    
    public init?(description: String) {
        let type: LaneIndicationType
        switch description {
        case "left":
            type = .Left
        case "right":
            type = .Right
        case "sharp left":
            type = .SharpLeft
        case "sharp right":
            type = .SharpRight
        case "slight left":
            type = .SlightLeft
        case "slight right":
            type = .SlightRight
        case "straight":
            type = .Straight
        case "uturn":
            type = .Uturn
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .Left:
            return "left"
        case .Right:
            return "right"
        case .SharpLeft:
            return "sharp left"
        case .SharpRight:
            return "sharp right"
        case .SlightLeft:
            return "slight left"
        case .SlightRight:
            return "slight right"
        case .Straight:
            return "straight"
        case .Uturn:
            return "uturn"
        }
    }
}

public class Lane: NSObject {
    public var validTurn: Bool
    public var indications: [LaneIndicationType]
    
    internal init(validTurn: Bool, indications: [LaneIndicationType]) {
        self.validTurn = validTurn
        self.indications = indications
    }
    
    internal convenience init(json: JSONDictionary) {
        let validTurn = json["valid"] as! Bool
        let indicationsJSON = json["indications"] as! [String]
        let indications = indicationsJSON.map{ LaneIndicationType(description: $0)! }
        
        self.init(validTurn: validTurn, indications: indications)
    }
}
