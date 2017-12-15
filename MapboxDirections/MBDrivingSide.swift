import Foundation

/**
 A `DrivingSide` indicates which side of the road cars and traffic flow.
 */
@objc(MBDrivingSide)
public enum DrivingSide: Int, CustomStringConvertible, Codable {
    /**
     Indicates driving occurs on the `left` side.
     */
    case left
    
    /**
     Indicates driving occurs on the `right` side.
     */
    case right
    
    public init?(description: String) {
        var side: DrivingSide
        switch description {
        case "left":
            side = .left
        case "right":
            side = .right
        default:
            return nil
        }
        
        self.init(rawValue: side.rawValue)
    }
    
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        }
    }
}

