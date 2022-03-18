import Foundation
#if canImport(CoreLocation)
import CoreLocation
#endif
import Turf

/**
 A `MatchOptions` object is a structure that specifies the criteria for results returned by the Mapbox Map Matching API.

 Pass an instance of this class into the `Directions.calculate(_:completionHandler:)` method.
 */
open class MatchOptions: DirectionsOptions {
    // MARK: Creating a Match Options Object
    
    #if canImport(CoreLocation)
    /**
     Initializes a match options object for matching locations against the road network.

     - parameter locations: An array of `CLLocation` objects representing locations to attempt to match against the road network. The array should contain at least two locations (the source and destination) and at most 100 locations. (Some profiles, such as `ProfileIdentifier.automobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/#directions).)
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. `ProfileIdentifier.automobile` is used by default.
     - parameter queryItems: URL query items to be parsed and applied as configuration to the resulting options.
     */
    public convenience init(locations: [CLLocation], profileIdentifier: ProfileIdentifier? = nil, queryItems: [URLQueryItem]? = nil) {
        let waypoints = locations.map {
            Waypoint(location: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier, queryItems: queryItems)
    }
    #endif

    /**
     Initializes a match options object for matching geographic coordinates against the road network.

     - parameter coordinates: An array of geographic coordinates representing locations to attempt to match against the road network. The array should contain at least two locations (the source and destination) and at most 100 locations. (Some profiles, such as `ProfileIdentifier.automobileAvoidingTraffic`, [may have lower limits](https://docs.mapbox.com/api/navigation/#directions).) Each coordinate is converted into a `Waypoint` object.
     - parameter profileIdentifier: A string specifying the primary mode of transportation for the routes. `ProfileIdentifier.automobile` is used by default.
     - parameter queryItems: URL query items to be parsed and applied as configuration to the resulting options.
     */
    public convenience init(coordinates: [LocationCoordinate2D], profileIdentifier: ProfileIdentifier? = nil, queryItems: [URLQueryItem]? = nil) {
        let waypoints = coordinates.map {
            Waypoint(coordinate: $0)
        }
        self.init(waypoints: waypoints, profileIdentifier: profileIdentifier, queryItems: queryItems)
    }

    public required init(waypoints: [Waypoint], profileIdentifier: ProfileIdentifier? = nil, queryItems: [URLQueryItem]? = nil) {
        super.init(waypoints: waypoints, profileIdentifier: profileIdentifier, queryItems: queryItems)
        
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
        
        if mappedQueryItems[CodingKeys.resamplesTraces.stringValue] == "true" {
            self.resamplesTraces = true
        }
        
        if let mappedValue = mappedQueryItems["waypoints"] {
            let indicies = mappedValue.components(separatedBy: ";").compactMap { Int($0) }
            if !indicies.isEmpty {
                waypoints.enumerated().forEach {
                    $0.element.separatesLegs = indicies.contains($0.offset)
                }
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case resamplesTraces = "tidy"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resamplesTraces, forKey: .resamplesTraces)
        try super.encode(to: encoder)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resamplesTraces = try container.decode(Bool.self, forKey: .resamplesTraces)
        try super.init(from: decoder)
    }
    
    // MARK: Resampling the Locations Before Matching
    
    /**
     If true, the input locations are re-sampled for improved map matching results. The default is  `false`.
     */
    open var resamplesTraces: Bool = false
    
    // MARK: Separating the Matches Into Legs
    
    /**
     An index set containing indices of two or more items in `coordinates`. These will be represented by `Waypoint`s in the resulting `Match` objects.

     Use this property when the `DirectionsOptions.includesSteps` property is `true` or when `coordinates` represents a trace with a high sample rate. If this property is `nil`, the resulting `Match` objects contain a waypoint for each coordinate in the match options.

     If specified, each index must correspond to a valid index in `coordinates`, and the index set must contain 0 and the last index (one less than `endIndex`) of `coordinates`.
     */
    @available(*, deprecated, message: "Use Waypoint.separatesLegs instead.")
    open var waypointIndices: IndexSet?
    
    override var legSeparators: [Waypoint] {
        if let indices = (self as MatchOptionsDeprecations).waypointIndices {
            return indices.map { super.waypoints[$0] }
        } else {
            return super.legSeparators
        }
    }
    
    // MARK: Getting the Request URL
    
    override open var urlQueryItems: [URLQueryItem] {
        var queryItems = super.urlQueryItems

        queryItems.append(URLQueryItem(name: "tidy", value: String(describing: resamplesTraces)))

        if let waypointIndices = (self as MatchOptionsDeprecations).waypointIndices {
            queryItems.append(URLQueryItem(name: "waypoints", value: waypointIndices.map {
                String(describing: $0)
            }.joined(separator: ";")))
        }

        return queryItems
    }

    internal override var abridgedPath: String {
        return "matching/v5/\(profileIdentifier.rawValue)"
    }
}

private protocol MatchOptionsDeprecations {
    var waypointIndices: IndexSet? { get set }
}

extension MatchOptions: MatchOptionsDeprecations {}

// MARK: - Equatable
public extension MatchOptions {
    static func == (lhs: MatchOptions, rhs: MatchOptions) -> Bool {
        let isSuperEqual = ((lhs as DirectionsOptions) == (rhs as DirectionsOptions))
        return isSuperEqual &&
            lhs.abridgedPath == rhs.abridgedPath &&
            lhs.resamplesTraces == rhs.resamplesTraces
    }
}
