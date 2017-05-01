/**
 A `RouteShapeFormat` indicates the format of a route’s shape in the raw HTTP response.
 */
@objc(MBRouteShapeFormat)
public enum RouteShapeFormat: UInt, CustomStringConvertible {
    /**
     The route’s shape is delivered in [GeoJSON](http://geojson.org/) format.
     
     This standard format is human-readable and can be parsed straightforwardly, but it is far more verbose than `polyline`.
     */
    case geoJSON
    /**
     The route’s shape is delivered in [encoded polyline algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm) format.
     
     This machine-readable format is considerably more compact than `geoJSON`.
     */
    case polyline
    
    public init?(description: String) {
        let format: RouteShapeFormat
        switch description {
        case "geojson":
            format = .geoJSON
        case "polyline":
            format = .polyline
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .geoJSON:
            return "geojson"
        case .polyline:
            return "polyline"
        }
    }
}

/**
 A `RouteShapeResolution` indicates the level of detail in a route’s shape, or whether the shape is present at all.
 */
@objc(MBRouteShapeResolution)
public enum RouteShapeResolution: UInt, CustomStringConvertible {
    /**
     The route’s shape is omitted.
     
     Specify this resolution if you do not intend to show the route line to the user or analyze the route line in any way.
     */
    case none
    /**
     The route’s shape is simplified.
     
     This resolution considerably reduces the size of the response. The resulting shape is suitable for display at a low zoom level, but it lacks the detail necessary for focusing on individual segments of the route.
     */
    case low
    /**
     The route’s shape is as detailed as possible.
     
     The resulting shape is equivalent to concatenating the shapes of all the route’s consitituent steps. You can focus on individual segments of this route while faithfully representing the path of the route. If you only intend to show a route overview and do not need to analyze the route line in any way, consider specifying `low` instead to considerably reduce the size of the response.
     */
    case full
    
    public init?(description: String) {
        let granularity: RouteShapeResolution
        switch description {
        case "false":
            granularity = .none
        case "simplified":
            granularity = .low
        case "full":
            granularity = .full
        default:
            return nil
        }
        self.init(rawValue: granularity.rawValue)
    }
    
    public var description: String {
        switch self {
        case .none:
            return "false"
        case .low:
            return "simplified"
        case .full:
            return "full"
        }
    }
}

