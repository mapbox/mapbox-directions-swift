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
                scope.insert(.sharpRight)
            case "right":
                scope.insert(.right)
            case "slight right":
                scope.insert(.slightRight)
            case "straight":
                scope.insert(.straightAhead)
            case "slight left":
                scope.insert(.slightLeft)
            case "sharp left":
                scope.insert(.sharpLeft)
            case "left":
                scope.insert(.left)
            case "uturn":
                scope.insert(.uTurn)
            case "none":
                break
            default:
                return nil
            }
        }
        self.init(rawValue: scope.rawValue)
    }
    
    public var description: String {
        var descriptions: [String] = []
        if contains(LaneIndication.sharpRight) {
            descriptions.append("sharp right")
        }
        if contains(LaneIndication.sharpRight) {
            descriptions.append("sharp right")
        }
        if contains(LaneIndication.slightRight) {
            descriptions.append("slight right")
        }
        if contains(LaneIndication.straightAhead) {
            descriptions.append("straight")
        }
        if contains(LaneIndication.slightLeft) {
            descriptions.append("slight left")
        }
        if contains(LaneIndication.left) {
            descriptions.append("left")
        }
        if contains(LaneIndication.sharpLeft) {
            descriptions.append("sharp left")
        }
        if contains(LaneIndication.uTurn) {
            descriptions.append("uturn")
        }
        return descriptions.joined(separator: ",")
    }
}
