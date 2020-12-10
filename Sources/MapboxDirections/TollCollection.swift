import Foundation

/**
 `TollCollection` describes corresponding object on the route.
 */
public struct TollCollection: Codable, Equatable {

    public enum CollectionType: String, Codable {
        case booth = "toll_booth"
        case gantry = "toll_gantry"
    }

    /**
     The type of the toll collection point.
     */
    public let type: CollectionType

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(type: CollectionType) {
        self.type = type
    }
}
