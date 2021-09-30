import Foundation

/**
Option set that contains attributes of a road segment.
*/
public struct RoadClasses: OptionSet, CustomStringConvertible {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /**
     The road segment is [tolled](https://wiki.openstreetmap.org/wiki/Key:toll).
     */
    public static let toll = RoadClasses(rawValue: 1 << 1)
    
    /**
     The road segment has access restrictions.
     
     A road segment may have this class if there are [general access restrictions](https://wiki.openstreetmap.org/wiki/Key:access) or a [high-occupancy vehicle](https://wiki.openstreetmap.org/wiki/Key:hov) restriction.
     */
    public static let restricted = RoadClasses(rawValue: 1 << 2)
    
    /**
     The road segment is a [freeway](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway) or [freeway ramp](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway_link).
     
     It may be desirable to suppress the name of the freeway when giving instructions and give instructions at fixed distances before an exit (such as 1 mile or 1 kilometer ahead).
     */
    public static let motorway = RoadClasses(rawValue: 1 << 3)
    
    /**
     The user must travel this segment of the route by ferry.
     
     The user should verify that the ferry is in operation. For driving and cycling directions, the user should also verify that his or her vehicle is permitted onboard the ferry.
     
     In general, the transport type of the step containing the road segment is also `TransportType.ferry`.
     */
    public static let ferry = RoadClasses(rawValue: 1 << 4)
    
    /**
     The user must travel this segment of the route through a [tunnel](https://wiki.openstreetmap.org/wiki/Key:tunnel).
     */
    public static let tunnel = RoadClasses(rawValue: 1 << 5)
    
    /**
     The road segment is a HOV-2 road.
    */
    public static let hov2 = RoadClasses(rawValue: 1 << 6)
    
    /**
     The road segment is a HOV-3 road.
    */
    public static let hov3 = RoadClasses(rawValue: 1 << 7)
    
    /**
     The road segment is a HOT road.
    */
    public static let hot = RoadClasses(rawValue: 1 << 8)
    
    /**
     Creates a `RoadClasses` given an array of strings.
     */
    public init?(descriptions: [String]) {
        var roadClasses: RoadClasses = []
        for description in descriptions {
            switch description {
            case "toll":
                roadClasses.insert(.toll)
            case "restricted":
                roadClasses.insert(.restricted)
            case "motorway":
                roadClasses.insert(.motorway)
            case "ferry":
                roadClasses.insert(.ferry)
            case "tunnel":
                roadClasses.insert(.tunnel)
            case "":
                continue
            default:
                return nil
            }
        }
        self.init(rawValue: roadClasses.rawValue)
    }
    
    public var description: String {
        var descriptions: [String] = []
        if contains(.toll) {
            descriptions.append("toll")
        }
        if contains(.restricted) {
            descriptions.append("restricted")
        }
        if contains(.motorway) {
            descriptions.append("motorway")
        }
        if contains(.ferry) {
            descriptions.append("ferry")
        }
        if contains(.tunnel) {
            descriptions.append("tunnel")
        }
        return descriptions.joined(separator: ",")
    }
}

extension RoadClasses: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description.components(separatedBy: ",").filter { !$0.isEmpty })
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let descriptions = try container.decode([String].self)
        if let roadClasses = RoadClasses(descriptions: descriptions){
            self = roadClasses
        }
        else{
            throw DirectionsError.invalidResponse(nil)
        }
    }
}
