import Foundation

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as? String
let defaultApiEndPointURLString = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAPIBaseURL") as? String

public struct DirectionsCredentials {
    public let accessToken: String?
    public let host: URL
    public var skuToken: String? {
        guard let mbx: AnyClass = NSClassFromString("MBXAccounts") else { return nil }
        guard mbx.responds(to: Selector(("serviceSkuToken"))) else { return nil }
        return mbx.value(forKeyPath: "serviceSkuToken") as? String
    }
    
    public init(accessToken: String? = nil, host: URL? = nil) {
        self.accessToken = accessToken ?? defaultAccessToken
        
        precondition(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://account.mapbox.com/access-tokens/>. In Info.plist, set the MGLMapboxAccessToken key to your access token, or use the Directions(accessToken:host:) initializer.")
        
        if let host = host {
            self.host = host
        } else if let defaultHostString = defaultApiEndPointURLString, let defaultHost = URL(string: defaultHostString) {
            self.host = defaultHost
        } else {
            self.host = URL(string: "https://api.mapbox.com")!
        }
    }
}

