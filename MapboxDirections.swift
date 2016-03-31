import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse?, NSError?) -> Void
public typealias MBETAHandler = (MBETAResponse?, NSError?) -> Void
internal typealias JSON = [String: AnyObject]

//public typealias MBETAHandler = (MBETAResponse?, NSError?) -> Void

// MARK: - Point

public class MBPoint {

    public let name: String?
    public let coordinate: CLLocationCoordinate2D

    internal init(name: String?, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }

}

private func CLLocationCoordinate2DFromJSONArray(array: [Double]) -> CLLocationCoordinate2D? {
    guard array.count == 2 else {
        return nil
    }
    
    return CLLocationCoordinate2D(latitude: array[1], longitude: array[0])
}

// MARK: - ETA Response

internal protocol MBResponse {
    var source: MBPoint { get }
    var waypoints: [MBPoint] { get }
    var destination: MBPoint { get }
}

public class MBETAResponse: MBResponse {
    public let source: MBPoint
    public let waypoints: [MBPoint]
    public let destination: MBPoint
    public let expectedTravelTime: NSTimeInterval

    internal init(source: MBPoint, waypoints: [MBPoint] = [], destination: MBPoint, expectedTravelTime: NSTimeInterval) {
        self.source = source
        self.waypoints = waypoints
        self.destination = destination
        self.expectedTravelTime = expectedTravelTime
    }
}

// MARK: - Step

public class MBRouteStep {
    public enum ManeuverType: String {
        case Turn = "turn"
        case PassNameChange = "new name"
        case PassWaypoint = "waypoint"
        case PassInformationalPoint = "suppressed"
        case Merge = "merge"
        case TakeRamp = "ramp"
        case ReachFork = "fork"
        case ReachEnd = "end of road"
        case EnterRoundabout = "enter roundabout"
        case ExitRoundabout = "exit roundabout"
        
        // Undocumented but present in API responses
        case Depart = "depart"
        case Arrive = "arrive"
        case Continue = "continue"
        
        init?(v4RawValue: String) {
            let rawValue: String
            switch v4RawValue {
            case "bear right", "turn right", "sharp right", "sharp left", "turn left", "bear left", "u-turn":
                rawValue = "turn"
            default:
                rawValue = v4RawValue
            }
            self.init(rawValue: rawValue)
        }
    }
    
    public enum ManeuverDirection: String {
        case UTurn = "uturn"
        case SharpRight = "sharp right"
        case Right = "right"
        case SlightRight = "slight right"
        case StraightAhead = "straight"
        case SlightLeft = "slight left"
        case Left = "left"
        case SharpLeft = "sharp left"
        
        init?(v4RawValue: String) {
            let rawValue: String
            switch v4RawValue {
            case "bear right", "bear left":
                rawValue = v4RawValue.stringByReplacingOccurrencesOfString("bear", withString: "slight")
            case "turn right", "turn left":
                rawValue = v4RawValue.stringByReplacingOccurrencesOfString("turn ", withString: "")
            case "u-turn":
                rawValue = "uturn"
            default:
                rawValue = v4RawValue
            }
            self.init(rawValue: rawValue)
        }
    }

    //    var polyline: MKPolyline! { get }
    public let instructions: String
    //    var notice: String! { get }
    public let distance: CLLocationDistance
    public let transportType: MBDirectionsRequest.MBDirectionsTransportType
    public let profileIdentifier: String

    // Mapbox-specific stuff
    public let geometry: [CLLocationCoordinate2D]?
    public let duration: NSTimeInterval
    public let name: String?
    public let initialHeading: CLLocationDirection?
    public let finalHeading: CLLocationDirection?
    public let maneuverType: ManeuverType
    public let maneuverDirection: ManeuverDirection?
    public let maneuverLocation: CLLocationCoordinate2D
    public let exitIndex: NSInteger?

