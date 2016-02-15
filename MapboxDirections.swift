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

// MARK: - ETA Response

public class MBETAResponse {

    public let sourceCoordinate: CLLocationCoordinate2D
    public let waypointCoordinates: [CLLocationCoordinate2D]
    public let destinationCoordinate: CLLocationCoordinate2D
    public let expectedTravelTime: NSTimeInterval

    internal init(sourceCoordinate: CLLocationCoordinate2D, waypointCoordinates: [CLLocationCoordinate2D] = [], destinationCoordinate: CLLocationCoordinate2D, expectedTravelTime: NSTimeInterval) {
        self.sourceCoordinate = sourceCoordinate
        self.waypointCoordinates = waypointCoordinates
        self.destinationCoordinate = destinationCoordinate
        self.expectedTravelTime = expectedTravelTime
    }

}

// MARK: - Step

public class MBRouteStep {

    public enum Direction: String {
        case N = "N"
        case NE = "NE"
        case E = "E"
        case SE = "SE"
        case S = "S"
        case SW = "SW"
        case W = "W"
        case NW = "NW"
    }

    public enum ManeuverType: String {
        case Continue = "continue"
        case BearRight = "bear right"
        case TurnRight = "turn right"
        case SharpRight = "sharp right"
        case UTurn = "u-turn"
        case SharpLeft = "sharp left"
        case TurnLeft = "turn left"
        case BearLeft = "bear left"
        case Waypoint = "waypoint"
        case Depart = "depart"
        case EnterRoundabout = "enter roundabout"
        case Arrive = "arrive"
    }

    //    var polyline: MKPolyline! { get }
    internal(set) public var instructions: String! = ""
    //    var notice: String! { get }
    internal(set) public var distance: CLLocationDistance = 0
    public var transportType: MBDirectionsRequest.MBDirectionsTransportType {
        return MBDirectionsRequest.MBDirectionsTransportType(rawValue: profileIdentifier) ?? .Automobile
    }
    public let profileIdentifier: String

    // Mapbox-specific stuff
    internal(set) public var duration: NSTimeInterval?
    internal(set) public var way_name: String?
    internal(set) public var direction: Direction?
    internal(set) public var heading: CLLocationDirection?
    internal(set) public var maneuverType: ManeuverType?
    internal(set) public var maneuverLocation: CLLocationCoordinate2D?

    internal init?(json: JSON, profileIdentifier: String) {
        self.profileIdentifier = profileIdentifier
        if let maneuver = json["maneuver"] as? JSON,
          let instruction = maneuver["instruction"] as? String,
          let distance = json["distance"] as? Double,
          let duration = json["duration"] as? Double,
          let way_name = json["way_name"] as? String,
          let direction = json["direction"] as? String,
          let heading = json["heading"] as? Double,
          let type = maneuver["type"] as? String,
          let location = maneuver["location"] as? JSON,
          let coordinates = location["coordinates"] as? [Double] {
            self.instructions = instruction
            self.distance = distance
            self.duration = duration
            self.way_name = way_name
            self.direction = Direction(rawValue: direction)
            self.heading = heading
            self.maneuverType = ManeuverType(rawValue: type)!
            self.maneuverLocation = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
        } else {
            return nil
        }
    }

}

// MARK: - Route

public class MBRoute {

    //    var polyline: MKPolyline! { get }
    public let steps: [MBRouteStep]!
    //    var name: String! { get }
    //    var advisoryNotices: [AnyObject]! { get }
    public let distance: CLLocationDistance
    public let expectedTravelTime: NSTimeInterval
    public var transportType: MBDirectionsRequest.MBDirectionsTransportType {
        return MBDirectionsRequest.MBDirectionsTransportType(rawValue: profileIdentifier) ?? .Automobile
    }
    public let profileIdentifier: String

    // Mapbox-specific stuff
    public let summary: String
    public let geometry: [CLLocationCoordinate2D]

    public let origin: MBPoint
    public let waypoints: [MBPoint]
    public let destination: MBPoint

    internal init(origin: MBPoint, waypoints: [MBPoint] = [], destination: MBPoint, json: JSON, profileIdentifier: String) {
        self.origin = origin
        self.waypoints = waypoints
        self.destination = destination
        self.profileIdentifier = profileIdentifier
        if let jsonSteps = json["steps"] as? [JSON] {
            steps = jsonSteps.flatMap {
                MBRouteStep(json: $0, profileIdentifier: profileIdentifier)
            }
        } else {
            steps = []
        }
        self.distance = json["distance"] as! Double
        self.expectedTravelTime = json["duration"] as! Double
        self.summary = json["summary"] as! String
        if let jsonGeometry = json["geometry"] as? JSON, coordinates = jsonGeometry["coordinates"] as? [[Double]] {
            geometry = coordinates.map {
                CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
            }
        } else {
            geometry = []
        }
    }

}

// MARK: - Request

public class MBDirectionsRequest {

    public enum MBDirectionsTransportType: String {
        case Automobile = "mapbox.driving"
        case Walking    = "mapbox.walking"
        case Cycling    = "mapbox.cycling"
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
    
    private func URLRequestWithAccessToken(accessToken: String, includingGeometry includesGeometry: Bool, includingSteps includesSteps: Bool) -> NSURLRequest {
        let coordinates = [[sourceCoordinate], waypointCoordinates, [destinationCoordinate]].flatMap{$0}.map {
            "\($0.longitude),\($0.latitude)"
        }.joinWithSeparator(";")
        var serverRequestString = "https://api.mapbox.com/v4/directions/\(profileIdentifier)/\(coordinates).json?access_token=\(accessToken)"
        
        if !requestsAlternateRoutes {
            serverRequestString += "&alternatives=false"
        }
        if !includesGeometry {
            serverRequestString += "&geometry=false"
        }
        if !includesSteps {
            serverRequestString += "&steps=false"
        }
        
        return NSURLRequest(URL: NSURL(string: serverRequestString)!)
    }
}

// MARK: - Directions Response

public class MBDirectionsResponse {

