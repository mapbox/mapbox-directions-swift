import Polyline

/**
 A `Route` object defines a single route that the user can follow to visit a series of waypoints in order. The route object includes information about the route, such as its distance and expected travel time. Depending on the criteria used to calculate the route, the route object may also include detailed turn-by-turn instructions.
 
 Typically, you do not create instances of this class directly. Instead, you receive route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method. However, if you use the `Directions.url(forCalculating:)` method instead, you can pass the results of the HTTP request into this class’s initializer.
 */
@objc(MBRoute)
open class Route: NSObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case distance
        case routeIdentifier
        case legs
        case expectedTravelTime = "duration"
        case routeOptions
        case geometry
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case coordinates
        case type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(legs, forKey: .legs)
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encode(routeOptions, forKey: .routeOptions)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let geometry = try container.decodeIfPresent(GenericDecodable<GeoJSONGeometry, String>.self, forKey: .geometry)
        if let geo = geometry?.value as? String {
            coordinates = decodePolyline(geo, precision: 1e5)
        } else if let geo = geometry?.value as? GeoJSONGeometry {
            coordinates = geo.coordinates
        } else {
            coordinates = nil
        }
        
        legs = try container.decode([RouteLeg].self, forKey: .legs)
        
        if let routeOptions = try container.decodeIfPresent(RouteOptions.self, forKey: .routeOptions) {
            self.routeOptions = routeOptions
        } else {
            self.routeOptions = decoder.userInfo[CodingUserInfoKey.routeOptions!] as! RouteOptions
        }
        
        // Associate each leg JSON with a source and destination. The sequence of destinations is offset by one from the sequence of sources.
        let waypoints = routeOptions.waypoints
        let legInfos = zip(zip(waypoints.prefix(upTo: waypoints.endIndex - 1), waypoints.suffix(from: 1)), legs)
        for legInfo in legInfos {
            legInfo.1.source = legInfo.0.0
            legInfo.1.destination = legInfo.0.1
        }
        
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
    }
    
    // MARK: Creating a Route
    
    @objc internal init(routeOptions: RouteOptions, legs: [RouteLeg], distance: CLLocationDistance, expectedTravelTime: TimeInterval, coordinates: [CLLocationCoordinate2D]?) {
        self.routeOptions = routeOptions
        self.legs = legs
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.coordinates = coordinates
    }
    
    // MARK: Getting the Route Geometry
    
    /**
     An array of geographic coordinates defining the path of the route from start to finish.
     
     This array may be `nil` or simplified depending on the `routeShapeResolution` property of the original `RouteOptions` object.
     
     Using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [Mapbox Maps SDK for macOS](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display an overview of the route on an `MGLMapView`.
     */
    @objc open let coordinates: [CLLocationCoordinate2D]?
    
    /**
     The number of coordinates.
     
     The value of this property may be zero or reduced depending on the `routeShapeResolution` property of the original `RouteOptions` object.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates.count` property.
     */
    @objc open var coordinateCount: UInt {
        return UInt(coordinates?.count ?? 0)
    }
    
    /**
     Retrieves the coordinates.
     
     The array may be empty or simplified depending on the `routeShapeResolution` property of the original `RouteOptions` object.
     
     Using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [Mapbox Maps SDK for macOS](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display an overview of the route on an `MGLMapView`.
     
     - parameter coordinates: A pointer to a C array of `CLLocationCoordinate2D` instances. On output, this array contains all the vertices of the overlay.
     
     - precondition: `coordinates` must be large enough to hold `coordinateCount` instances of `CLLocationCoordinate2D`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates` property.
     */
    @objc open func getCoordinates(_ coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>) {
        for i in 0..<(self.coordinates?.count ?? 0) {
            coordinates.advanced(by: i).pointee = self.coordinates![i]
        }
    }
    
    /**
     An array of `RouteLeg` objects representing the legs of the route.
     
     The number of legs in this array depends on the number of waypoints. A route with two waypoints (the source and destination) has one leg, a route with three waypoints (the source, an intermediate waypoint, and the destination) has two legs, and so on.
     
     To determine the name of the route, concatenate the names of the route’s legs.
     */
    @objc open let legs: [RouteLeg]
    
    @objc open override var description: String {
        return legs.map { $0.name }.joined(separator: " – ")
    }
    
    // MARK: Getting Additional Route Details
    
    /**
     The route’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to traverse the path of the route. It is the sum of the `distance` properties of the route’s legs, not the sum of the direct distances between the route’s waypoints. You should not assume that the user would travel along this distance at a fixed speed.
     */
    @objc open let distance: CLLocationDistance
    
    /**
     The route’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to traverse the entire route. It is the sum of the `expectedTravelTime` properties of the route’s legs. If the route was calculated using the `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` profile, this property reflects current traffic conditions at the time of the request, not necessarily the traffic conditions at the time the user would begin the route. For other profiles, this property reflects travel time under ideal conditions and does not account for traffic congestion. If the route makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     
     Do not assume that the user would travel along the route at a fixed speed. For more granular travel times, use the `RouteLeg.expectedTravelTime` or `RouteStep.expectedTravelTime`. For even more granularity, specify the `AttributeOptions.expectedTravelTime` option and use the `RouteLeg.expectedSegmentTravelTimes` property.
     */
    @objc open let expectedTravelTime: TimeInterval
    
    /**
     `RouteOptions` used to create the directions request.
     
     The route options object’s profileIdentifier property reflects the primary mode of transportation used for the route. Individual steps along the route might use different modes of transportation as necessary.
     */
    @objc open let routeOptions: RouteOptions
    
    /**
     The [access token](https://www.mapbox.com/help/define-access-token/) used to make the directions request.
     
     This property is set automatically if a request is made via `Directions.calculate(_:completionHandler:)`.
     */
    @objc open var accessToken: String?
    
    /**
     The endpoint used to make the directions request.
     
     This property is set automatically if a request is made via `Directions.calculate(_:completionHandler:)`.
     */
    @objc open var apiEndpoint: URL?
    
    func debugQuickLookObject() -> Any? {
        if let coordinates = coordinates {
            return debugQuickLookURL(illustrating: coordinates, profileIdentifier: routeOptions.profileIdentifier)
        }
        return nil
    }
    
    /**
     A unique identifier for a directions request.
     
     Each route produced by a single call to `Directions.calculate(_:completionHandler:)` has the same route identifier.
     */
    @objc open var routeIdentifier: String?
}

// MARK: Support for Directions API v4

internal class RouteV4: Route {
    // TODO: Fix
//    convenience init(json: JSONDictionary, waypoints: [Waypoint], routeOptions: RouteOptions) {
//        let leg = RouteLegV4(json: json, source: waypoints.first!, destination: waypoints.last!, profileIdentifier: routeOptions.profileIdentifier)
//        let distance = json["distance"] as! Double
//        let expectedTravelTime = json["duration"] as! Double
//
//        var coordinates: [CLLocationCoordinate2D]?
//        switch json["geometry"] {
//        case let geometry as JSONDictionary:
//            coordinates = CLLocationCoordinate2D.coordinates(geoJSON: geometry)
//        case let geometry as String:
//            coordinates = decodePolyline(geometry, precision: 1e6)!
//        default:
//            coordinates = nil
//        }
//
//        self.init(routeOptions: routeOptions, legs: [leg], distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates)
//    }
}
