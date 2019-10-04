import Foundation
import CoreLocation


/**
 A `Tracepoint` represents a location matched to the road network.
 */

public class Tracepoint: Waypoint {
    
    /**
     Number of probable alternative matchings for this tracepoint. A value of zero indicates that this point was matched unambiguously.
     */
    open var alternateCount: Int = NSNotFound
    
    private enum CodingKeys: String, CodingKey {
        case alternateCount
    }
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int?, name: String?) {
        self.alternateCount = alternateCount ?? NSNotFound
        super.init(coordinate: coordinate, name: name)
    }

    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alternateCount = try container.decode(Int.self, forKey: .alternateCount)
    }

    
//    // MARK: Objective-C equality
//    open override func isEqual(_ object: Any?) -> Bool {
//        guard let opts = object as? Tracepoint else { return false }
//        return isEqual(to: opts)
//    }
//
//
//    open func isEqual(to other: Tracepoint?) -> Bool {
//        guard let other = other else { return false }
//        return super.isEqual(to: other) && type(of: self) == type(of: other) &&
//            alternateCount == other.alternateCount
//    }
}

extension Tracepoint { //Equatable
    public static func ==(lhs: Tracepoint, rhs: Tracepoint) -> Bool {
        let superEquals = (lhs as Waypoint == rhs as Waypoint)
        return superEquals && lhs.alternateCount == rhs.alternateCount
    }
}
