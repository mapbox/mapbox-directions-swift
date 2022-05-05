import Foundation
import Polyline
import Turf

/**
 Maximum length of an HTTP request URL for the purposes of switching from GET to
 POST.
 
 https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-limits.html#limits-general
 */
let MaximumURLLength = 1024 * 8

/**
 A `RouteShapeFormat` indicates the format of a route or match shape in the raw HTTP response.
 */
public enum RouteShapeFormat: String, Codable {
    /**
     The route’s shape is delivered in [GeoJSON](http://geojson.org/) format.

     This standard format is human-readable and can be parsed straightforwardly, but it is far more verbose than `polyline`.
     */
    case geoJSON = "geojson"
    /**
     The route’s shape is delivered in [encoded polyline algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm) format with 1×10<sup>−5</sup> precision.

     This machine-readable format is considerably more compact than `geoJSON` but less precise than `polyline6`.
     */
    case polyline
    /**
     The route’s shape is delivered in [encoded polyline algorithm](https://developers.google.com/maps/documentation/utilities/polylinealgorithm) format with 1×10<sup>−6</sup> precision.

     This format is an order of magnitude more precise than `polyline`.
     */
    case polyline6
    
    static let `default` = RouteShapeFormat.polyline
}

/**
 A `RouteShapeResolution` indicates the level of detail in a route’s shape, or whether the shape is present at all.
 */
public enum RouteShapeResolution: String, Codable {
    /**
     The route’s shape is omitted.

     Specify this resolution if you do not intend to show the route line to the user or analyze the route line in any way.
     */
    case none = "false"
    /**
     The route’s shape is simplified.

     This resolution considerably reduces the size of the response. The resulting shape is suitable for display at a low zoom level, but it lacks the detail necessary for focusing on individual segments of the route.
     */
    case low = "simplified"
    /**
     The route’s shape is as detailed as possible.

     The resulting shape is equivalent to concatenating the shapes of all the route’s consitituent steps. You can focus on individual segments of this route while faithfully representing the path of the route. If you only intend to show a route overview and do not need to analyze the route line in any way, consider specifying `low` instead to considerably reduce the size of the response.
     */
    case full
}

/**
 A system of units of measuring distances and other quantities.
 */
public enum MeasurementSystem: String, Codable {
    /**
     U.S. customary and British imperial units.

     Distances are measured in miles and feet.
     */
    case imperial

    /**
     The metric system.

     Distances are measured in kilometers and meters.
     */
    case metric
}

@available(*, deprecated, renamed: "DirectionsPriority")
public typealias MBDirectionsPriority = DirectionsPriority

/**
 A number that influences whether a route should prefer or avoid roadways or pathways of a given type.
 */
public struct DirectionsPriority: Hashable, RawRepresentable, Codable {
    public init(rawValue: Double) {
        self.rawValue = rawValue
    }
    
    public var rawValue: Double
    
    /**
     The priority level with which a route avoids a particular type of roadway or pathway.
     */
    static let low = DirectionsPriority(rawValue: -1.0)
    
    /**
     The priority level with which a route neither avoids nor prefers a particular type of roadway or pathway.
     */
    static let medium = DirectionsPriority(rawValue: 0.0)
    
    /**
     The priority level with which a route prefers a particular type of roadway or pathway.
     */
    static let high = DirectionsPriority(rawValue: 1.0)
}

/**
 Options for calculating results from the Mapbox Directions service.

 You do not create instances of this class directly. Instead, create instances of `MatchOptions` or `RouteOptions`.
 */
open class DirectionsOptions: Codable {
    // MARK: Creating a Directions Options Object
    
