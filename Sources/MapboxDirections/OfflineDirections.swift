import Foundation

public typealias OfflineVersion = String
public typealias OfflineDownloaderCompletionHandler = (_ location: URL?,_ response: URLResponse?, _ error: Error?) -> Void
public typealias OfflineDownloaderProgressHandler = (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void
public typealias OfflineVersionsHandler = (_ version: [OfflineVersion]?, _ error: Error?) -> Void

struct AvailableVersionsResponse: Codable {
    let availableVersions: [String]
}

public protocol OfflineDirectionsProtocol {
    /**
     Fetches the available offline routing tile versions and returns them in descending chronological order. The most recent version should typically be passed into `downloadTiles(in:version:completionHandler:)`.
     
     - parameter completionHandler: A closure of type `OfflineVersionsHandler` which will be called when the request completes
     */
    func fetchAvailableOfflineVersions(completionHandler: @escaping OfflineVersionsHandler) -> URLSessionDataTask
    
    /**
     Downloads offline routing tiles of the given version within the given coordinate bounds using the shared URLSession. The tiles are written to disk at the location passed into the `completionHandler`.
     
     - parameter coordinateBounds: The bounding box
     - parameter version: The version to download. Version is represented as a String (yyyy-MM-dd-x)
     - parameter completionHandler: A closure of type `OfflineDownloaderCompletionHandler` which will be called when the request completes
     */
    func downloadTiles(in coordinateBounds: CoordinateBounds, version: OfflineVersion, completionHandler: @escaping OfflineDownloaderCompletionHandler) -> URLSessionDownloadTask
}

extension Directions: OfflineDirectionsProtocol {
    /**
     The URL to a list of available versions.
     */
    public var availableVersionsURL: URL {
        let url = credentials.host.appendingPathComponent("route-tiles/v1").appendingPathComponent("versions")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "access_token", value: credentials.accessToken)]
        return components!.url!
    }
    
    /**
     Returns the URL to generate and download a tile pack from the Route Tiles API.
     
     - parameter coordinateBounds: The coordinate bounds that the tiles should cover.
     - parameter version: A version obtained from `availableVersionsURL`.
     - returns: The URL to generate and download the tile pack that covers the coordinate bounds.
     */
    public func tilesURL(for coordinateBounds: CoordinateBounds, version: OfflineVersion) -> URL {
        let url = credentials.host.appendingPathComponent("route-tiles/v1").appendingPathComponent(coordinateBounds.description)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "version", value: version),
                                  URLQueryItem(name: "access_token", value: credentials.accessToken)]
        return components!.url!
    }

    /**
     Fetches the available offline routing tile versions and returns them in descending chronological order. The most recent version should typically be passed into `downloadTiles(in:version:completionHandler:)`.
     
     - parameter completionHandler: A closure of type `OfflineVersionsHandler` which will be called when the request completes
     */
    @discardableResult
    public func fetchAvailableOfflineVersions(completionHandler: @escaping OfflineVersionsHandler) -> URLSessionDataTask {
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
        
        task.resume()
        
        return task
    }
    
    /**
     Downloads offline routing tiles of the given version within the given coordinate bounds using the shared URLSession. The tiles are written to disk at the location passed into the `completionHandler`.

     - parameter coordinateBounds: The bounding box
     - parameter version: The version to download. Version is represented as a String (yyyy-MM-dd-x)
     - parameter completionHandler: A closure of type `OfflineDownloaderCompletionHandler` which will be called when the request completes
     */
    @discardableResult
    public func downloadTiles(in coordinateBounds: CoordinateBounds,
                              version: OfflineVersion,
                              completionHandler: @escaping OfflineDownloaderCompletionHandler) -> URLSessionDownloadTask {
        let url = tilesURL(for: coordinateBounds, version: version)
        let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: url, completionHandler: completionHandler)
        task.resume()
        return task
    }
}
