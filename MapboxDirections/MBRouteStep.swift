import Polyline


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
        case v4wayName = "way_name"
        case ref
        case exits
        case phoneticExitNames = "pronunciation"
        case phoneticNames = "rotary_pronunciation"
        case transportType
        case rotaryName = "rotary_name"
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
        try container.encode(geometry, forKey: .geometry)
        
        var maneuver = container.nestedContainer(keyedBy: ManeuverCodingKeys.self, forKey: .maneuver)
        try maneuver.encode(instructions, forKey: .instruction)
        try maneuver.encodeIfPresent(maneuverType?.description, forKey: .type)
        try maneuver.encodeIfPresent(maneuverDirection?.description, forKey: .direction)
        try maneuver.encodeIfPresent(maneuverLocation, forKey: .location)
        try maneuver.encodeIfPresent(initialHeading, forKey: .initialHeading)
        try maneuver.encodeIfPresent(finalHeading, forKey: .finalHeading)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let maneuver = try container.nestedContainer(keyedBy: ManeuverCodingKeys.self, forKey: .maneuver)
        
        if let coordinate = try? maneuver.decode(UncertainCodable<Geometry, String>.self, forKey: .location).coordinates.first,
            let maneuverCoordinate = coordinate {
            maneuverLocation = maneuverCoordinate
        } else if let coordinate = try? maneuver.decode(CLLocationCoordinate2D.self, forKey: .location) {
            maneuverLocation = coordinate
        } else {
            maneuverLocation = CLLocationCoordinate2D()
        }
        
        maneuverType = try maneuver.decodeIfPresent(ManeuverType.self, forKey: .type)
        maneuverDirection = try maneuver.decodeIfPresent(ManeuverDirection.self, forKey: .direction)
        
        initialHeading = try maneuver.decodeIfPresent(CLLocationDirection.self, forKey: .initialHeading)
        finalHeading = try maneuver.decodeIfPresent(CLLocationDirection.self, forKey: .finalHeading)
        
        geometry = try container.decodeIfPresent(UncertainCodable<Geometry, String>.self, forKey: .geometry)
        coordinates = geometry?.coordinates

        name = try container.decodeIfPresent(String.self, forKey: .name) ?? container.decode(String.self, forKey: .v4wayName)
        
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
    
    fileprivate var geometry: UncertainCodable<Geometry, String>?
    
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
    open let maneuverType: ManeuverType?
    
    /**
     Additional directional information to clarify the maneuver type.
     */
    open let maneuverDirection: ManeuverDirection?
    
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
    open let transportType: TransportType?
    
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
