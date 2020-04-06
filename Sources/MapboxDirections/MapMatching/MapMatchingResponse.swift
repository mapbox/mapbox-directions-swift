import Foundation

class MapMatchingResponse: Decodable {
    var code: String
    var routes : [Route]?
    var waypoints: [Match.Waypoint]
    
    private enum CodingKeys: String, CodingKey {
        case code
        case matches = "matchings"
        case tracepoints
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        routes = try container.decodeIfPresent([Route].self, forKey: .matches)
        
        // Decode waypoints from the response and update their names according to the waypoints from DirectionsOptions.waypoints.
        let decodedWaypoints = try container.decode([Match.Waypoint].self, forKey: .tracepoints)
        if let options = decoder.userInfo[.options] as? DirectionsOptions {
            // The response lists the same number of tracepoints as the waypoints in the request, whether or not a given waypoint is leg-separating.
            waypoints = zip(decodedWaypoints, options.waypoints).map { (pair) -> Match.Waypoint in
                var (decodedWaypoint, waypointInOptions) = pair
                if /*waypointInOptions.separatesLegs,*/ let name = waypointInOptions.name?.nonEmptyString {
                    decodedWaypoint.name = name
                }
                return decodedWaypoint
            }
        } else {
            waypoints = decodedWaypoints
        }
        
        if let routes = try container.decodeIfPresent([Route].self, forKey: .matches) {
            // Postprocess each route.
            
            var legSeparators = waypoints
            if let options = decoder.userInfo[.options] as? DirectionsOptions {
                var optionsLegSeparators = options.legSeparators
                legSeparators = zip(waypoints, options.waypoints).compactMap { (pair) -> Match.Waypoint? in
                    let (decodedWaypoint, waypointInOptions) = pair
                    
                    guard let index = optionsLegSeparators.firstIndex(of: waypointInOptions) else {
                        return nil
                    }
                    optionsLegSeparators.remove(at: index)
                    return decodedWaypoint
                }
            }
            
            for route in routes {
                // Imbue each route’s legs with the leg-separating waypoints refined above.
                // TODO: Filter these waypoints by whether they separate legs, based on the options, if given.
                route.legSeparators = legSeparators// waypoints
            }
            self.routes = routes
        } else {
            routes = nil
        }
    }
}
