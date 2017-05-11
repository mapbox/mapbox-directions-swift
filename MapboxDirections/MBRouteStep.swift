import Polyline

/**
 A `TransportType` specifies the mode of transportation used for part of a route.
 */
@objc(MBTransportType)
public enum TransportType: Int, CustomStringConvertible {
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`
    
    /**
     The route requires the user to drive or ride a car, truck, or motorcycle.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`.
     */
    case automobile // automobile
    
    /**
     The route requires the user to board a ferry.
     
     The user should verify that the ferry is in operation. For driving and cycling directions, the user should also verify that his or her vehicle is permitted onboard the ferry.
     */
    case ferry // automobile, walking, cycling
    
    /**
     The route requires the user to cross a movable bridge.
     
     The user may need to wait for the movable bridge to become passable before continuing.
     */
    case movableBridge // automobile, cycling
    
    /**
     The route becomes impassable at this point.
     
     You should not encounter this transport type under normal circumstances.
     */
    case inaccessible // automobile, walking, cycling
    
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierWalking`
    
    /**
     The route requires the user to walk.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierWalking`. For cycling directions, this value indicates that the user is expected to dismount.
     */
    case walking // walking, cycling
    
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierCycling`
    
    /**
     The route requires the user to ride a bicycle.
     
     This is the usual transport type when the `profileIdentifier` is `MBDirectionsProfileIdentifierCycling`.
     */
    case cycling // cycling
    
    /**
     The route requires the user to board a train.
     
     The user should consult the train’s timetable. For cycling directions, the user should also verify that bicycles are permitted onboard the train.
     */
    case train // cycling
    
    public init?(description: String) {
        let type: TransportType
        switch description {
        case "driving":
            type = .automobile
        case "ferry":
            type = .ferry
        case "moveable bridge":
            type = .movableBridge
        case "unaccessible":
            type = .inaccessible
        case "walking":
            type = .walking
        case "cycling":
            type = .cycling
        case "train":
            type = .train
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .automobile:
            return "driving"
        case .ferry:
            return "ferry"
        case .movableBridge:
            return "moveable bridge"
        case .inaccessible:
            return "unaccessible"
        case .walking:
            return "walking"
        case .cycling:
            return "cycling"
        case .train:
            return "train"
        }
    }
}

/**
 A `ManeuverType` specifies the type of maneuver required to complete the route step. You can pair a maneuver type with a `ManeuverDirection` to choose an appropriate visual or voice prompt to present the user.
 
 In Swift, you can use pattern matching with a single switch statement on a tuple containing the maneuver type and maneuver direction to avoid a complex series of if-else-if statements or switch statements.
 */
@objc(MBManeuverType)
public enum ManeuverType: Int, CustomStringConvertible {
    /**
     The step requires the user to depart from a waypoint.
     
     If the waypoint is some distance away from the nearest road, the maneuver direction indicates the direction the user must turn upon reaching the road.
     */
    case depart
    
    /**
     The step requires the user to turn.
     
     The maneuver direction indicates the direction in which the user must turn relative to the current direction of travel. The exit index indicates the number of intersections, large or small, from the previous maneuver up to and including the intersection at which the user must turn.
     */
    case turn
    
    /**
     The step requires the user to continue after a turn.
     */
    case `continue`
    
    /**
     The step requires the user to continue on the current road as it changes names.
     
     The step’s name contains the road’s new name. To get the road’s old name, use the previous step’s name.
     */
    case passNameChange
    
    /**
     The step requires the user to merge onto another road.
     
     The maneuver direction indicates the side from which the other road approaches the intersection relative to the user.
     */
    case merge
    
    /**
     The step requires the user to take a entrance ramp (slip road) onto a highway.
     */
    case takeOnRamp
    
    /**
     The step requires the user to take an exit ramp (slip road) off a highway.
     
     The maneuver direction indicates the side of the highway from which the user must exit. The exit index indicates the number of highway exits from the previous maneuver up to and including the exit that the user must take.
     */
    case takeOffRamp
    
    /**
     The step requires the user to choose a fork at a Y-shaped fork in the road.
     
     The maneuver direction indicates which fork to take.
     */
    case reachFork
    
    /**
     The step requires the user to turn at either a T-shaped three-way intersection or a sharp bend in the road where the road also changes names.
     
     This maneuver type is called out separately so that the user may be able to proceed more confidently, without fear of having overshot the turn. If this distinction is unimportant to you, you may treat the maneuver as an ordinary `turn`.
     */
    case reachEnd
    
    /**
     The step requires the user to get into a specific lane in order to continue along the current road.
     
     The maneuver direction is set to `straightAhead`. Each of the first intersection’s usable approach lanes also has an indication of `straightAhead`. A maneuver in a different direction would instead have a maneuver type of `turn`.
     
     This maneuver type is called out separately so that the application can present the user with lane guidance based on the first element in the `intersections` property. If lane guidance is unimportant to you, you may treat the maneuver as an ordinary `continue` or ignore it.
     */
    case useLane
     
    /**
     The step requires the user to enter, traverse, and exit a roundabout (traffic circle or rotary).
     
     The step has no name, but the exit name is the name of the road to take to exit the roundabout. The exit index indicates the number of roundabout exits up to and including the exit to take.
     */
    case takeRoundabout
    
    /**
     The step requires the user to enter, traverse, and exit a large, named roundabout (traffic circle or rotary).
     
     The step’s name is the name of the roundabout. The exit name is the name of the road to take to exit the roundabout. The exit index indicates the number of rotary exits up to and including the exit that the user must take.
     */
    case takeRotary
    
    /**
     The step requires the user to enter and exit a roundabout (traffic circle or rotary) that is compact enough to constitute a single intersection.
     
     The step’s name is the name of the road to take after exiting the roundabout. This maneuver type is called out separately because the user may perceive the roundabout as an ordinary intersection with an island in the middle. If this distinction is unimportant to you, you may treat the maneuver as either an ordinary `turn` or as a `takeRoundabout`.
     */
    case turnAtRoundabout
    
    /**
     The step requires the user to respond to a change in travel conditions.
     
     This maneuver type may occur for example when driving directions require the user to board a ferry, or when cycling directions require the user to dismount. The step’s transport type and instructions contains important contextual details that should be presented to the user at the maneuver location.
     
     Similar changes can occur simultaneously with other maneuvers, such as when the road changes its name at the site of a movable bridge. In such cases, `heedWarning` is suppressed in favor of another maneuver type.
     */
    case heedWarning
    
    /**
     The step requires the user to arrive at a waypoint.
     
     The distance and expected travel time for this step are set to zero, indicating that the route or route leg is complete. The maneuver direction indicates the side of the road on which the waypoint can be found (or whether it is straight ahead).
     */
    case arrive
    
    /**
     The step requires the user to arrive at an intermediate waypoint.
     
     This maneuver type is only used by version 4 of the Mapbox Directions API.
     */
    case passWaypoint // v4
    
    public init?(description: String) {
        let type: ManeuverType
        switch description {
        case "depart":
            type = .depart
        case "turn":
            type = .turn
        case "continue":
            type = .continue
        case "new name":
            type = .passNameChange
        case "merge":
            type = .merge
        case "on ramp":
            type = .takeOnRamp
        case "off ramp":
            type = .takeOffRamp
        case "fork":
            type = .reachFork
        case "end of road":
            type = .reachEnd
        case "use lane":
            type = .useLane
        case "rotary":
            type = .takeRotary
        case "roundabout":
            type = .takeRoundabout
        case "roundabout turn":
            type = .turnAtRoundabout
        case "notification":
            type = .heedWarning
        case "arrive":
            type = .arrive
        case "waypoint": // v4
            type = .passWaypoint
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .depart:
            return "depart"
        case .turn:
            return "turn"
        case .continue:
            return "continue"
        case .passNameChange:
            return "new name"
        case .merge:
            return "merge"
        case .takeOnRamp:
            return "on ramp"
        case .takeOffRamp:
            return "off ramp"
        case .reachFork:
            return "fork"
        case .reachEnd:
            return "end of road"
        case .useLane:
            return "use lane"
        case .takeRotary:
            return "rotary"
        case .takeRoundabout:
            return "roundabout"
        case .turnAtRoundabout:
            return "roundabout turn"
        case .heedWarning:
            return "notification"
        case .arrive:
            return "arrive"
        case .passWaypoint: // v4
            return "waypoint"
        }
    }
}

/**
 A `ManeuverDirection` clarifies a `ManeuverType` with directional information. The exact meaning of the maneuver direction for a given step depends on the step’s maneuver type; see the `ManeuverType` documentation for details.
 */
@objc(MBManeuverDirection)
public enum ManeuverDirection: Int, CustomStringConvertible {
    /**
     The maneuver requires a sharp turn to the right.
     */
    case sharpRight
    
    /**
     The maneuver requires a turn to the right, a merge to the right, or an exit on the right, or the destination is on the right.
     */
    case right
    
    /**
     The maneuver requires a slight turn to the right.
     */
    case slightRight
    
    /**
     The maneuver requires no notable change in direction, or the destination is straight ahead.
     */
    case straightAhead
    
    /**
     The maneuver requires a slight turn to the left.
     */
    case slightLeft
    
    /**
     The maneuver requires a turn to the left, a merge to the left, or an exit on the left, or the destination is on the right.
     */
    case left
    
    /**
     The maneuver requires a sharp turn to the left.
     */
    case sharpLeft
    
    /**
     The maneuver requires a U-turn when possible.
     
     Use the difference between the step’s initial and final headings to distinguish between a U-turn to the left (typical in countries that drive on the right) and a U-turn on the right (typical in countries that drive on the left). If the difference in headings is greater than 180 degrees, the maneuver requires a U-turn to the left. If the difference in headings is less than 180 degrees, the maneuver requires a U-turn to the right.
     */
    case uTurn
    
    public init?(description: String) {
        let direction: ManeuverDirection
        switch description {
        case "sharp right":
            direction = .sharpRight
        case "right":
            direction = .right
        case "slight right":
            direction = .slightRight
        case "straight":
            direction = .straightAhead
        case "slight left":
            direction = .slightLeft
        case "left":
            direction = .left
        case "sharp left":
            direction = .sharpLeft
        case "uturn":
            direction = .uTurn
        default:
            return nil
        }
        self.init(rawValue: direction.rawValue)
    }
    
    public var description: String {
        switch self {
        case .sharpRight:
            return "sharp right"
        case .right:
            return "right"
        case .slightRight:
            return "slight right"
        case .straightAhead:
            return "straight"
        case .slightLeft:
            return "slight left"
        case .left:
            return "left"
        case .sharpLeft:
            return "sharp left"
        case .uTurn:
            return "uturn"
        }
    }
}

extension String {
    internal func tagValues(separatedBy separator: String) -> [String] {
        return components(separatedBy: separator).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}

/**
 Encapsulates all the information about a road.
 */
struct Road {
    let names: [String]?
    let codes: [String]?
    let destinations: [String]?
    let destinationCodes: [String]?
    let rotaryNames: [String]?
    
    init(name: String, ref: String?, destination: String?, rotaryName: String?) {
        var codes: [String]?
        if !name.isEmpty, let ref = ref {
            // Mapbox Directions API v5 encodes the ref separately from the name but redundantly includes the ref in the name for backwards compatibility. Remove the ref from the name.
            let parenthetical = "(\(ref))"
            if name == ref {
                self.names = nil
            } else {
                self.names = name.replacingOccurrences(of: parenthetical, with: "").tagValues(separatedBy: ";")
            }
            codes = ref.tagValues(separatedBy: ";")
        } else if !name.isEmpty, let codesRange = name.range(of: "\\(.+?\\)$", options: .regularExpression, range: name.startIndex..<name.endIndex) {
            // Mapbox Directions API v4 encodes the ref inside a parenthetical. Remove the ref from the name.
            let parenthetical = name.substring(with: codesRange)
            if name == ref {
                self.names = nil
            } else {
                self.names = name.replacingOccurrences(of: parenthetical, with: "").tagValues(separatedBy: ";")
            }
            codes = parenthetical.trimmingCharacters(in: CharacterSet(charactersIn: "()")).tagValues(separatedBy: ";")
        } else {
            self.names = name.isEmpty ? nil : name.tagValues(separatedBy: ";")
            codes = ref?.tagValues(separatedBy: ";")
        }
        
        // Mapbox Directions API v5 combines the destination’s ref and name.
        if let destination = destination, destination.contains(": ") {
            let destinationComponents = destination.components(separatedBy: ": ")
            self.destinationCodes = destinationComponents.first?.tagValues(separatedBy: ",")
            self.destinations = destinationComponents.dropFirst().joined(separator: ": ").tagValues(separatedBy: ",")
        } else {
            self.destinationCodes = nil
            self.destinations = destination?.tagValues(separatedBy: ",")
        }
        
        self.codes = codes
        self.rotaryNames = rotaryName?.tagValues(separatedBy: ";")
    }
}

/**
 A `RouteStep` object represents a single distinct maneuver along a route and the approach to the next maneuver. The route step object corresponds to a single instruction the user must follow to complete a portion of the route. For example, a step might require the user to turn then follow a road.
 
 You do not create instances of this class directly. Instead, you receive route step objects as part of route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method, setting the `includesSteps` option to `true` in the `RouteOptions` object that you pass into that method.
 */
@objc(MBRouteStep)
open class RouteStep: NSObject, NSSecureCoding {
    // MARK: Creating a Step
    
    internal init(finalHeading: CLLocationDirection?, maneuverType: ManeuverType?, maneuverDirection: ManeuverDirection?, maneuverLocation: CLLocationCoordinate2D, name: String, coordinates: [CLLocationCoordinate2D]?, json: JSONDictionary) {
        transportType = TransportType(description: json["mode"] as! String)
        
        let road = Road(name: name, ref: json["ref"] as? String, destination: json["destinations"] as? String, rotaryName: json["rotary_name"] as? String)
        if maneuverType == .takeRotary || maneuverType == .takeRoundabout {
            names = road.rotaryNames
            exitNames = road.names
        } else {
            names = road.names
            exitNames = nil
        }
        codes = road.codes
        destinationCodes = road.destinationCodes
        destinations = road.destinations
        
        let maneuver = json["maneuver"] as! JSONDictionary
        
        if let instructions = maneuver["instruction"] as? String {
            self.instructions = instructions
        } else if let mt = maneuverType, let md = maneuverDirection {
            instructions = "\(mt) \(md)"
        } else if let mt = maneuverType {
            instructions = String(describing: mt)
        } else if let md = maneuverDirection {
            instructions = String(describing: md)
        } else {
            instructions = ""
        }
        
        distance = json["distance"] as? Double ?? 0
        expectedTravelTime = json["duration"] as? Double ?? 0
        
        let intersectionsJSON = json["intersections"] as? [JSONDictionary]
        self.intersections = intersectionsJSON?.map { Intersection(json: $0) }
        
        initialHeading = maneuver["bearing_before"] as? Double
        self.finalHeading = finalHeading
        self.maneuverType = maneuverType
        self.maneuverDirection = maneuverDirection
        exitIndex = maneuver["exit"] as? Int
        
        self.maneuverLocation = maneuverLocation
        self.coordinates = coordinates
    }
    
    /**
     Initializes a new route step object with the given JSON dictionary representation.
     
     Normally, you do not create instances of this class directly. Instead, you receive route step objects as part of route objects when you request directions using the `Directions.calculateDirections(options:completionHandler:)` method, setting the `includesSteps` option to `true` in the `RouteOptions` object that you pass into that method.
     
     - parameter json: A JSON dictionary representation of a route step object as returnd by the Mapbox Directions API.
     */
    public convenience init(json: [String: Any]) {
        let maneuver = json["maneuver"] as! JSONDictionary
        let finalHeading = maneuver["bearing_after"] as? Double
        let maneuverType = ManeuverType(description: maneuver["type"] as! String)
        let maneuverDirection = ManeuverDirection(description: maneuver["modifier"] as? String ?? "")
        let maneuverLocation = CLLocationCoordinate2D(geoJSON: maneuver["location"] as! [Double])
        
        let name = json["name"] as! String
        
        var coordinates: [CLLocationCoordinate2D]?
        switch json["geometry"] {
        case let geometry as JSONDictionary:
            coordinates = CLLocationCoordinate2D.coordinates(geoJSON: geometry)
        case let geometry as String:
            coordinates = decodePolyline(geometry, precision: 1e5)!
        default:
            coordinates = nil
        }
        
        self.init(finalHeading: finalHeading, maneuverType: maneuverType, maneuverDirection: maneuverDirection, maneuverLocation: maneuverLocation, name: name, coordinates: coordinates, json: json)
    }
    
    public required init?(coder decoder: NSCoder) {
        let coordinateDictionaries = decoder.decodeObject(of: [NSArray.self, NSDictionary.self, NSString.self, NSNumber.self], forKey: "coordinates") as? [[String: CLLocationDegrees]]
		
        coordinates = coordinateDictionaries?.flatMap({ (coordinateDictionary) -> CLLocationCoordinate2D? in
            if let latitude = coordinateDictionary["latitude"], let longitude = coordinateDictionary["longitude"] {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                return nil
            }
        })
        
        guard let decodedInstructions = decoder.decodeObject(of: NSString.self, forKey: "instructions") as String? else {
            return nil
        }
        instructions = decodedInstructions
		
        initialHeading = decoder.containsValue(forKey: "initialHeading") ? decoder.decodeDouble(forKey: "initialHeading") : nil
        finalHeading = decoder.containsValue(forKey: "finalHeading") ? decoder.decodeDouble(forKey: "finalHeading") : nil
        
        guard let maneuverTypeDescription = decoder.decodeObject(of: NSString.self, forKey: "maneuverType") as String? else {
            return nil
        }
        maneuverType = ManeuverType(description: maneuverTypeDescription)
        guard let maneuverDirectionDescription = decoder.decodeObject(of: NSString.self, forKey: "maneuverDirection") as String? else {
            return nil
        }
        maneuverDirection = ManeuverDirection(description: maneuverDirectionDescription)
        
        if let maneuverLocationDictionary = decoder.decodeObject(of: [NSDictionary.self, NSString.self, NSNumber.self], forKey: "maneuverLocation") as? [String: CLLocationDegrees],
            let latitude = maneuverLocationDictionary["latitude"],
            let longitude = maneuverLocationDictionary["longitude"] {
            maneuverLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            maneuverLocation = kCLLocationCoordinate2DInvalid
        }
        
        exitIndex = decoder.containsValue(forKey: "exitIndex") ? decoder.decodeInteger(forKey: "exitIndex") : nil
        exitNames = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "exitNames") as? [String]
        distance = decoder.decodeDouble(forKey: "distance")
        expectedTravelTime = decoder.decodeDouble(forKey: "expectedTravelTime")
        names = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "names") as? [String]
        
        guard let transportTypeDescription = decoder.decodeObject(of: NSString.self, forKey: "transportType") as String? else {
            return nil
        }
        transportType = TransportType(description: transportTypeDescription)
        
        codes = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "codes") as? [String]
        destinationCodes = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "destinationCodes") as? [String]
        destinations = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "destinations") as? [String]
        
        intersections = decoder.decodeObject(of: [NSArray.self, Intersection.self], forKey: "intersections") as? [Intersection]
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        let coordinateDictionaries = coordinates?.map { [
            "latitude": $0.latitude,
            "longitude": $0.longitude,
            ] }
        coder.encode(coordinateDictionaries, forKey: "coordinates")
        
        coder.encode(instructions, forKey: "instructions")
        
        if let initialHeading = initialHeading {
            coder.encode(initialHeading, forKey: "initialHeading")
        }
        if let finalHeading = finalHeading {
            coder.encode(finalHeading, forKey: "finalHeading")
        }
        
        coder.encode(maneuverType?.description, forKey: "maneuverType")
        coder.encode(maneuverDirection?.description, forKey: "maneuverDirection")
        
        coder.encode(intersections, forKey: "intersections")
        
        coder.encode([
            "latitude": maneuverLocation.latitude,
            "longitude": maneuverLocation.longitude,
        ], forKey: "maneuverLocation")
        
        if let exitIndex = exitIndex {
            coder.encode(exitIndex, forKey: "exitIndex")
        }
        
        coder.encode(exitNames, forKey: "exitNames")
        coder.encode(distance, forKey: "distance")
        coder.encode(expectedTravelTime, forKey: "expectedTravelTime")
        coder.encode(names, forKey: "names")
        coder.encode(transportType?.description, forKey: "transportType")
        coder.encode(codes, forKey: "codes")
        coder.encode(destinationCodes, forKey: "destinationCodes")
        coder.encode(destinations, forKey: "destinations")
    }
    
    // MARK: Getting the Step Geometry
    
    /**
     An array of geographic coordinates defining the path of the route step from the location of the maneuver to the location of the next step’s maneuver.
     
     The value of this property may be `nil`, for example when the maneuver type is `arrive`.
     
     Using the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [Mapbox macOS SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display a portion of a route on an `MGLMapView`.
     */
    open let coordinates: [CLLocationCoordinate2D]?
    
    /**
     The number of coordinates.
     
     The value of this property may be zero, for example when the maneuver type is `arrive`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates.count` property.
     */
    open var coordinateCount: UInt {
        return UInt(coordinates?.count ?? 0)
    }
    
