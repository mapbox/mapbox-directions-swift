import Foundation


public enum MBRoadClasses: OptionSet {
    public typealias RawValue = UInt?
    
    public init() {
        self = .toll
    }
    
    public mutating func formUnion(_ other: __owned MBRoadClasses) { }
    public mutating func formIntersection(_ other: MBRoadClasses) { }
    public mutating func formSymmetricDifference(_ other: __owned MBRoadClasses) { }
    
    case toll
    case restricted
    case motorway
    case ferry
    case tunnel
}

extension MBRoadClasses: RawRepresentable {
    
    public init(rawValue: MBRoadClasses.RawValue) {
        switch rawValue {
        case 1 << 1:
            self = .toll
        case 1 << 2:
            self = .restricted
        case 1 << 3:
            self = .motorway
        case 1 << 4:
            self = .ferry
        case 1 << 5:
            self = .tunnel
        default:
            self = .toll
        }
    }
    
    public var rawValue: UInt? {
        switch self {
        case .toll:
            return 1 << 1
        case .restricted:
            return 1 << 2
        case .motorway:
            return 1 << 3
        case .ferry:
            return 1 << 4
        case .tunnel:
            return 1 << 5
        }
    }
}

