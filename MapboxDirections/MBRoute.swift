import Polyline

/**
 A `Route` object defines a single route that the user can follow to visit a series of waypoints in order. The route object includes information about the route, such as its distance and expected travel time. Depending on the criteria used to calculate the route, the route object may also include detailed turn-by-turn instructions.
 
 Typically, you do not create instances of this class directly. Instead, you receive route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method. However, if you use the `Directions.url(forCalculating:)` method instead, you can pass the results of the HTTP request into this class’s initializer.
 */
@objc(MBRoute)
open class Route: DirectionsResult {
    // MARK: Creating a Route
    
    @objc internal override init(legs: [RouteLeg], distance: CLLocationDistance, expectedTravelTime: TimeInterval, coordinates: [CLLocationCoordinate2D]?, speechLocale: Locale?, options: DirectionsOptions) {
        super.init(legs: legs, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, speechLocale: speechLocale, options: options)
    }
    
    /**
     Initializes a new route object with the given JSON dictionary representation and waypoints.
     
     This initializer is intended for use in conjunction with the `Directions.url(forCalculating:)` method.
     
     - parameter json: A JSON dictionary representation of the route as returned by the Mapbox Directions API.
     - parameter waypoints: An array of waypoints that the route visits in chronological order.
     - parameter routeOptions: The `RouteOptions` used to create the request.
     */
    @objc(initWithJSON:waypoints:routeOptions:)
    public init(json: [String: Any], waypoints: [Waypoint], options: RouteOptions) {
        // Associate each leg JSON with a source and destination. The sequence of destinations is offset by one from the sequence of sources.
        let legInfo = zip(zip(waypoints.prefix(upTo: waypoints.endIndex - 1), waypoints.suffix(from: 1)),
                          json["legs"] as? [JSONDictionary] ?? [])
        let legs = legInfo.map { (endpoints, json) -> RouteLeg in
            RouteLeg(json: json, source: endpoints.0, destination: endpoints.1, options: options)
        }
        let distance = json["distance"] as! Double
        let expectedTravelTime = json["duration"] as! Double
        
        let coordinates = options.shapeFormat.coordinates(from: json["geometry"])
        
        var speechLocale: Locale?
        if let locale = json["voiceLocale"] as? String {
            speechLocale = Locale(identifier: locale)
        }
        
        super.init(legs: legs, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, speechLocale: speechLocale, options: options)
    }
    
    public var routeOptions: RouteOptions {
        return super.directionsOptions as! RouteOptions
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}

// MARK: Support for Directions API v4

internal class RouteV4: Route {
    convenience override init(json: JSONDictionary, waypoints: [Waypoint], options: RouteOptions) {
        let leg = RouteLegV4(json: json, source: waypoints.first!, destination: waypoints.last!, options: options)
        let distance = json["distance"] as! Double
        let expectedTravelTime = json["duration"] as! Double
        
        var coordinates: [CLLocationCoordinate2D]?
        switch json["geometry"] {
        case let geometry as JSONDictionary:
            coordinates = CLLocationCoordinate2D.coordinates(geoJSON: geometry)
        case let geometry as String:
            coordinates = decodePolyline(geometry, precision: 1e6)!
        default:
            coordinates = nil
        }
        
        self.init(legs: [leg], distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, speechLocale: nil, options: options)
    }
}
