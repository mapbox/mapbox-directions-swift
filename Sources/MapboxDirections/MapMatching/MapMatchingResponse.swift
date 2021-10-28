import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct MapMatchingResponse {
    public let httpResponse: HTTPURLResponse?
    
    public var matches : [Match]?
    public var tracepoints: [Tracepoint?]?
    
    public let options: MatchOptions
    public let credentials: Credentials
    
    /**
     The time when this `MapMatchingResponse` object was created, which is immediately upon recieving the raw URL response.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    public var created: Date = Date()
}

extension MapMatchingResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case matches = "matchings"
        case tracepoints
    }

     public init(httpResponse: HTTPURLResponse?, matches: [Match]? = nil, tracepoints: [Tracepoint]? = nil, options: MatchOptions, credentials: Credentials) {
        self.httpResponse = httpResponse
        self.matches = matches
        self.tracepoints = tracepoints
        self.options = options
        self.credentials = credentials
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.httpResponse = decoder.userInfo[.httpResponse] as? HTTPURLResponse
        
        guard let options = decoder.userInfo[.options] as? MatchOptions else {
            throw DirectionsCodingError.missingOptions
        }
        self.options = options
        
        guard let credentials = decoder.userInfo[.credentials] as? Credentials else {
            throw DirectionsCodingError.missingCredentials
        }
        self.credentials = credentials
        
        tracepoints = try container.decodeIfPresent([Tracepoint?].self, forKey: .tracepoints)
        matches = try container.decodeIfPresent([Match].self, forKey: .matches)
    }
}
