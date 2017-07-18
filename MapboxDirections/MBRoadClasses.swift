import Foundation

public typealias RoadClasses = MBRoadClasses

extension RoadClasses: CustomStringConvertible {
    /**
     Creates a lane indication from the given description strings.
     */
    public init?(descriptions: [String]) {
        var laneIndication: RoadClasses = []
        for description in descriptions {
            switch description {
            case "toll":
                laneIndication.insert(.toll)
            case "restricted":
                laneIndication.insert(.restricted)
            case "highway":
                laneIndication.insert(.highway)
            case "ferry":
                laneIndication.insert(.ferry)
            case "none":
                break
            default:
                return nil
            }
        }
        self.init(rawValue: laneIndication.rawValue)
    }
    
    public var description: String {
        if isEmpty {
            return "none"
        }
        
        var descriptions: [String] = []
        if contains(.toll) {
            descriptions.append("toll")
        }
        if contains(.restricted) {
            descriptions.append("restricted")
        }
        if contains(.highway) {
            descriptions.append("highway")
        }
        if contains(.ferry) {
            descriptions.append("ferry")
        }
        return descriptions.joined(separator: ",")
    }
}
