import Foundation
import Turf


open class Isochrone {

    public typealias Session = (options: IsochroneOptions, credentials: IsochroneCredentials)
    public typealias IsochroneCompletionHandler = (_ session: Session, _ result: Result<FeatureCollection, IsochroneError>) -> Void
    
    public let credentials: IsochroneCredentials
    private let urlSession: URLSession
    private let processingQueue: DispatchQueue
    
    public static let shared = Isochrone()
    
    public init(credentials: IsochroneCredentials = .init(),
                urlSession: URLSession = .shared,
                processingQueue: DispatchQueue = .global(qos: .userInitiated)) {
        self.credentials = credentials
        self.urlSession = urlSession
        self.processingQueue = processingQueue
    }
    
    @discardableResult open func calculate(_ options: IsochroneOptions, completionHandler: @escaping IsochroneCompletionHandler) -> URLSessionDataTask {
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
                        let apiError = IsochroneError(code: nil, message: nil, response: possibleResponse, underlyingError: possibleError)

                        DispatchQueue.main.async {
                            completionHandler(session, .failure(apiError))
                        }
                        return
                    }
                    
                    guard (disposition.code == nil && disposition.message == nil) || disposition.code == "Ok" else {
                        let apiError = IsochroneError(code: disposition.code, message: disposition.message, response: response, underlyingError: possibleError)
                        DispatchQueue.main.async {
                            completionHandler(session, .failure(apiError))
                        }
                        return
                    }
                    
                    let result = try decoder.decode(FeatureCollection.self, from: data)
//                    guard !result.features.isEmpty else {
//                        DispatchQueue.main.async {
//                            completionHandler(session, .failure(.unableToContour))
//                        }
//                        return
//                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(session, .success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        let bailError = IsochroneError(code: nil, message: nil, response: response, underlyingError: error)
                        completionHandler(session, .failure(bailError))
                    }
                }
            }
        }
        requestTask.priority = 1
        requestTask.resume()
        
        return requestTask
    }
    
    open func url(forCalculating options: IsochroneOptions) -> URL {
        
        var params = options.urlQueryItems
        params.append(URLQueryItem(name: "access_token", value: credentials.accessToken))

        let unparameterizedURL = URL(string: options.path, relativeTo: credentials.host)!
        var components = URLComponents(url: unparameterizedURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }
    
    open func urlRequest(forCalculating options: IsochroneOptions) -> URLRequest {
        let getURL = self.url(forCalculating: options)
        var request = URLRequest(url: getURL)
//        if getURL.absoluteString.count > MaximumURLLength {
//            request.url = url(forCalculating: options, httpMethod: "POST")
//
//            let body = options.httpBody.data(using: .utf8)
//            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request.httpMethod = "POST"
//            request.httpBody = body
//        }
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }
}
