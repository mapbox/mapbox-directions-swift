import Foundation


public enum MBAttributeOptions: OptionSet {
    public typealias RawValue = UInt?
    
    public init() {
        self = .distance
    }
    
    public mutating func formUnion(_ other: __owned MBAttributeOptions) { }
    public mutating func formIntersection(_ other: MBAttributeOptions) { }
    public mutating func formSymmetricDifference(_ other: __owned MBAttributeOptions) { }
    
    case distance
    case expectedTravelTime
    case speed
    case congestionLevel
}

extension MBAttributeOptions: RawRepresentable {
    
    public init(rawValue: MBAttributeOptions.RawValue) {
        switch rawValue {
        case 1 << 1:
            self = .distance
        case 1 << 2:
            self = .expectedTravelTime
        case 1 << 3:
            self = .speed
        case 1 << 4:
            self = .congestionLevel
        default:
            self = .distance
        }
    }
    
    public var rawValue: UInt? {
        switch self {
        case .distance:
            return 1 << 1
        case .expectedTravelTime:
            return 1 << 2
        case .speed:
            return 1 << 3
        case .congestionLevel:
            return 1 << 4
        }
    }
}