    /**
     Initializes an options object for routes between the given waypoints and an optional profile identifier.

     Do not call `DirectionsOptions(waypoints:profileIdentifier:)` directly; instead call the corresponding initializer of `RouteOptions` or `MatchOptions`.

     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints. (Some profiles, such as `ProfileIdentifier.automobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. `ProfileIdentifier.automobile` is used by default.
     - parameter queryItems: URL query items to be parsed and applied as configuration to the resulting options.
     */
    required public init(waypoints: [Waypoint], profileIdentifier: ProfileIdentifier? = nil, queryItems: [URLQueryItem]? = nil) {
        self.waypoints = waypoints
        self.profileIdentifier = profileIdentifier ?? .automobile
        
        guard let queryItems = queryItems else {
            return
        }
        
        let mappedQueryItems = Dictionary<String, String>(queryItems.compactMap {
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        },
                   uniquingKeysWith: { (_, latestValue) in
            return latestValue
        })
        
        if let mappedValue = mappedQueryItems[CodingKeys.shapeFormat.stringValue],
           let shapeFormat = RouteShapeFormat(rawValue: mappedValue) {
            self.shapeFormat = shapeFormat
        }
        if let mappedValue = mappedQueryItems[CodingKeys.routeShapeResolution.stringValue],
           let routeShapeResolution = RouteShapeResolution(rawValue: mappedValue) {
            self.routeShapeResolution = routeShapeResolution
        }
        if mappedQueryItems[CodingKeys.includesSteps.stringValue] == "true" {
            self.includesSteps = true
        }
        if let mappedValue = mappedQueryItems[CodingKeys.locale.stringValue] {
            self.locale = Locale(identifier: mappedValue)
        }
        if mappedQueryItems[CodingKeys.includesSpokenInstructions.stringValue] == "true" {
            self.includesSpokenInstructions = true
        }
        if let mappedValue = mappedQueryItems[CodingKeys.distanceMeasurementSystem.stringValue],
           let measurementSystem = MeasurementSystem(rawValue: mappedValue) {
            self.distanceMeasurementSystem = measurementSystem
        }
        if mappedQueryItems[CodingKeys.includesVisualInstructions.stringValue] == "true" {
            self.includesVisualInstructions = true
        }
        if let mappedValue = mappedQueryItems[CodingKeys.attributeOptions.stringValue],
           let attributeOptions = AttributeOptions(descriptions: mappedValue.components(separatedBy: ",")) {
            self.attributeOptions = attributeOptions
        }
        if let mappedValue = mappedQueryItems["waypoints"] {
            let indicies = mappedValue.components(separatedBy: ";").compactMap { Int($0) }
            if !indicies.isEmpty {
                waypoints.enumerated().forEach {
                    $0.element.separatesLegs = indicies.contains($0.offset)
                }
            }
        }
        
        let waypointsData = [mappedQueryItems["approaches"]?.components(separatedBy: ";"),
                             mappedQueryItems["bearings"]?.components(separatedBy: ";"),
                             mappedQueryItems["radiuses"]?.components(separatedBy: ";"),
                             mappedQueryItems["waypoint_names"]?.components(separatedBy: ";"),
                             mappedQueryItems["snapping_include_closures"]?.components(separatedBy: ";")
        ] as [[String]?]
        
        let getElement: ((_ array: [String]?, _ index: Int) -> String?) = { array, index in
            if array?.count ?? -1 > index {
                return array?[index]
            }
            return nil
        }
        
        waypoints.enumerated().forEach {
            if let approach = getElement(waypointsData[0], $0.offset) {
                $0.element.allowsArrivingOnOppositeSide = approach == "unrestricted" ? true : false
            }
            
            if let descriptions = getElement(waypointsData[1], $0.offset)?.components(separatedBy: ",") {
                $0.element.heading = LocationDirection(descriptions.first!)
                $0.element.headingAccuracy = LocationDirection(descriptions.last!)
            }
            
            if let accuracy = getElement(waypointsData[2], $0.offset) {
                $0.element.coordinateAccuracy = LocationAccuracy(accuracy)
            }
            
            if let snaps = getElement(waypointsData[4], $0.offset) {
                $0.element.allowsSnappingToClosedRoad = snaps == "true"
            }
        }
        
        waypoints.filter { $0.separatesLegs }.enumerated().forEach {
            if let name = getElement(waypointsData[3], $0.offset) {
                $0.element.name = name
            }
        }
    }
    
