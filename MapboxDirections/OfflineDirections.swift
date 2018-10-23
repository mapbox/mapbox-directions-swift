import Foundation


public typealias OfflineDownloaderCompletionHandler = (_ location: URL?, _ error: Error?) -> Void
public typealias OfflineDownloaderProgressHandler = (_ bytesWritten: Int64,
    _ totalBytesWritten: Int64,
    _ totalBytesExpectedToWrite: Int64) -> Void
public typealias OfflineVersionsHandler = (_ version: [Version]?, _ error: Error?) -> Void

struct AvailableVersionsResponse: Codable {
    let availableVersions: [Version]
}

@objc(MBVersion)
public class Version: NSObject, Codable {
    let versionString: String
    let versionDate: Date
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    convenience init(_ versionDate: Date) {
        self.init(versionString: Version.dateFormatter.string(from: versionDate), versionDate: versionDate)
    }
    
    convenience init(_ versionString: String) {
        self.init(versionString: versionString, versionDate: Version.dateFormatter.date(from: versionString)!)
    }
    
    init(versionString: String, versionDate: Date) {
        self.versionString = versionString
        self.versionDate = versionDate
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        
        self.versionString = versionString
        self.versionDate = Version.dateFormatter.date(from: versionString)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(versionString)
    }
}

@objc(MBOfflineDirections)
public class OfflineDirections: NSObject, URLSessionDownloadDelegate {
    
    var progressHandler: OfflineDownloaderProgressHandler?
    
    var completionHandler: OfflineDownloaderCompletionHandler?
    
    /// The API endpoint to request the directions from.
    internal var apiEndpoint: URL
    
    /// The Mapbox access token to associate the request with.
    internal let accessToken: String
    
    @objc public init(accessToken: String?, host: String?) {
        let accessToken = accessToken ?? defaultAccessToken
        assert(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://www.mapbox.com/studio/account/tokens/>. In Info.plist, set the MGLMapboxAccessToken key to your access token, or use the Directions(accessToken:host:) initializer.")
        
        self.accessToken = accessToken!
        
        if let host = host, !host.isEmpty {
            var baseURLComponents = URLComponents()
            baseURLComponents.scheme = "https"
            baseURLComponents.host = host
            apiEndpoint = baseURLComponents.url!
        } else {
            apiEndpoint = URL(string:(defaultApiEndPointURLString ?? "https://api.mapbox.com"))!
        }
    }
    
    func availableVersionsURL() -> URL {
        
        let url = apiEndpoint.appendingPathComponent("route-tiles/v1").appendingPathComponent("versions")
        var components = URLComponents(string: url.absoluteString)
        components?.queryItems = [URLQueryItem(name: "access_token", value: accessToken)]
        
        return components!.url!
    }
    
    func tilesURL(for boundingBox: BoundingBox, version: Version) -> URL {
        
        let url = apiEndpoint.appendingPathComponent("route-tiles/v1").appendingPathComponent(boundingBox.path)
        var components = URLComponents(string: url.absoluteString)
        components?.queryItems = [URLQueryItem(name: "version", value: version.versionString),
                                  URLQueryItem(name: "access_token", value: accessToken)]
        
        return components!.url!
    }

    /**
     Fetches the available versions.
     */
    @discardableResult
    @objc
    public func availableVersions(completionHandler: @escaping OfflineVersionsHandler) -> URLSessionDataTask {
        
        return URLSession.shared.dataTask(with: availableVersionsURL()) { (data, response, error) in
            if let error = error {
                return completionHandler(nil, error)
            }
            
            guard let data = data else {
                return completionHandler(nil, error)
            }
            
            do {
                let versionResponse = try JSONDecoder().decode(AvailableVersionsResponse.self, from: data)
                completionHandler(versionResponse.availableVersions, error)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Initiates a download process of all tiles needed to provide routing within the given bounding box.
     
     - parameter boundingBox: The region of the pack to be downloaded.
     - parameter version: The version of the pack to be downloaded.
     - parameter progressHandler: Reports the progress of downloaded and yet to be downloaded bytes
     - parameter completionHandler: Informs when the download is completed or failed. The offline pack may be moved from the temporary directory and to a persistent store at this point.
     
     */
    @discardableResult
    @objc
    public func downloadTiles(for boundingBox: BoundingBox, version: Version, progressHandler: @escaping OfflineDownloaderProgressHandler, completionHandler: @escaping OfflineDownloaderCompletionHandler) -> URLSessionDownloadTask {
        
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        
        let configuration = URLSessionConfiguration.default
        
        let url = tilesURL(for: boundingBox, version: version)
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session.downloadTask(with: url) { [weak self] (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // TODO: Move file from temporary location to a provided location
//                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                    print("Success: \(statusCode)")
//                }
//                
//                do {
//                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
//                    completion()
//                } catch (let writeError) {
//                    print("error writing file \(localUrl) : \(writeError)")
//                }
                
            } else {
                self?.completionHandler?(nil, error)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        completionHandler?(location, nil)
    }
    
    private func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progressHandler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }
}
