import Foundation
import CoreLocation
import Polyline
import Turf

/**
 A `RouteLeg` object defines a single leg of a route between two waypoints. If the overall route has only two waypoints, it has a single `RouteLeg` object that covers the entire route. The route leg object includes information about the leg, such as its name, distance, and expected travel time. Depending on the criteria used to calculate the route, the route leg object may also include detailed turn-by-turn instructions.

 You do not create instances of this class directly. Instead, you receive route leg objects as part of route objects when you request directions using the `Directions.calculate(_:completionHandler:)` method.
 */
open class RouteLeg: Codable {
    public enum CodingKeys: String, CodingKey {
        case source
        case destination
        case steps
        case name = "summary"
        case distance
        case expectedTravelTime = "duration"
        case typicalTravelTime = "duration_typical"
        case profileIdentifier
        case annotation
        case administrationRegions = "admins"
        case incidents
    }
    
    // MARK: Creating a Leg
    
    /**
     Initializes a route leg.
     
     - parameter steps: The steps that are traversed in order.
     - parameter name: A name that describes the route leg.
     - parameter expectedTravelTime: The route leg’s expected travel time, measured in seconds.
     - parameter typicalTravelTime: The route leg’s typical travel time, measured in seconds.
     - parameter profileIdentifier: The primary mode of transportation for the route leg.
     */
    public init(steps: [RouteStep], name: String, distance: CLLocationDistance, expectedTravelTime: TimeInterval, typicalTravelTime: TimeInterval? = nil, profileIdentifier: DirectionsProfileIdentifier) {
        self.steps = steps
        self.name = name
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.typicalTravelTime = typicalTravelTime
        self.profileIdentifier = profileIdentifier
        
        segmentDistances = nil
        expectedSegmentTravelTimes = nil
        segmentSpeeds = nil
        segmentCongestionLevels = nil
    }
    
    /**
     Creates a route leg from a decoder.
     
     - precondition: If the decoder is decoding JSON data from an API response, the `Decoder.userInfo` dictionary must contain a `RouteOptions` or `MatchOptions` object in the `CodingUserInfoKey.options` key. If it does not, a `DirectionsCodingError.missingOptions` error is thrown.
     - parameter decoder: The decoder of JSON-formatted API response data or a previously encoded `RouteLeg` object.
     */
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decodeIfPresent(Waypoint.self, forKey: .source)
        destination = try container.decodeIfPresent(Waypoint.self, forKey: .destination)
        steps = try container.decode([RouteStep].self, forKey: .steps)
        name = try container.decode(String.self, forKey: .name)
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
        typicalTravelTime = try container.decodeIfPresent(TimeInterval.self, forKey: .typicalTravelTime)
        
        if let profileIdentifier = try container.decodeIfPresent(DirectionsProfileIdentifier.self, forKey: .profileIdentifier) {
            self.profileIdentifier = profileIdentifier
        } else if let options = decoder.userInfo[.options] as? DirectionsOptions {
            profileIdentifier = options.profileIdentifier
        } else {
            throw DirectionsCodingError.missingOptions
        }
        
        if let attributes = try container.decodeIfPresent(Attributes.self, forKey: .annotation) {
            self.attributes = attributes
        }

        if let admins = try container.decodeIfPresent([AdministrationRegion].self, forKey: .administrationRegions) {
            self.administrationRegions = admins
        }

        if let incidents = try container.decodeIfPresent([Incident].self, forKey: .incidents) {
            self.incidents = incidents
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(destination, forKey: .destination)
        try container.encode(steps, forKey: .steps)
        try container.encode(name, forKey: .name)
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encodeIfPresent(typicalTravelTime, forKey: .typicalTravelTime)
        try container.encode(profileIdentifier, forKey: .profileIdentifier)
        
        let attributes = self.attributes
        if !attributes.isEmpty {
            try container.encode(attributes, forKey: .annotation)
        }

        if let admins = administrationRegions {
            try container.encode(admins, forKey: .administrationRegions)
        }

        if let incidents = incidents {
            try container.encode(incidents, forKey: .incidents)
        }
    }
    
    // MARK: Getting the Endpoints of the Leg

    /**
     The starting point of the route leg.

     Unless this is the first leg of the route, the source of this leg is the same as the destination of the previous leg.
     
     This property is set to `nil` if the leg was decoded from a JSON RouteLeg object.
     */
    public var source: Waypoint?

    /**
     The endpoint of the route leg.

     Unless this is the last leg of the route, the destination of this leg is the same as the source of the next leg.
     
     This property is set to `nil` if the leg was decoded from a JSON RouteLeg object.
     */
    public var destination: Waypoint?
    
    // MARK: Getting the Steps Along the Leg
    
