
import Foundation

/// 'Mapbox Streets V8' compliant street class definition
///
/// For detailed info on road classes, see [the documentation](https://docs.mapbox.com/vector-tiles/reference/mapbox-streets-v8/#road)
public enum MapboxStreetClass: String, Codable {
    /// High-speed, grade-separated highways
    case motorway = "motorway"
    /// Link roads/lanes/ramps connecting to motorways
    case motorwayLink = "motorway_link"
    /// Important roads that are not motorways.
    case trunk = "trunk"
    /// Link roads/lanes/ramps connecting to trunk roads
    case trunkLink = "trunk_link"
    /// A major highway linking large towns.
    case primary = "primary"
    /// Link roads/lanes connecting to primary roads
    case primaryLink = "primary_link"
    /// A highway linking large towns.
    case secondary = "secondary"
    /// Link roads/lanes connecting to secondary roads
    case secondaryLink = "secondary_link"
    /// A road linking small settlements, or the local centres of a large town or city.
    case tertiary = "tertiary"
    /// Link roads/lanes connecting to tertiary roads
    case tertiaryLink = "tertiary_link"
    /// Standard unclassified, residential, road, and living_street road types
    case street = "street"
    /// Streets that may have limited or no access for motor vehicles.
    case streetLimited = "street_limited"
    /// Includes pedestrian streets, plazas, and public transportation platforms.
    case pedestrian = "pedestrian"
    /// Includes motor roads under construction (but not service roads, paths, etc.
    case construction = "construction"
    /// Roads mostly for agricultural and forestry use etc.
    case track = "track"
    /// Access roads, alleys, agricultural tracks, and other services roads. Also includes parking lot aisles, public & private driveways.
    case service = "service"
    /// Those that serves automobiles and no or unspecified automobile service.
    case ferry = "ferry"
    /// Foot paths, cycle paths, ski trails.
    case path = "path"
    /// Railways, including mainline, commuter rail, and rapid transit.
    case majorRail = "major_rail"
    /// Includes light rail & tram lines.
    case minorRail = "minor_rail"
    /// Yard and service railways.
    case serviceRail = "service_rail"
    /// Ski lifts, gondolas, and other types of aerialway.
    case aerialway = "aerialway"
    /// The approximate centerline of a golf course hole
    case golf = "golf"
    /// Circular continuous-flow intersection
    case roundabout = "roundabout"
    /// Smaller variation of a roundabout with no center island or obstacle
    case miniRoundabout = "mini_roundabout"
    /// Widened section at the end of a cul-de-sac for turning around a vehicle. (point) 
    case turningCircle = "turning_circle"
    /// Similar to a turning circle but with an island or other obstruction at the centerpoint. (point)
    case turningLoop = "turning_loop"
    /// Lights or other signal controlling traffic flow at an intersection. (point)
    case trafficSignals = "traffic_signals"
    /// A point indication for road junctions. (point)
    case junction = "junction"
    /// Indicating the class and type of roads meeting at an intersection. Intersections are only available in Japan. (point)
    case intersection = "intersection"
}
