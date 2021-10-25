import Foundation

public struct IsochroneCredentials: Equatable {
    /**
    The mapbox access token. You can find this in your Mapbox account dashboard.
     */
    public var accessToken: String?
    /**
     The host to reach. Defaults to `api.mapbox.com`.
     */
    public var host: URL
    
    /**
     Intialize a new credential.
     
     - parameter accessToken: Optional. An access token to provide. If this value is nil, the SDK will attempt to find a token from your app's `info.plist`.
     - parameter host: Optional. A parameter to pass a custom host. If `nil` is provided, the SDK will attempt to find a host from your app's `info.plist`, and barring that will default to  `https://api.mapbox.com`.
     */
    public init(accessToken token: String? = nil, host: URL? = nil) {
        let accessToken = token ?? defaultAccessToken
        
        precondition(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://account.mapbox.com/access-tokens/>. In Info.plist, set the MBXAccessToken key to your access token, or use the Directions(accessToken:host:) initializer.")
        self.accessToken = accessToken!
        if let host = host {
            self.host = host
        } else if let defaultHostString = defaultApiEndPointURLString, let defaultHost = URL(string: defaultHostString) {
            self.host = defaultHost
        } else {
            self.host = URL(string: "https://api.mapbox.com")!
        }
    }
}
