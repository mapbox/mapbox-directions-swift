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
            case "left":
                scope.insert(.left)
            case "sharp left":
                scope.insert(.sharpLeft)
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
        if isEmpty {
            return "none"
        }
        
        var descriptions: [String] = []
        if contains(.sharpRight) {
            descriptions.append("sharp right")
        }
        if contains(.right) {
            descriptions.append("right")
        }
        if contains(.slightRight) {
            descriptions.append("slight right")
        }
        if contains(.straightAhead) {
            descriptions.append("straight")
        }
        if contains(.slightLeft) {
            descriptions.append("slight left")
        }
        if contains(.left) {
            descriptions.append("left")
        }
        if contains(.sharpLeft) {
            descriptions.append("sharp left")
        }
        if contains(.uTurn) {
            descriptions.append("uturn")
        }
        return descriptions.joined(separator: ",")
    }
}
