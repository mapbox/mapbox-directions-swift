import Polyline

/**
 A `TransportType` specifies the mode of transportation used for part of a route.
 */
@objc(MBTransportType)
public enum TransportType: Int, CustomStringConvertible, Codable {
    // Possible transport types when the `profileIdentifier` is `MBDirectionsProfileIdentifierAutomobile` or `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`
    
    /**
     The step does not have a particular transport type associated with it.
     
     This transport type is used as a workaround for bridging to Objective-C which does not support nullable enumeration-typed values.
     */
    case none
    
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
        case "none":
            type = .none
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
        case .none:
            return "none"
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
public enum ManeuverType: Int, CustomStringConvertible, Codable {
    /**
     The step does not have a particular maneuver type associated with it.
     
     This maneuver type is used as a workaround for bridging to Objective-C which does not support nullable enumeration-typed values.
     */
    case none
    
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
     The step requires the user to enter and traverse a roundabout (traffic circle or rotary).
     
     The step has no name, but the exit name is the name of the road to take to exit the roundabout. The exit index indicates the number of roundabout exits up to and including the exit to take.
     
     If `RouteOptions.includesExitRoundaboutManeuver` is set to `true`, this step is followed by an `.exitRoundabout` maneuver. Otherwise, this step represents the entire roundabout maneuver, from the entrance to the exit.
     */
    case takeRoundabout
    
    /**
     The step requires the user to enter and traverse a large, named roundabout (traffic circle or rotary).
     
     The step’s name is the name of the roundabout. The exit name is the name of the road to take to exit the roundabout. The exit index indicates the number of rotary exits up to and including the exit that the user must take.
     
      If `RouteOptions.includesExitRoundaboutManeuver` is set to `true`, this step is followed by an `.exitRotary` maneuver. Otherwise, this step represents the entire roundabout maneuver, from the entrance to the exit.
     */
    case takeRotary
    
    /**
     The step requires the user to enter and exit a roundabout (traffic circle or rotary) that is compact enough to constitute a single intersection.
     
     The step’s name is the name of the road to take after exiting the roundabout. This maneuver type is called out separately because the user may perceive the roundabout as an ordinary intersection with an island in the middle. If this distinction is unimportant to you, you may treat the maneuver as either an ordinary `turn` or as a `takeRoundabout`.
     */
    case turnAtRoundabout
    
    /**
     The step requires the user to exit a roundabout (traffic circle or rotary).
     
     This maneuver type follows a `.takeRoundabout` maneuver. It is only used when `RouteOptions.includesExitRoundaboutManeuver` is set to true.
     */
    case exitRoundabout
    
    /**
     The step requires the user to exit a large, named roundabout (traffic circle or rotary).
     
     This maneuver type follows a `.takeRotary` maneuver. It is only used when `RouteOptions.includesExitRoundaboutManeuver` is set to true.
     */
    case exitRotary
    
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
        case "exit roundabout":
            type = .exitRoundabout
        case "exit rotary":
            type = .exitRotary
        case "notification":
            type = .heedWarning
        case "arrive":
            type = .arrive
        case "waypoint": // v4
            type = .passWaypoint
        default:
            type = .none
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .none:
            return "none"
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
        case .exitRoundabout:
            return "exit roundabout"
        case .exitRotary:
            return "exit rotary"
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
public enum ManeuverDirection: Int, CustomStringConvertible, Codable {
    /**
     The step does not have a particular maneuver direction associated with it.
     
     This maneuver direction is used as a workaround for bridging to Objective-C which does not support nullable enumeration-typed values.
     */
    case none
    
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
            direction = .none
        }
        self.init(rawValue: direction.rawValue)
    }
    