    internal init(json: JSON, profileIdentifier: String, version: MBDirectionsRequest.APIVersion) {
        self.profileIdentifier = profileIdentifier
        if let mode = json["mode"] as? String {
            transportType = MBDirectionsRequest.MBDirectionsTransportType(rawValue: "mapbox/\(mode)") ?? .Automobile
        } else {
            transportType = MBDirectionsRequest.MBDirectionsTransportType(rawValue: profileIdentifier) ?? .Automobile
        }
        
        let maneuver = json["maneuver"] as! JSON
        instructions = maneuver["instruction"] as? String ?? "" // mapbox/api-directions#515
        
        distance = json["distance"] as? Double ?? 0
        duration = json["duration"] as? Double ?? 0
        
        switch version {
        case .Four:
            initialHeading = nil
            finalHeading = json["heading"] as? Double
            maneuverType = ManeuverType(v4RawValue: maneuver["type"] as! String)!
            maneuverDirection = ManeuverDirection(v4RawValue: maneuver["type"] as! String)
            exitIndex = nil
            
            let location = maneuver["location"] as! JSON
            let coordinates = location["coordinates"] as! [Double]
            maneuverLocation = CLLocationCoordinate2DFromJSONArray(coordinates)!
            
            name = json["way_name"] as? String
            
            geometry = nil
        case .Five:
            initialHeading = maneuver["bearing_before"] as? Double
            finalHeading = maneuver["bearing_after"] as? Double
            maneuverType = ManeuverType(rawValue: maneuver["type"] as! String)!
            maneuverDirection = ManeuverDirection(rawValue: maneuver["modifier"] as? String ?? "")
            exitIndex = maneuver["exit"] as? Int
            
            name = json["name"] as? String
            
            let location = maneuver["location"] as! [Double]
            maneuverLocation = CLLocationCoordinate2DFromJSONArray(location)!
            
            let jsonGeometry = json["geometry"] as? JSON
            let coordinates = jsonGeometry?["coordinates"] as? [[Double]] ?? []
            geometry = coordinates.flatMap(CLLocationCoordinate2DFromJSONArray)
        }
    }
}

// MARK: - Leg

public class MBRouteLeg {
//    var polyline: MKPolyline! { get }
    public let steps: [MBRouteStep]
    public let name: String
//    var advisoryNotices: [AnyObject]! { get }
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public var transportType: MBDirectionsRequest.MBDirectionsTransportType {
        return MBDirectionsRequest.MBDirectionsTransportType(rawValue: profileIdentifier) ?? .Automobile
    }
    public let profileIdentifier: String

    public let source: MBPoint
    public let destination: MBPoint

    internal init(source: MBPoint, destination: MBPoint, json: JSON, profileIdentifier: String, version: MBDirectionsRequest.APIVersion) {
        self.source = source
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        steps = (json["steps"] as? [JSON] ?? []).map {
            MBRouteStep(json: $0, profileIdentifier: profileIdentifier, version: version)
        }
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        name = json["summary"] as! String
    }
}

// MARK: - Route

public class MBRoute {
//    var polyline: MKPolyline! { get }
    public let legs: [MBRouteLeg]
//    public let name: String
//    var advisoryNotices: [AnyObject]! { get }
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public var transportType: MBDirectionsRequest.MBDirectionsTransportType {
        return MBDirectionsRequest.MBDirectionsTransportType(rawValue: profileIdentifier) ?? .Automobile
    }
    public let profileIdentifier: String

    // Mapbox-specific stuff
    public let geometry: [CLLocationCoordinate2D]

    public let source: MBPoint
    public let waypoints: [MBPoint]
    public let destination: MBPoint

    internal init(source: MBPoint, waypoints: [MBPoint] = [], destination: MBPoint, json: JSON, profileIdentifier: String, version: MBDirectionsRequest.APIVersion) {
        self.source = source
        self.waypoints = waypoints
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        
        switch version {
        case .Four:
            legs = [MBRouteLeg(source: source, destination: destination, json: json, profileIdentifier: profileIdentifier, version: version)]
        case .Five:
            // Associate each leg JSON with an origin and destination. The sequence
            // of destinations is offset by one from the sequence of origins.
            let legInfo = zip(zip([source] + waypoints, waypoints + [destination]),
                              json["legs"] as? [JSON] ?? [])
            legs = legInfo.map { (endpoints, json) -> MBRouteLeg in
                MBRouteLeg(source: endpoints.0, destination: endpoints.1, json: json, profileIdentifier: profileIdentifier, version: version)
            }
        }
        
        distance = json["distance"] as! Double
        expectedTravelTime = json["duration"] as! Double
        let jsonGeometry = json["geometry"] as? JSON
        let coordinates = jsonGeometry?["coordinates"] as? [[Double]] ?? []
        geometry = coordinates.flatMap(CLLocationCoordinate2DFromJSONArray)
    }
}

// MARK: - Request

