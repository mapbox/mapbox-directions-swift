import Polyline

@objc(MBRoute)
public class Route: NSObject {
    // MARK: Getting the Route Geometry
    
    public let coordinates: [CLLocationCoordinate2D]
    public let legs: [RouteLeg]
    
    // MARK: Getting Additional Route Details
    
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public let profileIdentifier: String
    
    // MARK: Creating a Route
    
    internal init(json: JSONDictionary, waypoints: [Waypoint], profileIdentifier: String) {
        self.profileIdentifier = profileIdentifier
        
        // Associate each leg JSON with a source and destination. The sequence of destinations is offset by one from the sequence of sources.
        let legInfo = zip(zip(waypoints.prefixUpTo(waypoints.endIndex - 1), waypoints.suffixFrom(1)),
                          json["legs"] as? [JSONDictionary] ?? [])
        legs = legInfo.map { (endpoints, json) -> RouteLeg in
            RouteLeg(json: json, source: endpoints.0, destination: endpoints.1, profileIdentifier: profileIdentifier)
        }
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        coordinates = decodePolyline(json["geometry"] as! String, precision: 1e5)!
    }
}
