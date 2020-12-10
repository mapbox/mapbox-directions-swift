import Foundation

/**
 `RestStop` describes corresponding object on the route.
 */
public struct RestStop: Codable, Equatable {

    public enum StopType: String, Codable {
        case serviceArea = "service_area"
        case restArea = "rest_area"
    }

    /**
     The kind of the rest stop.
     */
    public let type: StopType

    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(type: StopType) {
        self.type = type
    }
}
