import Foundation

public struct MapMatchingResponse {
    public var code: String
    public var routes : [Route]?
    public var waypoints: [Waypoint]
}

extension MapMatchingResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case code
        case matches = "matchings"
        case tracepoints
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        routes = try container.decodeIfPresent([Route].self, forKey: .matches)
        
        // Decode waypoints from the response and update their names according to the waypoints from DirectionsOptions.waypoints.
        // Map Matching API responses can contain null tracepoints. Null tracepoints can’t correspond to waypoints, so they’re irrelevant to the decoded structure.
        let decodedWaypoints = try container.decode([Waypoint?].self, forKey: .tracepoints).compactMap { $0 }
        if let options = decoder.userInfo[.options] as? DirectionsOptions {
            // The response lists the same number of tracepoints as the waypoints in the request, whether or not a given waypoint is leg-separating.
            waypoints = zip(decodedWaypoints, options.waypoints).map { (pair) -> Waypoint in
                let (decodedWaypoint, waypointInOptions) = pair
                let waypoint = Waypoint(coordinate: decodedWaypoint.coordinate, coordinateAccuracy: waypointInOptions.coordinateAccuracy, name: waypointInOptions.name?.nonEmptyString ?? decodedWaypoint.name)
                waypoint.separatesLegs = waypointInOptions.separatesLegs
                return waypoint
            }
            waypoints.first?.separatesLegs = true
            waypoints.last?.separatesLegs = true
        } else {
            waypoints = decodedWaypoints
        }
        
        if let routes = try container.decodeIfPresent([Route].self, forKey: .matches) {
            // Postprocess each route.
            for route in routes {
                // Imbue each route’s legs with the leg-separating waypoints refined above.
                route.legSeparators = waypoints.filter { $0.separatesLegs }
            }
            self.routes = routes
        } else {
            routes = nil
        }
    }
}
