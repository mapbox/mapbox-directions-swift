
import Foundation

public struct MapboxStreetClasses: OptionSet, CustomStringConvertible {
    public var rawValue: UInt32
    var key: String?
    
    public init(rawValue: RawValue) {
        self.init(rawValue: rawValue, key: nil)
    }
    
    init(rawValue: RawValue, key: String?) {
        self.rawValue = rawValue
        self.key = key
    }
    
    /// High-speed, grade-separated highways
    public static let Motorway = MapboxStreetClasses(rawValue: 1 << 0, key: "motorway")
    /// Link roads/lanes/ramps connecting to motorways
    public static let MotorwayLink = MapboxStreetClasses(rawValue: 1 << 1, key: "motorway_link")
    /// Important roads that are not motorways.
    public static let Trunk = MapboxStreetClasses(rawValue: 1 << 2, key: "trunk")
    /// Link roads/lanes/ramps connecting to trunk roads
    public static let TrunkLink = MapboxStreetClasses(rawValue: 1 << 3, key: "trunk_link")
    /// A major highway linking large towns.
    public static let Primary = MapboxStreetClasses(rawValue: 1 << 4, key: "primary")
    /// Link roads/lanes connecting to primary roads
    public static let PrimaryLink = MapboxStreetClasses(rawValue: 1 << 5, key: "primary_link")
    /// A highway linking large towns.
    public static let Secondary = MapboxStreetClasses(rawValue: 1 << 6, key: "secondary")
    /// Link roads/lanes connecting to secondary roads
    public static let SecondaryLink = MapboxStreetClasses(rawValue: 1 << 7, key: "secondary_link")
    /// A road linking small settlements, or the local centres of a large town or city.
    public static let Tertiary = MapboxStreetClasses(rawValue: 1 << 8, key: "tertiary")
    /// Link roads/lanes connecting to tertiary roads
    public static let TertiaryLink = MapboxStreetClasses(rawValue: 1 << 9, key: "tertiary_link")
    /// Standard unclassified, residential, road, and living_street road types
    public static let Street = MapboxStreetClasses(rawValue: 1 << 10, key: "street")
    /// Streets that may have limited or no access for motor vehicles.
    public static let StreetLimited = MapboxStreetClasses(rawValue: 1 << 11, key: "street_limited")
    /// Includes pedestrian streets, plazas, and public transportation platforms.
    public static let Pedestrian = MapboxStreetClasses(rawValue: 1 << 12, key: "pedestrian")
    /// Includes motor roads under construction (but not service roads, paths, etc).
    public static let Construction = MapboxStreetClasses(rawValue: 1 << 13, key: "construction")
    /// Roads mostly for agricultural and forestry use etc.
    public static let Track = MapboxStreetClasses(rawValue: 1 << 14, key: "track")
    /// Access roads, alleys, agricultural tracks, and other services roads. Also includes parking lot aisles, public & private driveways.
    public static let Service = MapboxStreetClasses(rawValue: 1 << 15, key: "service")
    /// Those that serves automobiles and no or unspecified automobile service.
    public static let Ferry = MapboxStreetClasses(rawValue: 1 << 16, key: "ferry")
    /// Foot paths, cycle paths, ski trails.
    public static let Path = MapboxStreetClasses(rawValue: 1 << 17, key: "path")
    /// Railways, including mainline, commuter rail, and rapid transit.
    public static let MajorRail = MapboxStreetClasses(rawValue: 1 << 18, key: "major_rail")
    /// Includes light rail & tram lines.
    public static let MinorRail = MapboxStreetClasses(rawValue: 1 << 19, key: "minor_rail")
    /// Yard and service railways.
    public static let ServiceRail = MapboxStreetClasses(rawValue: 1 << 20, key: "service_rail")
    /// Ski lifts, gondolas, and other types of aerialway.
    public static let Aerialway = MapboxStreetClasses(rawValue: 1 << 21, key: "aerialway")
    /// The approximate centerline of a golf course hole
    public static let Golf = MapboxStreetClasses(rawValue: 1 << 22, key: "golf")
    /// Circular continuous-flow intersection
    public static let Roundabout = MapboxStreetClasses(rawValue: 1 << 23, key: "roundabout")
    /// Smaller variation of a roundabout with no center island or obstacle
    public static let MiniRoundabout = MapboxStreetClasses(rawValue: 1 << 24, key: "mini_roundabout")
    /// (point) Widened section at the end of a cul-de-sac for turning around a vehicle
    public static let TurningCircle = MapboxStreetClasses(rawValue: 1 << 25, key: "turning_circle")
    /// (point) Similar to a turning circle but with an island or other obstruction at the centerpoint
    public static let TurningLoop = MapboxStreetClasses(rawValue: 1 << 26, key: "turning_loop")
    /// (point) Lights or other signal controlling traffic flow at an intersection
    public static let TrafficSignals = MapboxStreetClasses(rawValue: 1 << 27, key: "traffic_signals")
    /// (point) A point indication for road junctions
    public static let Junction = MapboxStreetClasses(rawValue: 1 << 28, key: "junction")
    /// (point) Indicating the class and type of roads meeting at an intersection. Intersections are only available in Japan
    public static let Intersection = MapboxStreetClasses(rawValue: 1 << 29, key: "intersection")
    
    static var allClasses: [MapboxStreetClasses] {
        return [
            .Motorway, .MotorwayLink, .Trunk, .TrunkLink, .Primary,
            .PrimaryLink, .Secondary, .SecondaryLink, .Tertiary, .TertiaryLink,
            .Street, .StreetLimited, .Pedestrian, .Construction, .Track,
            .Service, .Ferry, .Path, .MajorRail, .MinorRail,
            .ServiceRail, .Aerialway, .Golf, .Roundabout, .MiniRoundabout,
            .TurningCircle, .TurningLoop, .TrafficSignals, .Junction, .Intersection
        ]
    }
    
    public var description: String {
        var descriptions: [String] = []
        
        Self.allClasses.forEach {
            if contains($0), let key = $0.key {
                descriptions.append(key)
            }
        }
        return descriptions.joined(separator: ",")
    }
}
