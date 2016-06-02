import Polyline

/**
 A `RouteLeg` object defines a single leg of a route between two waypoints. If the overall route has only two waypoints, it has a single `RouteLeg` object that covers the entire route. The route leg object includes information about the leg, such as its name, distance, and expected travel time. Depending on the criteria used to calculate the route, the route leg object may also include detailed turn-by-turn instructions.
 
 You do not create instances of this class directly. Instead, you receive route leg objects as part of route objects when you request directions using the `Directions.calculateDirections(options:completionHandler:)` method.
 */
@objc(MBRouteLeg)
public class RouteLeg: NSObject {
    // MARK: Getting the Leg Geometry
    
    /**
     The starting point of the route leg.
     
     Unless this is the first leg of the route, the source of this leg is the same as the destination of the previous leg.
     */
    public let source: Waypoint
    
    /**
     The endpoint of the route leg.
     
     Unless this is the last leg of the route, the destination of this leg is the same as the source of the next leg.
     */
    public let destination: Waypoint
    
    /**
     An array of one or more `RouteStep` objects representing the steps for traversing this leg of the route.
     
     Each route step object corresponds to a distinct maneuver and the approach to the next maneuver.
     
     This array is empty if the `includesSteps` property of the original `RouteOptions` object is set to `false`.
     */
    public let steps: [RouteStep]
    
    // MARK: Getting Additional Leg Details
    
    /**
     A name that describes the route leg.
     
     The name describes the leg using the most significant roads or trails along the route leg. You can display this string to the user to help the user can distinguish one route from another based on how the legs of the routes are named.
     
     The leg’s name does not identify the start and end points of the leg. To distinguish one leg from another within the same route, concatenate the `name` properties of the `source` and `destination` waypoints.
     */
    public let name: String
    
    public override var description: String {
        return name
    }
    
    /**
     The route leg’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to arrive at the destination from the source. It is not the direct distance between the source and destination, nor should not assume that the user would travel along this distance at a fixed speed.
     */
    public let distance: CLLocationDistance
    
    /**
     The route leg’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to traverse the route leg under ideal conditions. You should not assume that the user would travel along the route leg at a fixed speed. The actual travel time may vary based on the weather, traffic conditions, road construction, and other variables. If the route leg makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     */
    public let expectedTravelTime: NSTimeInterval
    
    /**
     A string specifying the primary mode of transportation for the route leg.
     
     The value of this property is `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`, depending on the `profileIdentifier` property of the original `RouteOptions` object. This property reflects the primary mode of transportation used for the route leg. Individual steps along the route leg might use different modes of transportation as necessary.
     */
    public let profileIdentifier: String
    
    // MARK: Creating a Leg
    
    internal init(steps: [RouteStep], json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: String) {
        self.source = source
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        self.steps = steps
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        self.name = json["summary"] as! String
    }
    
    internal convenience init(json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: String) {
        let steps = (json["steps"] as? [JSONDictionary] ?? []).map { RouteStep(json: $0) }
        self.init(steps: steps, json: json, source: source, destination: destination, profileIdentifier: profileIdentifier)
    }
}

// MARK: Support for Directions API v4

internal class RouteLegV4: RouteLeg {
    internal convenience init(json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: String) {
        let steps = (json["steps"] as? [JSONDictionary] ?? []).map { RouteStepV4(json: $0) }
        self.init(steps: steps, json: json, source: source, destination: destination, profileIdentifier: profileIdentifier)
    }
}
