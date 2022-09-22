import Foundation

/**
 Attributes are metadata information for a route leg.
 
 When any of the attributes are specified, the resulting route leg contains one attribute value for each segment in leg, where a segment is the straight line between two coordinates in the route leg’s full geometry.
 */
public struct AttributeOptions: OptionSet, CustomStringConvertible {
    public var rawValue: Int
    
    /**
     Provides a text value description for user-provided options.
     
     `AttributeOptions` will recognize a custom option if it's unique `rawValue` flag is set and `customOptions` contains a description for that flag.
     Use `update(customOption:)` methid to append a custom option.
     */
    public var customOptions: [Int: String] = [:]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /**
     Distance (in meters) along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentDistances` property contains one value for each segment in the leg’s full geometry.
     */
    public static let distance = AttributeOptions(rawValue: 1 << 1)
    
    /**
     Expected travel time (in seconds) along the segment.
     
     When this attribute is specified, the `RouteLeg.expectedSegmentTravelTimes` property contains one value for each segment in the leg’s full geometry.
     */
    public static let expectedTravelTime = AttributeOptions(rawValue: 1 << 2)

    /**
     Current average speed (in meters per second) along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentSpeeds` property contains one value for each segment in the leg’s full geometry.
     */
    public static let speed = AttributeOptions(rawValue: 1 << 3)
    
    /**
     Traffic congestion level along the segment.
     
     When this attribute is specified, the `RouteLeg.congestionLevels` property contains one value for each segment in the leg’s full geometry.
     
     This attribute requires `ProfileIdentifier.automobileAvoidingTraffic`. Any other profile identifier produces `CongestionLevel.unknown` for each segment along the route.
     */
    public static let congestionLevel = AttributeOptions(rawValue: 1 << 4)
    
    /**
     The maximum speed limit along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentMaximumSpeedLimits` property contains one value for each segment in the leg’s full geometry.
     */
    public static let maximumSpeedLimit = AttributeOptions(rawValue: 1 << 5)

    /**
     Traffic congestion level in numeric form.

     When this attribute is specified, the `RouteLeg.numericCongestionLevels` property contains one value for each segment in the leg’s full geometry.

     This attribute requires `ProfileIdentifier.automobileAvoidingTraffic`. Any other profile identifier produces `nil` for each segment along the route.
     */
    public static let numericCongestionLevel = AttributeOptions(rawValue: 1 << 6)
    
    /**
     Creates an AttributeOptions from the given description strings.
     */
    public init?(descriptions: [String]) {
        var attributeOptions: AttributeOptions = []
        for description in descriptions {
            switch description {
            case "distance":
                attributeOptions.update(with: .distance)
            case "duration":
                attributeOptions.update(with: .expectedTravelTime)
            case "speed":
                attributeOptions.update(with: .speed)
            case "congestion":
                attributeOptions.update(with: .congestionLevel)
            case "maxspeed":
                attributeOptions.update(with: .maximumSpeedLimit)
            case "congestion_numeric":
                attributeOptions.update(with: .numericCongestionLevel)
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
        if contains(.speed) {
            descriptions.append("speed")
        }
        if contains(.congestionLevel) {
            descriptions.append("congestion")
        }
        if contains(.maximumSpeedLimit) {
            descriptions.append("maxspeed")
        }
        if contains(.numericCongestionLevel) {
            descriptions.append("congestion_numeric")
        }
        for (key, value) in customOptions {
            if rawValue & key != 0 {
                descriptions.append(value)
            }
        }
        return descriptions.joined(separator: ",")
    }
}

extension AttributeOptions: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description.components(separatedBy: ",").filter { !$0.isEmpty })
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let descriptions = try container.decode([String].self)
        self = AttributeOptions(descriptions: descriptions)!
    }
}

extension AttributeOptions {
    
    private func conflictingOption(in member: Self.Element, at key: Int) -> Bool {
        return customOptions[key] != nil && customOptions[key] != member.customOptions[key]
    }
    
    public func contains(_ member: Self.Element) -> Bool {
        let intersection = rawValue & member.rawValue
        var containsCustomKeys = true
        for offset in 0..<intersection.bitWidth {
            let bit = member.rawValue & 1<<offset
            if bit != 0 {
                if bit != rawValue & 1<<offset ||
                    (conflictingOption(in: member, at: bit) && member.customOptions[bit] != nil) {
                    containsCustomKeys = false
                    break
                }
            }
        }
        return containsCustomKeys && intersection != 0
    }
    
    @discardableResult @inlinable
    public mutating func insert(_ newMember: Self.Element) -> (inserted: Bool, memberAfterInsert: Self.Element) {
        let intersection = rawValue & newMember.rawValue
        
        guard intersection == 0 else {
            var result = Self(rawValue: intersection)
            result.customOptions = customOptions.filter({ element in intersection & element.key != 0 })
            return (false, result)
        }
        
        rawValue = rawValue | newMember.rawValue
        
        customOptions.merge(newMember.customOptions) { current, _ in current }
        
        return (true, newMember)
    }

    @discardableResult @inlinable
    public mutating func remove(_ member: Self.Element) -> Self.Element? {
        let originalRawValue = rawValue
        let customKeysToPreserve = customOptions.reduce(0) { partialResult, item in
            if member.customOptions[item.key] == nil ||
                member.customOptions[item.key] == customOptions[item.key] {
                return partialResult
            } else {
                return partialResult + item.key
            }
        }
        rawValue = (rawValue ^ (rawValue & member.rawValue)) | customKeysToPreserve
        
        let intersectionOptions = customOptions.filter({ element in customKeysToPreserve & element.key != 0 })
        customOptions = customOptions.filter({ element in customKeysToPreserve & element.key == 0 })
        
        guard originalRawValue != rawValue else { return nil }
        var result = Self(rawValue: originalRawValue ^ rawValue)
        result.customOptions = intersectionOptions
        return result
    }

    @discardableResult @inlinable
    public mutating func update(with newMember: Self.Element) -> Self.Element? {
        let intersection = rawValue & newMember.rawValue
        rawValue = rawValue | newMember.rawValue
        
        customOptions.merge(newMember.customOptions) { current, _ in current }
        
        guard intersection != 0 else { return nil }
        
        var result = Self(rawValue: intersection)
        result.customOptions = customOptions.filter({ element in intersection & element.key != 0 })
        return result
    }
    
    /// Inserts the given element into the set unconditionally.
    ///
    /// If an element equal to `customOption` is already contained in the set,
    /// `customOption` replaces the existing element. Otherwise - updates the set contents and fills `customOptions` accordingly.
    ///
    /// - Parameter customOption: An element to insert into the set.
    /// - Returns: For ordinary sets, an element equal to `customOption` if the set
    ///   already contained such a member; otherwise, `nil`. In some cases, the
    ///   returned element may be distinguishable from `customOption` by identity
    ///   comparison or some other means.
    ///
    ///   For sets where the set type and element type are the same, like
    ///   `OptionSet` types, this method returns any intersection between the
    ///   set and `[customOption]`, or `nil` if the intersection is empty.
    @discardableResult @inlinable
    mutating public func update(customOption: (Int, String)) -> Self.Element? {
        let result = update(with: .init(rawValue: customOption.0))
        customOptions[customOption.0] = customOption.1
        return result
    }
    
}
