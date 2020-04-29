import Foundation

public struct RouteRefreshResponse {
    public let httpResponse: HTTPURLResponse?
    
    public let identifier: String?
    public var routeIndex: Int
    public var legIndex: Int
    
    public var route: Route? // pass it in a user info? and then consturct new route during decoding?
    
    public let credentials: DirectionsCredentials
    
    private var legAnnotations: [RouteLegAnnotation]
    
    /**
     The time when this `RouteRefreshResponse` object was created, which is immediately upon recieving the raw URL response.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    public var created: Date = Date()
}

extension RouteRefreshResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "uuid"
        case route
    }
    
    private func applyRefreshingTo(route: Route) -> Route{
        let updatedLegs = zip(legAnnotations, route.legs.enumerated()).map { (pair) -> RouteLeg in
            let (annotation, legEnum) = pair
            let leg = legEnum.element.copy() as! RouteLeg
            if legEnum.offset >= legIndex {
                leg.updateAnnotationData(from: annotation)
            }
            return leg
        }
        
        let route = Route(legs: updatedLegs,
                           shape: route.shape,
                           distance: route.distance,
                           expectedTravelTime: route.expectedTravelTime)
        route.routeIdentifier = route.routeIdentifier
        route.routeIndex = route.routeIndex
        
        return route
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.httpResponse = decoder.userInfo[.httpResponse] as? HTTPURLResponse
        
        guard let credentials = decoder.userInfo[.credentials] as? DirectionsCredentials else {
            throw DirectionsCodingError.missingCredentials
        }
        
        self.credentials = credentials
        
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        
        let refreshedRoute = try container.decode(RefreshedRoute.self, forKey: .route)
        self.legAnnotations = refreshedRoute.legAnnotations
        
        self.routeIndex = decoder.userInfo[.routeIndex] as! Int
        self.legIndex = decoder.userInfo[.legIndex] as! Int
        let refreshingRoute = decoder.userInfo[.refreshingRoute] as! Route
        
        self.route = applyRefreshingTo(route: refreshingRoute)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        
        let route = RefreshedRoute(legAnnotations: legAnnotations)
        try container.encode(route, forKey: .route)
    }

}