    /**
     Creates new options object by deserializing given `url`
     
     Initialization fails if it is unable to extract `waypoints` list and `profileIdentifier`. If other properties are failed to decode - it will just skip them.
     
     - parameter url: An URL, used to make a route request.
     */
    public convenience init?(url: URL) {
        guard url.pathComponents.count >= 3 else {
            return nil
        }
        
        let waypointsString = url.lastPathComponent.replacingOccurrences(of: ".json", with: "")
        let waypoints: [Waypoint] = waypointsString.components(separatedBy: ";").compactMap {
            let coordinates = $0.components(separatedBy: ",")
            guard coordinates.count == 2,
                  let latitudeString = coordinates.last,
                  let longitudeString = coordinates.first,
                  let latitude = LocationDegrees(latitudeString),
                  let longitude = LocationDegrees(longitudeString) else {
                      return nil
            }
            return Waypoint(coordinate: .init(latitude: latitude,
                                              longitude: longitude))
        }
            
        guard waypoints.count >= 2 else {
            return nil
        }
        
        let profileIdentifier = ProfileIdentifier(rawValue: url.pathComponents.dropLast().suffix(2).joined(separator: "/"))
        
        self.init(waypoints: waypoints,
                  profileIdentifier: profileIdentifier,
                  queryItems: URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case waypoints
        case profileIdentifier = "profile"
        case includesSteps = "steps"
        case shapeFormat = "geometries"
        case routeShapeResolution = "overview"
        case attributeOptions = "annotations"
        case locale = "language"
        case includesSpokenInstructions = "voice_instructions"
        case distanceMeasurementSystem = "voice_units"
        case includesVisualInstructions = "banner_instructions"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(profileIdentifier, forKey: .profileIdentifier)
        try container.encode(includesSteps, forKey: .includesSteps)
        try container.encode(shapeFormat, forKey: .shapeFormat)
        try container.encode(routeShapeResolution, forKey: .routeShapeResolution)
        try container.encode(attributeOptions, forKey: .attributeOptions)
        try container.encode(locale.identifier, forKey: .locale)
        try container.encode(includesSpokenInstructions, forKey: .includesSpokenInstructions)
        try container.encode(distanceMeasurementSystem, forKey: .distanceMeasurementSystem)
        try container.encode(includesVisualInstructions, forKey: .includesVisualInstructions)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        waypoints = try container.decode([Waypoint].self, forKey: .waypoints)
        profileIdentifier = try container.decode(ProfileIdentifier.self, forKey: .profileIdentifier)
        includesSteps = try container.decode(Bool.self, forKey: .includesSteps)
        shapeFormat = try container.decode(RouteShapeFormat.self, forKey: .shapeFormat)
        routeShapeResolution = try container.decode(RouteShapeResolution.self, forKey: .routeShapeResolution)
        attributeOptions = try container.decode(AttributeOptions.self, forKey: .attributeOptions)
        let identifier = try container.decode(String.self, forKey: .locale)
        locale = Locale(identifier: identifier)
        includesSpokenInstructions = try container.decode(Bool.self, forKey: .includesSpokenInstructions)
        distanceMeasurementSystem = try container.decode(MeasurementSystem.self, forKey: .distanceMeasurementSystem)
        includesVisualInstructions = try container.decode(Bool.self, forKey: .includesVisualInstructions)
    }
    
    // MARK: Specifying the Path of the Route
    
    /**
     An array of `Waypoint` objects representing locations that the route should visit in chronological order.

     A waypoint object indicates a location to visit, as well as an optional heading from which to approach the location.

     The array should contain at least two waypoints (the source and destination) and at most 25 waypoints.
     */
    open var waypoints: [Waypoint]
    
    /**
     The waypoints that separate legs.
     */
    var legSeparators: [Waypoint] {
        var waypoints = self.waypoints
        let source = waypoints.removeFirst()
        let destination = waypoints.removeLast()
        return [source] + waypoints.filter { $0.separatesLegs } + [destination]
    }
    
    // MARK: Specifying the Mode of Transportation
    
    /**
     A string specifying the primary mode of transportation for the routes.

     The default value of this property is `ProfileIdentifier.automobile`, which specifies driving directions.
     */
    open var profileIdentifier: ProfileIdentifier

    // MARK: Specifying the Response Format

    /**
     A Boolean value indicating whether `RouteStep` objects should be included in the response.

     If the value of this property is `true`, the returned route contains turn-by-turn instructions. Each returned `Route` object contains one or more `RouteLeg` object that in turn contains one or more `RouteStep` objects. On the other hand, if the value of this property is `false`, the `RouteLeg` objects contain no `RouteStep` objects.

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

    /**
     The locale in which the route’s instructions are written.

     If you use the MapboxDirections framework with the Mapbox Directions API or Map Matching API, this property affects the sentence contained within the `RouteStep.instructions` property, but it does not affect any road names contained in that property or other properties such as `RouteStep.name`.

     The Directions API can provide instructions in [a number of languages](https://docs.mapbox.com/api/navigation/#instructions-languages). Set this property to `Bundle.main.preferredLocalizations.first` or `Locale.autoupdatingCurrent` to match the application’s language or the system language, respectively.

     By default, this property is set to the current system locale.
     */
    open var locale = Locale.current {
        didSet {
            self.distanceMeasurementSystem = locale.usesMetricSystem ? .metric : .imperial
        }
    }

    /**
     A Boolean value indicating whether each route step includes an array of `SpokenInstructions`.

     If this option is set to true, the `RouteStep.instructionsSpokenAlongStep` property is set to an array of `SpokenInstructions`.
     */
    open var includesSpokenInstructions = false

    /**
     The measurement system used in spoken instructions included in route steps.

     If the `includesSpokenInstructions` property is set to `true`, this property determines the units used for measuring the distance remaining until an upcoming maneuver. If the `includesSpokenInstructions` property is set to `false`, this property has no effect.

     You should choose a measurement system appropriate for the current region. You can also allow the user to indicate their preferred measurement system via a setting.
     */
    open var distanceMeasurementSystem: MeasurementSystem = Locale.current.usesMetricSystem ? .metric : .imperial

    /**
     If true, each `RouteStep` will contain the property `visualInstructionsAlongStep`.

     `visualInstructionsAlongStep` contains an array of `VisualInstruction` objects used for visually conveying information about a given `RouteStep`.
     */
    open var includesVisualInstructions = false
    
    /**
     The time immediately before a `Directions` object fetched this result.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.fetchStartDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    open var fetchStartDate: Date?
    

    
    // MARK: Getting the Request URL
    
    /**
     The path of the request URL, specifying service name, version and profile.
     
     The query items are included in the URL of a GET request or the body of a POST request.
     */
    var abridgedPath: String {
        assertionFailure("abridgedPath should be overriden by subclass")
        return ""
    }
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    var path: String {
        guard let coordinates = coordinates, !coordinates.isEmpty else {
            assertionFailure("No query")
            return ""
        }
        return "\(abridgedPath)/\(coordinates)"
    }
    
    /**
     An array of URL query items (parameters) to include in an HTTP request.
     
     The query items are included in the URL of a GET request or the body of a POST request.
     */
    open var urlQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "geometries", value: shapeFormat.rawValue),
            URLQueryItem(name: "overview", value: routeShapeResolution.rawValue),
            
