import Foundation

/**
 Speed value for a segment which is unknown.
 */
public let MBSpeedIsInvalid: Double = -1.0

/**
 A localized limit for measuring speed limits.
 */
@objc(MBSpeedLimit)
public class SpeedLimit: NSObject, NSSecureCoding {
    
    /**
     A unitless measure of speed which is dependent on the `MaximumSpeedLimit.speedUnits`.
     
     By default, the speed will be unknown and equal to `MBSpeedIsInvalid` which is -1.
     
     If the speed is none, the value will be equal to `Double.greatestFiniteMagnitude`.
     */
    @objc public var value: Double = MBSpeedIsInvalid
    
    
    /**
     Units for `MaximumSpeedLimit.speed`.
     */
    @objc public var unit: SpeedUnit = .kilometersPerHour
    
    /**
     Initialize a new `SpeedLimit` object.
     */
    public init(speed: Double, speedUnits: SpeedUnit) {
        self.value = speed
        self.unit = speedUnits
    }
    
    /**
     Initialize a new `SpeedLimit` object from a JSON dictionary.
     */
    @objc public convenience init(json: [String: Any]) {
        var speed = json["speed"] as? Double ?? MBSpeedIsInvalid
        if let speedNone = json["none"] as? Bool, speedNone {
            speed = .greatestFiniteMagnitude
        }
        
        let speedUnits: SpeedUnit
        if let speedString = json["unit"] as? String {
            speedUnits = SpeedUnit(description: speedString) ?? .kilometersPerHour
        } else {
            speedUnits = .kilometersPerHour
        }
        
        self.init(speed: speed, speedUnits: speedUnits)
    }
    
    open static var supportsSecureCoding = true
    
    public required init?(coder decoder: NSCoder) {
        value = decoder.decodeDouble(forKey: "value")
        
        guard let speedUnitString = decoder.decodeObject(of: NSString.self, forKey: "unit") as String?, let speedUnits = SpeedUnit(description: speedUnitString) else {
                return nil
        }
        self.unit = speedUnits
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(value, forKey: "value")
        coder.encode(unit, forKey: "unit")
    }
}


/**
 Units for measure `SpeedLimit`.
 */
@objc(MBSpeedUnits)
public enum SpeedUnit: Int, CustomStringConvertible {
    
    /**
     Indicates the road segment uses miles per hour for measuring speed limits.
     */
    case milesPerHour
    
    /**
     Indicates the road segment uses kilometers per hour for measuring speed limits.
     */
    case kilometersPerHour
    
    public init?(description: String) {
        let unit: SpeedUnit
        switch description {
        case "mph":
            unit = .milesPerHour
        case "kph":
            unit = .kilometersPerHour
        default:
            unit = .kilometersPerHour
        }
        self.init(rawValue: unit.rawValue)
    }
    
    public var description: String {
        switch self {
        case .milesPerHour:
            return "mph"
        case .kilometersPerHour:
            return "kph"
        }
    }
}

