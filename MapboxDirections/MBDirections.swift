typealias JSONDictionary = [String: AnyObject]

/// Indicates that an error occurred in MapboxDirections.
public let MBDirectionsErrorDomain = "MBDirectionsErrorDomain"

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken = NSBundle.mainBundle().objectForInfoDictionaryKey("MGLMapboxAccessToken") as? String

/// The user agent string for any HTTP requests performed directly within this library.
let userAgent: String = {
    var components: [String] = []
    
    if let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String {
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        components.append("\(appName)/\(version)")
    }
    
    let libraryBundle: NSBundle? = NSBundle(forClass: Directions.self)
    
    if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String, version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
        components.append("\(libraryName)/\(version)")
    }
    
    let system: String
    #if os(OSX)
        system = "OS X"
    #elseif os(iOS)
        system = "iOS"
    #elseif os(watchOS)
        system = "watchOS"
    #elseif os(tvOS)
        system = "tvOS"
    #elseif os(Linux)
        system = "Linux"
    #endif
    let systemVersion = NSProcessInfo().operatingSystemVersion
    components.append("\(system)/\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)")
    
    let chip: String
    #if arch(x86_64)
        chip = "x86_64"
    #elseif arch(arm)
        chip = "arm"
    #elseif arch(arm64)
        chip = "arm64"
    #elseif arch(i386)
        chip = "i386"
    #endif
    components.append("(\(chip))")
    
    return components.joinWithSeparator(" ")
}()

extension CLLocationCoordinate2D {
    /**
     Initializes a coordinate pair based on the given GeoJSON coordinates array.
     */
    internal init(geoJSON array: [Double]) {
        assert(array.count == 2)
        self.init(latitude: array[1], longitude: array[0])
    }
    
    /**
     Initializes a coordinate pair based on the given GeoJSON point object.
     */
    internal init(geoJSON point: JSONDictionary) {
        assert(point["type"] as? String == "Point")
        self.init(geoJSON: point["coordinates"] as! [Double])
    }
    