    /**
     Retrieves the coordinates.
     
     The array may be empty, for example when the maneuver type is `arrive`.
     
     Using the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [Mapbox macOS SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display a portion of a route on an `MGLMapView`.
     
     - parameter coordinates: A pointer to a C array of `CLLocationCoordinate2D` instances. On output, this array contains all the vertices of the overlay.
     - returns: True if the step has coordinates and `coordinates` has been populated, or false if the step has no coordinates and `coordinates` has not been modified.
     
     - precondition: `coordinates` must be large enough to hold `coordinateCount` instances of `CLLocationCoordinate2D`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates` property.
     */
    open func getCoordinates(_ coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>) -> Bool {
        guard let stepCoordinates = self.coordinates else {
            return false
        }
        
        for i in 0..<stepCoordinates.count {
            coordinates.advanced(by: i).pointee = stepCoordinates[i]
        }
        return true
    }
    
    // MARK: Getting Details About the Maneuver
    
    /**
     A string with instructions explaining how to perform the step’s maneuver.
     
     You can display this string or read it aloud to the user. The string does not include the distance to or from the maneuver. If you need localized or customized instructions, you can construct them yourself from the step’s other properties or use [osrm-text-instructions](https://github.com/Project-OSRM/osrm-text-instructions).
     
     - note: If you use MapboxDirections.swift with the Mapbox Directions API, this property is formatted for display to the user. If you use OSRM directly, this property contains a basic string that only includes the maneuver type and direction. Use [osrm-text-instructions](https://github.com/Project-OSRM/osrm-text-instructions) to construct a complete instruction string for display.
     */
    open let instructions: String
    
