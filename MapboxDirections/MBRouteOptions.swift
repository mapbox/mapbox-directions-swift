/**
 A `RouteOptions` object is a structure that specifies the criteria for results returned by the Mapbox Directions API.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBRouteOptions)
open class RouteOptions: DirectionsOptions {
    /**
     Initializes a route options object for routes between the given locations and an optional profile identifier.

     - note: This initializer is intended for `CLLocation` objects created using the `CLLocation.init(latitude:longitude:)` initializer. If you intend to use a `CLLocation` object obtained from a `CLLocationManager` object, consider increasing the `horizontalAccuracy` or set it to a negative value to avoid overfitting, since the `Waypoint` class’s `coordinateAccuracy` property represents the maximum allowed deviation from the waypoint.

     - parameter locations: An array of `CLLocation` objects representing locations that the route should visit in chronological order. The array should contain at least two locations (the source and destination) and at most 25 locations. Each location object is converted into a `Waypoint` object. This class respects the `CLLocation` class’s `coordinate` and `horizontalAccuracy` properties, converting them into the `Waypoint` class’s `coordinate` and `coordinateAccuracy` properties, respectively.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc public convenience init(locations: [CLLocation], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map { Waypoint(location: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    /**
     Initializes a route options object for routes between the given geographic coordinates and an optional profile identifier.

     - parameter coordinates: An array of geographic coordinates representing locations that the route should visit in chronological order. The array should contain at least two locations (the source and destination) and at most 25 locations. Each coordinate is converted into a `Waypoint` object.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = coordinates.map { Waypoint(coordinate: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    /**
     Initializes a route options object for routes between the given waypoints and an optional profile identifier.
     
     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc public required init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
        self.allowsUTurnAtWaypoint = ![MBDirectionsProfileIdentifier.automobile.rawValue, MBDirectionsProfileIdentifier.automobileAvoidingTraffic.rawValue].contains(self.profileIdentifier.rawValue)
    }
    
    @objc internal convenience init(matchOptions: MatchOptions) {
        self.init(waypoints: matchOptions.waypoints, profileIdentifier: matchOptions.profileIdentifier)
        self.includesSteps = matchOptions.includesSteps
        self.shapeFormat = matchOptions.shapeFormat
        self.attributeOptions = matchOptions.attributeOptions
        self.routeShapeResolution = matchOptions.routeShapeResolution
        self.locale = matchOptions.locale
        self.includesSpokenInstructions = matchOptions.includesSpokenInstructions
        self.includesVisualInstructions = matchOptions.includesVisualInstructions
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        allowsUTurnAtWaypoint = decoder.decodeBool(forKey: "allowsUTurnAtWaypoint")

        includesAlternativeRoutes = decoder.decodeBool(forKey: "includesAlternativeRoutes")

        includesExitRoundaboutManeuver = decoder.decodeBool(forKey: "includesExitRoundaboutManeuver")

        let roadClassesToAvoidDescriptions = decoder.decodeObject(of: NSString.self, forKey: "roadClassesToAvoid") as String?
        roadClassesToAvoid = RoadClasses(descriptions: roadClassesToAvoidDescriptions?.components(separatedBy: ",") ?? []) ?? []
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(allowsUTurnAtWaypoint, forKey: "allowsUTurnAtWaypoint")
        coder.encode(includesAlternativeRoutes, forKey: "includesAlternativeRoutes")
        coder.encode(includesExitRoundaboutManeuver, forKey: "includesExitRoundaboutManeuver")
        coder.encode(roadClassesToAvoid.description, forKey: "roadClassesToAvoid")
    }
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal override var path: String {
        assert(!queries.isEmpty, "No query")
        
        let queryComponent = queries.joined(separator: ";")
        return "directions/v5/\(profileIdentifier.rawValue)/\(queryComponent).json"
    }

    /**
     A Boolean value that indicates whether a returned route may require a point U-turn at an intermediate waypoint.

     If the value of this property is `true`, a returned route may require an immediate U-turn at an intermediate waypoint. At an intermediate waypoint, if the value of this property is `false`, each returned route may continue straight ahead or turn to either side but may not U-turn. This property has no effect if only two waypoints are specified.

     Set this property to `true` if you expect the user to traverse each leg of the trip separately. For example, it would be quite easy for the user to effectively “U-turn” at a waypoint if the user first parks the car and patronizes a restaurant there before embarking on the next leg of the trip. Set this property to `false` if you expect the user to proceed to the next waypoint immediately upon arrival. For example, if the user only needs to drop off a passenger or package at the waypoint before continuing, it would be inconvenient to perform a U-turn at that location.

     The default value of this property is `false` when the profile identifier is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` and `true` otherwise.
     */
    @objc open var allowsUTurnAtWaypoint: Bool = false

    /**
     A Boolean value indicating whether alternative routes should be included in the response.

     If the value of this property is `false`, the server only calculates a single route that visits each of the waypoints. If the value of this property is `true`, the server attempts to find additional reasonable routes that visit the waypoints. Regardless, multiple routes are only returned if it is possible to visit the waypoints by a different route without significantly increasing the distance or travel time. The alternative routes may partially overlap with the preferred route, especially if intermediate waypoints are specified.

     Alternative routes may take longer to calculate and make the response significantly larger, so only request alternative routes if you intend to display them to the user or let the user choose them over the preferred route. For example, do not request alternative routes if you only want to know the distance or estimated travel time to a destination.

     The default value of this property is `false`.
     */
    @objc open var includesAlternativeRoutes = false

    /**
     A Boolean value indicating whether the route includes a `ManeuverType.exitRoundabout` or `ManeuverType.exitRotary` step when traversing a roundabout or rotary, respectively.

     If this option is set to `true`, a route that traverses a roundabout includes both a `ManeuverType.takeRoundabout` step and a `ManeuverType.exitRoundabout` step; likewise, a route that traverses a large, named roundabout includes both a `ManeuverType.takeRotary` step and a `ManeuverType.exitRotary` step. Otherwise, it only includes a `ManeuverType.takeRoundabout` or `ManeuverType.takeRotary` step. This option is set to `false` by default.
     */
    @objc open var includesExitRoundaboutManeuver = false

    /**
     The route classes that the calculated routes will avoid.
     
     Currently, you can only specify a single road class to avoid.
     */
    @objc open var roadClassesToAvoid: RoadClasses = []
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal override var params: [URLQueryItem] {
        var params = super.params
        
        params.append(contentsOf: [
            URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)),
            URLQueryItem(name: "continue_straight", value: String(!allowsUTurnAtWaypoint))
        ])

        if includesExitRoundaboutManeuver {
            params.append(URLQueryItem(name: "roundabout_exits", value: String(includesExitRoundaboutManeuver)))
        }
        
        if !roadClassesToAvoid.isEmpty {
            let allRoadClasses = roadClassesToAvoid.description.components(separatedBy: ",")
            if allRoadClasses.count > 1 {
                assert(false, "`roadClassesToAvoid` only accepts one `RoadClasses`.")
            }
            if let firstRoadClass = allRoadClasses.first {
                params.append(URLQueryItem(name: "exclude", value: firstRoadClass))
            }
        }

        return params
    }

    /**
     Returns response objects that represent the given JSON dictionary data.

     - parameter json: The API response in JSON dictionary format.
     - returns: A tuple containing an array of waypoints and an array of routes.
     */
    internal func response(from json: JSONDictionary) -> ([Waypoint]?, [Route]?) {
        var namedWaypoints: [Waypoint]?
        if let jsonWaypoints = (json["waypoints"] as? [JSONDictionary]) {
            namedWaypoints = zip(jsonWaypoints, self.waypoints).map { (api, local) -> Waypoint in
                let location = api["location"] as! [Double]
                let coordinate = CLLocationCoordinate2D(geoJSON: location)
                let possibleAPIName = api["name"] as? String
                let apiName = possibleAPIName?.nonEmptyString
                return Waypoint(coordinate: coordinate, name: local.name ?? apiName)
            }
        }
        
        let waypoints = namedWaypoints ?? self.waypoints
        
        let routes = (json["routes"] as? [JSONDictionary])?.map {
            Route(json: $0, waypoints: waypoints, options: self)
        }
        return (waypoints, routes)
    }
    
    override public class var supportsSecureCoding: Bool {
        return true
    }
    
    
    // MARK: NSCopying
    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! RouteOptions
        copy.allowsUTurnAtWaypoint = allowsUTurnAtWaypoint
        copy.includesAlternativeRoutes = includesAlternativeRoutes
        copy.includesExitRoundaboutManeuver = includesExitRoundaboutManeuver
        copy.roadClassesToAvoid = roadClassesToAvoid
        return copy
    }
    
    //MARK: - OBJ-C Equality
    open override func isEqual(_ object: Any?) -> Bool {
        guard let opts = object as? RouteOptions else { return false }
        return isEqual(to: opts)
    }
    
    @objc(isEqualToRouteOptions:)
    open func isEqual(to routeOptions: RouteOptions?) -> Bool {
        guard let other = routeOptions else { return false }
        guard super.isEqual(to: routeOptions) else { return false }
        guard allowsUTurnAtWaypoint == other.allowsUTurnAtWaypoint,
            includesAlternativeRoutes == other.includesAlternativeRoutes,
            includesExitRoundaboutManeuver == other.includesExitRoundaboutManeuver,
            roadClassesToAvoid == other.roadClassesToAvoid else { return false }
        return true
    }
}

