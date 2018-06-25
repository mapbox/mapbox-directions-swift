import Polyline

/**
 A `Match` object defines a single route that was created from a series of points that were matched against a road network.
 
 Typically, you do not create instances of this class directly. Instead, you receive match objects when you pass a `MatchOptions` object into the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method.
 */
@objc(MBMatch)
open class Match: DirectionsResult {
    
    init(matchOptions: MatchOptions, legs: [RouteLeg], tracepoints: [Tracepoint], distance: CLLocationDistance, expectedTravelTime: TimeInterval, coordinates: [CLLocationCoordinate2D]?, confidence: Float, speechLocale: Locale?, waypointIndices: IndexSet) {
        self.confidence = confidence
        self.tracepoints = tracepoints
        self.waypointIndices = waypointIndices
        super.init(legs: legs, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, speechLocale: speechLocale, options: matchOptions)
    }
    
    /**
     Initializes a new match object with the given JSON dictionary representation and tracepoints.
     
     - parameter json: A JSON dictionary representation of the route as returned by the Mapbox Map Matching API.
     - parameter tracepoints: An array of `Tracepoint` that the match found in order.
     - parameter matchOptions: The `MatchOptions` used to create the request.
    */
    @objc(initWithJSON:tracepoints:waypointIndices:matchOptions:)
    public convenience init(json: [String: Any], tracepoints: [Tracepoint], waypointIndices: IndexSet, matchOptions: MatchOptions) {
        let legInfo = zip(zip(tracepoints.prefix(upTo: tracepoints.endIndex - 1), tracepoints.suffix(from: 1)),
                          json["legs"] as? [JSONDictionary] ?? [])
        let legs = legInfo.map { (endpoints, json) -> RouteLeg in
            return RouteLeg(json: json, source: endpoints.0, destination: endpoints.1, options: RouteOptions(matchOptions: matchOptions))
        }
        
        let distance = json["distance"] as! Double
        let expectedTravelTime = json["duration"] as! Double
        
        let coordinates = matchOptions.shapeFormat.coordinates(from: json["geometry"])
        
        let confidence = (json["confidence"] as! NSNumber).floatValue
        
        var speechLocale: Locale?
        if let locale = json["voiceLocale"] as? String {
            speechLocale = Locale(identifier: locale)
        }
        
        self.init(matchOptions: matchOptions, legs: legs, tracepoints: tracepoints, distance: distance, expectedTravelTime: expectedTravelTime, coordinates: coordinates, confidence: confidence, speechLocale: speechLocale, waypointIndices: waypointIndices)
    }
    
    /**
     A number between 0 and 1 that indicates the Map Matching API’s confidence that the match is accurate. A higher confidence means the match is more likely to be accurate.
     */
    @objc open var confidence: Float
    
    
    /**
     Tracepoints on the road network that match the tracepoints in the match options.
     
     Any outlier tracepoint is omitted from the match. This array represents an outlier tracepoint is a `Tracepoint` object whose `Tracepoint.coordinate` property is `kCLLocationCoordinate2DInvalid`.
     */
    @objc open var tracepoints: [Tracepoint]
    
    
    /**
     Index of the waypoint inside the matched route.
     */
    @objc open var waypointIndices: IndexSet?
    
    /**
     `MatchOptions` used to create the match request.
     */
    public var matchOptions: MatchOptions {
        return super.directionsOptions as! MatchOptions
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        confidence = decoder.decodeFloat(forKey: "confidence")
        
        guard let tracepoints = decoder.decodeObject(of: [NSArray.self, Tracepoint.self], forKey: "tracepoints") as? [Tracepoint] else {
            return nil
        }
        self.tracepoints = tracepoints
        
        waypointIndices = decoder.decodeObject(of: NSIndexSet.self, forKey: "waypointIndices") as IndexSet?
        
        super.init(coder: decoder)
    }
    
    override public class var supportsSecureCoding: Bool {
        return true
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(confidence, forKey: "confidence")
        coder.encode(tracepoints, forKey: "tracepoints")
        coder.encode(waypointIndices, forKey: "waypointIndices")
        super.encode(with: coder)
    }
    
    //MARK: - OBJ-C Equality
    open override func isEqual(_ object: Any?) -> Bool {
        guard let opts = object as? Match else { return false }
        return isEqual(to: opts)
    }
    
    @objc(isEqualToMatch:)
    open func isEqual(to match: Match?) -> Bool {
        guard let other = match else { return false }
        guard tracepoints == other.tracepoints,
            matchOptions == other.matchOptions,
            confidence == other.confidence else { return false }
        return true
    }
}
