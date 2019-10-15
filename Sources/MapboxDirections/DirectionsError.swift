import Foundation
import CoreLocation


public enum DirectionsError: Error, RawRepresentable {
    public init?(rawValue: String) {
        assertionFailure("Do not use init(rawValue:) for DirectionsError.")
        return nil
    }
    
    public var rawValue: String {
        return """
        Error: \(String(describing: self))
        Failure Reason: \(failureReason)
        Recovery Suggestion: \(recoverySuggestion)
        """
    }
    public var failureReason: String {
        switch self {
        case .noData:
            return "No data was returned from the server."
        case .invalidResponse:
            return "A response was recieved from the server, but it was not of a valid format."
        case .unableToRoute:
            return "No route could be found between the specified locations."
        case .unableToLocate:
            return "A specified location could not be associated with a roadway or pathway."
        case .profileNotFound:
            return "Unrecognized profile identifier."
        case .requestTooLarge:
            return "The request is too large."
        case let .rateLimited(rateLimitInterval: interval, rateLimit: limit, _):
            let intervalFormatter = DateComponentsFormatter()
            intervalFormatter.unitsStyle = .full
            guard let interval = interval, let limit = limit else {
                return "Too many requests."
            }
            let formattedInterval = intervalFormatter.string(from: interval) ?? "\(interval) seconds"
            let formattedCount = NumberFormatter.localizedString(from: NSNumber(value: limit), number: .decimal)
            return "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)"
        case let .unknown(response: response, underlying: error, code: code):
            return "Unknown Error. Response: \(response.debugDescription) Underlying Error: \(error.debugDescription) Code: \(code.debugDescription)"
        }
    }
    
    public var recoverySuggestion: String {
        switch self {
        case .noData:
            return "Make sure you have an active internet connection."
        case .unableToRoute:
            return "Make sure it is possible to travel between the locations with the mode of transportation implied by the profileIdentifier option. For example, it is impossible to travel by car from one continent to another without either a land bridge or a ferry connection."
        case .unableToLocate:
            return "Make sure the locations are close enough to a roadway or pathway. Try setting the coordinateAccuracy property of all the waypoints to a negative value."
        case .profileNotFound:
            return "Make sure the profileIdentifier option is set to one of the provided constants, such as MBDirectionsProfileIdentifierAutomobile."
        case .requestTooLarge:
            return "Try specifying fewer waypoints or giving the waypoints shorter names."
        case let .rateLimited(rateLimitInterval: _, rateLimit: _, resetTime: reset):
            guard let reset = reset else {
                return "Wait a little while before retrying."
            }
            let formattedDate: String = DateFormatter.localizedString(from: reset, dateStyle: .long, timeStyle: .long)
            return "Wait until \(formattedDate) before retrying."
        case .invalidResponse:
            fallthrough
        case .unknown(_,_,_):
            return "Please contact Mapbox Support."
        }
    }
    public typealias RawValue = String
     
    
    case noData
    case invalidResponse
    case unableToRoute
    case unableToLocate
    case profileNotFound
    case requestTooLarge
    case rateLimited(rateLimitInterval: TimeInterval?, rateLimit: UInt?, resetTime: Date?)
    case unknown(response: URLResponse?, underlying: Error?, code: String?)
    
}
