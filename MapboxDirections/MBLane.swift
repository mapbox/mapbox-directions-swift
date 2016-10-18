import Foundation

@objc(MBLaneIndication)
public enum LaneIndication: Int, CustomStringConvertible {
    
    /**
     An indication indicating a turn to the left.
     */
    case Left
    
    /**
     An indication indicating a turn to the right.
     */
    case Right
    
    /**
     An indication indicating a sharp turn to the left.
     */
    case SharpLeft
    
    /**
     An indication indicating a sharp turn to the right.
     */
    case SharpRight
    
    /**
     An indication indicating a slight turn to the left.
     */
    case SlightLeft
    
    /**
     An indication indicating a slight turn to the right.
     */
    case SlightRight
    
    /**
     No dedicated indication is shown.
     */
    case StraightAhead
    
    /**
     An indication signaling the possibility to reverse
    */
    case Uturn
    
    /**
     No dedicated indication is shown.
    */
    case None
    
    public init?(description: String) {
        let type: LaneIndication
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
            type = .StraightAhead
        case "uturn":
            type = .Uturn
        case "none":
            type = .None
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
        case .StraightAhead:
            return "straight"
        case .Uturn:
            return "uturn"
        case .None:
            return "None"
        }
    }
}

@objc(MBLane)
public class Lane: NSObject {
    
    public let indications: [LaneIndication]
    
    public var indicationValues: [NSValue] {
        return indications.map { $0.rawValue as NSValue }
    }
    
    internal init(indications: [LaneIndication]) {
        self.indications = indications
    }
    
    internal convenience init(json: JSONDictionary) {
        let indicationsJSON = json["indications"] as! [String]
        let indications = indicationsJSON.map{ LaneIndication(description: $0)! }
        
        self.init(indications: indications)
    }
}
