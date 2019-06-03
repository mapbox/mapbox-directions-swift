import Foundation


public enum MBDirectionsPriority {
    public typealias RawValue = Double
    case low
    case `default`
    case high
    case custom(Double)
}

extension MBDirectionsPriority: RawRepresentable {
    public init(rawValue: Double) {
        switch rawValue {
        case MBDirectionsPriority.low.rawValue:
            self = .low
        case MBDirectionsPriority.default.rawValue:
            self = .default
        case MBDirectionsPriority.high.rawValue:
            self = .high
        case MBDirectionsPriority.custom(rawValue).rawValue:
            self = .custom(rawValue)
        default:
            self = .default
        }
    }
    
    public var rawValue: Double {
        switch self {
        case .low:
            return -1.0
        case .default:
            return 0
        case .high:
            return 1.0
        case .custom(let val):
            return val
        }
    }
}
