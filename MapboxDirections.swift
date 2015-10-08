import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse?, NSError?) -> Void

//public typealias MBETAHandler = (MBETAResponse?, NSError?) -> Void

// MARK: - Point

public class MBPoint {

    public let name: String
    public let coordinate: CLLocationCoordinate2D

    internal init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }

}

// MARK: - ETA Response

public class MBETAResponse {

    public let sourceCoordinate: CLLocationCoordinate2D
    public let destinationCoordinate: CLLocationCoordinate2D
    public let expectedTravelTime: NSTimeInterval

    internal init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, expectedTravelTime: NSTimeInterval) {
        self.sourceCoordinate = sourceCoordinate
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
    //    var transportType: MKDirectionsTransportType { get }

    // Mapbox-specific stuff
    internal(set) public var duration: NSTimeInterval?
    internal(set) public var way_name: String?
    internal(set) public var direction: Direction?
    internal(set) public var heading: CLLocationDirection?
    internal(set) public var maneuverType: ManeuverType?
    internal(set) public var maneuverLocation: CLLocationCoordinate2D?

    internal init?(json: [String: AnyObject]) {
        if let
            maneuver = json["maneuver"] as? [String: AnyObject],
            instruction = maneuver["instruction"] as? String,
            distance = json["distance"] as? Double,
            duration = json["duration"] as? Double,
            wayName = json["way_name"] as? String,
            direction = json["direction"] as? String,
            heading = json["heading"] as? Double,
            maneuverType = (maneuver["type"] as? String).flatMap({ ManeuverType(rawValue: $0) }),
            coordinates = json["location"]?["coordinates"] as? [Double] {
                self.instructions = instruction
                self.distance = distance
                self.duration = duration
                self.way_name = wayName
                self.direction = Direction(rawValue: direction)
                self.heading = heading
                self.maneuverType = maneuverType
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
    //    var transportType: MKDirectionsTransportType { get }

    // Mapbox-specific stuff
    public let summary: String
    public let geometry: [CLLocationCoordinate2D]

    public let origin: MBPoint
    public let destination: MBPoint

    internal init(origin: MBPoint, destination: MBPoint, json: [String: AnyObject]) {
        self.origin = origin
        self.destination = destination
        self.steps = {
            var steps = [MBRouteStep]()
            for step in json["steps"] as! [[String: AnyObject]] {
                if let routeStep = MBRouteStep(json: step) {
                    steps.append(routeStep)
                }
            }
            return steps
            }()
        self.distance = json["distance"] as! Double
        self.expectedTravelTime = json["duration"] as! Double
        self.summary = json["summary"] as! String
        let geometryDict = json["geometry"] as! [String: AnyObject]
        let coordinates = geometryDict["coordinates"] as! [[CLLocationDegrees]]
        self.geometry = coordinates.map { point in
            return CLLocationCoordinate2D(latitude: point[1], longitude: point[0])
        }
    }

}

// MARK: - Request

public class MBDirectionsRequest {

    public enum MBDirectionsTransportType: String {
        case Automobile = "driving"
        case Walking    = "walking"
        case Cycling    = "cycling"
        case Any        = ""
    }

    public let sourceCoordinate: CLLocationCoordinate2D
    public let destinationCoordinate: CLLocationCoordinate2D
    public var requestsAlternateRoutes = false
    public var transportType = MBDirectionsTransportType.Automobile
    //    var departureDate: NSDate!
    //    var arrivalDate: NSDate!

    //    class func isDirectionsRequestURL
    //    func initWithContentsOfURL

    public init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
    }

}

// MARK: - Directions Response

public class MBDirectionsResponse {

    public let sourceCoordinate: CLLocationCoordinate2D
    public let destinationCoordinate: CLLocationCoordinate2D
    public let routes: [MBRoute]!

    internal init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, routes: [MBRoute]) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.routes = routes
    }

}

// MARK: - Manager

public class MBDirections: NSObject {

    private let request: MBDirectionsRequest
    private let accessToken: NSString
    private var task: NSURLSessionDataTask?
    private var calculating = false
    private(set) public var cancelled = false

    public init(request: MBDirectionsRequest, accessToken: String) {
        self.request = request
        self.accessToken = accessToken
        super.init()
    }

    public func calculateDirectionsWithCompletionHandler(completionHandler: MBDirectionsHandler) {

        self.cancelled = false

        var endpoint: String

        var serverRequestString = "http://api.mapbox.com/v4/directions/mapbox.\(request.transportType.rawValue)/\(self.request.sourceCoordinate.longitude),\(self.request.sourceCoordinate.latitude);\(self.request.destinationCoordinate.longitude),\(self.request.destinationCoordinate.latitude).json?access_token=\(self.accessToken)"

        if (self.request.requestsAlternateRoutes) {
            serverRequestString += "&alternatives=true"
        }

        let serverRequest = NSURLRequest(URL: NSURL(string: serverRequestString)!)

        self.calculating = true

        self.task = NSURLSession.sharedSession().dataTaskWithRequest(serverRequest) { [weak self] (data, response, error) in
            if let dataTaskSelf = self {
                dataTaskSelf.calculating = false

                if let error = error where !dataTaskSelf.cancelled {
                    dispatch_sync(dispatch_get_main_queue()) {
                        completionHandler(nil, error)
                    }
                    return
                }
                var parsedRoutes = [MBRoute]()
                if let
                    json = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as? [String: AnyObject],
                    origin = json["origin"] as? [String: AnyObject],
                    destination = json["destination"] as? [String: AnyObject] {

                        let origin = MBPoint(name: origin["properties"]!["name"] as! String,
                            coordinate: {
                                let coordinates = origin["geometry"]!["coordinates"] as! [Double]
                                return CLLocationCoordinate2D(latitude: coordinates[1],
                                    longitude: coordinates[0])
                                }())
                        let destination = MBPoint(name: destination["properties"]!["name"] as! String,
                            coordinate: {
                                let coordinates = destination["geometry"]!["coordinates"] as! [Double]
                                return CLLocationCoordinate2D(latitude: coordinates[1],
                                    longitude: coordinates[0])
                                }())
                        for route in json["routes"] as! [[String: AnyObject]] {
                            parsedRoutes.append(MBRoute(origin: origin, destination: destination, json: route))
                        }
                        if !dataTaskSelf.cancelled {
                            dispatch_sync(dispatch_get_main_queue()) {
                                completionHandler(MBDirectionsResponse(sourceCoordinate: dataTaskSelf.request.sourceCoordinate,
                                    destinationCoordinate: dataTaskSelf.request.destinationCoordinate, routes: parsedRoutes), nil)
                            }
                        }
                }
            }
        }
        self.task!.resume()
    }

    //    public func calculateETAWithCompletionHandler(MBETAHandler!)

    public func cancel() {
        self.cancelled = true
        self.task?.cancel()
    }

}
