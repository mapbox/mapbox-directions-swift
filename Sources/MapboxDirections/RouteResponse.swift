import Foundation

struct RouteResponse {
    var code: String?
    var message: String?
    var error: String?
    let uuid: String?
    let routes: [Route]?
    let waypoints: [Route.Waypoint]?
}

extension RouteResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case error
        case uuid
        case routes
        case waypoints
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try container.decodeIfPresent(String.self, forKey: .code)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
        self.uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        
        // Decode waypoints from the response and update their names according to the waypoints from DirectionsOptions.waypoints.
        let decodedWaypoints = try container.decodeIfPresent([Route.Waypoint].self, forKey: .waypoints)
        if let decodedWaypoints = decodedWaypoints, let options = decoder.userInfo[.options] as? DirectionsOptions {
            // The response lists the same number of tracepoints as the waypoints in the request, whether or not a given waypoint is leg-separating.
            waypoints = zip(decodedWaypoints, options.waypoints).map { (pair) -> Route.Waypoint in
                var (decodedWaypoint, waypointInOptions) = pair
                if /*waypointInOptions.separatesLegs, */let name = waypointInOptions.name?.nonEmptyString {
                    decodedWaypoint.name = name
                }
                return decodedWaypoint
            }
        } else {
            waypoints = decodedWaypoints
        }
        
        if let routes = try container.decodeIfPresent([Route].self, forKey: .routes) {
            // Postprocess each route.
            var legSeparators = waypoints?.compactMap { $0 }
            if let options = decoder.userInfo[.options] as? DirectionsOptions, let waypoints = waypoints {
                // select first, last and all other waypoints which separate legs.
                var optionsLegSeparators = options.legSeparators
                legSeparators = zip(waypoints, options.waypoints).compactMap { (pair) -> Route.Waypoint? in
                    let (decodedWaypoint, waypointInOptions) = pair
                    if decodedWaypoint == waypoints.last! ||
                        decodedWaypoint == waypoints.first! {
                        return decodedWaypoint
                    }
                    
                    guard let index = optionsLegSeparators.firstIndex(of: waypointInOptions) else {
                        return nil
                    }
                    optionsLegSeparators.remove(at: index)
                    return decodedWaypoint
                }
            }
            
            for route in routes {
                route.routeIdentifier = uuid
                // Imbue each route’s legs with the waypoints refined above.
                // TODO: Filter these waypoints by whether they separate legs, based on the options, if given.
                if let legSeparators = legSeparators {
                    route.legSeparators = legSeparators//waypoints
                }
            }
            self.routes = routes
        } else {
            routes = nil
        }
    }
}