public class MBDirectionsRequest {
    public enum APIVersion: UInt {
        case Four = 4
        case Five = 5
    }
    public var version: APIVersion = .Five
    
    public enum MBDirectionsTransportType: String {
        case Automobile = "mapbox/driving"
        case Walking    = "mapbox/walking"
        case Cycling    = "mapbox/cycling"
//        case Any        = ""
    }

    public let sourceCoordinate: CLLocationCoordinate2D
    public let waypointCoordinates: [CLLocationCoordinate2D]
    public let destinationCoordinate: CLLocationCoordinate2D
    public var requestsAlternateRoutes = false
    public var transportType: MBDirectionsTransportType {
        get {
            return MBDirectionsTransportType(rawValue: profileIdentifier) ?? .Automobile
        }
        set {
            profileIdentifier = newValue.rawValue
        }
    }
    public var profileIdentifier: String = MBDirectionsTransportType.Automobile.rawValue
    //    var departureDate: NSDate!
    //    var arrivalDate: NSDate!

    //    class func isDirectionsRequestURL
    //    func initWithContentsOfURL

    public init(sourceCoordinate: CLLocationCoordinate2D, waypointCoordinates: [CLLocationCoordinate2D] = [], destinationCoordinate: CLLocationCoordinate2D) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.waypointCoordinates = waypointCoordinates
    }
}

// MARK: - Directions Response

public class MBDirectionsResponse: MBResponse {
    public let source: MBPoint
    public let waypoints: [MBPoint]
    public let destination: MBPoint
    public let routes: [MBRoute]

    internal init(source: MBPoint, waypoints: [MBPoint] = [], destination: MBPoint, routes: [MBRoute]) {
        self.source = source
        self.waypoints = waypoints
        self.destination = destination
        self.routes = routes
    }
}

// MARK: - Manager

public let MBDirectionsErrorDomain = "MBDirectionsErrorDomain"

public enum MBDirectionsErrorCode: UInt {
    case DirectionsNotFound = 200
    case ProfileNotFound = 404
    case InvalidInput = 422
}

public class MBDirections: NSObject {

    private let request: MBDirectionsRequest
    private let configuration: MBDirectionsConfiguration
    private var task: NSURLSessionDataTask?
    public var calculating = false
    private(set) public var cancelled = false

    public init(request: MBDirectionsRequest, accessToken: String) {
        self.request = request
        configuration = MBDirectionsConfiguration(accessToken)
        super.init()
    }

    public func calculateDirectionsWithCompletionHandler(completionHandler: MBDirectionsHandler) {
        cancelled = false
        
        var profileIdentifier = request.profileIdentifier
        let waypoints = [[request.sourceCoordinate], request.waypointCoordinates, [request.destinationCoordinate]].flatMap{ $0 }.map { MBDirectionsWaypoint(coordinate: $0, accuracy: nil, heading: nil) }
        let version = request.version
        let router: MBDirectionsRouter
        switch version {
        case .Four:
            profileIdentifier = profileIdentifier.stringByReplacingOccurrencesOfString("/", withString: ".")
            router = MBDirectionsRouter.V4(configuration, profileIdentifier, waypoints, request.requestsAlternateRoutes, nil, nil, nil)
        case .Five:
            router = MBDirectionsRouter.V5(configuration, profileIdentifier, waypoints, request.requestsAlternateRoutes, .GeoJSON, .Full, true, nil)
        }
        
        calculating = true
        
        task = taskWithRouter(router, completionHandler: { (source, waypoints, destination, routes, error) in
            let response = MBDirectionsResponse(source: source, waypoints: Array(waypoints), destination: destination, routes: routes.map {
                MBRoute(source: source, waypoints: Array(waypoints), destination: destination, json: $0, profileIdentifier: profileIdentifier, version: version)
            })
            completionHandler(response, nil)
        }, errorHandler: { (error) in
            completionHandler(nil, error)
        })
    }

