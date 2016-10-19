import Foundation

public typealias LaneIndication = MBLaneIndication

extension LaneIndication: CustomStringConvertible {
    
    public init?(descriptions: [String]) {
        var scope: LaneIndication = []
        for description in descriptions {
            switch description {
            case "left":
                scope.insert(.Left)
            case "right":
                scope.insert(.Right)
            case "sharp left":
                scope.insert(.SharpLeft)
            case "sharp right":
                scope.insert(.SharpRight)
            case "slight left":
                scope.insert(.SlightLeft)
            case "slight right":
                scope.insert(.SlightRight)
            case "straight":
                scope.insert(.StraightAhead)
            case "uturn":
                scope.insert(.Uturn)
            case "none":
                scope.insert(.None)
            default:
                return nil
            }
        }
        self.init(rawValue: scope.rawValue)
    }
    
    public var description: String {
        var descriptions: [String] = []
        if contains(LaneIndication.Left) {
            descriptions.append("Left")
        }
        if contains(LaneIndication.Right) {
            descriptions.append("right")
        }
        if contains(LaneIndication.SharpLeft) {
            descriptions.append("sharp left")
        }
        if contains(LaneIndication.SharpRight) {
            descriptions.append("sharp right")
        }
        if contains(LaneIndication.SlightLeft) {
            descriptions.append("slight left")
        }
        if contains(LaneIndication.SlightRight) {
            descriptions.append("slight right")
        }
        if contains(LaneIndication.StraightAhead) {
            descriptions.append("straight")
        }
        if contains(LaneIndication.Uturn) {
            descriptions.append("uturn")
        }
        if contains(LaneIndication.None) {
            descriptions.append("none")
        }
        return descriptions.joinWithSeparator(",")
    }
}

@objc(MBLane)
public class Lane: NSObject {
    
    public let indications: LaneIndication
    
    internal init(indications: LaneIndication) {
        self.indications = indications
    }
    
    internal convenience init(json: JSONDictionary) {
        let indicationsJSON = json["indications"] as! [String]
        let indications = LaneIndication(descriptions: indicationsJSON)
        
        self.init(indications: indications!)
    }
}
