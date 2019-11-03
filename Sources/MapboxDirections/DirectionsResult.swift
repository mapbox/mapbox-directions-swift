import Foundation
import struct Polyline.Polyline
import CoreLocation
import struct Turf.LineString

/**
 A `DirectionsResult` represents a result returned from either the Mapbox Directions service.
 
 You do not create instances of this class directly. Instead, you receive `Route` or `Match` objects when you request directions using the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method.
 */
open class DirectionsResult: Codable {
    private enum CodingKeys: String, CodingKey {
        case shape = "geometry"
        case legs
        case distance
        case expectedTravelTime = "duration"
        case directionsOptions
        case accessToken
        case apiEndpoint
        case routeIdentifier
        case speechLocale = "voiceLocale"
    }
    
    // MARK: Creating a Directions Result
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        legs = try container.decode([RouteLeg].self, forKey: .legs)
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
        
        _directionsOptions = decoder.userInfo[.options] as! DirectionsOptions
    
        if let polyLineString = try container.decodeIfPresent(PolyLineString.self, forKey: .shape) {
            shape = try LineString(polyLineString: polyLineString)
        } else {
            shape = nil
        }
        
        // Associate each leg JSON with a source and destination. The sequence of destinations is offset by one from the sequence of sources.
        
        let waypoints = directionsOptions.legSeparators //we don't want to name via points
        let legInfo = zip(zip(waypoints.prefix(upTo: waypoints.endIndex - 1), waypoints.suffix(from: 1)), legs)
        
        for (endpoints, leg) in legInfo {
            leg.source = endpoints.0
            leg.destination = endpoints.1
        }
        
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        apiEndpoint = try container.decodeIfPresent(URL.self, forKey: .apiEndpoint)
        routeIdentifier = try container.decodeIfPresent(String.self, forKey: .routeIdentifier)
        
        do {
            speechLocale = try container.decodeIfPresent(Locale.self, forKey: .speechLocale)
        } catch let DecodingError.typeMismatch(mismatchedType, context){
            guard mismatchedType == Dictionary<String, Any>.self else {
                throw DecodingError.typeMismatch(mismatchedType, context)
            }
            let identifier = try container.decode(String.self, forKey: .speechLocale)
            speechLocale = Locale(identifier: identifier)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(legs, forKey: .legs)
        if let shape = shape {
            let polyLineString = PolyLineString(lineString: shape, shapeFormat: directionsOptions.shapeFormat)
            try container.encode(polyLineString, forKey: .shape)
        }
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encodeIfPresent(accessToken, forKey: .accessToken)
        try container.encodeIfPresent(apiEndpoint, forKey: .apiEndpoint)
        try container.encodeIfPresent(routeIdentifier, forKey: .routeIdentifier)
        try container.encodeIfPresent(speechLocale, forKey: .speechLocale)
    }
    
    // MARK: Getting the Shape of the Route
    
    /**
     An array of geographic coordinates defining the path of the route from start to finish.
     
     This array may be `nil` or simplified depending on the `DirectionsOptions.routeShapeResolution` property of the original `RouteOptions` or `MatchOptions` object.
     
     Using the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [Mapbox Maps SDK for macOS](https://mapbox.github.io/mapbox-gl-native/macos/), you can create an `MGLPolyline` object using these coordinates to display an overview of the route on an `MGLMapView`.
     */   
    public let shape: LineString?
    
    // MARK: Getting the Legs Along the Route
    
    /**
     An array of `RouteLeg` objects representing the legs of the route.
     
     The number of legs in this array depends on the number of waypoints. A route with two waypoints (the source and destination) has one leg, a route with three waypoints (the source, an intermediate waypoint, and the destination) has two legs, and so on.
     
     To determine the name of the route, concatenate the names of the route’s legs.
     */
    public let legs: [RouteLeg]
    
    // MARK: Getting Statistics About the Route
    
    /**
     The route’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to traverse the path of the route. It is the sum of the `distance` properties of the route’s legs, not the sum of the direct distances between the route’s waypoints. You should not assume that the user would travel along this distance at a fixed speed.
     */
    public let distance: CLLocationDistance
    
    /**
     The route’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to traverse the entire route. It is the sum of the `expectedTravelTime` properties of the route’s legs. If the route was calculated using the `DirectionsProfileIdentifier.automobileAvoidingTraffic` profile, this property reflects current traffic conditions at the time of the request, not necessarily the traffic conditions at the time the user would begin the route. For other profiles, this property reflects travel time under ideal conditions and does not account for traffic congestion. If the route makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     
     Do not assume that the user would travel along the route at a fixed speed. For more granular travel times, use the `RouteLeg.expectedTravelTime` or `RouteStep.expectedTravelTime`. For even more granularity, specify the `AttributeOptions.expectedTravelTime` option and use the `RouteLeg.expectedSegmentTravelTimes` property.
     */
    public let expectedTravelTime: TimeInterval
    
    // MARK: Configuring Speech Synthesis
    
    /**
     The locale to use for spoken instructions.
     
     This locale is specific to Mapbox Voice API. If `nil` is returned, the instruction should be spoken with an alternative speech synthesizer.
     */
    open var speechLocale: Locale?
    
    // MARK: Reproducing the Route
    
    /**
     `RouteOptions` used to create the directions request.
     
     The route options object’s profileIdentifier property reflects the primary mode of transportation used for the route. Individual steps along the route might use different modes of transportation as necessary.
     */
    public var directionsOptions: DirectionsOptions {
        return _directionsOptions
    }
    
    private let _directionsOptions: DirectionsOptions
    
    /**
     The [access token](https://docs.mapbox.com/help/glossary/access-token/) used to make the directions request.
     
     This property is set automatically if a request is made via `Directions.calculate(_:completionHandler:)`.
     */
    open var accessToken: String?
    
    /**
     The endpoint used to make the directions request.
     
     This property is set automatically if a request is made via `Directions.calculate(_:completionHandler:)`.
     */
    open var apiEndpoint: URL?
    
    // MARK: Auditing the Server Response
    
    /**
     A unique identifier for a directions request.
     
     Each route produced by a single call to `Directions.calculate(_:completionHandler:)` has the same route identifier.
     */
    open var routeIdentifier: String?
    
    /**
     The time immediately before a `Directions` object fetched this result.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.fetchStartDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    open var fetchStartDate: Date?
    
    /**
     The time immediately before a `Directions` object received the last byte of this result.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    open var responseEndDate: Date?
}