    public let sourceCoordinate: CLLocationCoordinate2D
    public let waypointCoordinates: [CLLocationCoordinate2D]
    public let destinationCoordinate: CLLocationCoordinate2D
    public let routes: [MBRoute]!

    internal init(sourceCoordinate: CLLocationCoordinate2D, waypointCoordinates: [CLLocationCoordinate2D] = [], destinationCoordinate: CLLocationCoordinate2D, routes: [MBRoute]) {
        self.sourceCoordinate = sourceCoordinate
        self.waypointCoordinates = waypointCoordinates
        self.destinationCoordinate = destinationCoordinate
        self.routes = routes
    }

}

// MARK: - Manager

public class MBDirections: NSObject {

    private let request: MBDirectionsRequest
    private let accessToken: String
    private var task: NSURLSessionDataTask?
    private var calculating = false
    private(set) public var cancelled = false

    public init(request: MBDirectionsRequest, accessToken: String) {
        self.request = request
        self.accessToken = accessToken
        super.init()
    }

    public func calculateDirectionsWithCompletionHandler(completionHandler: MBDirectionsHandler) {

        cancelled = false

        let profileIdentifier = request.profileIdentifier
        let serverRequest = request.URLRequestWithAccessToken(accessToken, includingGeometry: true, includingSteps: true)

        calculating = true

        task = NSURLSession.sharedSession().dataTaskWithRequest(serverRequest) { [weak self] (data, response, error) in
            if let dataTaskSelf = self {
                dataTaskSelf.calculating = false

                if let data = data {
                    var parsedRoutes = [MBRoute]()
                    if let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? JSON,
                        routes = json["routes"] as? [JSON] {
                        for route in routes {
                            let waypoints = json["waypoints"] as? [JSON] ?? []
                            if let origin = json["origin"] as? JSON,
                                originProperties = origin["properties"] as? JSON,
                                originName = originProperties["name"] as? String,
                                originGeometry = origin["geometry"] as? JSON,
                                originCoordinates = originGeometry["coordinates"] as? [Double],
                                
                                destination = json["destination"] as? JSON,
                                destinationProperties = destination["properties"] as? JSON,
                                destinationName = destinationProperties["name"] as? String,
                                destinationGeometry = destination["geometry"] as? JSON,
                                destinationCoordinates = destinationGeometry["coordinates"] as? [Double] {
                                let waypointsCoordinates = waypoints.flatMap { $0["geometry"] as? JSON }.flatMap {
                                    $0["coordinates"] as? [Double]
                                }.map {
                                    MBPoint(name: nil, coordinate: CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]))
                                }
                                
                                let routeOrigin = MBPoint(name: originName,
                                    coordinate: CLLocationCoordinate2D(latitude: originCoordinates[1],
                                        longitude: originCoordinates[0]))
                                let routeDestination = MBPoint(name: destinationName,
                                    coordinate: CLLocationCoordinate2D(latitude: destinationCoordinates[1],
                                        longitude: destinationCoordinates[0]))
                                parsedRoutes.append(MBRoute(origin: routeOrigin, waypoints: waypointsCoordinates, destination: routeDestination, json: route, profileIdentifier: profileIdentifier))
                            }
                        }
                        if !dataTaskSelf.cancelled {
                            dispatch_sync(dispatch_get_main_queue()) { [weak dataTaskSelf] in
                                if let completionSelf = dataTaskSelf {
                                    completionHandler(MBDirectionsResponse(sourceCoordinate: completionSelf.request.sourceCoordinate,
                                        waypointCoordinates: completionSelf.request.waypointCoordinates,
                                        destinationCoordinate: completionSelf.request.destinationCoordinate, routes: parsedRoutes), nil)
                                }
                            }
                        }
                    }
                } else {
                    if !dataTaskSelf.cancelled {
                        dispatch_sync(dispatch_get_main_queue()) {
                            completionHandler(nil, error)
                        }
                    }
                }
            }
        }
        task!.resume()
    }

    public func calculateETAWithCompletionHandler(completionHandler: MBETAHandler) {
        cancelled = false
        
        let serverRequest = request.URLRequestWithAccessToken(accessToken, includingGeometry: false, includingSteps: false)
        
        calculating = true
        
        task = NSURLSession.sharedSession().dataTaskWithRequest(serverRequest) { [weak self] (data, response, error) in
            if let dataTaskSelf = self {
                dataTaskSelf.calculating = false
                if let data = data,
                    json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? JSON,
                    routes = json["routes"] as? [JSON] where !dataTaskSelf.cancelled {
                    let expectedTravelTime = routes.flatMap {
                        $0["duration"] as? NSTimeInterval
                    }.minElement()
                    if let expectedTravelTime = expectedTravelTime {
                        dispatch_sync(dispatch_get_main_queue()) { [weak dataTaskSelf] in
                            if let completionSelf = dataTaskSelf {
                                completionHandler(MBETAResponse(sourceCoordinate: completionSelf.request.sourceCoordinate,
                                    waypointCoordinates: completionSelf.request.waypointCoordinates,
                                    destinationCoordinate: completionSelf.request.destinationCoordinate, expectedTravelTime: expectedTravelTime), nil)
                            }
                        }
                    }
                } else if !dataTaskSelf.cancelled {
                    dispatch_sync(dispatch_get_main_queue()) {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task!.resume()
    }

    public func cancel() {
        self.cancelled = true
        self.task?.cancel()
    }

}
