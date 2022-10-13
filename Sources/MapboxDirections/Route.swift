import Foundation
import Turf

/**
 A `Route` object defines a single route that the user can follow to visit a series of waypoints in order. The route object includes information about the route, such as its distance and expected travel time. Depending on the criteria used to calculate the route, the route object may also include detailed turn-by-turn instructions.
 
 Typically, you do not create instances of this class directly. Instead, you receive route objects when you request directions using the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method. However, if you use the `Directions.url(forCalculating:)` method instead, you can use `JSONDecoder` to convert the HTTP response into a `RouteResponse` or `MapMatchingResponse` object and access the `RouteResponse.routes` or `MapMatchingResponse.routes` property.
 */
open class Route: DirectionsResult {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case tollPrices = "toll_costs"
    }
    
    /**
     Initializes a route.
     
     - parameter legs: The legs that are traversed in order.
     - parameter shape: The roads or paths taken as a contiguous polyline.
     - parameter distance: The route’s distance, measured in meters.
     - parameter expectedTravelTime: The route’s expected travel time, measured in seconds.
     - parameter typicalTravelTime: The route’s typical travel time, measured in seconds.
     */
    public override init(legs: [RouteLeg], shape: LineString?, distance: LocationDistance, expectedTravelTime: TimeInterval, typicalTravelTime: TimeInterval? = nil) {
        super.init(legs: legs, shape: shape, distance: distance, expectedTravelTime: expectedTravelTime, typicalTravelTime: typicalTravelTime)
    }
    
    /**
     Initializes a route from a decoder.
     
     - precondition: If the decoder is decoding JSON data from an API response, the `Decoder.userInfo` dictionary must contain a `RouteOptions` or `MatchOptions` object in the `CodingUserInfoKey.options` key. If it does not, a `DirectionsCodingError.missingOptions` error is thrown.
     - parameter decoder: The decoder of JSON-formatted API response data or a previously encoded `Route` object.
     */
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tollPrices = try container.decodeIfPresent([TollPriceCoder].self, forKey: .tollPrices)?.reduce(into: []) { $0.append(contentsOf: $1.tollPrices) }
        
        try super.init(from: decoder)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(tollPrices.map { TollPriceCoder(tollPrices: $0) }, forKey: .tollPrices)
        
        try super.encode(to: encoder)
    }
    
    /**
     :nodoc:
     List of calculated toll costs for this route.
     
     This property is set to `nil` unless request `RouteOptions.includesTollPrices` is set to `true`.
     See `TollPrice`.
     */
    open var tollPrices: [TollPrice]?
}

extension Route: Equatable {
    public static func ==(lhs: Route, rhs: Route) -> Bool {
        return lhs.distance == rhs.distance &&
            lhs.expectedTravelTime == rhs.expectedTravelTime &&
            lhs.typicalTravelTime == rhs.typicalTravelTime &&
            lhs.speechLocale == rhs.speechLocale &&
            lhs.responseContainsSpeechLocale == rhs.responseContainsSpeechLocale &&
            lhs.legs == rhs.legs &&
            lhs.shape == rhs.shape &&
            lhs.tollPrices.map { Set($0) } == rhs.tollPrices.map { Set($0) } // comparing sets to mitigate items reordering caused by custom Coding impl.
    }
}
