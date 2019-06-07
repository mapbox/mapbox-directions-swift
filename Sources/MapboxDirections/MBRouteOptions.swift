import Foundation
import CoreLocation
#if SWIFT_PACKAGE
import CMapboxDirections
#endif


/**
 By default, pedestrians are assumed to walk at an average rate of 1.42 meters per second (5.11 kilometers per hour or 3.18 miles per hour), corresponding to a typical preferred walking speed.
 */
public let MBDefaultWalkingSpeed: CLLocationSpeed = 1.42

/**
 Pedestrians are assumed to walk no slower than 0.14 meters per second (0.50 kilometers per hour or 0.31 miles per hour) on average.
 */
public let MBMinimumWalkingSpeed: CLLocationSpeed = 0.14

/**
 Pedestrians are assumed to walk no faster than 6.94 meters per second (25.0 kilometers per hour or 15.5 miles per hour) on average.
 */
public let MBMaximumWalkingSpeed: CLLocationSpeed = 6.94

/**
 A `RouteOptions` object is a structure that specifies the criteria for results returned by the Mapbox Directions API.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objcMembers
@objc(MBRouteOptions)
open class RouteOptions: DirectionsOptions {
    /**
     Initializes a route options object for routes between the given locations and an optional profile identifier.

     - note: This initializer is intended for `CLLocation` objects created using the `CLLocation.init(latitude:longitude:)` initializer. If you intend to use a `CLLocation` object obtained from a `CLLocationManager` object, consider increasing the `horizontalAccuracy` or set it to a negative value to avoid overfitting, since the `Waypoint` class’s `coordinateAccuracy` property represents the maximum allowed deviation from the waypoint.

     - parameter locations: An array of `CLLocation` objects representing locations that the route should visit in chronological order. The array should contain at least two locations (the source and destination) and at most 25 locations. Each location object is converted into a `Waypoint` object. This class respects the `CLLocation` class’s `coordinate` and `horizontalAccuracy` properties, converting them into the `Waypoint` class’s `coordinate` and `coordinateAccuracy` properties, respectively.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(locations: [CLLocation], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = locations.map { Waypoint(location: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    /**
     Initializes a route options object for routes between the given geographic coordinates and an optional profile identifier.

     - parameter coordinates: An array of geographic coordinates representing locations that the route should visit in chronological order. The array should contain at least two locations (the source and destination) and at most 25 locations. Each coordinate is converted into a `Waypoint` object.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public convenience init(coordinates: [CLLocationCoordinate2D], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        let waypoints = coordinates.map { Waypoint(coordinate: $0) }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }

    /**
     Initializes a route options object for routes between the given waypoints and an optional profile identifier.

     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public required init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
        self.allowsUTurnAtWaypoint = ![MBDirectionsProfileIdentifier.automobile.rawValue, MBDirectionsProfileIdentifier.automobileAvoidingTraffic.rawValue].contains(self.profileIdentifier.rawValue)
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

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        allowsUTurnAtWaypoint = decoder.decodeBool(forKey: "allowsUTurnAtWaypoint")

        includesAlternativeRoutes = decoder.decodeBool(forKey: "includesAlternativeRoutes")

        includesExitRoundaboutManeuver = decoder.decodeBool(forKey: "includesExitRoundaboutManeuver")

        let roadClassesToAvoidDescriptions = decoder.decodeObject(of: NSString.self, forKey: "roadClassesToAvoid") as String?
        roadClassesToAvoid = RoadClasses(descriptions: roadClassesToAvoidDescriptions?.components(separatedBy: ",") ?? []) ?? []
        
        alleyPriority = MBDirectionsPriority(rawValue: decoder.decodeDouble(forKey: "alleyPriority"))
        walkwayPriority = MBDirectionsPriority(rawValue: decoder.decodeDouble(forKey: "walkwayPriority"))
        speed = decoder.decodeDouble(forKey: "speed")
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(allowsUTurnAtWaypoint, forKey: "allowsUTurnAtWaypoint")
        coder.encode(includesAlternativeRoutes, forKey: "includesAlternativeRoutes")
        coder.encode(includesExitRoundaboutManeuver, forKey: "includesExitRoundaboutManeuver")
        coder.encode(roadClassesToAvoid.description, forKey: "roadClassesToAvoid")
        coder.encode(alleyPriority.rawValue, forKey: "alleyPriority")
        coder.encode(walkwayPriority.rawValue, forKey: "walkwayPriority")
        coder.encode(speed, forKey: "speed")
    }

    internal override var abridgedPath: String {
        return "directions/v5/\(profileIdentifier.rawValue)"
    }

    /**
     A Boolean value that indicates whether a returned route may require a point U-turn at an intermediate waypoint.

     If the value of this property is `true`, a returned route may require an immediate U-turn at an intermediate waypoint. At an intermediate waypoint, if the value of this property is `false`, each returned route may continue straight ahead or turn to either side but may not U-turn. This property has no effect if only two waypoints are specified.

     Set this property to `true` if you expect the user to traverse each leg of the trip separately. For example, it would be quite easy for the user to effectively “U-turn” at a waypoint if the user first parks the car and patronizes a restaurant there before embarking on the next leg of the trip. Set this property to `false` if you expect the user to proceed to the next waypoint immediately upon arrival. For example, if the user only needs to drop off a passenger or package at the waypoint before continuing, it would be inconvenient to perform a U-turn at that location.

     The default value of this property is `false` when the profile identifier is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` and `true` otherwise.
     */
    open var allowsUTurnAtWaypoint: Bool = false

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
     A number that influences whether the route should prefer or avoid alleys or narrow service roads between buildings.
     
     This property has no effect unless the profile identifier is set to `MBDirectionsProfileIdentifier.walking`.
     
     The value of this property must be at least `MBDirectionsPriority.low` and at most `MBDirectionsPriority.high`. The default value of `MBDirectionsPriority.default` neither prefers nor avoids alleys, while a negative value between `MBDirectionsPriority.low` and `MBDirectionsPriority.default` avoids alleys, and a positive value between `MBDirectionsPriority.default` and `MBDirectionsPriority.high` prefers alleys. A value of 0.9 is suitable for pedestrians who are comfortable with walking down alleys.
     */
    open var alleyPriority: MBDirectionsPriority = .default
    
    /**
     A number that influences whether the route should prefer or avoid roads or paths that are set aside for pedestrian-only use (walkways or footpaths).
     
     This property has no effect unless the profile identifier is set to `MBDirectionsProfileIdentifier.walking`. You can adjust this property to avoid [sidewalks and crosswalks that are mapped as separate footpaths](https://wiki.openstreetmap.org/wiki/Sidewalks#Sidewalk_as_separate_way), which may be more granular than needed for some forms of pedestrian navigation.
     
     The value of this property must be at least `MBDirectionsPriority.low` and at most `MBDirectionsPriority.high`. The default value of `MBDirectionsPriority.default` neither prefers nor avoids walkways, while a negative value between `MBDirectionsPriority.low` and `MBDirectionsPriority.default` avoids walkways, and a positive value between `MBDirectionsPriority.default` and `MBDirectionsPriority.high` prefers walkways. A value of −0.1 results in less verbose routes in cities where sidewalks and crosswalks are generally mapped as separate footpaths.
     */
    open var walkwayPriority: MBDirectionsPriority = .default
    
    /**
     The expected uniform travel speed measured in meters per second.
     
     This property has no effect unless the profile identifier is set to `MBDirectionsProfileIdentifier.walking`. You can adjust this property to account for running or for faster or slower gaits. When the profile identifier is set to another profile identifier, such as `MBDirectionsProfileIdentifier.driving`, this property is ignored in favor of the expected travel speed on each road along the route. This property may be supported by other routing profiles in the future.
     
     The value of this property must be at least `MBMinimumWalkingSpeed` and at most `MBMaximumWalkingSpeed`. The default value is `MBDefaultWalkingSpeed`.
     */
    open var speed: CLLocationSpeed = MBDefaultWalkingSpeed

    override open var urlQueryItems: [URLQueryItem] {
        var queryItems = super.urlQueryItems

        queryItems.append(contentsOf: [
            URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)),
            URLQueryItem(name: "continue_straight", value: String(!allowsUTurnAtWaypoint))
        ])
        
        if includesExitRoundaboutManeuver {
            queryItems.append(URLQueryItem(name: "roundabout_exits", value: String(includesExitRoundaboutManeuver)))
        }
        
        if profileIdentifier == .walking {
            queryItems.append(URLQueryItem(name: "alley_bias", value: String(alleyPriority.rawValue)))
            queryItems.append(URLQueryItem(name: "walkway_bias", value: String(walkwayPriority.rawValue)))
            queryItems.append(URLQueryItem(name: "walking_speed", value: String(speed)))
        }

        if !roadClassesToAvoid.isEmpty {
            let allRoadClasses = roadClassesToAvoid.description.components(separatedBy: ",")
            if allRoadClasses.count > 1 {
                assert(false, "`roadClassesToAvoid` only accepts one `RoadClasses`.")
            }
            if let firstRoadClass = allRoadClasses.first {
                queryItems.append(URLQueryItem(name: "exclude", value: firstRoadClass))
            }
        }

        if waypoints.first(where: { CLLocationCoordinate2DIsValid($0.targetCoordinate) }) != nil {
            let targetCoordinates = waypoints.map { $0.targetCoordinate.stringForRequestURL ?? "" }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "waypoint_targets", value: targetCoordinates))
        }

        return queryItems
    }

    /**
     Returns response objects that represent the given JSON dictionary data.

     - parameter json: The API response in JSON dictionary format.
     - returns: A tuple containing an array of waypoints and an array of routes.
     */
    public func response(from json: [String: Any]) -> ([Waypoint]?, [Route]?) {
        var namedWaypoints: [Waypoint]?
        if let jsonWaypoints = (json["waypoints"] as? [JSONDictionary]) {
            namedWaypoints = zip(jsonWaypoints, self.waypoints).map { (api, local) -> Waypoint in
                let location = api["location"] as! [Double]
                let coordinate = CLLocationCoordinate2D(geoJSON: location)
                let possibleAPIName = api["name"] as? String
                let apiName = possibleAPIName?.nonEmptyString
                let waypoint = local.copy() as! Waypoint
                waypoint.coordinate = coordinate
                waypoint.name = waypoint.name ?? apiName
                return waypoint
            }
        }

        let waypoints = namedWaypoints ?? self.waypoints
        waypoints.first?.separatesLegs = true
        waypoints.last?.separatesLegs = true
        let legSeparators = waypoints.filter { $0.separatesLegs }

        let routes = (json["routes"] as? [JSONDictionary])?.map {
            Route(json: $0, waypoints: legSeparators, options: self)
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
        copy.alleyPriority = alleyPriority
        copy.walkwayPriority = walkwayPriority
        copy.speed = speed
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
            roadClassesToAvoid == other.roadClassesToAvoid,
            alleyPriority == other.alleyPriority,
            walkwayPriority == other.walkwayPriority,
            speed == other.speed else { return false }
        return true
    }
}