    public func calculateETAWithCompletionHandler(completionHandler: MBETAHandler) {
        cancelled = false
        
        let waypoints = [[request.sourceCoordinate], request.waypointCoordinates, [request.destinationCoordinate]].flatMap{ $0 }.map { MBDirectionsWaypoint(coordinate: $0, accuracy: nil, heading: nil) }
        let router: MBDirectionsRouter
        switch request.version {
        case .Four:
            let profileIdentifier = request.profileIdentifier.stringByReplacingOccurrencesOfString("/", withString: ".")
            router = MBDirectionsRouter.V4(configuration, profileIdentifier, waypoints, false, nil, .None, false)
        case .Five:
            router = MBDirectionsRouter.V5(configuration, request.profileIdentifier, waypoints, false, .GeoJSON, .None, false, nil)
        }
        
        calculating = true
        
        task = taskWithRouter(router, completionHandler: { (source, waypoints, destination, routes, error) in
            let expectedTravelTime = routes.flatMap {
                $0["duration"] as? NSTimeInterval
            }.minElement()
            if let expectedTravelTime = expectedTravelTime {
                let response = MBETAResponse(source: source, waypoints: waypoints, destination: destination, expectedTravelTime: expectedTravelTime)
                completionHandler(response, nil)
            } else {
                completionHandler(nil, nil)
            }
        }, errorHandler: { (error) in
            completionHandler(nil, error)
        })
    }
    
    internal func taskWithRouter(router: MBDirectionsRouter, completionHandler completion: (MBPoint, [MBPoint], MBPoint, [JSON], NSError?) -> Void, errorHandler: (NSError?) -> Void) -> NSURLSessionDataTask? {
        return router.loadJSON(JSON.self) { [weak self] (json, error) in
            guard let dataTaskSelf = self where !dataTaskSelf.cancelled else {
                return
            }
            dataTaskSelf.calculating = false
            
            guard error == nil && json != nil else {
                dispatch_sync(dispatch_get_main_queue()) {
                    errorHandler(error as? NSError)
                }
                return
            }
            
            let version: MBDirectionsRequest.APIVersion
            var errorMessage: String? = nil
            switch router {
            case .V4:
                version = .Four
                errorMessage = json!["error"] as? String
            case .V5:
                version = .Five
                if json!["code"] as? String != "ok" {
                    errorMessage = json!["message"] as! String
                }
            }
            
            guard errorMessage == nil else {
                let userInfo = [
                    NSLocalizedFailureReasonErrorKey: errorMessage!,
                ]
                let apiError = NSError(domain: MBDirectionsErrorDomain, code: 200, userInfo: userInfo)
                dispatch_sync(dispatch_get_main_queue()) {
                    errorHandler(apiError)
                }
                return
            }
            
            let routes = json!["routes"] as! [JSON]
            let points: [MBPoint]
            switch version {
            case .Four:
                let origin = json!["origin"] as! JSON
                let originProperties = origin["properties"] as! JSON
                let originGeometry = origin["geometry"] as! JSON
                let originCoordinate = CLLocationCoordinate2DFromJSONArray(originGeometry["coordinates"] as! [Double])!
                let originPoint = MBPoint(name: originProperties["name"] as? String, coordinate: originCoordinate)
                
                let destination = json!["destination"] as! JSON
                let destinationProperties = destination["properties"] as! JSON
                let destinationGeometry = destination["geometry"] as! JSON
                let destinationCoordinate = CLLocationCoordinate2DFromJSONArray(destinationGeometry["coordinates"] as! [Double])!
                let destinationPoint = MBPoint(name: destinationProperties["name"] as? String, coordinate: destinationCoordinate)
                
                let waypoints = json!["waypoints"] as? [JSON] ?? []
                let waypointPoints = waypoints.flatMap { $0["geometry"] as? JSON }.flatMap {
                    CLLocationCoordinate2DFromJSONArray($0["coordinates"] as! [Double])
                }.map {
                    MBPoint(name: nil, coordinate: $0)
                }
                
                points = [[originPoint], waypointPoints, [destinationPoint]].flatMap{ $0 }
            case .Five:
                points = (json!["waypoints"] as? [JSON] ?? []).map { waypoint -> MBPoint in
                    let location = waypoint["location"] as! [Double]
                    let coordinate = CLLocationCoordinate2DFromJSONArray(location)!
                    return MBPoint(name: waypoint["name"] as? String, coordinate: coordinate)
                }
            }
            
            let source = points.first!
            let destination = points.last!
            var waypoints = points.suffixFrom(1)
            waypoints = waypoints.prefixUpTo(waypoints.count)
            
            dispatch_sync(dispatch_get_main_queue()) {
                completion(source, Array(waypoints), destination, routes, error as? NSError)
            }
        }
    }

    public func cancel() {
        self.cancelled = true
        self.task?.cancel()
    }

}
