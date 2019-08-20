import Foundation

extension Measurement where UnitType: UnitSpeed {
    /**
     Initializes a new speed from a JSON dictionary.
     */
    init?(json: [String: Any]) {
        let value: Double
        if let speedNone = json["none"] as? Bool, speedNone {
            value = .greatestFiniteMagnitude
        } else if let speed = json["speed"] as? Double {
            value = speed
        } else {
            return nil
        }
        if let speedUnknown = json["unknown"] as? Bool, speedUnknown {
            return nil
        }
        
        let unit: UnitSpeed
        switch json["unit"] as? String {
        case "mph":
            unit = .milesPerHour
        case "km/h":
            unit = .kilometersPerHour
        default:
            unit = .kilometersPerHour
        }
        
        self.init(value: value, unit: unit as! UnitType)
    }
}
