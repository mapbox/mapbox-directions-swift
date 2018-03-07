import Foundation

@objc(MBMatchingOptions)
open class MatchingOptions: DirectionsOptions {
    
    /**
     Initializes a match options object for matching locations against the road network.
     
     - parameter location: An array of `CLLocation` objects representing locations the route should try to match the road network against. The array should contain at least two locations (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(locations: [CLLocation], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map {
            Waypoint(location: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
        self.timestamps = locations.map { $0.timestamp }
    }
    
    public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = coordinates.map {
            Waypoint(coordinate: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    @objc public required init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier?) {
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    
    /**
     If true, the input locations are re-sampled for improved map matching results. The default is  `false`.
     */
    @objc open var resamplesTraces: Bool = false
    
    
    /**
     Timestamps corresponding to each coordinate provided in the request.
     
     There must be as many `timestamps` as there are coordinates in the request.
     */
    @objc private var timestamps: [Date]?
    
    
    /**
     An IndexSet of unique integers representing which coordinates should be treated as `Wapoints`.
     */
    @objc open var waypointIndices: IndexSet?
    
    @objc public required convenience init?(coder decoder: NSCoder) {
        self.init(coder: decoder)
        resamplesTraces = decoder.decodeBool(forKey: "resampleTraces")
        timestamps = decoder.decodeObject(of: [NSArray.self, NSDate.self], forKey: "timestamps") as? [Date]
        waypointIndices = decoder.decodeObject(of: NSIndexSet.self, forKey: "waypointIndices") as IndexSet?
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(resamplesTraces, forKey: "resampleTraces")
        coder.encode(timestamps, forKey: "timestamps")
        coder.encode(waypointIndices, forKey: "waypointIndices")
    }
    
    override internal var params: [URLQueryItem] {
        var params = super.params
        
        params.append(URLQueryItem(name: "tidy", value: String(describing: resamplesTraces)))
        
        if let timestamps = timestamps, !timestamps.isEmpty {
            let timeStrings = timestamps.map {
                String(describing: $0.timeIntervalSince1970)
                }.joined(separator: ";")
            
            params.append(URLQueryItem(name: "timestamps", value: timeStrings))
        }
        
        if let waypointIndices = waypointIndices {
            params.append(URLQueryItem(name: "waypoints", value: waypointIndices.map {
                String(describing: $0)
                }.joined(separator: ";")))
        }
        
        return params
    }
    
    internal override var path: String {
        return "matching/v5/\(profileIdentifier.rawValue).json"
    }
    
    internal var encodedParam: String {
        let joinedParams = params.flatMap({ (param) -> String? in
            guard let value = param.value else { return nil }
            return "\(param.name)=\(value)"
        }).joined(separator: "&")
        
        let locations = waypoints.map { "\($0.coordinate.longitude),\($0.coordinate.latitude)" }.joined(separator: ";")
        
        return "\(joinedParams)&locations=\(locations)"
    }
    
    internal func response(from json: JSONDictionary) -> ([Tracepoint]?, [Match]?) {
        let jsonTracePoints = (json["tracepoints"] as! [Any]).flatMap {
            $0 as? JSONDictionary
        }
        let tracePoints = jsonTracePoints.map { api -> Tracepoint in
            let location = api["location"] as! [Double]
            let coordinate = CLLocationCoordinate2D(geoJSON: location)
            let alternateCount = api["alternatives_count"] as! Int
            let waypointIndex = api["waypoint_index"] as? Int
            let matchingIndex = api["matchings_index"] as! Int
            let name = api["name"] as? String
            return Tracepoint(coordinate: coordinate, alternateCount: alternateCount, waypointIndex: waypointIndex, matchingIndex: matchingIndex, name: name)
        }
        
        let matchings = (json["matchings"] as? [JSONDictionary])?.map { 
            Match(json: $0, tracePoints: tracePoints, matchOptions: self)
        }
        
        return (tracePoints, matchings)
    }
    
    /**
     Returns response objects that represent the given JSON dictionary data.
     
     - parameter json: The API response in JSON dictionary format.
     - returns: A tuple containing an array of waypoints and an array of routes.
     */
    internal func response(containingRoutesFrom json: JSONDictionary) -> ([Waypoint]?, [Route]?) {

        var namedWaypoints: [Waypoint]?
        if let jsonWaypoints = (json["tracepoints"] as? [JSONDictionary]) {
            namedWaypoints = zip(jsonWaypoints, self.waypoints).map { (api, local) -> Waypoint in
                let location = api["location"] as! [Double]
                let coordinate = CLLocationCoordinate2D(geoJSON: location)
                let possibleAPIName = api["name"] as? String
                let apiName = possibleAPIName?.nonEmptyString
                return Waypoint(coordinate: coordinate, name: local.name ?? apiName)
            }
        }
        
        let waypoints = namedWaypoints ?? self.waypoints
        let opts = RouteOptions(matchOptions: self)
        
        var filteredWaypoints: [Waypoint]?
        if let indices = self.waypointIndices {
            filteredWaypoints = []
            for (i, waypoint) in waypoints.enumerated() {
                if indices.contains(i) {
                    filteredWaypoints?.append(waypoint)
                }
            }
        }
        
        let routes = (json["matchings"] as? [JSONDictionary])?.map {
            Route(json: $0, waypoints: filteredWaypoints ?? waypoints, routeOptions: opts)
        }
        
        return (waypoints, routes)
    }
}
