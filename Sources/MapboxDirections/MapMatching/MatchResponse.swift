import Foundation

public struct MatchResponse {
    public var code: String
    public var message: String?
    public var matches : [Match]?
    public var tracepoints: [Tracepoint?]?
}

extension MatchResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case matches = "matchings"
        case tracepoints
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        tracepoints = try container.decodeIfPresent([Tracepoint?].self, forKey: .tracepoints)
        matches = try container.decodeIfPresent([Match].self, forKey: .matches)
        
        if let points = self.tracepoints {
            matches?.forEach {
                $0.tracepoints = points
            }
        }
    }
}
