import Foundation

struct RouteResponse {
    var code: String?
    var message: String?
    var error: String?
    let uuid: String?
    let routes: [Route]?
    let waypoints: [Waypoint]?
 
    init(code: String?, message: String?, error: String?) {
        self.code = code
        self.message = message
        self.error = error
        self.uuid = nil
        self.routes = nil
        self.waypoints = nil
    }
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
        let decodedWaypoints = try container.decodeIfPresent([Waypoint].self, forKey: .waypoints)
        if let decodedWaypoints = decodedWaypoints, let options = decoder.userInfo[.options] as? DirectionsOptions {
            // The response lists the same number of tracepoints as the waypoints in the request, whether or not a given waypoint is leg-separating.
            waypoints = zip(decodedWaypoints, options.waypoints).map { (pair) -> Waypoint in
                let (decodedWaypoint, waypointInOptions) = pair
                let waypoint = Waypoint(coordinate: decodedWaypoint.coordinate, coordinateAccuracy: waypointInOptions.coordinateAccuracy, name: waypointInOptions.name?.nonEmptyString ?? decodedWaypoint.name)
                waypoint.separatesLegs = waypointInOptions.separatesLegs
                return waypoint
            }
            waypoints?.first?.separatesLegs = true
            waypoints?.last?.separatesLegs = true
        } else {
            waypoints = decodedWaypoints
        }
        
        if let routes = try container.decodeIfPresent([Route].self, forKey: .routes) {
            // Postprocess each route.
            for route in routes {
                route.routeIdentifier = uuid
                // Imbue each route’s legs with the waypoints refined above.
                if let waypoints = waypoints {
                    route.legSeparators = waypoints.filter { $0.separatesLegs }
                }
            }
            self.routes = routes
        } else {
            routes = nil
        }
    }
}
