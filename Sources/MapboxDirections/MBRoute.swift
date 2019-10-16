import Polyline

/**
 A `Route` object defines a single route that the user can follow to visit a series of waypoints in order. The route object includes information about the route, such as its distance and expected travel time. Depending on the criteria used to calculate the route, the route object may also include detailed turn-by-turn instructions.
 
 Typically, you do not create instances of this class directly. Instead, you receive route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method. However, if you use the `Directions.url(forCalculating:)` method instead, you can pass the results of the HTTP request into this class’s initializer.
 */

open class Route: DirectionsResult {
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    public var routeOptions: RouteOptions {
         return super.directionsOptions as! RouteOptions
     }
}
