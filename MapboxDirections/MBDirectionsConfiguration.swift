import Foundation

internal struct MBDirectionsConfiguration {
    internal var apiEndpoint: String = "https://api.mapbox.com"
    internal var accessToken: String?
    
    /**
     Create a new configuration object.
     - Parameter accessToken: a Mapbox access token is required to use the Mapbox Geocoding API
     */
    internal init(_ accessToken: String) {
        self.accessToken = accessToken
    }
}