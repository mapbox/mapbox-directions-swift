import Foundation

public struct RestStop: Codable, Equatable {

    public enum StopType: String, Codable {
        case serviceArea = "service_area"
        case restArea = "rest_area"
    }

    let stopType: StopType

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        stopType = try values.decode(StopType.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stopType.rawValue, forKey: .type)
    }
}
