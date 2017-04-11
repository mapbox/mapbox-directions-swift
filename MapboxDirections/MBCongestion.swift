import Foundation

public typealias Congestion = MBCongestion

extension Congestion: CustomStringConvertible {
    
    public init?(description: String) {
        var scope: Congestion = []
        switch description {
        case "unknown":
            scope.update(with: .unknown)
        case "low":
            scope.update(with: .low)
        case "moderate":
            scope.update(with: .moderate)
        case "heavy":
            scope.update(with: .heavy)
        case "severe":
            scope.update(with: .severe)
        default:
            return nil
        }
        self.init(rawValue: scope.rawValue)
    }
    
    public var description: String {
        var descriptions: [String] = []
        if contains(.unknown ) {
            descriptions.append("unknown")
        }
        if contains(.low) {
            descriptions.append("low")
        }
        if contains(.moderate) {
            descriptions.append("moderate")
        }
        if contains(.heavy) {
            descriptions.append("heavy")
        }
        if contains(.severe) {
            descriptions.append("severe")
        }
        return descriptions.joined(separator: ",")
    }
}