    public var description: String {
        switch self {
        case .none:
            return "none"
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

/**
 A `DrivingSide` indicates which side of the road cars and traffic flow.
 */
@objc(MBDrivingSide)
public enum DrivingSide: Int, CustomStringConvertible, Codable {
    /**
     Indicates driving occurs on the `left` side.
     */
    case left
    
    /**
     Indicates driving occurs on the `right` side.
     */
    case right
    
    public init?(description: String) {
        var side: DrivingSide
        switch description {
        case "left":
            side = .left
        case "right":
            side = .right
        default:
            return nil
        }
        
        self.init(rawValue: side.rawValue)
    }
    
    public var description: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
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
    let exitCodes: [String]?
    let destinations: [String]?
    let destinationCodes: [String]?
    let rotaryNames: [String]?
    
    init(name: String, ref: String?, exits: String?, destination: String?, rotaryName: String?) {
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
            let parenthetical = name[codesRange]
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
        
        self.exitCodes = exits?.tagValues(separatedBy: ";")
        self.codes = codes
        self.rotaryNames = rotaryName?.tagValues(separatedBy: ";")
    }
}

struct GeoJSONGeometry: Codable {
    let coordinates: [CLLocationCoordinate2D]?
    let type: String?
}
/**
 A `RouteStep` object represents a single distinct maneuver along a route and the approach to the next maneuver. The route step object corresponds to a single instruction the user must follow to complete a portion of the route. For example, a step might require the user to turn then follow a road.
 
 You do not create instances of this class directly. Instead, you receive route step objects as part of route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method, setting the `includesSteps` option to `true` in the `RouteOptions` object that you pass into that method.
 */
@objc(MBRouteStep)
open class RouteStep: NSObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case codes
        case geometry
        case destinationCodes
        case destinations
        case distance
        case drivingSide = "driving_side"
        case exitCodes
        case exitIndex
        case exitNames
        case expectedTravelTime = "duration"
        case instructions
        case instructionsDisplayedAlongStep = "bannerInstructions"
        case instructionsSpokenAlongStep = "voiceInstructions"
        case intersections
        case maneuver
        case name
        case ref
        case exits
        case phoneticExitNames = "pronunciation"
        case phoneticNames = "rotary_pronunciation"
        case transportType
        case rotaryName = "rotary_name"
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case coordinates
        case type
    }
    
    private enum ManeuverCodingKeys: String, CodingKey {
        case instruction
        case location
        case type
        case direction = "modifier"
        case initialHeading = "bearing_before"
        case finalHeading = "bearing_after"
    }
    
    private enum RoadCodingKeys: String, CodingKey {
        case names
        case phoneticNames
        case exitNames
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instructionsSpokenAlongStep, forKey: .instructionsSpokenAlongStep)
        try container.encode(instructionsDisplayedAlongStep, forKey: .instructionsDisplayedAlongStep)
        try container.encode(exitIndex, forKey: .exitIndex)
        try container.encode(exitCodes, forKey: .exitCodes)
        try container.encode(exitNames, forKey: .exitNames)
        try container.encode(phoneticExitNames, forKey: .phoneticExitNames)
        try container.encode(phoneticNames, forKey: .phoneticNames)
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encode(codes, forKey: .codes)
        try container.encode(transportType, forKey: .transportType)
        try container.encode(destinationCodes, forKey: .destinationCodes)
        try container.encode(destinations, forKey: .destinations)
        try container.encode(intersections, forKey: .intersections)
        try container.encode(drivingSide.description, forKey: .drivingSide)
        try container.encode(name, forKey: .name)

        var maneuver = container.nestedContainer(keyedBy: ManeuverCodingKeys.self, forKey: .maneuver)
        try maneuver.encode(instructions, forKey: .instruction)
        try maneuver.encodeIfPresent(maneuverType?.description, forKey: .type)
        try maneuver.encodeIfPresent(maneuverDirection?.description, forKey: .direction)
        try maneuver.encodeIfPresent(maneuverLocation, forKey: .location)
        try maneuver.encodeIfPresent(initialHeading, forKey: .initialHeading)
        try maneuver.encodeIfPresent(finalHeading, forKey: .finalHeading)
        
        var geometry = container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .geometry)
        try geometry.encodeIfPresent(coordinates, forKey: .coordinates)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let maneuver = try container.nestedContainer(keyedBy: ManeuverCodingKeys.self, forKey: .maneuver)
        maneuverLocation = try maneuver.decode(CLLocationCoordinate2D.self, forKey: .location)
        
        // TODO: Move encoding/decoding into ManeuverType
        
        if let type = try maneuver.decodeIfPresent(String.self, forKey: .type) {
        maneuverDirection = ManeuverDirection(description: maneuverDirectionDescription) ?? .none
        
            maneuverType = ManeuverType(description: type)
        } else {
            maneuverType = nil
        }
        
