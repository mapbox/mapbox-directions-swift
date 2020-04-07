import CoreLocation
import Turf

/**
 A `Route` object defines a single route that the user can follow to visit a series of waypoints in order. The route object includes information about the route, such as its distance and expected travel time. Depending on the criteria used to calculate the route, the route object may also include detailed turn-by-turn instructions.
 
 Typically, you do not create instances of this class directly. Instead, you receive route objects when you request directions using the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method. However, if you use the `Directions.url(forCalculating:)` method instead, you can use `JSONDecoder` to convert the HTTP response into a `RouteResponse` or `MapMatchingResponse` object and access the `RouteResponse.routes` or `MapMatchingResponse.routes` property.
 */
open class Route: DirectionsResult {
}

extension Route: Equatable {
    public static func ==(lhs: Route, rhs: Route) -> Bool {
        return lhs.routeIdentifier == rhs.routeIdentifier &&
            lhs.distance == rhs.distance &&
            lhs.expectedTravelTime == rhs.expectedTravelTime &&
            lhs.speechLocale == rhs.speechLocale &&
            lhs.legs == rhs.legs &&
            lhs.shape == rhs.shape
    }
}