    open override var description: String {
        return instructions
    }
    
    /**
     The user’s heading immediately before performing the maneuver.
     */
    open let initialHeading: CLLocationDirection?
    
    /**
     The user’s heading immediately after performing the maneuver.
     
     The value of this property may differ from the user’s heading after traveling along the road past the maneuver.
     */
    open let finalHeading: CLLocationDirection?
    
    /**
     The type of maneuver required for beginning this step.
     */
    open let maneuverType: ManeuverType?
    
    /**
     Additional directional information to clarify the maneuver type.
     */
    open let maneuverDirection: ManeuverDirection?
    
    /**
     The location of the maneuver at the beginning of this step.
     */
    open let maneuverLocation: CLLocationCoordinate2D
    
    /**
     The number of exits from the previous maneuver up to and including this step’s maneuver.
     
     If the maneuver takes place on a surface street, this property counts intersections. The number of intersections does not necessarily correspond to the number of blocks. If the maneuver takes place on a grade-separated highway (freeway or motorway), this property counts highway exits but not highway entrances. If the maneuver is a roundabout maneuver, the exit index is the number of exits from the approach to the recommended outlet.
     
     In some cases, the number of exits leading to a maneuver may be more useful to the user than the distance to the maneuver.
     */
    open let exitIndex: Int?
    
