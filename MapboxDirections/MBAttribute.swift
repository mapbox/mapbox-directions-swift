import Foundation

public typealias AttributeOptions = MBAttributeOptions

extension AttributeOptions: CustomStringConvertible {
    /**
     Creates an AttributeOptions from the given description strings.
     */
    public init?(descriptions: [String]) {
        var attributeOptions: AttributeOptions = []
        for description in descriptions {
            switch description {
            case "distance":
                attributeOptions.update(with: .distance)
            case "expectedTravelTime":
                attributeOptions.update(with: .expectedTravelTime)
            case "openStreetMapNodeIdentifier":
                attributeOptions.update(with: .openStreetMapNodeIdentifier)
            case "speed":
                attributeOptions.update(with: .speed)
            case "":
                continue
            default:
                return nil
            }
        }
        self.init(rawValue: attributeOptions.rawValue)
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
