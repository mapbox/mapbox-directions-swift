import Foundation

struct RouteResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case error
        case uuid
        case routes
        case waypoints
    }
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.code = try container.decodeIfPresent(String.self, forKey: .code)
        
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
        
        let uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        self.uuid = uuid
        
        let waypoints = try container.decodeIfPresent([Waypoint].self, forKey: .waypoints)
        self.waypoints = waypoints
        
        let rawRoutes = try container.decodeIfPresent([Route].self, forKey: .routes)
        var routesWithDestinations: [Route]? = rawRoutes
        if let destinations = waypoints?.dropFirst() {
            routesWithDestinations = rawRoutes?.map({ (route) -> Route in
                for (leg, destination) in zip(route.legs, destinations) {
                    if leg.destination?.name?.nonEmptyString == nil {
                        leg.destination = destination
                    }
                }
                return route
            })
        }
        
        let routesWithIdentifiers = routesWithDestinations?.map({ (route) -> Route in
            route.routeIdentifier = uuid
            return route
        })
        
        self.routes = routesWithIdentifiers
    }
}