    /**
     The names of the roundabout exit.
     
     This property is only set for roundabout (traffic circle or rotary) maneuvers. For the signposted names associated with a highway exit, use the `destinations` property.
     
     If you display a name to the user, you may need to abbreviate common words like “East” or “Boulevard” to ensure that it fits in the allotted space.
     */
    public let exitNames: [String]?
    
    // MARK: Getting Details About the Approach to the Next Maneuver
    
    /**
     The step’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to go from this step’s maneuver location to the next step’s maneuver location. It is not the sum of the direct distances between the route’s waypoints, nor should you assume that the user would travel along this distance at a fixed speed.
     */
    open let distance: CLLocationDistance
    
    /**
     The step’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to go from this step’s maneuver location to the next step’s maneuver location under ideal conditions. You should not assume that the user would travel along the step at a fixed speed. The actual travel time may vary based on the weather, traffic conditions, road construction, and other variables. If the step makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     */
    open let expectedTravelTime: TimeInterval
    
    /**
     The names of the road or path leading from this step’s maneuver to the next step’s maneuver.
     
     If the maneuver is a turning maneuver, the step’s names are the name of the road or path onto which the user turns. If you display a name to the user, you may need to abbreviate common words like “East” or “Boulevard” to ensure that it fits in the allotted space.
     
     If the maneuver is a roundabout maneuver, the outlet to take is named in the `exitNames` property; the `names` property is only set for large roundabouts that have their own names.
     */
    open let names: [String]?
    
