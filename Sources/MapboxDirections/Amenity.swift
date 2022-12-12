import Foundation

/**
 Provides information about amenity that is available at a given `RestStop`.
 */
public struct Amenity: Codable, Equatable {
    
    /**
     Name of the amenity, if available.
     */
    public let name: String?
    
    /**
     Brand of the amenity, if available.
     */
    public let brand: String?
    
    /**
     Type of the amenity.
     */
    public let type: AmenityType
    
    /**
     Initializes an `Amenity`.
     
     - parameter type: Type of the amenity.
     - parameter name: Name of the amenity.
     - parameter brand: Brand of the amenity.
     */
    public init(type: AmenityType, name: String? = nil, brand: String? = nil) {
        self.type = type
        self.name = name
        self.brand = brand
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name &&
        lhs.brand == rhs.brand &&
        lhs.type == rhs.type
    }
}