/**
 A `RouteOptions` object is a structure that specifies the criteria for results returned by the Mapbox Directions API.
 
 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBRouteOptions)
open class RouteOptions: NSObject, NSSecureCoding {
    // MARK: Creating a Route Options Object
    
    /**
     Initializes a route options object for routes between the given waypoints and an optional profile identifier.
     
     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    public init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        assert(waypoints.count >= 2, "A route requires at least a source and destination.")
        assert(waypoints.count <= 25, "A route may not have more than 25 waypoints.")
        
        self.waypoints = waypoints
        self.profileIdentifier = profileIdentifier ?? .automobile
        self.allowsUTurnAtWaypoint = ![MBDirectionsProfileIdentifier.automobile.rawValue, MBDirectionsProfileIdentifier.automobileAvoidingTraffic.rawValue].contains(self.profileIdentifier.rawValue)
    }
    
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
    
    public required init?(coder decoder: NSCoder) {
        guard let waypoints = decoder.decodeObject(of: [NSArray.self, Waypoint.self], forKey: "waypoints") as? [Waypoint] else {
            return nil
        }
        self.waypoints = waypoints
        
        allowsUTurnAtWaypoint = decoder.decodeBool(forKey: "allowsUTurnAtWaypoint")
        
        guard let profileIdentifier = decoder.decodeObject(of: NSString.self, forKey: "profileIdentifier") as String? else {
            return nil
        }
        self.profileIdentifier = MBDirectionsProfileIdentifier(rawValue: profileIdentifier)
        
        includesAlternativeRoutes = decoder.decodeBool(forKey: "includesAlternativeRoutes")
        includesSteps = decoder.decodeBool(forKey: "includesSteps")
        
        guard let shapeFormat = RouteShapeFormat(description: decoder.decodeObject(of: NSString.self, forKey: "shapeFormat") as String? ?? "") else {
            return nil
        }
        self.shapeFormat = shapeFormat
        
        guard let routeShapeResolution = RouteShapeResolution(description: decoder.decodeObject(of: NSString.self, forKey: "routeShapeResolution") as String? ?? "") else {
            return nil
        }
        self.routeShapeResolution = routeShapeResolution
        
        guard let descriptions = decoder.decodeObject(of: NSString.self, forKey: "attributeOptions") as String?,
            let attributeOptions = AttributeOptions(descriptions: descriptions.components(separatedBy: ",")) else {
            return nil
        }
        self.attributeOptions = attributeOptions
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(waypoints, forKey: "waypoints")
        coder.encode(allowsUTurnAtWaypoint, forKey: "allowsUTurnAtWaypoint")
        coder.encode(profileIdentifier, forKey: "profileIdentifier")
        coder.encode(includesAlternativeRoutes, forKey: "includesAlternativeRoutes")
        coder.encode(includesSteps, forKey: "includesSteps")
        coder.encode(shapeFormat.description, forKey: "shapeFormat")
        coder.encode(routeShapeResolution.description, forKey: "routeShapeResolution")
        coder.encode(attributeOptions.description, forKey: "attributeOptions")
    }
    
    // MARK: Specifying the Path of the Route
    
    /**
     An array of `Waypoint` objects representing locations that the route should visit in chronological order.
     
     A waypoint object indicates a location to visit, as well as an optional heading from which to approach the location.
     
     The array should contain at least two waypoints (the source and destination) and at most 25 waypoints.
     */
    open var waypoints: [Waypoint]
    
    /**
     A Boolean value that indicates whether a returned route may require a point U-turn at an intermediate waypoint.
     
     If the value of this property is `true`, a returned route may require an immediate U-turn at an intermediate waypoint. At an intermediate waypoint, if the value of this property is `false`, each returned route may continue straight ahead or turn to either side but may not U-turn. This property has no effect if only two waypoints are specified.
     
     Set this property to `true` if you expect the user to traverse each leg of the trip separately. For example, it would be quite easy for the user to effectively “U-turn” at a waypoint if the user first parks the car and patronizes a restaurant there before embarking on the next leg of the trip. Set this property to `false` if you expect the user to proceed to the next waypoint immediately upon arrival. For example, if the user only needs to drop off a passenger or package at the waypoint before continuing, it would be inconvenient to perform a U-turn at that location.
     
     The default value of this property is `false` when the profile identifier is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` and `true` otherwise.
     */
    open var allowsUTurnAtWaypoint: Bool
    
    // MARK: Specifying Transportation Options
    
    /**
     A string specifying the primary mode of transportation for the routes.
     
     This property should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. The default value of this property is `MBDirectionsProfileIdentifierAutomobile`, which specifies driving directions.
     */
    open var profileIdentifier: MBDirectionsProfileIdentifier
    
    // MARK: Specifying the Response Format
    
    /**
     A Boolean value indicating whether alternative routes should be included in the response.
     
     If the value of this property is `false`, the server only calculates a single route that visits each of the waypoints. If the value of this property is `true`, the server attempts to find additional reasonable routes that visit the waypoints. Regardless, multiple routes are only returned if it is possible to visit the waypoints by a different route without significantly increasing the distance or travel time. The alternative routes may partially overlap with the preferred route, especially if intermediate waypoints are specified.
     
     Alternative routes may take longer to calculate and make the response significantly larger, so only request alternative routes if you intend to display them to the user or let the user choose them over the preferred route. For example, do not request alternative routes if you only want to know the distance or estimated travel time to a destination.
     
     The default value of this property is `false`.
     */
    open var includesAlternativeRoutes = false
    
    /**
     A Boolean value indicating whether `MBRouteStep` objects should be included in the response.
     
     If the value of this property is `true`, the returned route contains turn-by-turn instructions. Each returned `MBRoute` object contains one or more `MBRouteLeg` object that in turn contains one or more `MBRouteStep` objects. On the other hand, if the value of this property is `false`, the `MBRouteLeg` objects contain no `MBRouteStep` objects.
     
     If you only want to know the distance or estimated travel time to a destination, set this property to `false` to minimize the size of the response and the time it takes to calculate the response. If you need to display turn-by-turn instructions, set this property to `true`.
     
     The default value of this property is `false`.
     */
    open var includesSteps = false
    
    /**
     Format of the data from which the shapes of the returned route and its steps are derived.
     
     This property has no effect on the returned shape objects, although the choice of format can significantly affect the size of the underlying HTTP response.
     
     The default value of this property is `polyline`.
     */
    open var shapeFormat = RouteShapeFormat.polyline
    
    /**
     Resolution of the shape of the returned route.
     
     This property has no effect on the shape of the returned route’s steps.
     
     The default value of this property is `low`, specifying a low-resolution route shape.
     */
    open var routeShapeResolution = RouteShapeResolution.low
    
    /**
     AttributeOptions for the route. Any combination of `AttributeOptions` can be specified.
     
     By default, no attribute options are specified. It is recommended that `routeShapeResolution` be set to `.full`.
     */
    open var attributeOptions: AttributeOptions = []
    
    // MARK: Constructing the Request URL
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        assert(!queries.isEmpty, "No query")
        
        let queryComponent = queries.joined(separator: ";")
        return "directions/v5/\(profileIdentifier.rawValue)/\(queryComponent).json"
    }
    
    /**
     An array of geocoding query strings to include in the request URL.
     */
    internal var queries: [String] {
        return waypoints.map { "\($0.coordinate.longitude),\($0.coordinate.latitude)" }
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "alternatives", value: String(includesAlternativeRoutes)),
            URLQueryItem(name: "geometries", value: String(describing: shapeFormat)),
            URLQueryItem(name: "overview", value: String(describing: routeShapeResolution)),
            URLQueryItem(name: "steps", value: String(includesSteps)),
            URLQueryItem(name: "continue_straight", value: String(!allowsUTurnAtWaypoint)),
        ]
        
        // Include headings and heading accuracies if any waypoint has a nonnegative heading.
        if !waypoints.filter({ $0.heading >= 0 }).isEmpty {
            let headings = waypoints.map { $0.headingDescription }.joined(separator: ";")
            params.append(URLQueryItem(name: "bearings", value: headings))
        }
        
        // Include location accuracies if any waypoint has a nonnegative coordinate accuracy.
        if !waypoints.filter({ $0.coordinateAccuracy >= 0 }).isEmpty {
            let accuracies = waypoints.map {
                $0.coordinateAccuracy >= 0 ? String($0.coordinateAccuracy) : "unlimited"
                }.joined(separator: ";")
            params.append(URLQueryItem(name: "radiuses", value: accuracies))
        }
        
        if !attributeOptions.isEmpty {
            let attributesStrings = String(describing:attributeOptions)
            
            params.append(URLQueryItem(name: "annotations", value: attributesStrings))
        }
        
        return params
    }
    
    /**
     Returns response objects that represent the given JSON dictionary data.
     
     - parameter json: The API response in JSON dictionary format.
     - returns: A tuple containing an array of waypoints and an array of routes.
     */
    internal func response(_ json: JSONDictionary) -> ([Waypoint]?, [Route]?) {
        let waypoints = (json["waypoints"] as? [JSONDictionary])?.map { waypoint -> Waypoint in
            let location = waypoint["location"] as! [Double]
            let coordinate = CLLocationCoordinate2D(geoJSON: location)
            return Waypoint(coordinate: coordinate, name: waypoint["name"] as? String)
        }
        let routes = (json["routes"] as? [JSONDictionary])?.map {
            Route(json: $0, waypoints: waypoints ?? self.waypoints, routeOptions: self)
        }
        return (waypoints, routes)
    }
}

