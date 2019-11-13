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
                let (decodedWaypoint, waypointInOptions) = pair
                var waypoint = decodedWaypoint
                if waypointInOptions.separatesLegs, let name = waypointInOptions.name?.nonEmptyString {
                    waypoint.name = name
                }
                return waypoint
            }
        } else {
            waypoints = decodedWaypoints
        }
        
        if let routes = try container.decodeIfPresent([Route].self, forKey: .routes) {
            // Postprocess each route.
            for route in routes {
                route.routeIdentifier = uuid
                // Imbue each route’s legs with the waypoints refined above.
                // TODO: Filter these waypoints by whether they separate legs, based on the options, if given.
                if let waypoints = waypoints {
                    route.legSeparators = waypoints
                }
            }
            self.routes = routes
        } else {
            routes = nil
        }
    }
}
