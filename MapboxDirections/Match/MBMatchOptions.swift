import Foundation

/**
 A `MatchOptions` object is a structure that specifies the criteria for results returned by the Mapbox Map Matching API.
 
 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */

@objc(MBMatchOptions)
open class MatchOptions: DirectionsOptions {
    
    /**
     Initializes a match options object for matching locations against the road network.
     
     - parameter locations: An array of `CLLocation` objects representing locations to attempt to match against the road network. The array should contain at least two locations (the source and destination) and at most 25 locations. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc public convenience init(locations: [CLLocation], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map {
            Waypoint(location: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    /**
     Initializes a match options object for matching geographic coordinates against the road network.
     
     - parameter coordinates: An array of geographic coordinates representing locations to attempt to match against the road network. The array should contain at least two locations (the source and destination) and at most 25 locations. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).) Each coordinate is converted into a `Waypoint` object.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
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
     An index set containing indices of two or more items in `coordinates`. These will be represented by `Waypoint`s in the resulting `Match` objects.
     
     Use this property when the `includesSteps` property is `true` or when `coordinates` represents a trace with a high sample rate. If this property is `nil`, the resulting `Match` objects contain a waypoint for each coordinate in the match options.
     
     If specified, each index must correspond to a valid index in `coordinates`, and the index set must contain 0 and the last index (one less than `endIndex`) of `coordinates`.
     */
    @objc open var waypointIndices: IndexSet?
    
    @objc public required init?(coder decoder: NSCoder) {
        resamplesTraces = decoder.decodeBool(forKey: "resampleTraces")
        waypointIndices = decoder.decodeObject(of: NSIndexSet.self, forKey: "waypointIndices") as IndexSet?
        super.init(coder: decoder)
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(resamplesTraces, forKey: "resampleTraces")
        coder.encode(waypointIndices, forKey: "waypointIndices")
        super.encode(with: coder)
    }
    
    public override class var supportsSecureCoding: Bool {
        return true
    }
    
    override internal var params: [URLQueryItem] {
        var params = super.params
        
        params.append(URLQueryItem(name: "tidy", value: String(describing: resamplesTraces)))
        
        if let waypointIndices = waypointIndices {
            params.append(URLQueryItem(name: "waypoints", value: waypointIndices.map {
                String(describing: $0)
                }.joined(separator: ";")))
        }
        
        return params
    }
    
    internal override var path: String {
        return "matching/v5/\(profileIdentifier.rawValue)"
    }
    
    internal var encodedParam: String {
        let joinedParams = params.compactMap({ (param) -> String? in
            guard let value = param.value else { return nil }
            return "\(param.name)=\(value)"
        }).joined(separator: "&")
        
        let locations = waypoints.map { "\($0.coordinate.longitude),\($0.coordinate.latitude)" }.joined(separator: ";")
        
        return "\(joinedParams)&coordinates=\(locations)"
    }
    
    internal func response(from json: JSONDictionary) -> [Match]? {
        
        var waypointIndices = IndexSet()
        
        let tracepoints = (json["tracepoints"] as! [Any]).map { api -> Tracepoint in
            guard let api = api as? JSONDictionary else {
                return Tracepoint(coordinate: kCLLocationCoordinate2DInvalid, alternateCount: nil, name: nil)
            }
            let location = api["location"] as! [Double]
            let coordinate = CLLocationCoordinate2D(geoJSON: location)
            let alternateCount = api["alternatives_count"] as! Int
            let name = api["name"] as? String
            if let waypointIndex = api["waypoint_index"] as? Int {
                waypointIndices.insert(waypointIndex)
            }
            return Tracepoint(coordinate: coordinate, alternateCount: alternateCount, name: name)
        }
        
        let matchings = (json["matchings"] as? [JSONDictionary])?.map { 
            Match(json: $0, tracepoints: tracepoints, waypointIndices: waypointIndices, matchOptions: self)
        }
        
        return matchings
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
            Route(json: $0, waypoints: filteredWaypoints ?? waypoints, options: opts)
        }
        
        return (waypoints, routes)
    }
}
