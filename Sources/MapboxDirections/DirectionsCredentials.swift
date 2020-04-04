import Foundation

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as? String
let defaultApiEndPointURLString = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAPIBaseURL") as? String

public struct DirectionsCredentials: Equatable {
    
    /**
    The mapbox access token. You can find this in your Mapbox account dashboard.
     */
    public let accessToken: String?
    
    /**
     The host to reach. defaults to `api.mapbox.com`.
     */
    public let host: URL
    
    /**
     The SKU Token associated with the request. Used for billing.
     */
    public var skuToken: String? {
        guard let mbx: AnyClass = NSClassFromString("MBXAccounts") else { return nil }
        guard mbx.responds(to: Selector(("serviceSkuToken"))) else { return nil }
        return mbx.value(forKeyPath: "serviceSkuToken") as? String
    }
    
    /**
     Intialize a new credential.
     
     - parameter accessToken: Optional. An access token to provide. If this value is nil, the SDK will attempt to find a token from your app's `info.plist`.
     - parameter host: Optional. A parameter to pass a custom host. If `nil` is provided, the SDK will attempt to find a host from your app's `info.plist`, and barring that will default to  `https://api.mapbox.com`.
     */
    public init(accessToken token: String? = nil, host: URL? = nil) {
        let accessToken = token ?? defaultAccessToken
        
        precondition(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://account.mapbox.com/access-tokens/>. In Info.plist, set the MGLMapboxAccessToken key to your access token, or use the Directions(accessToken:host:) initializer.")
        self.accessToken = accessToken
        if let host = host {
            self.host = host
        } else if let defaultHostString = defaultApiEndPointURLString, let defaultHost = URL(string: defaultHostString) {
            self.host = defaultHost
        } else {
            self.host = URL(string: "https://api.mapbox.com")!
        }
    }
}

