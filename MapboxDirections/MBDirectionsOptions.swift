import Foundation
import Polyline

/**
 A `RouteShapeFormat` indicates the format of a route or match shape in the raw HTTP response.
 */
@objc(MBRouteShapeFormat)
public enum RouteShapeFormat: UInt, CustomStringConvertible {
    /**
     The route’s shape is delivered in [GeoJSON](http://geojson.org/) format.
     
     This standard format is human-readable and can be parsed straightforwardly, but it is far more verbose than `polyline`.
     */
    case geoJSON
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
    
    public init?(description: String) {
        let format: RouteShapeFormat
        switch description {
        case "geojson":
            format = .geoJSON
        case "polyline":
            format = .polyline
        case "polyline6":
            format = .polyline6
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
        case .polyline6:
            return "polyline6"
        }
    }
}

extension RouteShapeFormat {
    
    func coordinates(from geometry: Any?) -> [CLLocationCoordinate2D]? {
        switch self {
        case .geoJSON:
            if let geometry = geometry as? JSONDictionary {
                return CLLocationCoordinate2D.coordinates(geoJSON: geometry)
            }
        case .polyline:
            if let geometry = geometry as? String {
                return decodePolyline(geometry, precision: 1e5)!
            }
        case .polyline6:
            if let geometry = geometry as? String {
                return decodePolyline(geometry, precision: 1e6)!
            }
        }
        return nil
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
 A system of units of measuring distances and other quantities.
 */
@objc(MBMeasurementSystem)
public enum MeasurementSystem: UInt, CustomStringConvertible {
    
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
    
    public init?(description: String) {
        let measurementSystem: MeasurementSystem
        switch description {
        case "imperial":
            measurementSystem = .imperial
        case "metric":
            measurementSystem = .metric
        default:
            return nil
        }
        self.init(rawValue: measurementSystem.rawValue)
    }
    
    public var description: String {
        switch self {
        case .imperial:
            return "imperial"
        case .metric:
            return "metric"
        }
    }
}

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
 Options for calculating results from the Mapbox Directions service.
 
 You do not create instances of this class directly. Instead, create instances of `MatchOptions` or `RouteOptions`.
 */
@objc(MBDirectionsOptions)
open class DirectionsOptions: NSObject, NSSecureCoding, NSCopying {
    
    /**
     Initializes an options object for routes between the given waypoints and an optional profile identifier.
     
     Do not call `DirectionsOptions(waypoints:profileIdentifier:)` directly; instead call the corresponding initializer of `RouteOptions` or `MatchOptions`.
     
     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc required public init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        self.waypoints = waypoints
        self.profileIdentifier = profileIdentifier ?? .automobile
    }
    
    public class var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: NSCopying
    @objc open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(waypoints: waypoints, profileIdentifier: profileIdentifier)
        copy.includesSteps = includesSteps
        copy.shapeFormat = shapeFormat
        copy.routeShapeResolution = routeShapeResolution
        copy.locale = locale
        copy.attributeOptions = attributeOptions
        copy.includesSpokenInstructions = includesSpokenInstructions
        copy.distanceMeasurementSystem = distanceMeasurementSystem
        copy.includesVisualInstructions = includesVisualInstructions
        return copy
    }
    
    // MARK: Objective-C equality
    open override func isEqual(_ object: Any?) -> Bool {
        guard let opts = object as? DirectionsOptions else { return false }
        return isEqual(to: opts)
    }
    
    @objc(isEqualToDirectionsOptions:)
    open func isEqual(to directionsOptions: DirectionsOptions?) -> Bool {
        guard let other = directionsOptions else { return false }
        guard type(of: self) == type(of: other) else { return false }
        guard waypoints == other.waypoints,
            profileIdentifier == other.profileIdentifier,
            includesSteps == other.includesSteps,
            shapeFormat == other.shapeFormat,
            routeShapeResolution == other.routeShapeResolution,
            attributeOptions == other.attributeOptions,
            locale == other.locale,
            includesSpokenInstructions == other.includesSpokenInstructions,
            includesVisualInstructions == other.includesVisualInstructions,
            distanceMeasurementSystem == other.distanceMeasurementSystem else { return false }
        return true
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(waypoints, forKey: "waypoints")
        coder.encode(profileIdentifier, forKey: "profileIdentifier")
        coder.encode(includesSteps, forKey: "includesSteps")
        coder.encode(shapeFormat.description, forKey: "shapeFormat")
        coder.encode(routeShapeResolution.description, forKey: "routeShapeResolution")
        coder.encode(attributeOptions.description, forKey: "attributeOptions")
        coder.encode(locale, forKey: "locale")
        coder.encode(includesSpokenInstructions, forKey: "includesSpokenInstructions")
        coder.encode(distanceMeasurementSystem.description, forKey: "distanceMeasurementSystem")
        coder.encode(includesVisualInstructions, forKey: "includesVisualInstructions")
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let waypoints = decoder.decodeObject(of: [NSArray.self, Waypoint.self], forKey: "waypoints") as? [Waypoint] else {
            return nil
        }
        self.waypoints = waypoints
        
        guard let profileIdentifier = decoder.decodeObject(of: NSString.self, forKey: "profileIdentifier") as String? else {
            return nil
        }
        self.profileIdentifier = MBDirectionsProfileIdentifier(rawValue: profileIdentifier)
        
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
        
        
        if let locale = decoder.decodeObject(of: NSLocale.self, forKey: "locale") as Locale? {
            self.locale = locale
        }
        
        includesSpokenInstructions = decoder.decodeBool(forKey: "includesSpokenInstructions")
        
        if let distanceMeasurementSystem = MeasurementSystem(description: decoder.decodeObject(of: NSString.self, forKey: "distanceMeasurementSystem") as String? ?? "") {
            self.distanceMeasurementSystem = distanceMeasurementSystem
        }
        
        includesVisualInstructions = decoder.decodeBool(forKey: "includesVisualInstructions")
    }
    
    /**
     An array of directions query strings to include in the request URL.
     */
    internal var queries: [String] {
        return waypoints.map { "\($0.coordinate.longitude),\($0.coordinate.latitude)" }
    }
    
    internal var path: String {
        assert(false, "path should be overriden by subclass")
        return ""
    }
    
    /**
     An array of `Waypoint` objects representing locations that the route should visit in chronological order.
     
     A waypoint object indicates a location to visit, as well as an optional heading from which to approach the location.
     
     The array should contain at least two waypoints (the source and destination) and at most 25 waypoints.
     */
    @objc open var waypoints: [Waypoint]
    
    /**
     A string specifying the primary mode of transportation for the routes.
     
     This property should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. The default value of this property is `MBDirectionsProfileIdentifierAutomobile`, which specifies driving directions.
     */
    @objc open var profileIdentifier: MBDirectionsProfileIdentifier
    
    /**
     A Boolean value indicating whether `MBRouteStep` objects should be included in the response.
     
     If the value of this property is `true`, the returned route contains turn-by-turn instructions. Each returned `MBRoute` object contains one or more `MBRouteLeg` object that in turn contains one or more `MBRouteStep` objects. On the other hand, if the value of this property is `false`, the `MBRouteLeg` objects contain no `MBRouteStep` objects.
     
     If you only want to know the distance or estimated travel time to a destination, set this property to `false` to minimize the size of the response and the time it takes to calculate the response. If you need to display turn-by-turn instructions, set this property to `true`.
     
     The default value of this property is `false`.
     */
    @objc open var includesSteps = false
    
    /**
     Format of the data from which the shapes of the returned route and its steps are derived.
     
     This property has no effect on the returned shape objects, although the choice of format can significantly affect the size of the underlying HTTP response.
     
     The default value of this property is `polyline`.
     */
    @objc open var shapeFormat = RouteShapeFormat.polyline
    
    /**
     Resolution of the shape of the returned route.
     
     This property has no effect on the shape of the returned route’s steps.
     
     The default value of this property is `low`, specifying a low-resolution route shape.
     */
    @objc open var routeShapeResolution = RouteShapeResolution.low
    
    /**
     AttributeOptions for the route. Any combination of `AttributeOptions` can be specified.
     
     By default, no attribute options are specified. It is recommended that `routeShapeResolution` be set to `.full`.
     */
    @objc open var attributeOptions: AttributeOptions = []
    
    /**
     The locale in which the route’s instructions are written.
     
     If you use MapboxDirections.swift with the Mapbox Directions API or Map Matching API, this property affects the sentence contained within the `RouteStep.instructions` property, but it does not affect any road names contained in that property or other properties such as `RouteStep.name`.
     
     The Directions API can provide instructions in [a number of languages](https://www.mapbox.com/api-documentation/#instructions-languages). Set this property to `Bundle.main.preferredLocalizations.first` or `Locale.autoupdatingCurrent` to match the application’s language or the system language, respectively.
     
     By default, this property is set to the current system locale.
     */
    @objc open var locale = Locale.autoupdatingCurrent {
        didSet {
            self.distanceMeasurementSystem = locale.usesMetric ? .metric : .imperial
        }
    }
    
    /**
     A Boolean value indicating whether each route step includes an array of `SpokenInstructions`.
     
     If this option is set to true, the `RouteStep.instructionsSpokenAlongStep` property is set to an array of `SpokenInstructions`.
     */
    @objc open var includesSpokenInstructions = false
    
    /**
     The measurement system used in spoken instructions included in route steps.
     
     If the `includesSpokenInstructions` property is set to `true`, this property determines the units used for measuring the distance remaining until an upcoming maneuver. If the `includesSpokenInstructions` property is set to `false`, this property has no effect.
     
     You should choose a measurement system appropriate for the current region. You can also allow the user to indicate their preferred measurement system via a setting.
     */
    @objc open var distanceMeasurementSystem: MeasurementSystem = Locale.autoupdatingCurrent.usesMetric ? .metric : .imperial
    
    /**
     If true, each `RouteStep` will contain the property `visualInstructionsAlongStep`.
     
     `visualInstructionsAlongStep` contains an array of `VisualInstruction` objects used for visually conveying information about a given `RouteStep`.
     */
    @objc open var includesVisualInstructions = false
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "geometries", value: String(describing: shapeFormat)),
            URLQueryItem(name: "overview", value: String(describing: routeShapeResolution)),
            URLQueryItem(name: "steps", value: String(includesSteps)),
            URLQueryItem(name: "language", value: locale.identifier)
        ]
        
