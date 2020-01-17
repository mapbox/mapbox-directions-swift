import Foundation

public struct MapMatchingResponse {
    public var code: String?
    public var message: String?
    public var error: DirectionsError?
    public var matches : [Match]?
    public var tracepoints: [Tracepoint?]?
}

extension MapMatchingResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case error
        case matches = "matchings"
        case tracepoints
    }
    
    public init(error: DirectionsError) {
        self.init(code: nil, message: nil, error: error, matches: nil, tracepoints: nil)
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
    
    func postprocess(accessToken: String, apiEndpoint: URL, fetchStartDate: Date, responseEndDate: Date) {
        guard let matches = self.matches else {
            return
        }
        
        for result in matches {
            result.accessToken = accessToken
            result.apiEndpoint = apiEndpoint
            result.fetchStartDate = fetchStartDate
            result.responseEndDate = responseEndDate
        }
    }
}