    internal static func coordinates(geoJSON lineString: JSONDictionary) -> [CLLocationCoordinate2D] {
        let type = lineString["type"] as? String
        assert(type == "LineString" || type == "Point")
        let coordinates = lineString["coordinates"] as! [[Double]]
        return coordinates.map { self.init(geoJSON: $0) }
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

/**
 A `Directions` object provides you with optimal directions between different locations, or waypoints. The directions object passes your request to the [Mapbox Directions API](https://www.mapbox.com/api-documentation/?language=Swift#directions) and returns the requested information to a closure (block) that you provide. A directions object can handle multiple simultaneous requests. A `RouteOptions` object specifies criteria for the results, such as intermediate waypoints, a mode of transportation, or the level of detail to be returned.
 
 Each result produced by the directions object is stored in a `Route` object. Depending on the `RouteOptions` object you provide, each route may include detailed information suitable for turn-by-turn directions, or it may include only high-level information such as the distance, estimated travel time, and name of each leg of the trip. The waypoints that form the request may be conflated with nearby locations, as appropriate; the resulting waypoints are provided to the closure.
 */
@objc(MBDirections)
public class Directions: NSObject {
    /**
     A closure (block) to be called when a directions request is complete.
     
     - parameter waypoints: An array of `Waypoint` objects. Each waypoint object corresponds to a `Waypoint` object in the original `RouteOptions` object. The locations and names of these waypoints are the result of conflating the original waypoints to known roads. The waypoints may include additional information that was not specified in the original waypoints.
        
        If the request was canceled or there was an error obtaining the routes, this parameter may be `nil`.
     - parameter routes: An array of `Route` objects. The preferred route is first; any alternative routes come next if the `RouteOptions` object’s `includesAlternativeRoutes` property was set to `true`. The preferred route depends on the route options object’s `profileIdentifier` property.
        
        If the request was canceled or there was an error obtaining the routes, this parameter is `nil`. This is not to be confused with the situation in which no results were found, in which case the array is present but empty.
     - parameter error: The error that occurred, or `nil` if the placemarks were obtained successfully.
     */
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
     - parameter host: An optional hostname to the server API. The [Mapbox Directions API](https://www.mapbox.com/api-documentation/?language=Swift#directions) endpoint is used by default.
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
     
     The directions object sends requests to the [Mapbox Directions API](https://www.mapbox.com/api-documentation/?language=Swift#directions) endpoint.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the directions object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    public convenience init(accessToken: String?) {
        self.init(accessToken: accessToken, host: nil)
    }
    
    // MARK: Getting Directions
    
    /**
     Begins asynchronously calculating the route or routes using the given options and delivers the results to a closure.
     
     This method retrieves the routes asynchronously over a network connection. If a connection error or server error occurs, details about the error are passed into the given completion handler in lieu of the routes.
     
     Routes may be displayed atop a [Mapbox map](https://www.mapbox.com/maps/). They may be cached but may not be stored permanently. To use the results in other contexts or store them permanently, [upgrade to a Mapbox enterprise plan](https://www.mapbox.com/directions/#pricing).
     
     - parameter options: A `RouteOptions` object specifying the requirements for the resulting routes.
     - parameter completionHandler: The closure (block) to call with the resulting routes. This closure is executed on the application’s main thread.
     - returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting routes, cancel this task.
     */
    public func calculateDirections(options options: RouteOptions, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        let url = URLForCalculatingDirections(options: options)
        let task = dataTaskWithURL(url, completionHandler: { (json) in
            let response = options.response(json: json)
            completionHandler(waypoints: response.0, routes: response.1, error: nil)
        }) { (error) in
            completionHandler(waypoints: nil, routes: nil, error: error)
        }
        task.resume()
        return task
    }
    
    /**
     Returns a URL session task for the given URL that will run the given closures on completion or error.
     
     - parameter url: The URL to request.
     - parameter completionHandler: The closure to call with the parsed JSON response dictionary.
     - parameter errorHandler: The closure to call when there is an error.
     - returns: The data task for the URL.
     - postcondition: The caller must resume the returned task.
     */
    private func dataTaskWithURL(url: NSURL, completionHandler: (json: JSONDictionary) -> Void, errorHandler: (error: NSError) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            var json: JSONDictionary = [:]
            if let data = data {
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDictionary
                } catch {
                    assert(false, "Invalid data")
                }
            }
            
            let apiStatusCode = json["code"] as? String
            let apiMessage = json["message"] as? String
            guard data != nil && error == nil && ((apiStatusCode == nil && apiMessage == nil) || apiStatusCode == "Ok") else {
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
     
     After requesting the URL returned by this method, you can parse the JSON data in the response and pass it into the `Route.init(json:waypoints:profileIdentifier:)` initializer.
     */
    public func URLForCalculatingDirections(options options: RouteOptions) -> NSURL {
        let params = options.params + [
            NSURLQueryItem(name: "access_token", value: accessToken),
        ]
        
        let unparameterizedURL = NSURL(string: options.path, relativeToURL: apiEndpoint)!
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
                recoverySuggestion = "Make sure the locations are close enough to a roadway or pathway. Try setting the coordinateAccuracy property of all the waypoints to a negative value."
            case (404, "ProfileNotFound"):
                failureReason = "Unrecognized profile identifier."
                recoverySuggestion = "Make sure the profileIdentifier option is set to one of the provided constants, such as MBDirectionsProfileIdentifierAutomobile."
            case (429, _):
                if let timeInterval = response.allHeaderFields["x-rate-limit-interval"] as? NSTimeInterval, maximumCountOfRequests = response.allHeaderFields["x-rate-limit-limit"] as? UInt {
                    let intervalFormatter = NSDateComponentsFormatter()
                    intervalFormatter.unitsStyle = .Full
                    let formattedInterval = intervalFormatter.stringFromTimeInterval(timeInterval)
                    let formattedCount = NSNumberFormatter.localizedStringFromNumber(maximumCountOfRequests, numberStyle: .DecimalStyle)
                    failureReason = "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)."
                }
                if let rolloverTimestamp = response.allHeaderFields["x-rate-limit-reset"] as? Double {
                    let date = NSDate(timeIntervalSince1970: rolloverTimestamp)
                    let formattedDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .LongStyle, timeStyle: .FullStyle)
                    recoverySuggestion = "Wait until \(formattedDate) before retrying."
                }
            default:
                // `message` is v4 or v5; `error` is v4
                failureReason = json["message"] as? String ?? json["error"] as? String
            }
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?? userInfo[NSLocalizedFailureReasonErrorKey] ?? NSHTTPURLResponse.localizedStringForStatusCode(error?.code ?? -1)
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion ?? userInfo[NSLocalizedRecoverySuggestionErrorKey]
        }
        userInfo[NSUnderlyingErrorKey] = error
        return NSError(domain: error?.domain ?? MBDirectionsErrorDomain, code: error?.code ?? -1, userInfo: userInfo)
    }
}
