import Foundation

public typealias AttributeOptions = MBAttributeOptions

extension AttributeOptions: CustomStringConvertible {
    /**
     Creates an AttributeOptions from the given description strings.
     */
    public init?(description: String) {
        var scope: AttributeOptions = []
        switch description {
        case "distance":
            scope.update(with: .distance)
        case "expectedTravelTime":
            scope.update(with: .expectedTravelTime)
        case "openStreetMapNodeIdentifier":
            scope.update(with: .openStreetMapNodeIdentifier)
        case "speed":
            scope.update(with: .speed)
        default:
            return nil
        }
        self.init(rawValue: scope.rawValue)
    }
    
    public var description: String {
        var descriptions: [String] = []
        if contains(.distance) {
            descriptions.append("distance")
        }
        if contains(.expectedTravelTime) {
            descriptions.append("duration")
        }
        if contains(.openStreetMapNodeIdentifier) {
            descriptions.append("nodes")
        }
        if contains(.speed) {
            descriptions.append("speed")
        }
        return descriptions.joined(separator: ",")
    }
}