    /**
     Any route reference codes assigned to the road or path leading from this step’s maneuver to the next step’s maneuver.
     
     A route reference code commonly consists of an alphabetic network code, a space or hyphen, and a route number. You should not assume that the network code is globally unique: for example, a network code of “NH” may indicate a “National Highway” or “New Hampshire”. Moreover, a route number may not even uniquely identify a route within a given network.
     
     If a highway ramp is part of a numbered route, its reference code is contained in this property. On the other hand, guide signage for a highway ramp usually indicates route reference codes of the adjoining road; use the `destinationCodes` property for those route reference codes.
     */
    open let codes: [String]?
    
    // MARK: Getting Additional Step Details
    
    /**
     The mode of transportation used for the step.
     
     This step may use a different mode of transportation than the overall route.
     */
    open let transportType: TransportType?
    
    /**
     Any route reference codes that appear on guide signage for the road leading from this step’s maneuver to the next step’s maneuver.
     
     This property is typically available in steps leading to or from a freeway or expressway. This property contains route reference codes associated with a road later in the route. If a highway ramp is itself part of a numbered route, its reference code is contained in the `codes` property.
     
     A route reference code commonly consists of an alphabetic network code, a space or hyphen, and a route number. You should not assume that the network code is globally unique: for example, a network code of “NH” may indicate a “National Highway” or “New Hampshire”. Moreover, a route number may not even uniquely identify a route within a given network. A destination code for a divided road is often suffixed with the cardinal direction of travel, for example “I 80 East”.
     */
    public let destinationCodes: [String]?
    
