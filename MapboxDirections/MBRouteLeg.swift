import Polyline

/**
 A `RouteLeg` object defines a single leg of a route between two waypoints. If the overall route has only two waypoints, it has a single `RouteLeg` object that covers the entire route. The route leg object includes information about the leg, such as its name, distance, and expected travel time. Depending on the criteria used to calculate the route, the route leg object may also include detailed turn-by-turn instructions.
 
 You do not create instances of this class directly. Instead, you receive route leg objects as part of route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBRouteLeg)
open class RouteLeg: NSObject, NSSecureCoding {

    // MARK: Creating a Leg
    
    internal init(steps: [RouteStep], json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: MBDirectionsProfileIdentifier) {
        self.source = source
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        self.steps = steps
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        self.name = json["summary"] as! String
        
        var segmentDistances: [CLLocationDistance]?
        var expectedSegmentTravelTimes: [TimeInterval]?
        var segmentSpeeds: [CLLocationSpeed]?
        var openStreetMapNodeIdentifiers: [Int64]?
        
        if let jsonAttributes = json["annotation"] as? [String: Any] {
            if let distance = jsonAttributes["distance"] {
                segmentDistances = distance as? [CLLocationDistance]
            }
            if let duration = jsonAttributes["duration"] {
                expectedSegmentTravelTimes = duration as? [TimeInterval] ?? []
            }
            if let speed = jsonAttributes["speed"] {
                segmentSpeeds = speed as? [CLLocationSpeed] ?? []
            }
            if let nodes = jsonAttributes["nodes"] {
                openStreetMapNodeIdentifiers = nodes as? [Int64] ?? []
            }
        }
        
        self.segmentDistances = segmentDistances
        self.expectedSegmentTravelTimes = expectedSegmentTravelTimes
        self.segmentSpeeds = segmentSpeeds
        self.openStreetMapNodeIdentifiers = openStreetMapNodeIdentifiers
    }
    
    /**
     Initializes a new route leg object with the given JSON dictionary representation and waypoints.
     
     Normally, you do not create instances of this class directly. Instead, you receive route leg objects as part of route objects when you request directions using the `Directions.calculateDirections(options:completionHandler:)` method.
     
     - parameter json: A JSON dictionary representation of a route leg object as returnd by the Mapbox Directions API.
     - parameter source: The waypoint at the beginning of the leg.
     - parameter destination: The waypoint at the end of the leg.
     - parameter profileIdentifier: The profile identifier used to request the routes.
     */
    public convenience init(json: [String: Any], source: Waypoint, destination: Waypoint, profileIdentifier: MBDirectionsProfileIdentifier) {
        let steps = (json["steps"] as? [JSONDictionary] ?? []).map { RouteStep(json: $0) }
        
        self.init(steps: steps, json: json, source: source, destination: destination, profileIdentifier: profileIdentifier)
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let decodedSource = decoder.decodeObject(of: Waypoint.self, forKey: "source") else {
            return nil
        }
        source = decodedSource
        
        guard let decodedDestination = decoder.decodeObject(of: Waypoint.self, forKey: "destination") else {
            return nil
        }
        destination = decodedDestination
        
        steps = decoder.decodeObject(of: [NSArray.self, RouteStep.self], forKey: "steps") as? [RouteStep] ?? []
        
        guard let decodedName = decoder.decodeObject(of: NSString.self, forKey: "name") as String? else {
            return nil
        }
        name = decodedName
        
        distance = decoder.decodeDouble(forKey: "distance")
        expectedTravelTime = decoder.decodeDouble(forKey: "expectedTravelTime")
        
        guard let decodedProfileIdentifier = decoder.decodeObject(of: NSString.self, forKey: "profileIdentifier") as String? else {
            return nil
        }
        profileIdentifier = MBDirectionsProfileIdentifier(rawValue: decodedProfileIdentifier)
        
        segmentDistances = decoder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "segmentDistances") as? [CLLocationDistance]
        expectedSegmentTravelTimes = decoder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "expectedSegmentTravelTimes") as? [TimeInterval]
        segmentSpeeds = decoder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "segmentSpeeds") as? [CLLocationSpeed]
        openStreetMapNodeIdentifiers = decoder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "openStreetMapNodeIdentifiers") as? [Int64]
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(source, forKey: "source")
        coder.encode(destination, forKey: "destination")
        coder.encode(steps, forKey: "steps")
        coder.encode(name, forKey: "name")
        coder.encode(distance, forKey: "distance")
        coder.encode(expectedTravelTime, forKey: "expectedTravelTime")
        coder.encode(profileIdentifier, forKey: "profileIdentifier")
        coder.encode(segmentDistances, forKey: "segmentDistances")
        coder.encode(expectedSegmentTravelTimes, forKey: "expectedSegmentTravelTimes")
        coder.encode(segmentSpeeds, forKey: "segmentSpeeds")
        coder.encode(openStreetMapNodeIdentifiers, forKey: "openStreetMapNodeIdentifiers")
    }
    
    // MARK: Getting the Leg Geometry
    
    /**
     The starting point of the route leg.
     
     Unless this is the first leg of the route, the source of this leg is the same as the destination of the previous leg.
     */
    open let source: Waypoint
    
    /**
     The endpoint of the route leg.
     
     Unless this is the last leg of the route, the destination of this leg is the same as the source of the next leg.
     */
    open let destination: Waypoint
    
    /**
     An array of one or more `RouteStep` objects representing the steps for traversing this leg of the route.
     
     Each route step object corresponds to a distinct maneuver and the approach to the next maneuver.
     
     This array is empty if the `includesSteps` property of the original `RouteOptions` object is set to `false`.
     */
    open let steps: [RouteStep]
    
    /**
     An array containing the distance (measured in meters) between each coordinate in the route leg geometry.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.distance`.
     */
    open let segmentDistances: [CLLocationDistance]?
    
    /**
     An array containing the expected travel time (measured in seconds) between each coordinate in the route leg geometry.
     
     These values are dynamic, accounting for any conditions that may change along a segment, such as traffic congestion if the profile identifier is set to `.automobileAvoidingTraffic`.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.expectedTravelTime`.
     */
    open let expectedSegmentTravelTimes: [TimeInterval]?
    
    /**
     An array containing the expected average speed (measured in meters per second) between each coordinate in the route leg geometry.
     
     These values are dynamic; rather than speed limits, they account for the road’s classification and/or any traffic congestion (if the profile identifier is set to `.automobileAvoidingTraffic`).
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.speed`.
     */
    open let segmentSpeeds: [CLLocationSpeed]?
    
    /**
     An array containing [OpenStreetMap node identifiers](https://wiki.openstreetmap.org/wiki/Node), one for each coordinate along the route geometry.
     
     This property is set if the `RouteOptions.attributeOptions` property contains `.openStreetMapNodeIdentifier`.
     */
    open let openStreetMapNodeIdentifiers: [Int64]?
    
    // MARK: Getting Additional Leg Details
    
    /**
     A name that describes the route leg.
     
     The name describes the leg using the most significant roads or trails along the route leg. You can display this string to the user to help the user can distinguish one route from another based on how the legs of the routes are named.
     
     The leg’s name does not identify the start and end points of the leg. To distinguish one leg from another within the same route, concatenate the `name` properties of the `source` and `destination` waypoints.
     */
    open let name: String
    
    open override var description: String {
        return name
    }
    
    /**
     The route leg’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to arrive at the destination from the source. It is not the direct distance between the source and destination, nor should not assume that the user would travel along this distance at a fixed speed.
     */
    open let distance: CLLocationDistance
    
    /**
     The route leg’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to traverse the route leg under ideal conditions. You should not assume that the user would travel along the route leg at a fixed speed. The actual travel time may vary based on the weather, traffic conditions, road construction, and other variables. If the route leg makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     */
    open let expectedTravelTime: TimeInterval
    
    /**
     A string specifying the primary mode of transportation for the route leg.
     
     The value of this property is `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`, depending on the `profileIdentifier` property of the original `RouteOptions` object. This property reflects the primary mode of transportation used for the route leg. Individual steps along the route leg might use different modes of transportation as necessary.
     */
    open let profileIdentifier: MBDirectionsProfileIdentifier
}

// MARK: Support for Directions API v4

internal class RouteLegV4: RouteLeg {
    internal convenience init(json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: MBDirectionsProfileIdentifier) {
        let steps = (json["steps"] as? [JSONDictionary] ?? []).map { RouteStepV4(json: $0) }
        self.init(steps: steps, json: json, source: source, destination: destination, profileIdentifier: profileIdentifier)
    }
}
