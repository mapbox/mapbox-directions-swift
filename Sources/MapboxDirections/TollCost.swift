import Foundation
import Turf

/**
 :nodoc:
 Toll cost information for the `Route`.
 */
public struct TollCost: Equatable,  Codable, ForeignMemberContainer {
    public var foreignMembers: Turf.JSONObject = [:]
    
    private enum CodingKeys: String, CodingKey {
        case currency
        case paymentMethods = "payment_methods"
    }

    /**
     Related currency string.
     
     Uses ISO 4217 format. Refers to values in `CostPerVehicleSize`.
     */
    public let currency: String
    /**
     Information about toll payment methods.
     */
    public let paymentMethods: PaymentMethods
    
    init(currency: String, paymentMethods: PaymentMethods) {
        self.currency = currency
        self.paymentMethods = paymentMethods
    }
        
    /**
     :nodoc:
     Information about toll payment methods.
     */
    public struct PaymentMethods: Equatable, Codable, ForeignMemberContainer {
        public var foreignMembers: Turf.JSONObject = [:]
        
        private enum CodingKeys: String, CodingKey {
            case ETC = "etc"
            case cash
        }
        
        /**
         Information about payment by ETC.
         */
        public let ETC: CostPerVehicleSize?
        /**
         Information about payment by cash.
         */
        public let cash: CostPerVehicleSize?
        
        init(ETC: CostPerVehicleSize? = nil, cash: CostPerVehicleSize? = nil) {
            self.ETC = ETC
            self.cash = cash
        }
    }
    
    /**
     :nodoc:
     `PaymentMethods` details about particular vehicle size.
     
     Vehicle sizes are [standartized](https://en.wikipedia.org/wiki/Expressways_of_Japan#Tolls).
     */
    public struct CostPerVehicleSize: Equatable, Codable, ForeignMemberContainer {
        public var foreignMembers: Turf.JSONObject = [:]
        
        private enum CodingKeys: String, CodingKey {
            case small
            case standard
            case middle
            case large
            case jumbo
        }
        
        /**
         The toll cost for a small sized vehicle.
         
         A toll cost of `0` is valid and simply means that no toll costs are incurred for this route.
         */
        public let small: Double?
        /**
         The toll cost for a standard sized vehicle.
         
         A toll cost of `0` is valid and simply means that no toll costs are incurred for this route.
         */
        public let standard: Double?
        /**
         The toll cost for a middle sized vehicle.
         
         A toll cost of `0` is valid and simply means that no toll costs are incurred for this route.
         */
        public let middle: Double?
        /**
         The toll cost for a large sized vehicle.
         
         A toll cost of `0` is valid and simply means that no toll costs are incurred for this route.
         */
        public let large: Double?
        /**
         The toll cost for a jumbo sized vehicle.
         
         A toll cost of `0` is valid and simply means that no toll costs are incurred for this route.
         */
        public let jumbo: Double?
        
        init(small: Double? = nil,
             standard: Double? = nil,
             middle: Double? = nil,
             large: Double? = nil,
             jumbo: Double? = nil) {
            self.small = small
            self.standard = standard
            self.middle = middle
            self.large = large
            self.jumbo = jumbo
        }
    }
}


extension TollCost {
    public static func == (lhs: TollCost, rhs: TollCost) -> Bool {
        return lhs.currency == rhs.currency &&
               lhs.paymentMethods == rhs.paymentMethods
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(String.self, forKey: .currency)
        paymentMethods = try container.decode(PaymentMethods.self, forKey: .paymentMethods)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currency, forKey: .currency)
        try container.encode(paymentMethods, forKey: .paymentMethods)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

extension TollCost.PaymentMethods {
    public static func == (lhs: TollCost.PaymentMethods, rhs: TollCost.PaymentMethods) -> Bool {
        return lhs.ETC == rhs.ETC &&
               lhs.cash == rhs.cash
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ETC = try container.decodeIfPresent(TollCost.CostPerVehicleSize.self, forKey: .ETC)
        cash = try container.decodeIfPresent(TollCost.CostPerVehicleSize.self, forKey: .cash)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(ETC, forKey: .ETC)
        try container.encodeIfPresent(cash, forKey: .cash)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

extension TollCost.CostPerVehicleSize {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        small = try container.decodeIfPresent(Double.self, forKey: .small)
        standard = try container.decodeIfPresent(Double.self, forKey: .standard)
        middle = try container.decodeIfPresent(Double.self, forKey: .middle)
        large = try container.decodeIfPresent(Double.self, forKey: .large)
        jumbo = try container.decodeIfPresent(Double.self, forKey: .jumbo)
        
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(small, forKey: .small)
        try container.encodeIfPresent(standard, forKey: .standard)
        try container.encodeIfPresent(middle, forKey: .middle)
        try container.encodeIfPresent(large, forKey: .large)
        try container.encodeIfPresent(jumbo, forKey: .jumbo)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
