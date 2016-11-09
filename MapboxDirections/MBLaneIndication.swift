import Foundation

public typealias LaneIndication = MBLaneIndication

extension LaneIndication: CustomStringConvertible {
    /**
     Creates a lane indication from the given description strings.
     */
    public init?(descriptions: [String]) {
        var scope: LaneIndication = []
        for description in descriptions {
            switch description {
            case "sharp right":
                scope.insert(.SharpRight)
            case "right":
                scope.insert(.Right)
            case "slight right":
                scope.insert(.SlightRight)
            case "straight":
                scope.insert(.StraightAhead)
            case "slight left":
                scope.insert(.SlightLeft)
            case "left":
                scope.insert(.Left)
            case "sharp left":
                scope.insert(.SharpLeft)
            case "uturn":
                scope.insert(.UTurn)
            case "none":
                break
            default:
                return nil
            }
        }
        self.init(rawValue: scope.rawValue)
    }
    
    public var description: String {
        if isEmpty {
            return "none"
        }
        
        var descriptions: [String] = []
        if contains(LaneIndication.SharpRight) {
            descriptions.append("sharp right")
        }
        if contains(LaneIndication.Right) {
            descriptions.append("right")
        }
        if contains(LaneIndication.SlightRight) {
            descriptions.append("slight right")
        }
        if contains(LaneIndication.StraightAhead) {
            descriptions.append("straight")
        }
        if contains(LaneIndication.SlightLeft) {
            descriptions.append("slight left")
        }
        if contains(LaneIndication.Left) {
            descriptions.append("left")
        }
        if contains(LaneIndication.SharpLeft) {
            descriptions.append("sharp left")
        }
        if contains(LaneIndication.UTurn) {
            descriptions.append("uturn")
        }
        return descriptions.joinWithSeparator(",")
    }
}
