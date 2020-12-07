
import Foundation

public enum MapboxStreetClass: String, Codable {
    /// High-speed, grade-separated highways
    case Motorway = "motorway"
    /// Link roads/lanes/ramps connecting to motorways
    case MotorwayLink = "motorway_link"
    /// Important roads that are not motorways.
    case Trunk = "trunk"
    /// Link roads/lanes/ramps connecting to trunk roads
    case TrunkLink = "trunk_link"
    /// A major highway linking large towns.
    case Primary = "primary"
    /// Link roads/lanes connecting to primary roads
    case PrimaryLink = "primary_link"
    /// A highway linking large towns.
    case Secondary = "secondary"
    /// Link roads/lanes connecting to secondary roads
    case SecondaryLink = "secondary_link"
    /// A road linking small settlements, or the local centres of a large town or city.
    case Tertiary = "tertiary"
    /// Link roads/lanes connecting to tertiary roads
    case TertiaryLink = "tertiary_link"
    /// Standard unclassified, residential, road, and living_street road types
    case Street = "street"
    /// Streets that may have limited or no access for motor vehicles.
    case StreetLimited = "street_limited"
    /// Includes pedestrian streets, plazas, and public transportation platforms.
    case Pedestrian = "pedestrian"
    /// Includes motor roads under construction (but not service roads, paths, etc.
    case Construction = "construction"
    /// Roads mostly for agricultural and forestry use etc.
    case Track = "track"
    /// Access roads, alleys, agricultural tracks, and other services roads. Also includes parking lot aisles, public & private driveways.
    case Service = "service"
    /// Those that serves automobiles and no or unspecified automobile service.
    case Ferry = "ferry"
    /// Foot paths, cycle paths, ski trails.
    case Path = "path"
    /// Railways, including mainline, commuter rail, and rapid transit.
    case MajorRail = "major_rail"
    /// Includes light rail & tram lines.
    case MinorRail = "minor_rail"
    /// Yard and service railways.
    case ServiceRail = "service_rail"
    /// Ski lifts, gondolas, and other types of aerialway.
    case Aerialway = "aerialway"
    /// The approximate centerline of a golf course hole
    case Golf = "golf"
    /// Circular continuous-flow intersection
    case Roundabout = "roundabout"
    /// Smaller variation of a roundabout with no center island or obstacle
    case MiniRoundabout = "mini_roundabout"
    /// (point Widened section at the end of a cul-de-sac for turning around a vehicle
    case TurningCircle = "turning_circle"
    /// (point Similar to a turning circle but with an island or other obstruction at the centerpoint
    case TurningLoop = "turning_loop"
    /// (point Lights or other signal controlling traffic flow at an intersection
    case TrafficSignals = "traffic_signals"
    /// (point A point indication for road junctions
    case Junction = "junction"
    /// (point Indicating the class and type of roads meeting at an intersection. Intersections are only available in Japan
    case Intersection = "intersection"
}
