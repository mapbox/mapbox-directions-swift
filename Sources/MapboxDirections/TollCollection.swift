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
    
    /**
     The name of the toll collection point.
     */
    public var name: String?

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }

    public init(type: CollectionType, name: String? = nil) {
        self.type = type
        self.name = name
    }
}
