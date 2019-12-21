/**
 A `Route` object defines a single route that the user can follow to visit a series of waypoints in order. The route object includes information about the route, such as its distance and expected travel time. Depending on the criteria used to calculate the route, the route object may also include detailed turn-by-turn instructions.
 
 Typically, you do not create instances of this class directly. Instead, you receive route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method. However, if you use the `Directions.url(forCalculating:)` method instead, you can pass the results of the HTTP request into this class’s initializer.
 */
open class Route: DirectionsResult {
    private enum CodingKeys: String, CodingKey {
        case routeOptions
    }
    
    /**
     Creates a route from a decoder.
     
     - precondition: If the decoder is decoding JSON data from an API response, the `Decoder.userInfo` dictionary must contain a `RouteOptions` or `MatchOptions` object in the `CodingUserInfoKey.options` key. If it does not, a `DirectionsCodingError.missingOptions` error is thrown.
     - parameter decoder: The decoder of JSON-formatted API response data or a previously encoded `Route` object.
     */
    public required init(from decoder: Decoder) throws {
        if let matchOptions = decoder.userInfo[.options] as? MatchOptions {
            routeOptions = RouteOptions(matchOptions: matchOptions)
        } else if let routeOptions = decoder.userInfo[.options] as? RouteOptions {
            self.routeOptions = routeOptions
        } else {
            throw DirectionsCodingError.missingOptions
        }

        try super.init(from: decoder)
    }
    
    public override var directionsOptions: DirectionsOptions {
        return routeOptions as DirectionsOptions
    }
    public var routeOptions: RouteOptions
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
