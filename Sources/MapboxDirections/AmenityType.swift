import Foundation

/**
 Type of the `Amenity`.
 */
public enum AmenityType: String, Codable {
    
    /**
     Undefined amenity type.
     */
    case undefined
    
    /**
     Gas station amenity type.
     */
    case gasStation
    
    /**
     Electric charging station amenity type.
     */
    case electricChargingStation
    
    /**
     Toilet amenity type.
     */
    case toilet
    
    /**
     Coffee amenity type.
     */
    case coffee
    
    /**
     Restaurant amenity type.
     */
    case restaurant
    
    /**
     Snack amenity type.
     */
    case snack
    
    /**
     ATM amenity type.
     */
    case ATM
    
    /**
     Info amenity type.
     */
    case info
    
    /**
     Baby care amenity type.
     */
    case babyCare
    
    /**
     Facilities for disabled amenity type.
     */
    case facilitiesForDisabled
    
    /**
     Shop amenity type.
     */
    case shop
    
    /**
     Telephone amenity type.
     */
    case telephone
    
    /**
     Hotel amenity type.
     */
    case hotel
    
    /**
     Hot spring amenity type.
     */
    case hotSpring
    
    /**
     Shower amenity type.
     */
    case shower
    
    /**
     Picnic shelter amenity type.
     */
    case picnicShelter
    
    /**
     Post amenity type.
     */
    case post
    
    /**
     Fax amenity type.
     */
    case fax
    
    private enum CodingKeys: String, CodingKey {
        
        case undefined
        case gasStation = "gas_station"
        case electricChargingStation = "electric_charging_station"
        case toilet
        case coffee
        case restaurant
        case snack
        case ATM = "atm"
        case info
        case babyCare = "baby_care"
        case facilitiesForDisabled = "facilities_for_disabled"
        case shop
        case telephone
        case hotel
        case hotSpring = "hotspring"
        case shower
        case picnicShelter = "picnic_shelter"
        case post
        case fax
    }
}
