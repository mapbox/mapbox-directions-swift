typealias JSONDictionary = [String: AnyObject]

public let MBDirectionsErrorDomain = "MBDirectionsErrorDomain"

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken = NSBundle.mainBundle().objectForInfoDictionaryKey("MGLMapboxAccessToken") as? String

extension CLLocationCoordinate2D {
    /**
     Initializes a coordinate pair based on the given GeoJSON array.
     */
    internal init(geoJSON array: [Double]) {
        assert(array.count == 2)
        self.init(latitude: array[1], longitude: array[0])
    }
}

extension CLLocation {
    /**
     Initializes a CLLocation object with the given coordinate pair.
     */
    internal convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

@objc(MBDirections)
public class Directions: NSObject {
    public typealias CompletionHandler = (waypoints: [Waypoint]?, routes: [Route]?, error: NSError?) -> Void
    
    // MARK: Creating a Directions Object
    
    /**
     The shared directions object.
     
     To use this object, a Mapbox [access token](https://www.mapbox.com/help/define-access-token/) should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    public static let sharedDirections = Directions(accessToken: nil)
    
    /// The API endpoint to request the directions from.
    internal var apiEndpoint: NSURL
    
    /// The Mapbox access token to associate the request with.
    internal let accessToken: String
    
    /**
     Initializes a newly created directions object with an optional access token and host.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the directions object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     - parameter host: An optional hostname to the server API. The Mapbox Directions API endpoint is used by default.
     */
    public init(accessToken: String?, host: String?) {
        let accessToken = accessToken ?? defaultAccessToken
        assert(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://www.mapbox.com/studio/account/tokens/>. In Info.plist, set the MGLMapboxAccessToken key to your access token, or use the Directions(accessToken:host:) initializer.")
        
        self.accessToken = accessToken!
        
        let baseURLComponents = NSURLComponents()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = host ?? "api.mapbox.com"
        self.apiEndpoint = baseURLComponents.URL!
    }
    
    /**
     Initializes a newly created directions object with an optional access token.
     
     The directions object sends requests to the Mapbox Directions API endpoint.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the directions object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    public convenience init(accessToken: String?) {
        self.init(accessToken: accessToken, host: nil)
    }
    
    // MARK: Getting Directions
    
    /**
     Begins asynchronously calculating the route or routes using the given options and delivers the results to a closure.
     
     This method retrieves the routes asynchronously over a network connection. If a connection error or server error occurs, details about the error are passed into the given completion handler in lieu of the routes.
     
     - parameter options: A `RouteOptions` object specifying the requirements for the resulting routes.
     - parameter completionHandler: The closure (block) to call with the resulting routes. This closure is executed on the application’s main thread.
     - returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting routes, cancel this task.
     */
    public func calculateDirections(options options: RouteOptions, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        let url = URLForCalculatingDirections(options: options)
        let task = dataTaskWithURL(url, completionHandler: { (json) in
            let waypoints = (json["waypoints"] as? [JSONDictionary])?.map { waypoint -> Waypoint in
                let location = waypoint["location"] as! [Double]
                let coordinate = CLLocationCoordinate2D(geoJSON: location)
                return Waypoint(coordinate: coordinate, name: waypoint["name"] as? String)
            }
            let routes = (json["routes"] as? [JSONDictionary])?.map {
                Route(json: $0, waypoints: waypoints ?? options.waypoints, profileIdentifier: options.profileIdentifier)
            }
            
            completionHandler(waypoints: waypoints, routes: routes, error: nil)
        }) { (error) in
            completionHandler(waypoints: nil, routes: nil, error: error)
        }
        task.resume()
        return task
    }
    
    /**
     Returns a URL session task for the given URL that will run the given blocks on completion or error.
     
     - parameter url: The URL to request.
     - parameter completionHandler: The closure to call with the parsed JSON response dictionary.
     - parameter errorHandler: The closure to call when there is an error.
     - returns: The data task for the URL.
     - postcondition: The caller must resume the returned task.
     */
    private func dataTaskWithURL(url: NSURL, completionHandler: (json: AnyObject) -> Void, errorHandler: (error: NSError) -> Void) -> NSURLSessionDataTask {
        return NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            var json: JSONDictionary = [:]
            if let data = data {
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                } catch {
                    assert(false, "Invalid data")
                }
            }
            
            let apiStatusCode = json["code"] as? String
            guard data != nil && error == nil && apiStatusCode == "Ok" else {
                let apiError = Directions.descriptiveError(json, response: response, underlyingError: error)
                dispatch_async(dispatch_get_main_queue()) {
                    errorHandler(error: apiError)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(json: json)
            }
        }
    }
    