    /**
     Destinations, such as [control cities](https://en.wikipedia.org/wiki/Control_city), that appear on guide signage for the road leading from this step’s maneuver to the next step’s maneuver.
     
     This property is typically available in steps leading to or from a freeway or expressway.
     */
    open let destinations: [String]?
    
    /**
     An array of intersections along the step.
     
     Each item in the array corresponds to a cross street, starting with the intersection at the maneuver location indicated by the coordinates property and continuing with each cross street along the step.
    */
    public let intersections: [Intersection]?
}

// MARK: Support for Directions API v4

extension ManeuverType {
    internal init?(v4Description: String) {
        let description: String
        switch v4Description {
        case "bear right", "turn right", "sharp right", "sharp left", "turn left", "bear left", "u-turn":
            description = "turn"
        case "enter roundabout":
            description = "roundabout"
        default:
            description = v4Description
        }
        self.init(description: description)
    }
}

extension ManeuverDirection {
    internal init?(v4TypeDescription: String) {
        let description: String
        switch v4TypeDescription {
        case "bear right", "bear left":
            description = v4TypeDescription.replacingOccurrences(of: "bear", with: "slight")
        case "turn right", "turn left":
            description = v4TypeDescription.replacingOccurrences(of: "turn ", with: "")
        case "u-turn":
            description = "uturn"
        default:
            description = v4TypeDescription
        }
        self.init(description: description)
    }
}

internal class RouteStepV4: RouteStep {
    internal convenience init(json: JSONDictionary) {
        let maneuver = json["maneuver"] as! JSONDictionary
        let heading = maneuver["heading"] as? Double
        let maneuverType = ManeuverType(v4Description: maneuver["type"] as! String)
        let maneuverDirection = ManeuverDirection(v4TypeDescription: maneuver["type"] as! String)
        let maneuverLocation = CLLocationCoordinate2D(geoJSON: maneuver["location"] as! JSONDictionary)
        
        let name = json["way_name"] as! String
        
        self.init(finalHeading: heading, maneuverType: maneuverType, maneuverDirection: maneuverDirection, maneuverLocation: maneuverLocation, name: name, coordinates: nil, json: json)
    }
}
