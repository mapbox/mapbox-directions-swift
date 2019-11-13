import Foundation
import CoreLocation

public extension Match {
    /**
     A tracepoint represents a location matched to the road network.
     */
    struct Tracepoint: Matchpoint, Equatable {
        // MARK: Positioning the Waypoint
        
        /**
         The geographic coordinate of the waypoint, snapped to the road network.
         */
        public var coordinate: CLLocationCoordinate2D
        
        /**
         The straight-line distance from this waypoint to the corresponding waypoint in the `RouteOptions` or `MatchOptions` object.
         
         The requested waypoint is snapped to the road network. This property contains the straight-line distance from the original requested waypoint’s `DirectionsOptions.Waypoint.coordinate` property to the `coordinate` property.
         */
        public var correction: CLLocationDistance
        
        // MARK: Determining the Degree of Confidence
        
        /**
         Number of probable alternative matchings for this tracepoint. A value of zero indicates that this point was matched unambiguously.
         */
        public var countOfAlternatives: Int
    }
}

extension Match.Tracepoint: Codable {
    private enum CodingKeys: String, CodingKey {
        case coordinate = "location"
        case correction = "distance"
        case countOfAlternatives = "alternatives_count"
    }
}

extension Match.Tracepoint: CustomStringConvertible {
    public var description: String {
        return "<latitude: \(coordinate.latitude); longitude: \(coordinate.longitude)>"
    }
}
