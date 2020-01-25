import Foundation

public struct RouteResponse {
    public var code: String?
    public var message: String?
    public var error: DirectionsError?
    public let uuid: String?
    public let routes: [Route]?
    public let waypoints: [Waypoint]?
    
    public let request: RouteOptions
    public let credentials: DirectionsCredentials
//    public let accessToken: String
//    public let endpoint: URL?
    
    /**
     The time when this `RouteResponse` object was created, which is immediately upon recieving the raw URL response.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    public var created: Date = Date()
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
    public init(error: DirectionsError) {
        self.init(code: nil, message: nil, error: error, uuid: nil, routes: nil, waypoints: nil)
    }
    
//    public init(matchResponse match: MapMatchingResponse) {
//        self.code = match.code
//        self.message = match.message
//        self.error = match.error
//        self.routes = match.matches
//        self.waypoints = match.tracepoints
//
//    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Is this an edge-case, where we are creating a route response from the map matching service?
        
        self.code = try container.decodeIfPresent(String.self, forKey: .code)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        if let apiError = try container.decodeIfPresent(String.self, forKey: .error) {
            error = .unknown(response: nil, underlying: nil, code: self.code, message: apiError)
        }
        self.uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        
        // Decode waypoints from the response and update their names according to the waypoints from DirectionsOptions.waypoints.
        let decodedWaypoints = try container.decodeIfPresent([Waypoint?].self, forKey: .waypoints)
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(error, forKey: .error)
        try container.encodeIfPresent(uuid, forKey: .uuid)
        try container.encodeIfPresent(routes, forKey: .routes)
        try container.encodeIfPresent(waypoints, forKey: .waypoints)
    }
    
    /**
     Adds request- or response-specific information to each result in a response.
     */
    func postprocess(accessToken: String, apiEndpoint: URL, fetchStartDate: Date, responseEndDate: Date) {
        guard let routes = self.routes else {
            return
        }
        
        for result in routes {
            result.accessToken = accessToken
            result.apiEndpoint = apiEndpoint
            result.routeIdentifier = uuid
            result.fetchStartDate = fetchStartDate
            result.responseEndDate = responseEndDate
        }
    }

}
