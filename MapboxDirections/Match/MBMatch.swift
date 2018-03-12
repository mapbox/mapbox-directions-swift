import Polyline

/**
 A `Match` object defines a single route that was created from a series of points that were matched against a road network.
 
 Typically, you do not create instances of this class directly. Instead, you receive match objects when you pass a `MatchingOptions` object into the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method.
 */
@objc(MBMatch)
open class Match: DirectionsResult {
    
    init(matchOptions: MatchingOptions, legs: [RouteLeg], tracepoints: [Tracepoint], distance: CLLocationDistance, expectedTravelTime: TimeInterval, coordinates: [CLLocationCoordinate2D]?, confidence: Float, speechLocale: Locale?) {
        self.confidence = confidence
        self.tracepoints = tracepoints
        super.init(options: matchOptions, legs: legs, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, speechLocale: speechLocale)
    }
    
    /**
     Initializes a new match object with the given JSON dictionary representation and tracepoints.
     
     - parameter json: A JSON dictionary representation of the route as returned by the Mapbox Mapbox Map Matching API.
     - parameter tracepoints: An array of `Tracepoint` that the match found in order.
     - parameter matchOptions: The `MatchingOptions` used to create the request.
    */
    @objc public convenience init(json: [String: Any], tracepoints: [Tracepoint], matchOptions: MatchingOptions) {
        let legInfo = zip(zip(tracepoints.prefix(upTo: tracepoints.endIndex - 1), tracepoints.suffix(from: 1)),
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
        
        let confidence = json["confidence"] as! Float
        
        var speechLocale: Locale?
        if let locale = json["voiceLocale"] as? String {
            speechLocale = Locale(identifier: locale)
        }
        
        self.init(matchOptions: matchOptions, legs: legs, tracepoints: tracepoints, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, confidence: confidence, speechLocale: speechLocale)
    }
    
    /**
     A number between 0 and 1 that indicates the Map Matching API’s confidence that the match is accurate. A higher confidence means the match is more likely to be accurate.
     */
    @objc open var confidence: Float
    
    
    /**
     Tracepoints on the road network that match the tracepoints in the matching options.
     */
    @objc open var tracepoints: [Tracepoint]?
    
    /**
     `MatchingOptions` used to create the match request.
     */
    public var matchingOptions: MatchingOptions {
        return super.directionsOptions as! MatchingOptions
    }
    
    @objc public required convenience init?(coder decoder: NSCoder) {
        self.init(coder: decoder)
        confidence = decoder.decodeFloat(forKey: "confidence")
        
        guard let tracepoints = decoder.decodeObject(of: [NSArray.self, Tracepoint.self], forKey: "tracepoints") as? [Tracepoint] else {
            return nil
        }
        self.tracepoints = tracepoints
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(confidence, forKey: "confidence")
        coder.encode(tracepoints, forKey: "tracepoints")
    }
}
