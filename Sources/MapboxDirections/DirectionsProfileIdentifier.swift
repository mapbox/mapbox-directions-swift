import Foundation

@available(*, deprecated, renamed: "DirectionsProfileIdentifier")
public typealias MBDirectionsProfileIdentifier = DirectionsProfileIdentifier


/**
The returned directions are appropriate for driving or riding a car, truck, or motorcycle.

This profile prioritizes fast routes by preferring high-speed roads like highways. A driving route may use a ferry where necessary.
*/
public struct DirectionsProfileIdentifier: RawRepresentable {
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    public typealias RawValue = String
    
    /**
    The returned directions are appropriate for driving or riding a car, truck, or motorcycle.
    
    This profile prioritizes fast routes by preferring high-speed roads like highways. A driving route may use a ferry where necessary.
    */
    static let automobile: String = "mapbox/driving"
    
    /**
    The returned directions are appropriate for driving or riding a car, truck, or motorcycle.
    
    This profile avoids traffic congestion based on current traffic data. A driving route may use a ferry where necessary.
    
    Traffic data is available in [a number of countries and territories worldwide](https://docs.mapbox.com/help/how-mapbox-works/directions/#traffic-data). Where traffic data is unavailable, this profile prefers high-speed roads like highways, similar to `DirectionsProfileIdentifier.Automobile`.
    */
    static let automobileAvoidingTraffic: String = "mapbox/driving-traffic"
    
    /**
    The returned directions are appropriate for riding a bicycle.
    
    This profile prioritizes short, safe routes by avoiding highways and preferring cycling infrastructure, such as bike lanes on surface streets. A cycling route may, where necessary, use other modes of transportation, such as ferries or trains, or require dismounting the bicycle for a distance.
    */
    static let cycling: String = "mapbox/cycling"
    
    /**
    The returned directions are appropriate for walking or hiking.
    
    This profile prioritizes short routes, making use of sidewalks and trails where available. A walking route may use other modes of transportation, such as ferries or trains, where necessary.
    */
    static let walking: String = "mapbox/walking"
}

@available(*, deprecated, renamed: "DirectionsPriority")
public typealias MBDirectionsPriority = DirectionsPriority

public struct DirectionsPriority: RawRepresentable {
    public init?(rawValue: Double) {
        self.rawValue = rawValue
    }
    
    public var rawValue: Double
    
    public typealias RawValue = Double
    
    static let low = -1.0
    static let `default` = 0.0
    static let high = 1.0
}
