import Foundation
import Turf

/**
 :nodoc:
 Information about toll payment method.
 */
public struct PaymentMethod: Hashable, Equatable {
    /**
     Method identifier.
     */
    public let identifier: String
    
    /**
     Payment is done by electronic toll collection.
     */
    public static let electronicTollCollection = PaymentMethod(identifier: "etc")
    /**
     Payment is done by cash.
     */
    public static let cash = PaymentMethod(identifier: "cash")
}

/**
 :nodoc:
 Categories by which toll fees are divided.
 */
public struct Category: Hashable, Equatable {
    /**
     Category name.
     */
    public let name: String
    
    /**
     A small sized vehicle.
     
     Vehicle size is [standartized](https://en.wikipedia.org/wiki/Expressways_of_Japan#Tolls).
     */
    public static let small = Category(name: "small")
    /**
     A standard sized vehicle.
     
     Vehicle size is [standartized](https://en.wikipedia.org/wiki/Expressways_of_Japan#Tolls).
     */
    public static let standard = Category(name: "standard")
    /**
     A middle sized vehicle.
     
     Vehicle size is [standartized](https://en.wikipedia.org/wiki/Expressways_of_Japan#Tolls).
     */
    public static let middle = Category(name: "middle")
    /**
     A large sized vehicle.
     
     Vehicle size is [standartized](https://en.wikipedia.org/wiki/Expressways_of_Japan#Tolls).
     */
    public static let large = Category(name: "large")
    /**
     A jumbo sized vehicle.
     
     Vehicle size is [standartized](https://en.wikipedia.org/wiki/Expressways_of_Japan#Tolls).
     */
    public static let jumbo = Category(name: "jumbo")
}

public typealias CategoriesTolls = [Category: Decimal]
public typealias PaymentMethods = [PaymentMethod: CategoriesTolls]

/**
 :nodoc:
 Toll cost information for the `Route`.
 */
public struct TollPrice: Equatable,  Codable, ForeignMemberContainer {
    public var foreignMembers: Turf.JSONObject = [:]
    
    private enum CodingKeys: String, CodingKey {
        case currency
        case paymentMethods = "payment_methods"
    }

    /**
     Related currency code string.
     
     Uses ISO 4217 format. Refers to values in `CategoriesTolls`. A toll cost of `0` is valid and simply means that no toll costs are incurred for this route.
     */
    public let currencyCode: String
    /**
     Information about toll payment methods.
     */
    public let paymentMethods: PaymentMethods
    
    init(currencyCode: String, paymentMethods: PaymentMethods) {
        self.currencyCode = currencyCode
        self.paymentMethods = paymentMethods
    }
}


extension TollPrice {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyCode = try container.decode(String.self, forKey: .currency)
        
        let rawPaymentMethods = try? container.decode([String: [String: Decimal]].self, forKey: .paymentMethods)
        if let rawPaymentMethods = rawPaymentMethods {
            self.paymentMethods = paymentMethodsFromRawStrings(rawPaymentMethods)
        } else {
            self.paymentMethods = [:]
            try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyCode, forKey: .currency)
        try container.encode(paymentMethodsToRawStrings(paymentMethods), forKey: .paymentMethods)
        
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

private func paymentMethodsFromRawStrings(_ rawPaymentMethods: [String: [String: Decimal]]) -> PaymentMethods {
    return rawPaymentMethods.reduce(into: [:], { paymentResult, paymentElement in
        paymentResult[PaymentMethod(identifier: paymentElement.key)] = paymentElement.value.reduce(into: [:], { categoryResult, categoryElement in
            categoryResult[Category(name: categoryElement.key)] = categoryElement.value
        })
    })
}

private func paymentMethodsToRawStrings(_ paymentMethods: PaymentMethods) -> [String: [String: Decimal]] {
    return paymentMethods.reduce(into: [:], { paymentResult, paymentElement in
        paymentResult[paymentElement.key.identifier] = paymentElement.value.reduce(into: [:], { categoryResult, categoryElement in
            categoryResult[categoryElement.key.name] = categoryElement.value
        })
    })
}