        // TODO: Move encoding/decoding into ManeuverDirection
        if let direction = try maneuver.decodeIfPresent(String.self, forKey: .direction) {
            maneuverDirection = ManeuverDirection(description: direction)
        } else {
            maneuverDirection = nil
        }
        
        initialHeading = try maneuver.decodeIfPresent(CLLocationDirection.self, forKey: .initialHeading)
        finalHeading = try maneuver.decodeIfPresent(CLLocationDirection.self, forKey: .finalHeading)
        
        let geometry = try container.decodeIfPresent(GenericDecodable<GeoJSONGeometry, String>.self, forKey: .geometry)
        if let geo = geometry?.value as? String {
            coordinates = decodePolyline(geo, precision: 1e5)
        } else if let geo = geometry?.value as? GeoJSONGeometry {
            coordinates = geo.coordinates
        } else {
            coordinates = nil
        }
        transportType = TransportType(description: transportTypeDescription) ?? .none
        
        name = try container.decode(String.self, forKey: .name)
        
        let road = Road(name: name,
                        ref: try container.decodeIfPresent(String.self, forKey: .ref),
                        exits: try container.decodeIfPresent(String.self, forKey: .exits),
                        destination: try container.decodeIfPresent(String.self, forKey: .destinations),
                        rotaryName: try container.decodeIfPresent(String.self, forKey: .rotaryName))
        
        if let instruction = try? maneuver.decode(String.self, forKey: .instruction) {
            instructions = instruction
        } else if let mt = maneuverType, let md = maneuverDirection {
            instructions = "\(mt) \(md)"
        } else if let mt = maneuverType {
            instructions = String(describing: mt)
        } else if let md = maneuverDirection {
            instructions = String(describing: md)
        } else {
            instructions = ""
        }
        
        instructionsSpokenAlongStep = try container.decodeIfPresent([SpokenInstruction].self, forKey: .instructionsSpokenAlongStep)
        instructionsDisplayedAlongStep = try container.decodeIfPresent([VisualInstruction].self, forKey: .instructionsDisplayedAlongStep)
        
        drivingSide = DrivingSide(description: try container.decode(String.self, forKey: .drivingSide))!
        exitIndex = try container.decodeIfPresent(Int.self, forKey: .exitIndex)
        exitCodes = try container.decodeIfPresent([String].self, forKey: .exitCodes)
        distance = try container.decode(CLLocationDirection.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
        
        codes = road.codes
        transportType = try container.decodeIfPresent(TransportType.self, forKey: .transportType)
        destinationCodes = road.destinationCodes
        
        coder.encode(maneuverType.description, forKey: "maneuverType")
        intersections = try container.decodeIfPresent([Intersection].self, forKey: .intersections)
        
        destinations = road.destinations
        
        if let type = maneuverType,
            type == .takeRotary || type == .takeRoundabout {
            names = road.rotaryNames
            phoneticNames = try container.decodeIfPresent(String.self, forKey: .phoneticNames)?.tagValues(separatedBy: ";")
            exitNames = road.names
            phoneticExitNames = try container.decodeIfPresent(String.self, forKey: .phoneticExitNames)?.tagValues(separatedBy: ";")
        } else {
            names = road.names
            phoneticNames = try container.decodeIfPresent(String.self, forKey: .phoneticNames)?.tagValues(separatedBy: ";")
            exitNames = nil
            phoneticExitNames = nil
        }
    }
    
    // MARK: Getting the Step Geometry
    
    /**
     An array of geographic coordinates defining the path of the route step from the location of the maneuver to the location of the next step’s maneuver.
     
     The value of this property may be `nil`, for example when the maneuver type is `arrive`.
     
     Using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [Mapbox Maps SDK for macOS](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display a portion of a route on an `MGLMapView`.
     */
    @objc open let coordinates: [CLLocationCoordinate2D]?
    
    /**
     The number of coordinates.
     
     The value of this property may be zero, for example when the maneuver type is `arrive`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates.count` property.
     */
    @objc open var coordinateCount: UInt {
        return UInt(coordinates?.count ?? 0)
    }
    
