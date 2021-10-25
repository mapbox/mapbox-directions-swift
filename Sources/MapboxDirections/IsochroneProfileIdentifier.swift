import Foundation

/**
 Options determining the primary mode of transportation for the contours.
 */
public struct IsochroneProfileIdentifier: Codable, RawRepresentable {
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    /**
    The returned contours are calculated for driving or riding a car, truck, or motorcycle.
    
    This profile prioritizes fast routes by preferring high-speed roads like highways. A driving route may use a ferry where necessary.
    */
    public static let automobile: IsochroneProfileIdentifier = .init(rawValue: "mapbox/driving")
    
    /**
    The returned contours are calculated for riding a bicycle.
    
    This profile prioritizes short, safe routes by avoiding highways and preferring cycling infrastructure, such as bike lanes on surface streets. A cycling route may, where necessary, use other modes of transportation, such as ferries or trains, or require dismounting the bicycle for a distance.
    */
    public static let cycling: IsochroneProfileIdentifier = .init(rawValue: "mapbox/cycling")
    
    /**
    The returned contours are calculated for walking or hiking.
    
    This profile prioritizes short routes, making use of sidewalks and trails where available. A walking route may use other modes of transportation, such as ferries or trains, where necessary.
    */
    public static let walking: IsochroneProfileIdentifier = .init(rawValue: "mapbox/walking")
}