    /**
     An array of one or more `RouteStep` objects representing the steps for traversing this leg of the route.

     Each route step object corresponds to a distinct maneuver and the approach to the next maneuver.

     This array is empty if the original `RouteOptions` object’s `RouteOptions.includesSteps` property is set to `false`.
     */
    public let steps: [RouteStep]
    
    /**
     The ranges of each step’s segments within the overall leg.
     
     Each range corresponds to an element of the `steps` property. Use this property to safely subscript segment-based properties such as `segmentCongestionLevels` and `segmentMaximumSpeedLimits`.
     
     This array is empty if the original `RouteOptions` object’s `RouteOptions.includesSteps` property is set to `false`.
     */
    public private(set) lazy var segmentRangesByStep: [Range<Int>] = {
        var segmentRangesByStep: [Range<Int>] = []
        var currentStepStartIndex = 0
        for step in steps {
            if let coordinates = step.shape?.coordinates {
                let stepCoordinateCount = step.maneuverType == .arrive ? coordinates.count : coordinates.dropLast().count
                let currentStepEndIndex = currentStepStartIndex.advanced(by: stepCoordinateCount)
                segmentRangesByStep.append(currentStepStartIndex..<currentStepEndIndex)
                currentStepStartIndex = currentStepEndIndex
            } else {
                segmentRangesByStep.append(currentStepStartIndex..<currentStepStartIndex)
            }
        }
        return segmentRangesByStep
    }()
    
    /**
     :nodoc:
     Segments for each Intersection along the route.
     
     Ordered by `steps`, inside one `step` - ordered by `Intersection`.  `nil` value means no index was provided. Index values correspond to `route`'s `shape` elements.
     */
    public private(set) lazy var intersectionsIndexesByStep: [[Int?]?] = {
        var intersectionsIndexesByStep: [[Int?]?] = []
        for step in steps {
            intersectionsIndexesByStep.append(step.intersections?.map { $0.geometryIndex })
        }
        return intersectionsIndexesByStep
    }()
    
    // MARK: Getting Per-Segment Attributes Along the Leg
    
    /**
     An array containing the distance (measured in meters) between each coordinate in the route leg geometry.

     This property is set if the `RouteOptions.attributeOptions` property contains `AttributeOptions.distance`.
     */
    open var segmentDistances: [CLLocationDistance]?

    /**
     An array containing the expected travel time (measured in seconds) between each coordinate in the route leg geometry.

     These values are dynamic, accounting for any conditions that may change along a segment, such as traffic congestion if the profile identifier is set to `.automobileAvoidingTraffic`.

     This property is set if the `RouteOptions.attributeOptions` property contains `AttributeOptions.expectedTravelTime`.
     */
    open var expectedSegmentTravelTimes: [TimeInterval]?

    /**
     An array containing the expected average speed (measured in meters per second) between each coordinate in the route leg geometry.

     These values are dynamic; rather than speed limits, they account for the road’s classification and/or any traffic congestion (if the profile identifier is set to `.automobileAvoidingTraffic`).

     This property is set if the `RouteOptions.attributeOptions` property contains `AttributeOptions.speed`.
     */
    open var segmentSpeeds: [CLLocationSpeed]?

    /**
     An array containing the traffic congestion level along each road segment in the route leg geometry.

     Traffic data is available in [a number of countries and territories worldwide](https://docs.mapbox.com/help/how-mapbox-works/directions/#traffic-data).

     You can color-code a route line according to the congestion level along each segment of the route.

     This property is set if the `RouteOptions.attributeOptions` property contains `AttributeOptions.congestionLevel`.
     */
    open var segmentCongestionLevels: [CongestionLevel]?
    
    /**
     An array containing the maximum speed limit along each road segment along the route leg’s shape.
     
     The maximum speed may be an advisory speed limit for segments where legal limits are not posted, such as highway entrance and exit ramps. If the speed limit along a particular segment is unknown, it is represented in the array by a measurement whose value is negative. If the speed is unregulated along the segment, such as on the German _Autobahn_ system, it is represented by a measurement whose value is `Double.infinity`.
     
     Speed limit data is available in [a number of countries and territories worldwide](https://docs.mapbox.com/help/how-mapbox-works/directions/).
     
     This property is set if the `RouteOptions.attributeOptions` property contains `AttributeOptions.maximumSpeedLimit`.
     */
    open var segmentMaximumSpeedLimits: [Measurement<UnitSpeed>?]?
    
    /**
     The full collection of attributes along the leg.
     */
    var attributes: Attributes {
        get {
            return Attributes(segmentDistances: segmentDistances,
                              expectedSegmentTravelTimes: expectedSegmentTravelTimes,
                              segmentSpeeds: segmentSpeeds,
                              segmentCongestionLevels: segmentCongestionLevels,
                              segmentMaximumSpeedLimits: segmentMaximumSpeedLimits)
        }
        set {
            segmentDistances = newValue.segmentDistances
            expectedSegmentTravelTimes = newValue.expectedSegmentTravelTimes
            segmentSpeeds = newValue.segmentSpeeds
            segmentCongestionLevels = newValue.segmentCongestionLevels
            segmentMaximumSpeedLimits = newValue.segmentMaximumSpeedLimits
        }
    }
    
