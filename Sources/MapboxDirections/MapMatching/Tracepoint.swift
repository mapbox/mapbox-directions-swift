import Foundation
import Turf

/**
 A `Tracepoint` represents a location matched to the road network.
 */
public class Tracepoint: Waypoint {
    /**
     Number of probable alternative matchings for this tracepoint. A value of zero indicates that this point was matched unambiguously.
     */
    public let countOfAlternatives: Int
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case countOfAlternatives = "alternatives_count"
    }
    
    init(coordinate: LocationCoordinate2D, countOfAlternatives: Int, name: String?) {
        self.countOfAlternatives = countOfAlternatives
        super.init(coordinate: coordinate, name: name)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countOfAlternatives = try container.decode(Int.self, forKey: .countOfAlternatives)
        try super.init(from: decoder)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countOfAlternatives, forKey: .countOfAlternatives)
        try super.encode(to: encoder)
    }
}

extension Tracepoint { //Equatable
    public static func ==(lhs: Tracepoint, rhs: Tracepoint) -> Bool {
        let superEquals = (lhs as Waypoint == rhs as Waypoint)
        return superEquals && lhs.countOfAlternatives == rhs.countOfAlternatives
    }
}
