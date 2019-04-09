import Foundation

public enum MBLaneIndication: OptionSet {
    public typealias RawValue = UInt?
    
    public init() {
        self = .left
    }
    
    public mutating func formUnion(_ other: __owned MBLaneIndication) { }
    public mutating func formIntersection(_ other: MBLaneIndication) { }
    public mutating func formSymmetricDifference(_ other: __owned MBLaneIndication) { }
    
    case sharpRight
    case right
    case slightRight
    case straightAhead
    case slightLeft
    case left
    case sharpLeft
    case uTurn
}

extension MBLaneIndication: RawRepresentable {
    
    public init(rawValue: MBLaneIndication.RawValue) {
        switch rawValue {
        case 1 << 1:
            self = .sharpRight
        case 1 << 2:
            self = .right
        case 1 << 3:
            self = .slightRight
        case 1 << 4:
            self = .straightAhead
        case 1 << 5:
            self = .slightLeft
        case 1 << 6:
            self = .left
        case 1 << 7:
            self = .sharpLeft
        case 1 << 8:
            self = .uTurn
        default:
            self = .straightAhead
        }
    }
    
    public var rawValue: UInt? {
        switch self {
        case .sharpRight:
            return 1 << 1
        case .right:
            return 1 << 2
        case .slightRight:
            return 1 << 3
        case .straightAhead:
            return 1 << 4
        case .slightLeft:
            return 1 << 5
        case .left:
            return 1 << 6
        case .sharpLeft:
            return 1 << 7
        case .uTurn:
            return 1 << 8
        }
    }
}

