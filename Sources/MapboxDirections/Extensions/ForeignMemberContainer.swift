import Foundation
import Turf

/**
 A coding key as an extensible enumeration.
 */
struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension ForeignMemberContainer {
    /**
     Decodes any foreign members using the given decoder.
     */
    mutating func decodeForeignMembers<WellKnownCodingKeys>(notKeyedBy _: WellKnownCodingKeys.Type, with decoder: Decoder) throws where WellKnownCodingKeys: CodingKey {
        let foreignMemberContainer = try decoder.container(keyedBy: AnyCodingKey.self)
        for key in foreignMemberContainer.allKeys {
            if WellKnownCodingKeys(stringValue: key.stringValue) == nil {
                foreignMembers[key.stringValue] = try foreignMemberContainer.decode(JSONValue?.self, forKey: key)
            }
        }
    }

    /**
     Encodes any foreign members using the given encoder.
     */
    func encodeForeignMembers<WellKnownCodingKeys>(notKeyedBy _: WellKnownCodingKeys.Type, to encoder: Encoder) throws where WellKnownCodingKeys: CodingKey {
        var foreignMemberContainer = encoder.container(keyedBy: AnyCodingKey.self)
        for (key, value) in foreignMembers {
            if let key = AnyCodingKey(stringValue: key),
               WellKnownCodingKeys(stringValue: key.stringValue) == nil {
                try foreignMemberContainer.encode(value, forKey: key)
            }
        }
    }
}

/**
 A GeoJSON *class* that can contain [foreign members](https://datatracker.ietf.org/doc/html/rfc7946#section-6.1) in arbitrary keys.
 
 When subclassing `ForeignMemberContainerClass` type, you should call `decodeForeignMembers(notKeyedBy:with:)` during your `Decodable.init(from:)` initializer if your subclass has added any new properties.
 */
public protocol ForeignMemberContainerClass: AnyObject {
    var foreignMembers: JSONObject { get set }
    
    /**
     Decodes any foreign members using the given decoder.
     
     - parameter codingKeys: `CodingKeys` type which describes all properties declared  in current subclass.
     - parameter decoder: `Decoder` instance, which perfroms the decoding process.
     */
    func decodeForeignMembers<WellKnownCodingKeys>(notKeyedBy codingKeys: WellKnownCodingKeys.Type, with decoder: Decoder) throws where WellKnownCodingKeys: CodingKey & CaseIterable
    
    /**
     Encodes any foreign members using the given encoder.
     
     This method should be called in your `Encodable.encode(to:)` implementation only in the **base class**. Otherwise it will not encode  `foreignMembers` or way overwrite it.
     
     - parameter encoder: `Encoder` instance, performing the encoding process.
     */
    func encodeForeignMembers(to encoder: Encoder) throws
}

extension ForeignMemberContainerClass {

    public func decodeForeignMembers<WellKnownCodingKeys>(notKeyedBy _: WellKnownCodingKeys.Type, with decoder: Decoder) throws where WellKnownCodingKeys: CodingKey & CaseIterable {
        if foreignMembers.isEmpty {
            let foreignMemberContainer = try decoder.container(keyedBy: AnyCodingKey.self)
            for key in foreignMemberContainer.allKeys {
                if WellKnownCodingKeys(stringValue: key.stringValue) == nil {
                    foreignMembers[key.stringValue] = try foreignMemberContainer.decode(JSONValue?.self, forKey: key)
                }
            }
        }
        WellKnownCodingKeys.allCases.forEach {
            foreignMembers.removeValue(forKey: $0.stringValue)
        }
    }
    
    public func encodeForeignMembers(to encoder: Encoder) throws {
        var foreignMemberContainer = encoder.container(keyedBy: AnyCodingKey.self)
        for (key, value) in foreignMembers {
            if let key = AnyCodingKey(stringValue: key) {
                try foreignMemberContainer.encode(value, forKey: key)
            }
        }
    }
}
