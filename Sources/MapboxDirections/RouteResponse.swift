import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum ResponseOptions {
    case route(RouteOptions)
    case match(MatchOptions)
}

public struct RouteResponse {
    public let httpResponse: HTTPURLResponse?
    
    public let identifier: String?
    public var routes: [Route]? {
        didSet {
            parseIgnoredRoadClassesAvoidance()
        }
    }
    public let waypoints: [Waypoint]?
    
    public let options: ResponseOptions
    public let credentials: Credentials
    
    /**
     The time when this `RouteResponse` object was created, which is immediately upon recieving the raw URL response.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    public var created: Date = Date()
    
    /**
     Managed of `RoadClasses` restrictions specified to `RouteOptions.roadClassesToAvoid` which were violated during route calculation.
     
     Routing engine may still utilize `RoadClasses` meant to be avoided in cases when routing is impossible otherwise.
     
     Resulting array is in the same order as `routes`, showing exact `RoadClasses` restrictions were ignored for each particular route at specific leg/step/intersection. `nil` and empty return arrays correspond to `nil` and empty `routes` array.
     */
    public private(set) var roadClassExclusionViolations: [RoadClassExclusionViolation]?
}

extension RouteResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case error
        case identifier = "uuid"
        case routes
        case waypoints
    }
    
    public init(httpResponse: HTTPURLResponse?, identifier: String? = nil, routes: [Route]? = nil, waypoints: [Waypoint]? = nil, options: ResponseOptions, credentials: Credentials) {
        self.httpResponse = httpResponse
        self.identifier = identifier
        self.options = options
        self.routes = routes
        self.waypoints = waypoints
        self.credentials = credentials
        
        parseIgnoredRoadClassesAvoidance()
    }
    
    public init(matching response: MapMatchingResponse, options: MatchOptions, credentials: Credentials) throws {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        decoder.userInfo[.options] = options
        decoder.userInfo[.credentials] = credentials
        encoder.userInfo[.options] = options
        encoder.userInfo[.credentials] = credentials
        
        var routes: [Route]?
        
        if let matches = response.matches {
            let matchesData = try encoder.encode(matches)
            routes = try decoder.decode([Route].self, from: matchesData)
        }
        
        var waypoints: [Waypoint]?
        
        if let tracepoints = response.tracepoints {
            let filtered = tracepoints.compactMap { $0 }
            let tracepointsData = try encoder.encode(filtered)
            waypoints = try decoder.decode([Waypoint].self, from: tracepointsData)
        }
    
        self.init(httpResponse: response.httpResponse, identifier: nil, routes: routes, waypoints: waypoints, options: .match(options), credentials: credentials)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.httpResponse = decoder.userInfo[.httpResponse] as? HTTPURLResponse
        
        guard let credentials = decoder.userInfo[.credentials] as? Credentials else {
            throw DirectionsCodingError.missingCredentials
        }
        
        self.credentials = credentials
        
        if let options = decoder.userInfo[.options] as? RouteOptions {
            self.options = .route(options)
        } else if let options = decoder.userInfo[.options] as? MatchOptions {
            self.options = .match(options)
        } else {
            throw DirectionsCodingError.missingOptions
        }
        
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        
        // Decode waypoints from the response and update their names according to the waypoints from DirectionsOptions.waypoints.
        let decodedWaypoints = try container.decodeIfPresent([Waypoint?].self, forKey: .waypoints)?.compactMap{ $0 }
        var optionsWaypoints: [Waypoint] = []
        
        switch options {
        case let .match(options: matchOpts):
            optionsWaypoints = matchOpts.waypoints
        case let .route(options: routeOpts):
            optionsWaypoints = routeOpts.waypoints
        }
                
        if let decodedWaypoints = decodedWaypoints {
            // The response lists the same number of tracepoints as the waypoints in the request, whether or not a given waypoint is leg-separating.
            waypoints = zip(decodedWaypoints, optionsWaypoints).map { (pair) -> Waypoint in
                let (decodedWaypoint, waypointInOptions) = pair
                let waypoint = Waypoint(coordinate: decodedWaypoint.coordinate,
                                        coordinateAccuracy: waypointInOptions.coordinateAccuracy,
                                        name: waypointInOptions.name?.nonEmptyString ?? decodedWaypoint.name)

                waypoint.targetCoordinate = waypointInOptions.targetCoordinate
                waypoint.heading = waypointInOptions.heading
                waypoint.headingAccuracy = waypointInOptions.headingAccuracy
                waypoint.separatesLegs = waypointInOptions.separatesLegs
                waypoint.allowsArrivingOnOppositeSide = waypointInOptions.allowsArrivingOnOppositeSide
                
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
                // Imbue each route’s legs with the waypoints refined above.
                if let waypoints = waypoints {
                    route.legSeparators = waypoints.filter { $0.separatesLegs }
                }
            }
            self.routes = routes
        } else {
            routes = nil
        }
        
        parseIgnoredRoadClassesAvoidance()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(routes, forKey: .routes)
        try container.encodeIfPresent(waypoints, forKey: .waypoints)
    }

}

