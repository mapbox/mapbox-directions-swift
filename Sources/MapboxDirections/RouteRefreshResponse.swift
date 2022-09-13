import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Turf

/**
 A Directions Refresh API response.
 */
public struct RouteRefreshResponse: ForeignMemberContainer {
    public var foreignMembers: JSONObject = [:]
    
    /**
     The raw HTTP response from the Directions Refresh API.
     */
    public let httpResponse: HTTPURLResponse?
    
    /**
     The response identifier used to request the refreshed route.
     */
    public let identifier: String
    
    /**
     The route index used to request the refreshed route.
     */
    public var routeIndex: Int
    
    
    public var startLegIndex: Int
    
    /**
     A skeleton route that contains only the time-sensitive information that has been updated.
     
     Use the `Route.refreshLegAttributes(from:)`, `Route.refreshLegAttributes(from:legIndex:legShapeIndex:)` and `Route.refreshLegIncidents(from:)`, `Route.refreshLegIncidents(from:legIndex:legShapeIndex:)` methods to merge this object with the original route to continue using the original route with updated information.
     */
    public var route: RefreshedRoute
    
    /**
     The credentials used to make the request.
     */
    public let credentials: Credentials
    
    /**
     The time when this `RouteRefreshResponse` object was created, which is immediately upon recieving the raw URL response.
     
     If you manually start fetching a task returned by `Directions.urlRequest(forRefreshing:routeIndex:currentLegIndex:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    public var created = Date()
}

extension RouteRefreshResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "uuid"
        case route
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.httpResponse = decoder.userInfo[.httpResponse] as? HTTPURLResponse
        
        guard let credentials = decoder.userInfo[.credentials] as? Credentials else {
            throw DirectionsCodingError.missingCredentials
        }
        
        self.credentials = credentials
        
        if let identifier = decoder.userInfo[.responseIdentifier] as? String {
            self.identifier = identifier
        } else {
            throw DirectionsCodingError.missingOptions
        }
        
        route = try container.decode(RefreshedRoute.self, forKey: .route)
        
        if let routeIndex = decoder.userInfo[.routeIndex] as? Int {
            self.routeIndex = routeIndex
        } else {
            throw DirectionsCodingError.missingOptions
        }
        
        if let startLegIndex = decoder.userInfo[.startLegIndex] as? Int {
            self.startLegIndex = startLegIndex
        } else {
            throw DirectionsCodingError.missingOptions
        }
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        
        try container.encode(route, forKey: .route)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

extension Route {
    /**
     Merges the attributes of the given route’s legs into the receiver’s legs.
     
     - parameter refreshedRoute: The route containing leg attributes to merge into the receiver. If this route contains fewer legs than the receiver, this method skips legs from the beginning of the route to make up the difference, so that merging the attributes from a one-leg route affects only the last leg of the receiver.
     */
    public func refreshLegAttributes(from refreshedRoute: RouteRefreshSource) {
        for (leg, refreshedLeg) in zip(legs.suffix(refreshedRoute.refreshedLegs.count), refreshedRoute.refreshedLegs) {
            leg.attributes = refreshedLeg.refreshedAttributes
        }
    }

    /**
     Merges the attributes of the given route’s legs into the receiver’s legs.
     
     - parameter refreshedRoute: The route containing leg attributes to merge into the receiver. If this route contains fewer legs than the receiver, this method skips legs from the beginning of the route to make up the difference, so that merging the attributes from a one-leg route affects only the last leg of the receiver.
     - parameter legIndex: The index of a leg, from which to start applying the refreshed attributes.
     - parameter legShapeIndex: Index of a geometry of the `legIndex` leg, where to start refreshing from.
     */
    public func refreshLegAttributes(from refreshedRoute: RouteRefreshSource, legIndex: Int, legShapeIndex: Int) {
        guard legIndex + refreshedRoute.refreshedLegs.count <= legs.count else { return }
        for (leg, refreshedLeg) in zip(legs[legIndex..<legIndex + refreshedRoute.refreshedLegs.count].enumerated(), refreshedRoute.refreshedLegs) {
            let startIndex = leg.offset == 0 ? legShapeIndex : 0
            leg.element.refreshAttributes(newAttributes: refreshedLeg.refreshedAttributes, startLegShapeIndex: startIndex)
        }
    }
    
    /**
     Merges the incidents of the given route’s legs into the receiver’s legs.
     
     - parameter refreshedRoute: The route containing leg incidents to merge into the receiver. If this route contains fewer legs than the receiver, this method skips legs from the beginning of the route to make up the difference, so that merging the incidents from a one-leg route affects only the last leg of the receiver.
     */
    public func refreshLegIncidents(from refreshedRoute: RouteRefreshSource) {
        for (leg, refreshedLeg) in zip(legs.suffix(refreshedRoute.refreshedLegs.count), refreshedRoute.refreshedLegs) {
            leg.incidents = refreshedLeg.refreshedIncidents
        }
    }

    /**
     Merges the incidents of the given route’s legs into the receiver’s legs.
     
     - parameter refreshedRoute: The route containing leg incidents to merge into the receiver. If this route contains fewer legs than the receiver, this method skips legs from the beginning of the route to make up the difference, so that merging the incidents from a one-leg route affects only the last leg of the receiver.
     - parameter legIndex: The index of a leg, from which to start applying the refreshed incidents.
     - parameter legShapeIndex: Index of a geometry of the `legIndex` leg, where to start refreshing from.
     */
    public func refreshLegIncidents(from refreshedRoute: RouteRefreshSource, legIndex: Int, legShapeIndex: Int) {
        for (leg, refreshedLeg) in zip(legs[legIndex..<legIndex + refreshedRoute.refreshedLegs.count].enumerated(), refreshedRoute.refreshedLegs) {
            let startIndex = leg.offset == 0 ? legShapeIndex : 0
            leg.element.refreshIncidents(newIncidents: refreshedLeg.refreshedIncidents, startLegShapeIndex: startIndex)
        }
    }
}
