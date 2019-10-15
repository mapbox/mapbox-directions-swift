import Foundation


class MatchResponse: Codable {
    var matches : [Match]
    var tracepoints: [Tracepoint]
    
    private enum CodingKeys: String, CodingKey {
        case matches = "matchings"
        case tracepoints
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tracepoints = try container.decode([Tracepoint].self, forKey: .tracepoints)
        (decoder as? JSONDecoder)?.userInfo[.tracepoints] = tracepoints
        matches = try container.decode([Match].self, forKey: .matches)
    }
}