extension RouteResponse {
    
    mutating func parseIgnoredRoadClassesAvoidance() {
        guard case let .route(routeOptions) = options else {
            roadClassExclusionViolations = nil
            return
        }
        
        guard let routes = routes else {
            roadClassExclusionViolations = nil
            return
        }
        
        let avoidedClasses = routeOptions.roadClassesToAvoid
        
        guard !avoidedClasses.isEmpty else {
            roadClassExclusionViolations = nil
            return
        }
        
        var violations = [RoadClassExclusionViolation]()
        
        for (routeIndex, route) in routes.enumerated() {
            for (legIndex, leg) in route.legs.enumerated() {
                for (stepIndex, step) in leg.steps.enumerated() {
                    for (intersectionIndex, intersection) in (step.intersections ?? []).enumerated() {
                        if let outletRoadClasses = intersection.outletRoadClasses,
                           !avoidedClasses.isDisjoint(with: outletRoadClasses) {
                            violations.append(RoadClassExclusionViolation(roadClasses: avoidedClasses.intersection(outletRoadClasses),
                                                                          routeIndex: routeIndex,
                                                                          legIndex: legIndex,
                                                                          stepIndex: stepIndex,
                                                                          intersectionIndex: intersectionIndex))
                        }
                    }
                }
            }
        }
        roadClassExclusionViolations = violations
    }
    
    /**
     Filters `roadClassExclusionViolations` lazily to search for specific leg and step.
     
     - parameter routeIndex: Index of a route inside current `RouteResponse` to search in.
     - parameter legIndex: Index of a leg inside related `Route`to search in.
     - returns: Lazy filtered array of `RoadClassExclusionViolation` under given indicies.
     
     Passing `nil` as `legIndex` will result in searching for all legs.
     */
    public func exclusionViolations(routeIndex: Int, legIndex: Int? = nil) -> LazyFilterSequence<[RoadClassExclusionViolation]> {
        return filteredViolations(routeIndex: routeIndex,
                                  legIndex: legIndex,
                                  stepIndex: nil,
                                  intersectionIndex: nil)
    }
    
    /**
     Filters `roadClassExclusionViolations` lazily to search for specific leg and step.
     
     - parameter routeIndex: Index of a route inside current `RouteResponse` to search in.
     - parameter legIndex: Index of a leg inside related `Route`to search in.
     - parameter stepIndex: Index of a step inside given `Route`'s leg.
     - returns: Lazy filtered array of `RoadClassExclusionViolation` under given indicies.
     
     Passing `nil` as `stepIndex` will result in searching for all steps.
     */
    public func exclusionViolations(routeIndex: Int, legIndex: Int, stepIndex: Int? = nil) -> LazyFilterSequence<[RoadClassExclusionViolation]> {
        return filteredViolations(routeIndex: routeIndex,
                                  legIndex: legIndex,
                                  stepIndex: stepIndex,
                                  intersectionIndex: nil)
    }
    
    /**
     Filters `roadClassExclusionViolations` lazily to search for specific leg, step and intersection.
     
     - parameter routeIndex: Index of a route inside current `RouteResponse` to search in.
     - parameter legIndex: Index of a leg inside related `Route`to search in.
     - parameter stepIndex: Index of a step inside given `Route`'s leg.
     - parameter intersectionIndex: Index of an intersection inside given `Route`'s leg and step.
     - returns: Lazy filtered array of `RoadClassExclusionViolation` under given indicies.
     
     Passing `nil` as `intersectionIndex` will result in searching for all intersections of given step.
     */
    public func exclusionViolations(routeIndex: Int, legIndex: Int, stepIndex: Int, intersectionIndex: Int?) -> LazyFilterSequence<[RoadClassExclusionViolation]> {
        return filteredViolations(routeIndex: routeIndex,
                                  legIndex: legIndex,
                                  stepIndex: stepIndex,
                                  intersectionIndex: intersectionIndex)
    }
    
    private func filteredViolations(routeIndex: Int, legIndex: Int? = nil, stepIndex: Int? = nil, intersectionIndex: Int? = nil) -> LazyFilterSequence<[RoadClassExclusionViolation]> {
        assert(!(stepIndex == nil && intersectionIndex != nil), "It is forbidden to select `intersectionIndex` without specifying `stepIndex`.")
        
        guard let roadClassExclusionViolations = roadClassExclusionViolations else {
            return LazyFilterSequence<[RoadClassExclusionViolation]>(_base: [], {_ in true})
        }
        
        var filtered = roadClassExclusionViolations.lazy.filter {
            $0.routeIndex == routeIndex
        }
        
        if let legIndex = legIndex {
            filtered = filtered.filter {
                $0.legIndex == legIndex
            }
        }
        
        if let stepIndex = stepIndex {
            filtered = filtered.filter {
                $0.stepIndex == stepIndex
            }
        }
        
        if let intersectionIndex = intersectionIndex {
            filtered = filtered.filter {
                $0.intersectionIndex == intersectionIndex
            }
        }
        
        return filtered
    }
}
