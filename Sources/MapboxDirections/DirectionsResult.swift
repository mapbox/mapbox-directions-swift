import Foundation
import Polyline
import CoreLocation
import Turf

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
        case routeIdentifier
        case speechLocale = "voiceLocale"
    }
    
    // MARK: Creating a Directions Result
    init(legs: [RouteLeg], shape: LineString?, distance: CLLocationDistance, expectedTravelTime: TimeInterval) {
        self.legs = legs
        self.shape = shape
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let options = decoder.userInfo[.options] else {
            throw DirectionsCodingError.missingOptions
        }
        
        legs = try container.decode([RouteLeg].self, forKey: .legs)
        
        //populate legs with origin and destination
        if let options = options as? DirectionsOptions {
            let waypoints = options.waypoints
            legs.populate(waypoints: waypoints)
        } else {
            throw DirectionsCodingError.missingOptions
        }
        
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
    
        if let polyLineString = try container.decodeIfPresent(PolyLineString.self, forKey: .shape) {
            shape = try LineString(polyLineString: polyLineString)
            
        } else {
            shape = nil
        }
     
        routeIdentifier = try container.decodeIfPresent(String.self, forKey: .routeIdentifier)
        
        if let identifier = try container.decodeIfPresent(String.self, forKey: .speechLocale) {
            speechLocale = Locale(identifier: identifier)
        } else {
            speechLocale = nil
        }
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(legs, forKey: .legs)
        if let shape = shape {
            let options = encoder.userInfo[.options] as? DirectionsOptions
            let shapeFormat = options?.shapeFormat ?? .default
            let polyLineString = PolyLineString(lineString: shape, shapeFormat: shapeFormat)
            try container.encode(polyLineString, forKey: .shape)
        }
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encodeIfPresent(routeIdentifier, forKey: .routeIdentifier)
        try container.encodeIfPresent(speechLocale?.identifier, forKey: .speechLocale)
    }
    
    // MARK: Getting the Shape of the Route
    
    /**
     The roads or paths taken as a contiguous polyline.
     
     The shape may be `nil` or simplified depending on the `DirectionsOptions.routeShapeResolution` property of the original `RouteOptions` or `MatchOptions` object.
     
     Using the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [Mapbox Maps SDK for macOS](https://mapbox.github.io/mapbox-gl-native/macos/), you can create an `MGLPolyline` object using these coordinates to display an overview of the route on an `MGLMapView`.
     */   
    public let shape: LineString?
        
    // MARK: Getting the Legs Along the Route
    
    /**
     The legs that are traversed in order.
     
     The number of legs in this array depends on the number of waypoints. A route with two waypoints (the source and destination) has one leg, a route with three waypoints (the source, an intermediate waypoint, and the destination) has two legs, and so on.
     
     To determine the name of the route, concatenate the names of the route’s legs.
     */
    public let legs: [RouteLeg]
    
    public var legSeparators: [Waypoint?] {
        get {
            return legs.isEmpty ? [] : ([legs[0].source] + legs.map { $0.destination })
        }
        set {
            let endpointsByLeg = zip(newValue, newValue.suffix(from: 1))
            for (leg, (source, destination)) in zip(legs, endpointsByLeg) {
                leg.source = source
                leg.destination = destination
            }
        }
    }
    
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
    open var expectedTravelTime: TimeInterval
    
    // MARK: Configuring Speech Synthesis
    
    /**
     The locale to use for spoken instructions.
     
     This locale is specific to Mapbox Voice API. If `nil` is returned, the instruction should be spoken with an alternative speech synthesizer.
     */
    open var speechLocale: Locale?
    
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

extension DirectionsResult: CustomStringConvertible {
    public var description: String {
        return legs.map { $0.name }.joined(separator: " – ")
    }
}
extension DirectionsResult: CustomQuickLookConvertible {
    func debugQuickLookObject() -> Any? {
        guard let shape = shape else {
            return nil
        }
        return debugQuickLookURL(illustrating: shape, profileIdentifier: .automobile)
    }
}