/**
 A `RouteOptionsV4` object is a structure that specifies the criteria for results returned by the Mapbox Directions API v4.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objcMembers
@objc(MBRouteOptionsV4)
open class RouteOptionsV4: RouteOptions {
    // MARK: Specifying the Response Format

    /**
     The format of the returned route steps’ instructions.

     By default, the value of this property is `text`, specifying plain text instructions.
     */
    open var instructionFormat: InstructionFormat = .text

    /**
     A Boolean value indicating whether the returned routes and their route steps should include any geographic coordinate data.

     If the value of this property is `true`, the returned routes and their route steps include coordinates; if the value of this property is `false, they do not.

     The default value of this property is `true`.
     */
    open var includesShapes: Bool = true
    
    public required init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier?) {
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier)
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        if let description = decoder.decodeObject(of: NSString.self, forKey: "instructionFormat") as String?,
            let format = InstructionFormat(description: description) {
            instructionFormat = format
        }
        
        includesShapes = decoder.decodeBool(forKey: "includesShapes")
    }
    
    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(instructionFormat.description, forKey: "instructionFormat")
        coder.encode(includesShapes, forKey: "includesShapes")
    }
    
    override public class var supportsSecureCoding: Bool {
        return true
    }
    
    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! RouteOptionsV4
        copy.instructionFormat = instructionFormat
        copy.includesShapes = includesShapes
        return copy
    }
    
    internal override var abridgedPath: String {
        let profileIdentifier = self.profileIdentifier.rawValue.replacingOccurrences(of: "/", with: ".")
        return "v4/directions/\(profileIdentifier)"
    }

    override open var urlQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)),
            URLQueryItem(name: "instructions", value: String(describing: instructionFormat)),
            URLQueryItem(name: "geometry", value: includesShapes ? String(describing: shapeFormat) : String(false)),
            URLQueryItem(name: "steps", value: String(includesSteps)),
        ]
    }

    override public func response(from json: [String: Any]) -> ([Waypoint]?, [Route]?) {
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
