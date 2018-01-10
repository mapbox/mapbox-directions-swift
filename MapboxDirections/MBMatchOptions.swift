//
//  MBMatchOptions.swift
//  MapboxDirections
//
//  Created by Bobby Sudekum on 1/10/18.
//  Copyright © 2018 Mapbox. All rights reserved.
//

import Foundation

/**
 A `RouteOptions` object is a structure that specifies the criteria for results returned by the Mapbox Directions API.
 
 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
@objc(MBMatchOptions)
open class MatchOptions: NSObject, NSSecureCoding, NSCopying{
    // MARK: Creating a Route Options Object
    
    /**
     Initializes a route options object for routes between the given waypoints and an optional profile identifier.
     
     - parameter waypoints: An array of `Waypoint` objects representing locations that the route should visit in chronological order. The array should contain at least two waypoints (the source and destination) and at most 25 waypoints. (Some profiles, such as `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, [may have lower limits](https://www.mapbox.com/api-documentation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. This parameter, if set, should be set to `MBDirectionsProfileIdentifierAutomobile`, `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`, `MBDirectionsProfileIdentifierCycling`, or `MBDirectionsProfileIdentifierWalking`. `MBDirectionsProfileIdentifierAutomobile` is used by default.
     */
    @objc public init(waypoints: [Waypoint], profileIdentifier: MBDirectionsProfileIdentifier? = nil) {
        assert(waypoints.count >= 2, "A route requires at least a source and destination.")
        assert(waypoints.count <= 25, "A route may not have more than 25 waypoints.")
        
        self.waypoints = waypoints
        self.profileIdentifier = profileIdentifier ?? .automobile
    }
    
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
        
        guard let timestamps = decoder.decodeObject(of: NSString.self, forKey: "timestamps") as String? else {
            return nil
        }
        self.timestamps = timestamps.components(separatedBy: ",").flatMap {
            guard let time = TimeInterval($0) else { return nil }
            return Date(timeIntervalSinceNow: time)
        }
        
        resample = decoder.decodeBool(forKey: "resample")
    }
    
    open static var supportsSecureCoding = true
    
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
        coder.encode(timestamps, forKey: "timestamps")
        coder.encode(resample, forKey: "resample")
    }
    
    // MARK: Specifying the Path of the Route
    
    /**
     An array of `Waypoint` objects representing locations that the route should visit in chronological order.
     
     A waypoint object indicates a location to visit, as well as an optional heading from which to approach the location.
     
     The array should contain at least two waypoints (the source and destination) and at most 25 waypoints.
     */
    @objc open var waypoints: [Waypoint]
    
    // MARK: Specifying Transportation Options
    
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
    
    // MARK: Constructing the Request URL
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        assert(!queries.isEmpty, "No query")
        
        let queryComponent = queries.joined(separator: ";")
        return "matching/v5/\(profileIdentifier.rawValue)/\(queryComponent).json"
    }
    
    /**
     An array of directions query strings to include in the request URL.
     */
    internal var queries: [String] {
        return waypoints.map { "\($0.coordinate.longitude),\($0.coordinate.latitude)" }
    }
    
    /**
     The locale in which the route’s instructions are written.
     
     If you use MapboxDirections.swift with the Mapbox Directions API, this property affects the sentence contained within the `RouteStep.instructions` property, but it does not affect any road names contained in that property or other properties such as `RouteStep.name`.
     
     The Directions API can provide instructions in [a number of languages](https://www.mapbox.com/api-documentation/#instructions-languages). Set this property to `Bundle.main.preferredLocalizations.first` or `Locale.autoupdatingCurrent` to match the application’s language or the system language, respectively.
     
     By default, this property is set to the current system locale.
     */
    @objc open var locale = Locale.autoupdatingCurrent {
        didSet {
            self.distanceMeasurementSystem = locale.usesMetric ? .metric : .imperial
        }
    }
    
    /**
     AttributeOptions for the route. Any combination of `AttributeOptions` can be specified.
     
     By default, no attribute options are specified. It is recommended that `routeShapeResolution` be set to `.full`.
     */
    @objc open var attributeOptions: AttributeOptions = []
    
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
     :nodoc:
     If true, each `RouteStep` will contain the property `visualInstructionsAlongStep`.
     
     `visualInstructionsAlongStep` contains an array of `VisualInstruction` used for visually conveying information about a given `RouteStep`.
     */
    @objc open var includesVisualInstructions = false
    
    @objc open var resample: Bool = false
    
    @objc open var timestamps: [Date]?
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "geometries", value: String(describing: shapeFormat)),
            URLQueryItem(name: "overview", value: String(describing: routeShapeResolution)),
            URLQueryItem(name: "steps", value: String(includesSteps)),
            URLQueryItem(name: "language", value: locale.identifier),
            URLQueryItem(name: "tidy", value: String(describing: resample))
        ]
        
        if let timestamps = timestamps, !timestamps.isEmpty {
            let times = timestamps.map { String(describing: ($0.timeIntervalSince1970)) }
            params.append(URLQueryItem(name: "timestamps", value: times.joined(separator: ";")))
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
            Match(json: $0, waypoints: waypoints, routeOptions: self)
        }
        return (waypoints, routes)
    }
    
    // MARK: NSCopying
    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = RouteOptions(waypoints: waypoints, profileIdentifier: profileIdentifier)
        copy.includesSteps = includesSteps
        copy.shapeFormat = shapeFormat
        copy.routeShapeResolution = routeShapeResolution
        copy.attributeOptions = attributeOptions
        copy.locale = locale
        copy.includesSpokenInstructions = includesSpokenInstructions
        copy.distanceMeasurementSystem = distanceMeasurementSystem
        copy.includesVisualInstructions = includesVisualInstructions
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
}
