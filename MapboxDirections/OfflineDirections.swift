import Foundation


public typealias OfflineVersion = String
public typealias OfflineDownloaderCompletionHandler = (_ location: URL?,_ response: URLResponse?, _ error: Error?) -> Void
public typealias OfflineDownloaderProgressHandler = (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void
public typealias OfflineVersionsHandler = (_ version: [OfflineVersion]?, _ error: Error?) -> Void

struct AvailableVersionsResponse: Codable {
    let availableVersions: [String]
}

@objc(MBOfflineDirectionsProtocol)
public protocol OfflineDirectionsProtocol {
    
    /**
     Fetches the available versions.
     */
    @discardableResult
    func fetchAvailableOfflineVersions(completionHandler: @escaping OfflineVersionsHandler) -> URLSessionDataTask
    
    /**
     Initiates a download process of all tiles needed to provide routing within the given bounding box.
     
     - parameter coordinateBounds: The region of the pack to be downloaded.
     - parameter version: The version of the pack to be downloaded.
     - parameter completionHandler: Informs when the download is completed or failed. The offline pack may be moved from the temporary directory and to a persistent store at this point.
     */
    @discardableResult
    func downloadTiles(in coordinateBounds: CoordinateBounds, version: OfflineVersion, session: URLSession?, completionHandler: @escaping OfflineDownloaderCompletionHandler) -> URLSessionDownloadTask
}

extension Directions: OfflineDirectionsProtocol {
    
    /// URL to the endpoint listing available versions
    public var availableVersionsURL: URL {
        
        let url = apiEndpoint.appendingPathComponent("route-tiles/v1").appendingPathComponent("versions")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "access_token", value: accessToken)]
        
        return components!.url!
    }
    
    /// URL to the endpoint for downloading a tile pack
    public func tilesURL(for coordinateBounds: CoordinateBounds, version: OfflineVersion) -> URL {
        
        let url = apiEndpoint.appendingPathComponent("route-tiles/v1").appendingPathComponent(coordinateBounds.description)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "version", value: version),
                                  URLQueryItem(name: "access_token", value: accessToken)]
        
        return components!.url!
    }

    /**
     Fetch the available versions in descending chronological order. A version is represented as a String (yyyy-MM-dd or yyyy-MM-dd-x).
     
     - parameter completionHandler: The closure to call with the results
     - returns: A `URLSessionDataTask`
     */
    @discardableResult
    @objc public func fetchAvailableOfflineVersions(completionHandler: @escaping OfflineVersionsHandler) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: availableVersionsURL) { (data, response, error) in
            if let error = error {
                return completionHandler(nil, error)
            }
            
            guard let data = data else {
                return completionHandler(nil, error)
            }
            
            do {
                let versionResponse = try JSONDecoder().decode(AvailableVersionsResponse.self, from: data)
                let availableVersions = versionResponse.availableVersions.sorted(by: >)
                completionHandler(availableVersions, error)
            } catch {
                completionHandler(nil, error)
            }
        }
        
        return task
    }
    
    /**
     Initializes an `URLSessionDownloadTask` used for downloading tiles within a given bounding box.
     
     - parameter coordinateBounds: The bounding box
     - parameter version: The version to download. Version is represented as a String (yyyy-MM-dd-x)
     - parameter session: Optional URLSession
     - parameter completionHandler: The closure to call with the results
     
     - returns: A `URLSessionDownloadTask`
     */
    @discardableResult
    @objc public func downloadTiles(in coordinateBounds: CoordinateBounds,
                              version: OfflineVersion,
                              session: URLSession? = URLSession.shared,
                              completionHandler: @escaping OfflineDownloaderCompletionHandler) -> URLSessionDownloadTask {
        
        let urlSession = session ?? URLSession.shared
        let url = tilesURL(for: coordinateBounds, version: version)
        
        return urlSession.downloadTask(with: url, completionHandler: completionHandler)
    }
}
