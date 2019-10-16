
/**
 A `RouteOptions` object is a structure that specifies the criteria for results returned by the Mapbox Directions API.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
open class RouteOptions: DirectionsOptions {
    // MARK: Creating a Route Options Object

    /**
     Initializes a route options object for routes between the given waypoints and an optional profile identifier.

     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public required init(waypoints: [Waypoint], profileIdentifier: DirectionsProfileIdentifier? = nil) {

        let profilesDisallowingUTurns: [DirectionsProfileIdentifier] = [.automobile, .automobileAvoidingTraffic]
        allowsUTurnAtWaypoint =  !profilesDisallowingUTurns.contains(profileIdentifier ?? .automobile)
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    /**
     Initializes a route options object for routes between the given locations and an optional profile identifier.

     - note: This initializer is intended for `CLLocation` objects created using the `CLLocation.init(latitude:longitude:)` initializer. If you intend to use a `CLLocation` object obtained from a `CLLocationManager` object, consider increasing the `horizontalAccuracy` or set it to a negative value to avoid overfitting, since the `Waypoint` class’s `coordinateAccuracy` property represents the maximum allowed deviation from the waypoint.

     - parameter locations: An array of `CLLocation` objects representing locations that the route should visit in chronological order. The array should contain at least two locations (the source and destination) and at most 25 locations. Each location object is converted into a `Waypoint` object. This class respects the `CLLocation` class’s `coordinate` and `horizontalAccuracy` properties, converting them into the `Waypoint` class’s `coordinate` and `coordinateAccuracy` properties, respectively.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(locations: [CLLocation], profileIdentifier: DirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map { Waypoint(location: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    /**
     Initializes a route options object for routes between the given geographic coordinates and an optional profile identifier.

     - parameter coordinates: An array of geographic coordinates representing locations that the route should visit in chronological order. The array should contain at least two locations (the source and destination) and at most 25 locations. Each coordinate is converted into a `Waypoint` object.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: DirectionsProfileIdentifier? = nil) {
        let waypoints = coordinates.map { Waypoint(coordinate: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    private enum CodingKeys: String, CodingKey {
        case allowsUTurnAtWaypoint
        case includesAlternativeRoutes
       // case includesSteps
       // case shapeFormat
        //case routeShapeResolution
       // case attributeOptions
        case includesExitRoundaboutManeuver
       // case locale
       // case includesSpokenInstructions
        //case distanceMeasurementSystem
        //case includesVisualInstructions
        case roadClassesToAvoid
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(allowsUTurnAtWaypoint, forKey: .allowsUTurnAtWaypoint)
        try container.encode(includesAlternativeRoutes, forKey: .includesAlternativeRoutes)
        try container.encode(includesExitRoundaboutManeuver, forKey: .includesExitRoundaboutManeuver)
        try container.encode(roadClassesToAvoid, forKey: .roadClassesToAvoid)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        allowsUTurnAtWaypoint = try container.decode(Bool.self, forKey: .allowsUTurnAtWaypoint)

        includesAlternativeRoutes = try container.decode(Bool.self, forKey: .includesAlternativeRoutes)

        includesExitRoundaboutManeuver = try container.decode(Bool.self, forKey: .includesExitRoundaboutManeuver)
    
        roadClassesToAvoid = try container.decode(RoadClasses.self, forKey: .roadClassesToAvoid)
        try super.init(from: decoder)
    }
    
    internal convenience init(matchOptions: MatchOptions) {
        self.init(waypoints: matchOptions.waypoints, profileIdentifier: matchOptions.profileIdentifier)
        self.includesSteps = matchOptions.includesSteps
        self.shapeFormat = matchOptions.shapeFormat
        self.attributeOptions = matchOptions.attributeOptions
        self.routeShapeResolution = matchOptions.routeShapeResolution
        self.locale = matchOptions.locale
        self.includesSpokenInstructions = matchOptions.includesSpokenInstructions
        self.includesVisualInstructions = matchOptions.includesVisualInstructions
    }
    
    // MARK: Specifying the Path of the Route

    /**
     A Boolean value that indicates whether a returned route may require a point U-turn at an intermediate waypoint.

     If the value of this property is `true`, a returned route may require an immediate U-turn at an intermediate waypoint. At an intermediate waypoint, if the value of this property is `false`, each returned route may continue straight ahead or turn to either side but may not U-turn. This property has no effect if only two waypoints are specified.

     Set this property to `true` if you expect the user to traverse each leg of the trip separately. For example, it would be quite easy for the user to effectively “U-turn” at a waypoint if the user first parks the car and patronizes a restaurant there before embarking on the next leg of the trip. Set this property to `false` if you expect the user to proceed to the next waypoint immediately upon arrival. For example, if the user only needs to drop off a passenger or package at the waypoint before continuing, it would be inconvenient to perform a U-turn at that location.

     The default value of this property is `false` when the profile identifier is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` and `true` otherwise.
     */
    open var allowsUTurnAtWaypoint: Bool


    // MARK: Specifying the Response Format

    /**
     A Boolean value indicating whether alternative routes should be included in the response.

     If the value of this property is `false`, the server only calculates a single route that visits each of the waypoints. If the value of this property is `true`, the server attempts to find additional reasonable routes that visit the waypoints. Regardless, multiple routes are only returned if it is possible to visit the waypoints by a different route without significantly increasing the distance or travel time. The alternative routes may partially overlap with the preferred route, especially if intermediate waypoints are specified.

     Alternative routes may take longer to calculate and make the response significantly larger, so only request alternative routes if you intend to display them to the user or let the user choose them over the preferred route. For example, do not request alternative routes if you only want to know the distance or estimated travel time to a destination.

     The default value of this property is `false`.
     */
    open var includesAlternativeRoutes = false


    /**
     A Boolean value indicating whether the route includes a `ManeuverType.exitRoundabout` or `ManeuverType.exitRotary` step when traversing a roundabout or rotary, respectively.

     If this option is set to `true`, a route that traverses a roundabout includes both a `ManeuverType.takeRoundabout` step and a `ManeuverType.exitRoundabout` step; likewise, a route that traverses a large, named roundabout includes both a `ManeuverType.takeRotary` step and a `ManeuverType.exitRotary` step. Otherwise, it only includes a `ManeuverType.takeRoundabout` or `ManeuverType.takeRotary` step. This option is set to `false` by default.
     */
    open var includesExitRoundaboutManeuver = false


    /**
     The route classes that the calculated routes will avoid.
     
     Currently, you can only specify a single road class to avoid.
     */
    open var roadClassesToAvoid: RoadClasses = []
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)),
//            URLQueryItem(name: "geometries", value: String(describing: shapeFormat)),
//            URLQueryItem(name: "overview", value: String(describing: routeShapeResolution)),
//            URLQueryItem(name: "steps", value: String(includesSteps)),
            URLQueryItem(name: "continue_straight", value: String(!allowsUTurnAtWaypoint)),
