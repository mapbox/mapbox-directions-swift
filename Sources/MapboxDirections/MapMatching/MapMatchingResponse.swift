import Foundation

public struct MapMatchingResponse {
    public var code: String?
    public var message: String?
    public var error: DirectionsError?
    public var matches : [Match]?
    public var tracepoints: [Tracepoint?]?
    
    public let options: MatchOptions
    public let credentials: DirectionsCredentials
    
    /**
     The time when this `MapMatchingResponse` object was created, which is immediately upon recieving the raw URL response.
     
     If you manually start fetching a task returned by `Directions.url(forCalculating:)`, this property is set to `nil`; use the `URLSessionTaskTransactionMetrics.responseEndDate` property instead. This property may also be set to `nil` if you create this result from a JSON object or encoded object.
     
     This property does not persist after encoding and decoding.
     */
    public var created: Date = Date()
}

extension MapMatchingResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case error
        case matches = "matchings"
        case tracepoints
    }
    
    public init(credentials: DirectionsCredentials, options: MatchOptions, error: DirectionsError) {
        self.init(code: nil, message: nil, error: error, matches: nil, tracepoints: nil, options: options, credentials: credentials)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let options = decoder.userInfo[.options] as? MatchOptions else {
            throw DirectionsCodingError.missingOptions
        }
        self.options = options
        
        guard let credentials = decoder.userInfo[.credentials] as? DirectionsCredentials else {
            throw DirectionsCodingError.missingCredentials
        }
        self.credentials = credentials
        
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
    
//    func postprocess(accessToken: String, apiEndpoint: URL, fetchStartDate: Date, responseEndDate: Date) {
//        guard let matches = self.matches else {
//            return
//        }
//        
//        for result in matches {
//            result.accessToken = accessToken
//            result.apiEndpoint = apiEndpoint
//            result.fetchStartDate = fetchStartDate
//            result.responseEndDate = responseEndDate
//        }
//    }
}
