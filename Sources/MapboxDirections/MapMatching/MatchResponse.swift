import Foundation

class MatchResponse: Codable {
    var code: String
    var message: String?
    var matches : [Match]?
    var tracepoints: [Match.Tracepoint?]?
    
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
        tracepoints = try container.decodeIfPresent([Match.Tracepoint?].self, forKey: .tracepoints)
        matches = try container.decodeIfPresent([Match].self, forKey: .matches)
        
        if let tracepoints = self.tracepoints, let matches = matches {
            for match in matches {
                // TODO: Filter on matchings_index.
                // TODO: Push tracepoints down to individual legs to reflect waypoint_index.
                match.tracepoints = tracepoints
            }
        }
    }
}
