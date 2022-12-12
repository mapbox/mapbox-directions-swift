import Foundation

/**
 Provides information about amenity that is available at a given `RestStop`.
 */
public struct Amenity: Codable, Equatable {
    
    /**
     Name of the amenity, if available.
     */
    var name: String?
    
    /**
     Brand of the amenity, if available.
     */
    var brand: String?
    
    /**
     Type of the amenity.
     */
    var type: AmenityType
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name &&
        lhs.brand == rhs.brand &&
        lhs.type == rhs.type
    }
}