/**
 A `RouteOptionsV4` object is a structure that specifies the criteria for results returned by the Mapbox Directions API v4.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBRouteOptionsV4)
open class RouteOptionsV4: RouteOptions {
    // MARK: Specifying the Response Format

    /**
     The format of the returned route steps’ instructions.

     By default, the value of this property is `text`, specifying plain text instructions.
     */
    @objc open var instructionFormat: InstructionFormat = .text

    /**
     A Boolean value indicating whether the returned routes and their route steps should include any geographic coordinate data.

     If the value of this property is `true`, the returned routes and their route steps include coordinates; if the value of this property is `false, they do not.

     The default value of this property is `true`.
     */
    @objc open var includesShapes: Bool = true

    override var path: String {
        assert(!queries.isEmpty, "No query")

        let profileIdentifier = self.profileIdentifier.rawValue.replacingOccurrences(of: "/", with: ".")
        let queryComponent = queries.joined(separator: ";")
        return "v4/directions/\(profileIdentifier)/\(queryComponent).json"
    }

    override var params: [URLQueryItem] {
        return [
            URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)),
            URLQueryItem(name: "instructions", value: String(describing: instructionFormat)),
            URLQueryItem(name: "geometry", value: includesShapes ? String(describing: shapeFormat) : String(false)),
            URLQueryItem(name: "steps", value: String(includesSteps)),
        ]
    }

    override func response(from json: JSONDictionary) -> ([Waypoint]?, [Route]?) {
        let sourceWaypoint = Waypoint(geoJSON: json["origin"] as! JSONDictionary)!
        let destinationWaypoint = Waypoint(geoJSON: json["destination"] as! JSONDictionary)!
        let intermediateWaypoints = (json["waypoints"] as! [JSONDictionary]).compactMap { Waypoint(geoJSON: $0) }
        let waypoints = [sourceWaypoint] + intermediateWaypoints + [destinationWaypoint]
        let routes = (json["routes"] as? [JSONDictionary])?.map {
            RouteV4(json: $0, waypoints: waypoints, options: self)
        }
        return (waypoints, routes)
    }
}