    /**
     Retrieves the coordinates.
     
     The array may be empty, for example when the maneuver type is `arrive`.
     
     Using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [Mapbox Maps SDK for macOS](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/macos/), you can create an `MGLPolyline` object using these coordinates to display a portion of a route on an `MGLMapView`.
     
     - parameter coordinates: A pointer to a C array of `CLLocationCoordinate2D` instances. On output, this array contains all the vertices of the overlay.
     - returns: True if the step has coordinates and `coordinates` has been populated, or false if the step has no coordinates and `coordinates` has not been modified.
     
     - precondition: `coordinates` must be large enough to hold `coordinateCount` instances of `CLLocationCoordinate2D`.
     
     - note: This initializer is intended for Objective-C usage. In Swift code, use the `coordinates` property.
     */
    @objc open func getCoordinates(_ coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>) -> Bool {
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
     
     You can display this string or read it aloud to the user. The string does not include the distance to or from the maneuver. For instructions optimized for real-time delivery during turn-by-turn navigation, set the `RouteOptions.includesSpokenInstructions` option and use the `instructionsSpokenAlongStep` property. If you need customized instructions, you can construct them yourself from the step’s other properties or use [OSRM Text Instructions](https://github.com/Project-OSRM/osrm-text-instructions.swift/).
     
     - note: If you use MapboxDirections.swift with the Mapbox Directions API, this property is formatted and localized for display to the user. If you use OSRM directly, this property contains a basic string that only includes the maneuver type and direction. Use [OSRM Text Instructions](https://github.com/Project-OSRM/osrm-text-instructions.swift/) to construct a complete, localized instruction string for display.
     */
    @objc open let instructions: String
    
    fileprivate let name: String
    
    /**
     Instructions about the next step’s maneuver, optimized for speech synthesis.
    
     As the user traverses this step, you can give them advance notice of the upcoming maneuver by reading aloud each item in this array in order as the user reaches the specified distances along this step. The text of the spoken instructions refers to the details in the next step, but the distances are measured from the beginning of this step.
     
     This property is non-`nil` if the `RouteOptions.includesSpokenInstructions` option is set to `true`. For instructions designed for display, use the `instructions` property.
     */
    @objc open let instructionsSpokenAlongStep: [SpokenInstruction]?
    
    /**
     :nodoc:
     Instructions about the next step’s maneuver, optimized for display in real time.
     
     As the user traverses this step, you can give them advance notice of the upcoming maneuver by displaying each item in this array in order as the user reaches the specified distances along this step. The text and images of the visual instructions refer to the details in the next step, but the distances are measured from the beginning of this step.
     
     This property is non-`nil` if the `RouteOptions.includesVisualInstructions` option is set to `true`. For instructions designed for speech synthesis, use the `instructionsSpokenAlongStep` property. For instructions designed for display in a static list, use the `instructions` property.
     */
    @objc open let instructionsDisplayedAlongStep: [VisualInstruction]?
    
    @objc open override var description: String {
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
    @objc open let maneuverType: ManeuverType
    
    /**
     Additional directional information to clarify the maneuver type.
     */
    @objc open let maneuverDirection: ManeuverDirection
    
    /**
     Indicates what side of a bidirectional road the driver must be driving on. Also referred to as the rule of the road.
     */
    open let drivingSide: DrivingSide
    
    /**
     The location of the maneuver at the beginning of this step.
     */
    @objc open let maneuverLocation: CLLocationCoordinate2D
    
    /**
     The number of exits from the previous maneuver up to and including this step’s maneuver.
     
     If the maneuver takes place on a surface street, this property counts intersections. The number of intersections does not necessarily correspond to the number of blocks. If the maneuver takes place on a grade-separated highway (freeway or motorway), this property counts highway exits but not highway entrances. If the maneuver is a roundabout maneuver, the exit index is the number of exits from the approach to the recommended outlet. For the signposted exit numbers associated with a highway exit, use the `exitCodes` property.
     
     In some cases, the number of exits leading to a maneuver may be more useful to the user than the distance to the maneuver.
     */
    open let exitIndex: Int?
    
    /**
     Any [exit numbers](https://en.wikipedia.org/wiki/Exit_number) assigned to the highway exit at the maneuver.
     
     This property is only set when the `maneuverType` is `ManeuverType.takeOffRamp`. For the number of exits from the previous maneuver, regardless of the highway’s exit numbering scheme, use the `exitIndex` property. For the route reference codes associated with the connecting road, use the `destinationCodes` property. For the names associated with a roundabout exit, use the `exitNames` property.
     
     An exit number is an alphanumeric identifier posted at or ahead of a highway off-ramp. Exit numbers may increase or decrease sequentially along a road, or they may correspond to distances from either end of the road. An alphabetic suffix may appear when multiple exits are located in the same interchange. If multiple exits are [combined into a single exit](https://en.wikipedia.org/wiki/Local-express_lanes#Example_of_cloverleaf_interchanges), the step may have multiple exit codes.
     */
    @objc open let exitCodes: [String]?
    
    /**
     The names of the roundabout exit.
     
     This property is only set for roundabout (traffic circle or rotary) maneuvers. For the signposted names associated with a highway exit, use the `destinations` property. For the signposted exit numbers, use the `exitCodes` property.
     
     If you display a name to the user, you may need to abbreviate common words like “East” or “Boulevard” to ensure that it fits in the allotted space.
     */
    @objc public let exitNames: [String]?
    
    /**
     A phonetic or phonemic transcription indicating how to pronounce the names in the `exitNames` property.
     
     This property is only set for roundabout (traffic circle or rotary) maneuvers.
     
     The transcription is written in the [International Phonetic Alphabet](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet).
     */
    @objc open let phoneticExitNames: [String]?
    
    // MARK: Getting Details About the Approach to the Next Maneuver
    
    /**
     The step’s distance, measured in meters.
     
     The value of this property accounts for the distance that the user must travel to go from this step’s maneuver location to the next step’s maneuver location. It is not the sum of the direct distances between the route’s waypoints, nor should you assume that the user would travel along this distance at a fixed speed.
     */
    @objc open let distance: CLLocationDistance
    
    /**
     The step’s expected travel time, measured in seconds.
     
     The value of this property reflects the time it takes to go from this step’s maneuver location to the next step’s maneuver location. If the route was calculated using the `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` profile, this property reflects current traffic conditions at the time of the request, not necessarily the traffic conditions at the time the user would begin this step. For other profiles, this property reflects travel time under ideal conditions and does not account for traffic congestion. If the step makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.
     
     Do not assume that the user would travel along the step at a fixed speed. For the expected travel time on each individual segment along the leg, specify the `AttributeOptions.expectedTravelTime` option and use the `RouteLeg.expectedSegmentTravelTimes` property.
     */
    @objc open let expectedTravelTime: TimeInterval
    
    /**
     The names of the road or path leading from this step’s maneuver to the next step’s maneuver.
     
     If the maneuver is a turning maneuver, the step’s names are the name of the road or path onto which the user turns. If you display a name to the user, you may need to abbreviate common words like “East” or “Boulevard” to ensure that it fits in the allotted space.
     
     If the maneuver is a roundabout maneuver, the outlet to take is named in the `exitNames` property; the `names` property is only set for large roundabouts that have their own names.
     */
    @objc open let names: [String]?
    
    /**
     A phonetic or phonemic transcription indicating how to pronounce the names in the `names` property.
     
     The transcription is written in the [International Phonetic Alphabet](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet).
     
     If the maneuver traverses a large, named roundabout, the `exitPronunciationHints` property contains a hint about how to pronounce the names of the outlet to take.
     */
    @objc open let phoneticNames: [String]?
    
    /**
     Any route reference codes assigned to the road or path leading from this step’s maneuver to the next step’s maneuver.
     
     A route reference code commonly consists of an alphabetic network code, a space or hyphen, and a route number. You should not assume that the network code is globally unique: for example, a network code of “NH” may indicate a “National Highway” or “New Hampshire”. Moreover, a route number may not even uniquely identify a route within a given network.
     
     If a highway ramp is part of a numbered route, its reference code is contained in this property. On the other hand, guide signage for a highway ramp usually indicates route reference codes of the adjoining road; use the `destinationCodes` property for those route reference codes.
     */
    @objc open let codes: [String]?
    
    // MARK: Getting Additional Step Details
    
    /**
     The mode of transportation used for the step.
     
     This step may use a different mode of transportation than the overall route.
     */
    @objc open let transportType: TransportType
    
    /**
     Any route reference codes that appear on guide signage for the road leading from this step’s maneuver to the next step’s maneuver.
     
     This property is typically available in steps leading to or from a freeway or expressway. This property contains route reference codes associated with a road later in the route. If a highway ramp is itself part of a numbered route, its reference code is contained in the `codes` property. For the signposted exit numbers associated with a highway exit, use the `exitCodes` property.
     
     A route reference code commonly consists of an alphabetic network code, a space or hyphen, and a route number. You should not assume that the network code is globally unique: for example, a network code of “NH” may indicate a “National Highway” or “New Hampshire”. Moreover, a route number may not even uniquely identify a route within a given network. A destination code for a divided road is often suffixed with the cardinal direction of travel, for example “I 80 East”.
     */
    @objc public let destinationCodes: [String]?
    
    /**
     Destinations, such as [control cities](https://en.wikipedia.org/wiki/Control_city), that appear on guide signage for the road leading from this step’s maneuver to the next step’s maneuver.
     
     This property is typically available in steps leading to or from a freeway or expressway.
     */
    @objc open let destinations: [String]?
    
    /**
     An array of intersections along the step.
     
     Each item in the array corresponds to a cross street, starting with the intersection at the maneuver location indicated by the coordinates property and continuing with each cross street along the step.
    */
    @objc public let intersections: [Intersection]?
    
    func debugQuickLookObject() -> Any? {
        if let coordinates = coordinates {
            return debugQuickLookURL(illustrating: coordinates)
        }
        return nil
    }
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
    // TODO: Fix
//    internal convenience init(json: JSONDictionary) {
//        let maneuver = json["maneuver"] as! JSONDictionary
//        let heading = maneuver["heading"] as? Double
//        let maneuverType = ManeuverType(v4Description: maneuver["type"] as! String)
//        let maneuverDirection = ManeuverDirection(v4TypeDescription: maneuver["type"] as! String)
//        let maneuverLocation = CLLocationCoordinate2D(geoJSON: maneuver["location"] as! JSONDictionary)
//        let drivingSide = DrivingSide(description: json["driving_side"] as! String) ?? .right
//        let name = json["way_name"] as! String
//
//        self.init(finalHeading: heading, maneuverType: maneuverType, maneuverDirection: maneuverDirection, drivingSide: drivingSide, maneuverLocation: maneuverLocation, name: name, coordinates: nil, json: json)
//    }
}

func debugQuickLookURL(illustrating coordinates: [CLLocationCoordinate2D], profileIdentifier: MBDirectionsProfileIdentifier = .automobile) -> URL? {
    guard let accessToken = defaultAccessToken else {
        return nil
    }
    
    let styleIdentifier: String
    let identifierOfLayerAboveOverlays: String
    switch profileIdentifier {
    case MBDirectionsProfileIdentifier.automobileAvoidingTraffic:
        styleIdentifier = "mapbox/traffic-day-v2"
        identifierOfLayerAboveOverlays = "poi-driving-scalerank4"
    case MBDirectionsProfileIdentifier.cycling, MBDirectionsProfileIdentifier.walking:
        styleIdentifier = "mapbox/outdoors-v10"
        identifierOfLayerAboveOverlays = "housenum-label"
    default:
        styleIdentifier = "mapbox/streets-v10"
        identifierOfLayerAboveOverlays = "housenum-label"
    }
    let styleIdentifierComponent = "/\(styleIdentifier)/static"
    
    var allowedCharacterSet = CharacterSet.urlPathAllowed
    allowedCharacterSet.remove(charactersIn: "/)")
    let encodedPolyline = encodeCoordinates(coordinates, precision: 1e5).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    let overlaysComponent = "/path-10+3802DA-0.6(\(encodedPolyline))"
    
    let path = "/styles/v1\(styleIdentifierComponent)\(overlaysComponent)/auto/680x360@2x"
    
    var components = URLComponents()
    components.queryItems = [
        URLQueryItem(name: "before_layer", value: identifierOfLayerAboveOverlays),
        URLQueryItem(name: "access_token", value: accessToken),
    ]
    
    return URL(string: "https://api.mapbox.com\(path)?\(components.percentEncodedQuery!)")
}
