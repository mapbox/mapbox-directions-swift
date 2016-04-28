import Foundation
import RequestKit

internal struct MBDirectionsConfiguration: Configuration {
    internal var apiEndpoint: String = "https://api.mapbox.com"
    internal var accessToken: String?
    
    internal init(_ accessToken: String, host: String? = nil) {
        self.accessToken = accessToken
        if let host = host {
            let baseURLComponents = NSURLComponents()
            baseURLComponents.scheme = "https"
            baseURLComponents.host = host
            apiEndpoint = baseURLComponents.string ?? apiEndpoint
        }
    }
}