            URLQueryItem(name: "steps", value: String(includesSteps)),
            URLQueryItem(name: "language", value: locale.identifier)
        ]

        let mustArriveOnDrivingSide = !waypoints.filter { !$0.allowsArrivingOnOppositeSide }.isEmpty
        if mustArriveOnDrivingSide {
            let approaches = waypoints.map { $0.allowsArrivingOnOppositeSide ? "unrestricted" : "curb" }
            queryItems.append(URLQueryItem(name: "approaches", value: approaches.joined(separator: ";")))
        }

        if includesSpokenInstructions {
            queryItems.append(URLQueryItem(name: "voice_instructions", value: String(includesSpokenInstructions)))
            queryItems.append(URLQueryItem(name: "voice_units", value: distanceMeasurementSystem.rawValue))
        }

        if includesVisualInstructions {
            queryItems.append(URLQueryItem(name: "banner_instructions", value: String(includesVisualInstructions)))
        }

        // Include headings and heading accuracies if any waypoint has a nonnegative heading.
        if let bearings = self.bearings {
            queryItems.append(URLQueryItem(name: "bearings", value: bearings))
        }

        // Include location accuracies if any waypoint has a nonnegative coordinate accuracy.
        if let radiuses = self.radiuses {
            queryItems.append(URLQueryItem(name: "radiuses", value: radiuses))
        }

        if let annotations = self.annotations {
            queryItems.append((URLQueryItem(name: "annotations", value: annotations)))
        }

        if let waypointIndices = self.waypointIndices {
            queryItems.append(URLQueryItem(name: "waypoints", value: waypointIndices))
        }

        if let names = self.waypointNames {
            queryItems.append(URLQueryItem(name: "waypoint_names", value: names))
        }
        
        if let snapping = self.closureSnapping {
            queryItems.append(URLQueryItem(name: "snapping_include_closures", value: snapping))
        }
        
        return queryItems
    }
    
    
    var bearings: String? {
        guard waypoints.contains(where: { $0.heading ?? -1 >= 0 }) else {
            return nil
        }
        return waypoints.map({ $0.headingDescription }).joined(separator: ";")
    }
    
    var radiuses: String? {
        guard waypoints.contains(where: { $0.coordinateAccuracy ?? -1 >= 0 }) else {
            return nil
        }
        
        let accuracies = self.waypoints.map { (waypoint) -> String in
            guard let accuracy = waypoint.coordinateAccuracy, accuracy >= 0 else {
                return "unlimited"
            }
            return String(accuracy)
        }
        return accuracies.joined(separator: ";")
    }
    
    private var approaches: String? {
        if waypoints.filter( { !$0.allowsArrivingOnOppositeSide }).isEmpty {
            return nil
        }
        return waypoints.map { $0.allowsArrivingOnOppositeSide ? "unrestricted" : "curb" }.joined(separator: ";")
    }
    
    private var annotations: String? {
        if attributeOptions.isEmpty {
            return nil
        }
        return attributeOptions.description
    }
    
    private var waypointIndices: String? {
        var waypointIndices = waypoints.indices { $0.separatesLegs }
        waypointIndices.insert(waypoints.startIndex)
        waypointIndices.insert(waypoints.endIndex - 1)
        
        guard waypointIndices.count < waypoints.count else {
            return nil
        }
        return waypointIndices.map(String.init(describing:)).joined(separator: ";")
    }
    
    private var waypointNames: String? {
        if waypoints.compactMap({ $0.name }).isEmpty {
            return nil
        }
        return legSeparators.map({ $0.name ?? "" }).joined(separator: ";")
    }
    
    internal var coordinates: String? {
        return waypoints.map { $0.coordinate.requestDescription }.joined(separator: ";")
    }
    
    internal var closureSnapping: String? {
        guard waypoints.contains(where: \.allowsSnappingToClosedRoad) else {
            return nil
        }
        return waypoints.map { $0.allowsSnappingToClosedRoad ? "true": ""}.joined(separator: ";")
    }

    internal var httpBody: String {
        guard let coordinates = self.coordinates else { return "" }
        var components = URLComponents()
        components.queryItems = urlQueryItems + [
            URLQueryItem(name: "coordinates", value: coordinates),
        ]
        return components.percentEncodedQuery ?? ""
    }
    
}

extension DirectionsOptions: Equatable {
    public static func == (lhs: DirectionsOptions, rhs: DirectionsOptions) -> Bool {
        return lhs.waypoints == rhs.waypoints &&
            lhs.profileIdentifier == rhs.profileIdentifier &&
            lhs.includesSteps == rhs.includesSteps &&
            lhs.shapeFormat == rhs.shapeFormat &&
            lhs.routeShapeResolution == rhs.routeShapeResolution &&
            lhs.attributeOptions == rhs.attributeOptions &&
            lhs.locale.identifier == rhs.locale.identifier &&
            lhs.includesSpokenInstructions == rhs.includesSpokenInstructions &&
            lhs.distanceMeasurementSystem == rhs.distanceMeasurementSystem &&
            lhs.includesVisualInstructions == rhs.includesVisualInstructions
    }
}
