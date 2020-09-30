import Foundation

public struct AdministrationRegion: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case countryCodeAlpha3 = "iso_3166_1_alpha3"
        case countryCode = "iso_3166_1"
    }

    public var countryCodeAlpha3: String
    public var countryCode: String

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countryCodeAlpha3 = try values.decode(String.self, forKey: .countryCodeAlpha3)
        countryCode = try values.decode(String.self, forKey: .countryCode)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countryCodeAlpha3, forKey: .countryCodeAlpha3)
        try container.encode(countryCode, forKey: .countryCode)
    }
}
