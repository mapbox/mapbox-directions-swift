import Polyline

@objc(MBMatch)
open class Match: Route {
    
    init(matchOptions: MatchOptions, legs: [RouteLeg], distance: CLLocationDistance, expectedTravelTime: TimeInterval, coordinates: [CLLocationCoordinate2D]?) {
        super.init(routeOptions: matchOptions, legs: legs, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates)
    }
    
    convenience init(json: [String: Any], tracePoints: [TracePoint], matchOptions: MatchOptions) {
        let legInfo = zip(zip(tracePoints.prefix(upTo: tracePoints.endIndex - 1), tracePoints.suffix(from: 1)),
                          json["legs"] as? [JSONDictionary] ?? [])
        let legs = legInfo.map { (endpoints, json) -> RouteLeg in
            RouteLeg(json: json, source: endpoints.0, destination: endpoints.1, profileIdentifier: matchOptions.profileIdentifier)
        }
        
        let distance = json["distance"] as! Double
        let expectedTravelTime = json["duration"] as! Double
        
        var coordinates: [CLLocationCoordinate2D]?
        switch json["geometry"] {
        case let geometry as JSONDictionary:
            coordinates = CLLocationCoordinate2D.coordinates(geoJSON: geometry)
        case let geometry as String:
            coordinates = decodePolyline(geometry, precision: 1e5)!
        default:
            coordinates = nil
        }
        
        self.init(matchOptions: matchOptions, legs: legs, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates)
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