//            URLQueryItem(name: "language", value: locale.identifier)
        ]

        if includesExitRoundaboutManeuver {
            params.append(URLQueryItem(name: "roundabout_exits", value: String(includesExitRoundaboutManeuver)))
        }

//        if includesSpokenInstructions {
//            params.append(URLQueryItem(name: "voice_instructions", value: String(includesSpokenInstructions)))
//            params.append(URLQueryItem(name: "voice_units", value: String(describing: distanceMeasurementSystem)))
//        }
        
        if includesVisualInstructions {
            params.append(URLQueryItem(name: "banner_instructions", value: String(includesVisualInstructions)))
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

//        // Include headings and heading accuracies if any waypoint has a nonnegative heading.
//        if !waypoints.filter({ $0.heading >= 0 }).isEmpty {
//            let headings = waypoints.map { $0.headingDescription }.joined(separator: ";")
//            params.append(URLQueryItem(name: "bearings", value: headings))
//        }

//        // Include location accuracies if any waypoint has a nonnegative coordinate accuracy.
//        if !waypoints.filter({ $0.coordinateAccuracy >= 0 }).isEmpty {
//            let accuracies = waypoints.map {
//                $0.coordinateAccuracy >= 0 ? String($0.coordinateAccuracy) : "unlimited"
//                }.joined(separator: ";")
//            params.append(URLQueryItem(name: "radiuses", value: accuracies))
//        }
//
//        if !attributeOptions.isEmpty {
//            let attributesStrings = String(describing:attributeOptions)
//
//            params.append(URLQueryItem(name: "annotations", value: attributesStrings))
//        }

        return params
    }
    
//    // MARK: NSCopying
//    public func copy(with zone: NSZone? = nil) -> Any {
//        let data = try! JSONEncoder().encode(self)
//        return try! JSONDecoder().decode(RouteOptions.self, from: data)
//    }
//
//    //MARK: - OBJ-C Equality
//    open override func isEqual(_ object: Any?) -> Bool {
//        guard let opts = object as? RouteOptions else { return false }
//        return isEqual(to: opts)
//    }
//
//    @objc(isEqualToRouteOptions:)
//    open func isEqual(to routeOptions: RouteOptions?) -> Bool {
//        guard let other = routeOptions else { return false }
//        guard waypoints == other.waypoints,
//            profileIdentifier == other.profileIdentifier,
//            allowsUTurnAtWaypoint == other.allowsUTurnAtWaypoint,
//            includesSteps == other.includesSteps,
//            shapeFormat == other.shapeFormat,
//            routeShapeResolution == other.routeShapeResolution,
//            attributeOptions == other.attributeOptions,
//            includesExitRoundaboutManeuver == other.includesExitRoundaboutManeuver,
//            locale == other.locale,
//            includesSpokenInstructions == other.includesSpokenInstructions,
//            includesVisualInstructions == other.includesVisualInstructions,
//            roadClassesToAvoid == other.roadClassesToAvoid,
//            distanceMeasurementSystem == other.distanceMeasurementSystem else { return false }
//        return true
//    }
}

// MARK: Support for Directions API v4

/**
 A `RouteShapeFormat` indicates the format of a route’s shape in the raw HTTP response.
 */
public enum InstructionFormat: String {
    /**
     The route steps’ instructions are delivered in plain text format.
     */
    case text
    /**
     The route steps’ instructions are delivered in HTML format.

     Key phrases are boldfaced.
     */
    case html
}