    /**
     The HTTP URL used to fetch the routes from the API.
     */
    public func URLForCalculatingDirections(options options: RouteOptions) -> NSURL {
        let params = options.params + [
            NSURLQueryItem(name: "access_token", value: accessToken),
        ]
        
        assert(!options.queries.isEmpty, "No query")
        
        let queryComponent = options.queries.joinWithSeparator(";")
        let unparameterizedURL = NSURL(string: "directions/v5/\(options.profileIdentifier)/\(queryComponent).json", relativeToURL: apiEndpoint)!
        let components = NSURLComponents(URL: unparameterizedURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.URL!
    }
    
    /**
     Returns an error that supplements the given underlying error with additional information from the an HTTP response’s body or headers.
     */
    private static func descriptiveError(json: JSONDictionary, response: NSURLResponse?, underlyingError error: NSError?) -> NSError {
        let apiStatusCode = json["code"] as? String
        var userInfo = error?.userInfo ?? [:]
        if let response = response as? NSHTTPURLResponse {
            var failureReason: String? = nil
            var recoverySuggestion: String? = nil
            switch (response.statusCode, apiStatusCode ?? "") {
            case (200, "NoRoute"):
                failureReason = "No route could be found between the specified locations."
                recoverySuggestion = "Make sure it is possible to travel between the locations with the mode of transportation implied by the profileIdentifier option. For example, it is impossible to travel by car from one continent to another without either a land bridge or a ferry connection."
            case (200, "NoSegment"):
                failureReason = "A specified location could not be associated with a roadway or pathway."
                recoverySuggestion = "Make sure the locations are close enough to a roadway or pathway. Try setting the horizontalAccuracy property of the location property of all the waypoints to a negative value."
            case (404, "ProfileNotFound"):
                failureReason = "Unrecognized profile identifier."
                recoverySuggestion = "Make sure the profileIdentifier option is set to one of the provided constants, such as MBDirectionsProfileIdentifierAutomobile."
            case (429, _):
                if let timeInterval = response.allHeaderFields["x-rate-limit-interval"] as? NSTimeInterval, maximumCountOfRequests = response.allHeaderFields["x-rate-limit-limit"] as? UInt {
                    let components = NSDateComponents()
                    components.second = Int(round(timeInterval))
                    let formattedInterval = NSDateComponentsFormatter.localizedStringFromDateComponents(components, unitsStyle: .Full)
                    let formattedCount = NSNumberFormatter.localizedStringFromNumber(maximumCountOfRequests, numberStyle: .DecimalStyle)
                    failureReason = "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)."
                }
                if let rolloverTimestamp = response.allHeaderFields["x-rate-limit-reset"] as? Double {
                    let date = NSDate(timeIntervalSince1970: rolloverTimestamp)
                    let formattedDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .LongStyle, timeStyle: .FullStyle)
                    recoverySuggestion = "Wait until \(formattedDate) before retrying."
                }
            default:
                failureReason = json["message"] as? String
            }
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?? userInfo[NSLocalizedFailureReasonErrorKey] ?? NSHTTPURLResponse.localizedStringForStatusCode(error?.code ?? -1)
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion ?? userInfo[NSLocalizedRecoverySuggestionErrorKey]
        }
        userInfo[NSUnderlyingErrorKey] = error
        return NSError(domain: error?.domain ?? MBDirectionsErrorDomain, code: error?.code ?? -1, userInfo: userInfo)
    }
}
