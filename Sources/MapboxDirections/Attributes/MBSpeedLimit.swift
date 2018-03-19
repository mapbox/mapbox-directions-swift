import Foundation

/**
 A localized limit for measuring speed limits.
 */
@objc(MBSpeedLimit)
public class SpeedLimit: NSObject, NSSecureCoding {
    
    /**
     A unitless measure of speed which is dependent on the `MaximumSpeedLimit.speedUnits`.
     */
    @objc public var speed: Int = NSNotFound
    
    
    /**
     Units for `MaximumSpeedLimit.speed`.
     */
    @objc public var speedUnits: SpeedUnit = .none
    
    
    /**
     `Bool` whether the maximum speed for a segment is known.
     */
    @objc public var speedIsUnknown: Bool = true
    
    /**
     Initialize a new `SpeedLimit` object.
     */
    public init(speed: Int, speedUnits: SpeedUnit, speedIsUnknown: Bool) {
        self.speed = speed
        self.speedUnits = speedUnits
        self.speedIsUnknown = speedIsUnknown
    }
    
    /**
     Initialize a new `SpeedLimit` object from a JSON dictionary.
     */
    @objc public convenience init(json: [String: Any]) {
        let speed = json["speed"] as? Int ?? NSNotFound
        let unknown = speed == NSNotFound
        
        var speedUnits: SpeedUnit = .none
        if let speedString = json["unit"] as? String {
            speedUnits = SpeedUnit(description: speedString) ?? .none
        }
        
        self.init(speed: speed, speedUnits: speedUnits, speedIsUnknown: unknown)
    }
    
    open static var supportsSecureCoding = true
    
    public required init?(coder decoder: NSCoder) {
        speed = decoder.decodeInteger(forKey: "speed")
        
        guard let speedUnitString = decoder.decodeObject(of: NSString.self, forKey: "speedUnits") as String?, let speedUnits = SpeedUnit(description: speedUnitString) else {
                return nil
        }
        self.speedUnits = speedUnits
        
        speedIsUnknown = decoder.decodeBool(forKey: "speedIsUnknown")
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(speed, forKey: "speed")
        coder.encode(speedUnits, forKey: "speedUnits")
        coder.encode(speedIsUnknown, forKey: "speedIsUnknown")
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
    
    /**
     Indicates the segment does not have a speed limit.
    */
    case none
    
    public init?(description: String) {
        let level: SpeedUnit
        switch description {
        case "mph":
            level = .milesPerHour
        case "kph":
            level = .kilometersPerHour
        default:
            level = .none
        }
        self.init(rawValue: level.rawValue)
    }
    
    public var description: String {
        switch self {
        case .milesPerHour:
            return "mph"
        case .kilometersPerHour:
            return "kph"
        case .none:
            return "none"
        }
    }
}