// MARK: Support for Directions API v4

/**
 A `RouteShapeFormat` indicates the format of a route’s shape in the raw HTTP response.
 */
@objc(MBInstructionFormat)
public enum InstructionFormat: UInt, CustomStringConvertible {
    /**
     The route steps’ instructions are delivered in plain text format.
     */
    case text
    /**
     The route steps’ instructions are delivered in HTML format.
     
     Key phrases are boldfaced.
     */
    case html
    
    public init?(description: String) {
        let format: InstructionFormat
        switch description {
        case "text":
            format = .text
        case "html":
            format = .html
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .text:
            return "text"
        case .html:
            return "html"
        }
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
    open var instructionFormat: InstructionFormat = .text
    
    /**
     A Boolean value indicating whether the returned routes and their route steps should include any geographic coordinate data.
     
     If the value of this property is `true`, the returned routes and their route steps include coordinates; if the value of this property is `false, they do not.
     
     The default value of this property is `true`.
     */
    open var includesShapes: Bool = true
    
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
    
    override func response(_ json: JSONDictionary) -> ([Waypoint]?, [Route]?) {
        let sourceWaypoint = Waypoint(geoJSON: json["origin"] as! JSONDictionary)!
        let destinationWaypoint = Waypoint(geoJSON: json["destination"] as! JSONDictionary)!
        let intermediateWaypoints = (json["waypoints"] as! [JSONDictionary]).flatMap { Waypoint(geoJSON: $0) }
        let waypoints = [sourceWaypoint] + intermediateWaypoints + [destinationWaypoint]
        let routes = (json["routes"] as? [JSONDictionary])?.map {
            RouteV4(json: $0, waypoints: waypoints, routeOptions: self)
        }
        return (waypoints, routes)
    }
}
