import Polyline

@objc(MBRouteLeg)
public class RouteLeg: NSObject {
    // MARK: Getting the Leg Geometry
    
    public let source: Waypoint
    public let destination: Waypoint
    public let steps: [RouteStep]
    
    // MARK: Getting Additional Leg Details
    
    public let name: String
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public let profileIdentifier: String
    
    // MARK: Creating a Leg
    
    internal init(json: JSONDictionary, source: Waypoint, destination: Waypoint, profileIdentifier: String) {
        self.source = source
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        let name = json["summary"] as? String
        var stepNamesByDistance: [String: CLLocationDistance] = [:]
        steps = (json["steps"] as? [JSONDictionary] ?? []).map { json in
            let step = RouteStep(json: json)
            // If no summary is provided for some reason, synthesize one out of the two names that make up the longest cumulative distance along the route.
            if name == nil || name!.isEmpty {
                if let stepName = step.name where !stepName.isEmpty {
                    stepNamesByDistance[stepName] = (stepNamesByDistance[stepName] ?? 0) + step.distance
                }
            }
            return step
        }
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        let longestNames = Array(stepNamesByDistance.sort { $0.1 > $1.1 }.prefix(2))
        self.name = name ?? longestNames.map { $0.0 }.joinWithSeparator(" – ")
    }
}
