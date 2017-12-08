import Polyline

/**
 A `RouteLeg` object defines a single leg of a route between two waypoints. If the overall route has only two waypoints, it has a single `RouteLeg` object that covers the entire route. The route leg object includes information about the leg, such as its name, distance, and expected travel time. Depending on the criteria used to calculate the route, the route leg object may also include detailed turn-by-turn instructions.
 
 You do not create instances of this class directly. Instead, you receive route leg objects as part of route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBRouteLeg)
open class RouteLeg: NSObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case source
        case destination
        case steps
        case name = "summary"
        case distance = "distance"
        case expectedTravelTime = "duration"
        case profileIdentifier
        case annotation
    }
    
    private enum AnnotationCodingKeys: String, CodingKey {
        case openStreetMapNodeIdentifiers = "nodes"
        case segmentDistances = "distance"
        case expectedSegmentTravelTimes = "duration"
        case segmentSpeeds = "speed"
        case segmentCongestionLevels = "congestion"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(destination, forKey: .destination)
        try container.encode(steps, forKey: .steps)
        try container.encode(name, forKey: .name)
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encode(profileIdentifier.rawValue, forKey: .profileIdentifier)
        
        var annotation = container.nestedContainer(keyedBy: AnnotationCodingKeys.self, forKey: .annotation)
        try annotation.encode(openStreetMapNodeIdentifiers, forKey: .openStreetMapNodeIdentifiers)
        try annotation.encode(segmentDistances, forKey: .segmentDistances)
        try annotation.encode(expectedSegmentTravelTimes, forKey: .expectedSegmentTravelTimes)
        try annotation.encode(segmentSpeeds, forKey: .segmentSpeeds)
        try annotation.encode(segmentCongestionLevels, forKey: .segmentCongestionLevels)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let options = decoder.userInfo[CodingUserInfoKey.routeOptions!] as? RouteOptions
        
        source = try container.decodeIfPresent(Waypoint.self, forKey: .source)
        destination = try container.decodeIfPresent(Waypoint.self, forKey: .destination)
        steps = try container.decode([RouteStep].self, forKey: .steps)
        name = try container.decode(String.self, forKey: .name)
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
        
        if let profileIdentifier = options?.profileIdentifier {
            self.profileIdentifier = profileIdentifier
        } else {
            profileIdentifier = MBDirectionsProfileIdentifier(rawValue: try container.decode(String.self, forKey: .profileIdentifier))
        }
        
        let annotation = try? container.nestedContainer(keyedBy: AnnotationCodingKeys.self, forKey: .annotation)
        openStreetMapNodeIdentifiers = try annotation?.decodeIfPresent([Int64].self, forKey: .openStreetMapNodeIdentifiers)
        segmentDistances = try annotation?.decodeIfPresent([CLLocationDistance].self, forKey: .segmentDistances)
        expectedSegmentTravelTimes = try annotation?.decodeIfPresent([TimeInterval].self, forKey: .expectedSegmentTravelTimes)
        segmentSpeeds = try annotation?.decodeIfPresent([CLLocationSpeed].self, forKey: .segmentSpeeds)
        if let congestionLevels = try annotation?.decodeIfPresent([String].self, forKey: .segmentCongestionLevels) {
            segmentCongestionLevels = congestionLevels.map { CongestionLevel(description: $0)! }
        } else {
            segmentCongestionLevels = nil
        }
    }
    
    // MARK: Getting the Leg Geometry
    
    /**
     The starting point of the route leg.
     
     Unless this is the first leg of the route, the source of this leg is the same as the destination of the previous leg.
     */
    @objc open var source: Waypoint!
    
    /**
     The endpoint of the route leg.
     
     Unless this is the last leg of the route, the destination of this leg is the same as the source of the next leg.
     */
    @objc open var destination: Waypoint!
    
    /**
     An array of one or more `RouteStep` objects representing the steps for traversing this leg of the route.
     
     Each route step object corresponds to a distinct maneuver and the approach to the next maneuver.
     
     This array is empty if the `includesSteps` property of the original `RouteOptions` object is set to `false`.
     */
    @objc open let steps: [RouteStep]
    
    /**
     An array containing [OpenStreetMap node identifiers](https://wiki.openstreetmap.org/wiki/Node), one for each coordinate along the route geometry.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.openStreetMapNodeIdentifier`.
     */
    @objc open let openStreetMapNodeIdentifiers: [Int64]?
    
    /**
     An array containing the distance (measured in meters) between each coordinate in the route leg geometry.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.distance`.
     */
    @objc open let segmentDistances: [CLLocationDistance]?
    
    /**
     An array containing the expected travel time (measured in seconds) between each coordinate in the route leg geometry.
     
     These values are dynamic, accounting for any conditions that may change along a segment, such as traffic congestion if the profile identifier is set to `.automobileAvoidingTraffic`.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.expectedTravelTime`.
     */
    @objc open let expectedSegmentTravelTimes: [TimeInterval]?
    
    /**
     An array containing the expected average speed (measured in meters per second) between each coordinate in the route leg geometry.
     
     These values are dynamic; rather than speed limits, they account for the road’s classification and/or any traffic congestion (if the profile identifier is set to `.automobileAvoidingTraffic`).
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.speed`.
     */
    @objc open let segmentSpeeds: [CLLocationSpeed]?
    
    /**
     An array containing the traffic congestion level along each road segment in the route leg geometry.
     
     Traffic data is available in [a number of countries and territories worldwide](https://www.mapbox.com/api-documentation/pages/traffic-countries.html).
     
     You can color-code a route line according to the congestion level along each segment of the route.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.congestionLevel`.
     */
    open let segmentCongestionLevels: [CongestionLevel]?
    
    // MARK: Getting Additional Leg Details
    
    /**
     A name that describes the route leg.
     
     The name describes the leg using the most significant roads or trails along the route leg. You can display this string to the user to help the user can distinguish one route from another based on how the legs of the routes are named.
     
     The leg’s name does not identify the start and end points of the leg. To distinguish one leg from another within the same route, concatenate the `name` properties of the `source` and `destination` waypoints.
     */
    @objc open let name: String
    
    @objc open override var description: String {
        return name
    }
    
    /**
     The route leg’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to arrive at the destination from the source. It is not the direct distance between the source and destination, nor should not assume that the user would travel along this distance at a fixed speed.
     */
    @objc open let distance: CLLocationDistance
    
    /**
     The route leg’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to traverse the route leg. If the route was calculated using the `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` profile, this property reflects current traffic conditions at the time of the request, not necessarily the traffic conditions at the time the user would begin this leg. For other profiles, this property reflects travel time under ideal conditions and does not account for traffic congestion. If the leg makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     
     Do not assume that the user would travel along the leg at a fixed speed. For the expected travel time on each individual segment along the leg, use the `RouteStep.expectedTravelTimes` property. For more granularity, specify the `AttributeOptions.expectedTravelTime` option and use the `expectedSegmentTravelTimes` property.
     */
    @objc open let expectedTravelTime: TimeInterval
    
    /**
     A string specifying the primary mode of transportation for the route leg.
     
     The value of this property is `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`, depending on the `profileIdentifier` property of the original `RouteOptions` object. This property reflects the primary mode of transportation used for the route leg. Individual steps along the route leg might use different modes of transportation as necessary.
     */
    @objc open let profileIdentifier: MBDirectionsProfileIdentifier
    
    func debugQuickLookObject() -> Any? {
        let coordinates = steps.reduce([], { $0 + ($1.coordinates ?? []) })
        guard !coordinates.isEmpty else {
            return nil
        }
        return debugQuickLookURL(illustrating: coordinates)
    }
}

// MARK: Support for Directions API v4

internal class RouteLegV4: RouteLeg {
    // TODO: Fix
//    internal convenience init(json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: MBDirectionsProfileIdentifier) {
//        let steps = (json["steps"] as? [JSONDictionary] ?? []).map { RouteStepV4(json: $0) }
//        self.init(steps: steps, json: json, source: source, destination: destination, profileIdentifier: profileIdentifier)
//    }
}
