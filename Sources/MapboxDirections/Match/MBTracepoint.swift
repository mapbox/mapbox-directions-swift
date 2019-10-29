import Foundation
import CoreLocation


/**
 A `Tracepoint` represents a location matched to the road network.
 */

public class Tracepoint: Waypoint {
    
    /**
     Number of probable alternative matchings for this tracepoint. A value of zero indicates that this point was matched unambiguously.
     */
    public let alternateCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case alternateCount = "alternatives_count"
    }
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int?, name: String?) {
        self.alternateCount = alternateCount ?? NSNotFound
        super.init(coordinate: coordinate, name: name)
    }

    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alternateCount = try container.decode(Int.self, forKey: .alternateCount)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alternateCount, forKey: .alternateCount)
        try super.encode(to: encoder)
    }
}

extension Tracepoint { //Equatable
    public static func ==(lhs: Tracepoint, rhs: Tracepoint) -> Bool {
        let superEquals = (lhs as Waypoint == rhs as Waypoint)
        return superEquals && lhs.alternateCount == rhs.alternateCount
    }
}
