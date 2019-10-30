import Foundation

@available(*, deprecated, renamed: "DirectionsProfileIdentifier")
public typealias MBDirectionsProfileIdentifier = DirectionsProfileIdentifier


/**
The returned directions are appropriate for driving or riding a car, truck, or motorcycle.

This profile prioritizes fast routes by preferring high-speed roads like highways. A driving route may use a ferry where necessary.
*/
public struct DirectionsProfileIdentifier: Codable, Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public typealias RawValue = String
     
     public init(stringLiteral value: StringLiteralType) {
         self.init(rawValue: value)
     }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    
    /**
    The returned directions are appropriate for driving or riding a car, truck, or motorcycle.
    
    This profile prioritizes fast routes by preferring high-speed roads like highways. A driving route may use a ferry where necessary.
    */
    public static let automobile: DirectionsProfileIdentifier = "mapbox/driving"
    
    /**
    The returned directions are appropriate for driving or riding a car, truck, or motorcycle.
    
    This profile avoids traffic congestion based on current traffic data. A driving route may use a ferry where necessary.
    
    Traffic data is available in [a number of countries and territories worldwide](https://docs.mapbox.com/help/how-mapbox-works/directions/#traffic-data). Where traffic data is unavailable, this profile prefers high-speed roads like highways, similar to `DirectionsProfileIdentifier.Automobile`.
    */
    public static let automobileAvoidingTraffic: DirectionsProfileIdentifier = "mapbox/driving-traffic"
    
    /**
    The returned directions are appropriate for riding a bicycle.
    
    This profile prioritizes short, safe routes by avoiding highways and preferring cycling infrastructure, such as bike lanes on surface streets. A cycling route may, where necessary, use other modes of transportation, such as ferries or trains, or require dismounting the bicycle for a distance.
    */
    public static let cycling: DirectionsProfileIdentifier = "mapbox/cycling"
    
    /**
    The returned directions are appropriate for walking or hiking.
    
    This profile prioritizes short routes, making use of sidewalks and trails where available. A walking route may use other modes of transportation, such as ferries or trains, where necessary.
    */
    public static let walking: DirectionsProfileIdentifier = "mapbox/walking"
}

@available(*, deprecated, renamed: "DirectionsPriority")
public typealias MBDirectionsPriority = DirectionsPriority

public struct DirectionsPriority: Hashable, RawRepresentable {
    public init(rawValue: Double) {
        self.rawValue = rawValue
    }
    
    public var rawValue: Double
    
    public typealias RawValue = Double
    
    static let low = DirectionsPriority(rawValue: -1.0)
    static let `default` = DirectionsPriority(rawValue: 0.0)
    static let high = DirectionsPriority(rawValue: 1.0)
}
