import Foundation

struct DirectionsResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case uuid
        case routes
        case waypoints
    }
    
    let code: String?
    let message: String?
    let uuid: String?
    let routes: [Route]?
    let waypoints: [Waypoint]?
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decodeIfPresent(String.self, forKey: .code)
        self.code = code
        
        let message = try container.decodeIfPresent(String.self, forKey: .message)
        self.message = message
        
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