        let mustArriveOnDrivingSide = !waypoints.filter { !$0.allowsArrivingOnOppositeSide }.isEmpty
        if mustArriveOnDrivingSide {
            let approaches = waypoints.map { $0.allowsArrivingOnOppositeSide ? "unrestricted" : "curb" }
            params.append(URLQueryItem(name: "approaches", value: approaches.joined(separator: ";")))
        }
        
        if includesSpokenInstructions {
            params.append(URLQueryItem(name: "voice_instructions", value: String(includesSpokenInstructions)))
            params.append(URLQueryItem(name: "voice_units", value: String(describing: distanceMeasurementSystem)))
        }
        
        if includesVisualInstructions {
            params.append(URLQueryItem(name: "banner_instructions", value: String(includesVisualInstructions)))
        }
        
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
        
        if !waypoints.compactMap({ $0.name }).isEmpty {
            let names = waypoints.map { $0.name ?? "" }.joined(separator: ";")
            params.append(URLQueryItem(name: "waypoint_names", value: names))
        }
        
        return params
    }
}


extension Locale {
    fileprivate var usesMetric: Bool {
        guard let measurementSystem = (self as NSLocale).object(forKey: .measurementSystem) as? String else {
            return false
        }
        return measurementSystem == "Metric"
    }
}
