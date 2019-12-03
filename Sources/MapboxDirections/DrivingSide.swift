import Foundation

/**
 A `DrivingSide` indicates which side of the road cars and traffic flow.
 */
public enum DrivingSide: String, Codable {
    /**
     Indicates driving occurs on the `left` side.
     */
    case left

    /**
     Indicates driving occurs on the `right` side.
     */
    case right
    
    static let `default` = DrivingSide.right
}
