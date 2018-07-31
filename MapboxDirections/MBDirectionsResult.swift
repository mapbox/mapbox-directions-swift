import Polyline

/**
 A `DirectionsResult` represents a result returned from either the Mapbox Directions service.
 
 You do not create instances of this class directly. Instead, you receive `Route` or `Match` objects when you request directions using the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method.
 */
@objc(MBDirectionsResult)
open class DirectionsResult: NSObject, NSSecureCoding {
    
    @objc internal init(legs: [RouteLeg], distance: CLLocationDistance, expectedTravelTime: TimeInterval, coordinates: [CLLocationCoordinate2D]?, speechLocale: Locale?, options: DirectionsOptions) {
        self.directionsOptions = options
        self.legs = legs
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.coordinates = coordinates
        self.speechLocale = speechLocale
    }
        
    @objc public required init?(coder decoder: NSCoder) {
        let coordinateDictionaries = decoder.decodeObject(of: [NSArray.self, NSDictionary.self, NSString.self, NSNumber.self], forKey: "coordinates") as? [[String: CLLocationDegrees]]
        coordinates = coordinateDictionaries?.compactMap({ (coordinateDictionary) -> CLLocationCoordinate2D? in
            if let latitude = coordinateDictionary["latitude"],
                let longitude = coordinateDictionary["longitude"] {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                return nil
            }
        })
        
        legs = decoder.decodeObject(of: [NSArray.self, RouteLeg.self], forKey: "legs") as? [RouteLeg] ?? []
        distance = decoder.decodeDouble(forKey: "distance")
        expectedTravelTime = decoder.decodeDouble(forKey: "expectedTravelTime")
        
        guard let options = decoder.decodeObject(of: [DirectionsOptions.self], forKey: "directionsOptions") as? DirectionsOptions else {
            return nil
        }
        directionsOptions = options
        
        routeIdentifier = decoder.decodeObject(of: NSString.self, forKey: "routeIdentifier") as String?
        
        speechLocale = decoder.decodeObject(of: NSLocale.self, forKey: "speechLocale") as Locale?
    }
    
    public class var supportsSecureCoding: Bool {
        return true
    }
    
    @objc public func encode(with coder: NSCoder) {
        let coordinateDictionaries = coordinates?.map { [
            "latitude": $0.latitude,
            "longitude": $0.longitude,
            ] }
        coder.encode(coordinateDictionaries, forKey: "coordinates")
        
        coder.encode(legs, forKey: "legs")
        coder.encode(distance, forKey: "distance")
        coder.encode(expectedTravelTime, forKey: "expectedTravelTime")
        coder.encode(directionsOptions, forKey: "directionsOptions")
        coder.encode(routeIdentifier, forKey: "routeIdentifier")
        coder.encode(speechLocale, forKey: "speechLocale")
    }
    
    /**
     An array of geographic coordinates defining the path of the route from start to finish.
     
     This array may be `nil` or simplified depending on the `routeShapeResolution` property of the original `RouteOptions` object.
     
     Using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [Mapbox Maps SDK for macOS](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display an overview of the route on an `MGLMapView`.
     */
    @objc public let coordinates: [CLLocationCoordinate2D]?
    
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
    @objc public let legs: [RouteLeg]
    
    @objc open override var description: String {
        return legs.map { $0.name }.joined(separator: " – ")
    }
    
    // MARK: Getting Additional Route Details
    
    /**
     The route’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to traverse the path of the route. It is the sum of the `distance` properties of the route’s legs, not the sum of the direct distances between the route’s waypoints. You should not assume that the user would travel along this distance at a fixed speed.
     */
    @objc public let distance: CLLocationDistance
    
    /**
     The route’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to traverse the entire route. It is the sum of the `expectedTravelTime` properties of the route’s legs. If the route was calculated using the `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` profile, this property reflects current traffic conditions at the time of the request, not necessarily the traffic conditions at the time the user would begin the route. For other profiles, this property reflects travel time under ideal conditions and does not account for traffic congestion. If the route makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     
     Do not assume that the user would travel along the route at a fixed speed. For more granular travel times, use the `RouteLeg.expectedTravelTime` or `RouteStep.expectedTravelTime`. For even more granularity, specify the `AttributeOptions.expectedTravelTime` option and use the `RouteLeg.expectedSegmentTravelTimes` property.
     */
    @objc public let expectedTravelTime: TimeInterval
    
    /**
     `RouteOptions` used to create the directions request.
     
     The route options object’s profileIdentifier property reflects the primary mode of transportation used for the route. Individual steps along the route might use different modes of transportation as necessary.
     */
    @objc public let directionsOptions: DirectionsOptions
    
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
            return debugQuickLookURL(illustrating: coordinates, profileIdentifier: directionsOptions.profileIdentifier)
        }
        return nil
    }
    
    /**
     A unique identifier for a directions request.
     
     Each route produced by a single call to `Directions.calculate(_:completionHandler:)` has the same route identifier.
     */
    @objc open var routeIdentifier: String?
    
    /**
     The locale to use for spoken instructions.
     
     This locale is specific to Mapbox Voice API. If `nil` is returned, the instruction should be spoken with an alternative speech synthesizer.
     */
    @objc open var speechLocale: Locale?
}
