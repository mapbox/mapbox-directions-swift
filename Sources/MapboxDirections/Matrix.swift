import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


/**
 Computes distances and durations between origin-destination pairs, and returns the resulting distances in meters and durations in seconds.
 */
open class Matrix {
    /**
     A tuple type representing the matrix session that was generated from the request.
     
     - parameter options: A `MatrixOptions ` object representing the request parameter options.
     
     - parameter credentials: A object containing the credentials used to make the request.
     */
    public typealias Session = (options: MatrixOptions, credentials: Credentials)
    
    /**
     A closure (block) to be called when a matrix request is complete.
     
     - parameter session: A `Matrix.Session` object containing session information
     
     - parameter result: A `Result` enum that represents the (RETURN TYPE) if the request returned successfully, or the error if it did not.
     */
    public typealias MatrixCompletionHandler = (_ session: Session, _ result: Result<MatrixResponse, MatrixError>) -> Void
    
    // MARK: Creating an Matrix Object
    
    /**
     The Authorization & Authentication credentials that are used for this service.
     
     If nothing is provided, the default behavior is to read credential values from the developer's Info.plist.
     */
    public let credentials: Credentials
    private let urlSession: URLSession
    private let processingQueue: DispatchQueue
    
    /**
     The shared matrix object.
     
     To use this object, a Mapbox [access token](https://docs.mapbox.com/help/glossary/access-token/) should be specified in the `MBXAccessToken` key in the main application bundle’s Info.plist.
     */
    public static let shared = Matrix()
    
    /**
     Creates a new instance of Matrix object.
     - Parameters:
       - credentials: Credentials that will be used to make API requests to Mapbox Matrix API.
       - urlSession: URLSession that will be used to submit API requests to Mapbox Matrix API.
       - processingQueue: A DispatchQueue that will be used for CPU intensive work.
     */
    public init(credentials: Credentials = .init(),
                urlSession: URLSession = .shared,
                processingQueue: DispatchQueue = .global(qos: .userInitiated)) {
        self.credentials = credentials
        self.urlSession = urlSession
        self.processingQueue = processingQueue
    }
    
    // MARK: Getting Matrix
    /**
     Begins asynchronously calculating matrices using the given options and delivers the results to a closure.
     
     This method retrieves the matrices asynchronously from the [Mapbox Matrix API](https://docs.mapbox.com/api/navigation/matrix/) over a network connection. If a connection error or server error occurs, details about the error are passed into the given completion handler in lieu of the contours.
     
     - parameter options: A `MatrixOptions` object specifying the requirements for the resulting matrices.
     - parameter completionHandler: The closure (block) to call with the resulting matrices. This closure is executed on the application’s main thread.
     - returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting matrices, cancel this task.
     */
    @discardableResult open func calculate(_ options: MatrixOptions, completionHandler: @escaping MatrixCompletionHandler) -> URLSessionDataTask {
        let session = (options: options, credentials: self.credentials)
        let request = urlRequest(forCalculating: options)
        let requestTask = urlSession.dataTask(with: request) { (possibleData, possibleResponse, possibleError) in
            
            if let urlError = possibleError as? URLError {
                DispatchQueue.main.async {
                    completionHandler(session, .failure(.network(urlError)))
                }
                return
            }
            
            guard let response = possibleResponse, ["application/json", "text/html"].contains(response.mimeType) else {
                DispatchQueue.main.async {
                    completionHandler(session, .failure(.invalidResponse(possibleResponse)))
                }
                return
            }
            
            guard let data = possibleData else {
                DispatchQueue.main.async {
                    completionHandler(session, .failure(.noData))
                }
                return
            }
            
            self.processingQueue.async {
                do {
                    let decoder = JSONDecoder()
                    
                    guard let disposition = try? decoder.decode(ResponseDisposition.self, from: data) else {
                        let apiError = MatrixError(code: nil, message: nil, response: response, underlyingError: possibleError)
                        
                        DispatchQueue.main.async {
                            completionHandler(session, .failure(apiError))
                        }
                        return
                    }
                    
                    guard (disposition.code == nil && disposition.message == nil) || disposition.code == "Ok" else {
                        let apiError = MatrixError(code: disposition.code, message: disposition.message, response: response, underlyingError: possibleError)
                        
                        DispatchQueue.main.async {
                            completionHandler(session, .failure(apiError))
                        }
                        return
                    }
                    
                    let result = try decoder.decode(MatrixResponse.self, from: data)
                    
                    guard result.distances != nil || result.travelTimes != nil else {
                        DispatchQueue.main.async {
                            completionHandler(session, .failure(.noRoute))
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(session, .success(result))
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        let bailError = MatrixError(code: nil, message: nil, response: response, underlyingError: error)
                        completionHandler(session, .failure(bailError))
                    }
                }
            }
        }
        requestTask.priority = 1
        requestTask.resume()
        
        return requestTask
    }
    
    // MARK: Request URL Preparation
    /**
     The GET HTTP URL used to fetch the matrices from the Matrix API.
     
     - parameter options: A `MatrixOptions` object specifying the requirements for the resulting contours.
     - returns: The URL to send the request to.
     */
    open func url(forCalculating options: MatrixOptions) -> URL {
        
        var params = options.urlQueryItems
        params.append(URLQueryItem(name: "access_token", value: credentials.accessToken))

        let unparameterizedURL = URL(path: options.path, host: credentials.host)
        var components = URLComponents(url: unparameterizedURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }
    
    /**
     The HTTP request used to fetch the matrices from the Matrix API.
     
     - parameter options: A `MatrixOptions` object specifying the requirements for the resulting routes.
     - returns: A GET HTTP request to calculate the specified options.
     */
    open func urlRequest(forCalculating options: MatrixOptions) -> URLRequest {
        let getURL = self.url(forCalculating: options)
        var request = URLRequest(url: getURL)
        request.setupUserAgentString()
        return request
    }
}
