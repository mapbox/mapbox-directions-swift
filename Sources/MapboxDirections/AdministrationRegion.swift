import Foundation

/**
 :nodoc:
 `AdministrationRegion` describes corresponding object on the route.
 */
public struct AdministrationRegion: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case countryCodeAlpha3 = "iso_3166_1_alpha3"
        case countryCode = "iso_3166_1"
    }

    public var countryCodeAlpha3: String?
    public var countryCode: String

    public init(countryCode: String, countryCodeAlpha3: String) {
        self.countryCode = countryCode
        self.countryCodeAlpha3 = countryCodeAlpha3
    }
}
