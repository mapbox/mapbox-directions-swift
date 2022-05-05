import Foundation

/**
 A [rest stop](https://wiki.openstreetmap.org/wiki/Tag:highway%3Drest_area) along the route.
 */
public struct RestStop: Codable, Equatable {
    /// A kind of rest stop.
    public enum StopType: String, Codable {
        /// A primitive rest stop that provides parking but no additional services.
        case serviceArea = "service_area"
        /// A major rest stop that provides amenities such as fuel and food.
        case restArea = "rest_area"
    }

    /**
     The kind of the rest stop.
     */
    public let type: StopType
    
    /// The name of the rest stop, if available.
    public let name: String?

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
    
    /**
     Initializes an unnamed rest stop of a certain kind.
     
     - parameter type: The kind of rest stop.
     */
    public init(type: StopType) {
        self.type = type
        self.name = nil
    }
    
    /**
     Initializes an optionally named rest stop of a certain kind.
     
     - parameter type: The kind of rest stop.
     - parameter name: The name of the rest stop.
     */
    public init(type: StopType, name: String?) {
        self.type = type
        self.name = name
    }
}