    // MARK: Getting Statistics About the Leg

    /**
     A name that describes the route leg.

     The name describes the leg using the most significant roads or trails along the route leg. You can display this string to the user to help the user can distinguish one route from another based on how the legs of the routes are named.

     The leg’s name does not identify the start and end points of the leg. To distinguish one leg from another within the same route, concatenate the `name` properties of the `source` and `destination` waypoints.
     */
    public let name: String
    
    /**
     The route leg’s distance, measured in meters.

     The value of this property accounts for the distance that the user must travel to arrive at the destination from the source. It is not the direct distance between the source and destination, nor should not assume that the user would travel along this distance at a fixed speed.
     */
    public let distance: CLLocationDistance

    /**
     The route leg’s expected travel time, measured in seconds.

     The value of this property reflects the time it takes to traverse the route leg. If the route was calculated using the `DirectionsProfileIdentifier.automobileAvoidingTraffic` profile, this property reflects current traffic conditions at the time of the request, not necessarily the traffic conditions at the time the user would begin this leg. For other profiles, this property reflects travel time under ideal conditions and does not account for traffic congestion. If the leg makes use of a ferry or train, the actual travel time may additionally be subject to the schedules of those services.

     Do not assume that the user would travel along the leg at a fixed speed. For the expected travel time on each individual segment along the leg, use the `RouteStep.expectedTravelTimes` property. For more granularity, specify the `AttributeOptions.expectedTravelTime` option and use the `expectedSegmentTravelTimes` property.
     */
    open var expectedTravelTime: TimeInterval

    open var administrationRegions: [AdministrationRegion]?

    open var incidents: [Incident]?
    
    /**
     The route leg’s typical travel time, measured in seconds.
     
     The value of this property reflects the typical time it takes to traverse the route leg. This property is available when using the `DirectionsProfileIdentifier.automobileAvoidingTraffic` profile. This property reflects typical traffic conditions at the time of the request, not necessarily the typical traffic conditions at the time the user would begin this leg. If the leg makes use of a ferry, the typical travel time may additionally be subject to the schedule of this service.
     
     Do not assume that the user would travel along the route at a fixed speed. For more granular typical travel times, use the `RouteStep.typicalTravelTime` property.
     */
    open var typicalTravelTime: TimeInterval?
    
    // MARK: Reproducing the Route
    
    /**
     The primary mode of transportation for the route leg.

     The value of this property depends on the `RouteOptions.profileIdentifier` property of the original `RouteOptions` object. This property reflects the primary mode of transportation used for the route leg. Individual steps along the route leg might use different modes of transportation as necessary.
     */
    public let profileIdentifier: DirectionsProfileIdentifier
}

extension RouteLeg: Equatable {
    public static func == (lhs: RouteLeg, rhs: RouteLeg) -> Bool {
        return lhs.source == rhs.source &&
            lhs.destination == rhs.destination &&
            lhs.steps == rhs.steps &&
            lhs.segmentDistances == rhs.segmentDistances &&
            lhs.expectedSegmentTravelTimes == rhs.expectedSegmentTravelTimes &&
            lhs.segmentSpeeds == rhs.segmentSpeeds &&
            lhs.segmentCongestionLevels == rhs.segmentCongestionLevels &&
            lhs.segmentMaximumSpeedLimits == rhs.segmentMaximumSpeedLimits &&
            lhs.name == rhs.name &&
            lhs.distance == rhs.distance &&
            lhs.expectedTravelTime == rhs.expectedTravelTime &&
            lhs.typicalTravelTime == rhs.typicalTravelTime &&
            lhs.profileIdentifier == rhs.profileIdentifier
    }
}

extension RouteLeg: CustomStringConvertible {
    public var description: String {
        return name
    }
}

extension RouteLeg: CustomQuickLookConvertible {
    func debugQuickLookObject() -> Any? {
        let coordinates = steps.reduce([], { $0 + ($1.shape?.coordinates ?? []) })
        guard !coordinates.isEmpty else {
            return nil
        }
        return debugQuickLookURL(illustrating: LineString(coordinates))
    }
}

public extension Array where Element == RouteLeg {
    /**
     Populates source and destination information for each leg with waypoint information, typically gathered from `DirectionsOptions`.
     */
    func populate(waypoints: [Waypoint]) {
        let legInfo = zip(zip(waypoints.prefix(upTo: waypoints.endIndex - 1), waypoints.suffix(from: 1)), self)

        for (endpoints, leg) in legInfo {
            leg.source = endpoints.0
            leg.destination = endpoints.1
        }
    }
}
