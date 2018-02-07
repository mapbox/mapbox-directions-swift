import Foundation

@objc(MBMatchingOptions)
open class MatchingOptions: RouteOptions {
    
    /**
     Initializes a match options object for matching locations against the road network.
     
     - parameter location: An array of `CLLocation` objects representing locations the route should try to match the road network against. The array should contain at least two locations (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public init(locations: [CLLocation], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map {
            Waypoint(location: $0)
        }
        self.timestamps = locations.map { $0.timestamp }
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    
    /**
     If true, the input locations are re-sampled for improved map matching results. The default is  `false`.
     */
    @objc open var resampleTraces: Bool = false
    
    
    /**
     Timestamps corresponding to each coordinate provided in the request.
     
     There must be as many `timestamps` as there are coordinates in the request.
     */
    @objc private var timestamps: [Date]?
    
    
    /**
     An IndexSet of unique integers representing which coordinates should be treated as `Wapoints`.
     */
    @objc open var waypointIndices: IndexSet?
    
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var params: [URLQueryItem] {
        var params = super.params
        
        params.append(URLQueryItem(name: "tidy", value: String(describing: resampleTraces)))
        
        if let timestamps = timestamps, !timestamps.isEmpty {
            let timeStrings = timestamps.map {
                String(describing: $0.timeIntervalSince1970)
                }.joined(separator: ";")
            
            params.append(URLQueryItem(name: "timestamps", value: timeStrings))
        }
        
        if let waypointIndices = waypointIndices {
            params.append(URLQueryItem(name: "waypoints", value: waypointIndices.map {
                String(describing: $0)
                }.joined(separator: ",")))
        }
        
        return params
    }
    
    override internal var path: String {
        assert(!queries.isEmpty, "No query")
        
        let queryComponent = queries.joined(separator: ";")
        return "matching/v5/\(profileIdentifier.rawValue)/\(queryComponent).json"
    }
    
    internal func responseMatchOptions(from json: JSONDictionary) -> ([Tracepoint]?, [Match]?) {
        let jsonTracePoints = (json["tracepoints"] as! [JSONDictionary])
        let tracePoints = jsonTracePoints.map { api -> Tracepoint in
            let location = api["location"] as! [Double]
            let coordinate = CLLocationCoordinate2D(geoJSON: location)
            let alternateCount = api["alternatives_count"] as! Int
            let waypointIndex = api["waypoint_index"] as! Int
            let matchingIndex = api["matchings_index"] as! Int
            let name = api["name"] as? String
            return Tracepoint(coordinate: coordinate, alternateCount: alternateCount, waypointIndex: waypointIndex, matchingIndex: matchingIndex, name: name)
        }
        
        let matchings = (json["matchings"] as? [JSONDictionary])?.map { 
            Match(json: $0, tracePoints: tracePoints, matchOptions: self)
        }
        
        return (tracePoints, matchings)
    }
}
