import Foundation

public struct TollCollection: Codable, Equatable {

    public enum CollectionType: String, Codable {
        case tollBooth = "toll_booth"
        case tollGantry = "toll_gantry"
    }

    let collectionType: CollectionType

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        collectionType = try values.decode(CollectionType.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(collectionType, forKey: .type)
    }
}
