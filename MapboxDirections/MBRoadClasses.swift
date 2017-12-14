import Foundation

public typealias RoadClasses = MBRoadClasses

extension RoadClasses: CustomStringConvertible, Codable {
    
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
            case "none":
                break
            default:
                return nil
            }
        }
        self.init(rawValue: roadClasses.rawValue)
    }
    
    public var description: String {
        if isEmpty {
            return ""
        }
        
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description.components(separatedBy: ","))
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let descriptions = try container.decode([String].self)
        self = RoadClasses(descriptions: descriptions)!
    }
}
