import Foundation


class MatchResponse: Codable {
    var code: String
    var message: String?
    var matches : [Match]?
    var tracepoints: [Tracepoint?]?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case matches = "matchings"
        case tracepoints
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        tracepoints = try container.decodeIfPresent([Tracepoint?].self, forKey: .tracepoints)
        (decoder as? JSONDecoder)?.userInfo[.tracepoints] = tracepoints
        matches = try container.decodeIfPresent([Match].self, forKey: .matches)
    }
}
