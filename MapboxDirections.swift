import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse!, NSError!) -> Void // FIXME ObjC

//public typealias MBETAHandler = (MBETAResponse!, NSError!) -> Void // FIXME ObjC

// MARK: - Point

@objc public class MBPoint {

    public let name: String
    public let coordinate: CLLocationCoordinate2D

    internal init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }

}

// MARK: - ETA Response

@objc public class MBETAResponse {

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

@objc public class MBRouteStep {

    public enum Direction: String { // FIXME ObjC
        case N = "N"
        case NE = "NE"
        case E = "E"
        case SE = "SE"
        case S = "S"
        case SW = "SW"
        case W = "W"
        case NW = "NW"
    }

    public enum ManeuverType: String { // FIXME ObjC
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
    private(set) var instructions: String! = ""
//    var notice: String! { get }
    private(set) var distance: CLLocationDistance = 0
//    var transportType: MKDirectionsTransportType { get }

    // Mapbox-specific stuff
    private(set) var duration: NSTimeInterval? = nil
    private(set) var way_name: String? = nil
    private(set) var direction: Direction? = nil
    private(set) var heading: CLLocationDegrees? = nil
    private(set) var maneuverType: ManeuverType? = nil
    private(set) var maneuverLocation: CLLocationCoordinate2D? = nil

    internal init?(json: JSON) {
        var valid = false
        if (json["maneuver"]["instruction"].string != nil) {
            if (json["distance"].double != nil) {
                if (json["duration"].double != nil) {
                    if (json["way_name"].string != nil) {
                        if (json["direction"].string != nil) {
                            if (json["heading"].double != nil) {
                                if (json["maneuver"]["type"].string != nil) {
                                    if (json["maneuver"]["location"]["coordinates"].array != nil) {
                                        valid = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if (valid) {
            self.instructions = json["maneuver"]["instruction"].stringValue
            self.distance = json["distance"].doubleValue
            self.duration = json["duration"].doubleValue
            self.way_name = json["way_name"].stringValue
            self.direction = Direction(rawValue: json["direction"].stringValue)
            self.heading = json["heading"].doubleValue
            self.maneuverType = ManeuverType(rawValue: json["maneuver"]["type"].stringValue)!
            self.maneuverLocation = {
                let coordinates = json["maneuver"]["location"]["coordinates"].arrayValue
                let location = CLLocationCoordinate2D(latitude: coordinates[1].doubleValue, longitude: coordinates[0].doubleValue)
                return location
                }()
        } else {
            return nil
        }
    }

}

// MARK: - Route

@objc public class MBRoute {

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

    internal init(origin: MBPoint, destination: MBPoint, json: JSON) {
        self.origin = origin
        self.destination = destination
        self.steps = {
            var steps = [MBRouteStep]()
            for step: JSON in json["steps"].arrayValue {
                if let routeStep = MBRouteStep(json: step) {
                    steps.append(routeStep)
                }
            }
            return steps
            }()
        self.distance = json["distance"].doubleValue
        self.expectedTravelTime = json["duration"].doubleValue
        self.summary = json["summary"].stringValue
        self.geometry = {
            var points = [CLLocationCoordinate2D]()
            for point: JSON in json["geometry"]["coordinates"].arrayValue {
                points.append(CLLocationCoordinate2D(latitude: point.arrayValue[1].doubleValue, longitude: point.arrayValue[0].doubleValue))
            }
            return points
            }()
    }

}

// MARK: - Request

@objc public class MBDirectionsRequest {

    public let sourceCoordinate: CLLocationCoordinate2D!
    public let destinationCoordinate: CLLocationCoordinate2D!
    public var requestsAlternateRoutes = false
//    var transportType: MBDirectionsTransportType
//    var departureDate: NSDate!
//    var arrivalDate: NSDate!

//    class func isDirectionsRequestURL
//    func initWithContentsOfURL

    init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
    }

}

// MARK: - Directions Response

@objc public class MBDirectionsResponse {

    public let sourceCoordinate: CLLocationCoordinate2D!
    public let destinationCoordinate: CLLocationCoordinate2D!
    public let routes: [MBRoute]!

    internal init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, routes: [MBRoute]) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.routes = routes
    }

}

// MARK: - Manager

public class MBDirections: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    private let request: MBDirectionsRequest
    private let accessToken: NSString
    private var task: NSURLSessionDataTask?
    private(set) public var calculating = false
    private(set) public var cancelled = false

    init!(request: MBDirectionsRequest!, accessToken: String) {
        self.request = request
        self.accessToken = accessToken
        super.init()
    }

    func calculateDirectionsWithCompletionHandler(handler: MBDirectionsHandler!) {

        self.cancelled = false

        var serverRequestString = "http://api.tiles.mapbox.com/v4/directions/mapbox.driving/\(self.request.sourceCoordinate.longitude),\(self.request.sourceCoordinate.latitude);\(self.request.destinationCoordinate.longitude),\(self.request.destinationCoordinate.latitude).json?access_token=\(self.accessToken)"

        if (self.request.requestsAlternateRoutes) {
            serverRequestString += "&alternatives=true"
        }

        let serverRequest = NSURLRequest(URL: NSURL(string: serverRequestString)!)

        self.calculating = true

        self.task = NSURLSession.sharedSession().dataTaskWithRequest(serverRequest) { [unowned self] (data, response, error) in

            self.calculating = false

            if (error == nil) {
                var parsedRoutes = [MBRoute]()
                let json = JSON(data: data)
                for route: JSON in json["routes"].arrayValue {
                    let origin = MBPoint(name: json["origin"]["properties"]["name"].stringValue,
                        coordinate: {
                            let coordinates = json["origin"]["geometry"]["coordinates"].arrayValue
                            return CLLocationCoordinate2D(latitude: coordinates[1].doubleValue,
                                longitude: coordinates[0].doubleValue)
                            }())
                    let destination = MBPoint(name: json["destination"]["properties"]["name"].stringValue,
                        coordinate: {
                            let coordinates = json["destination"]["geometry"]["coordinates"].arrayValue
                            return CLLocationCoordinate2D(latitude: coordinates[1].doubleValue,
                                longitude: coordinates[0].doubleValue)
                            }())
                    parsedRoutes.append(MBRoute(origin: origin, destination: destination, json: route))
                }
                if (!self.cancelled) {
                    dispatch_sync(dispatch_get_main_queue()) { [unowned self] in
                        handler(MBDirectionsResponse(sourceCoordinate: self.request.sourceCoordinate, destinationCoordinate: self.request.destinationCoordinate, routes: parsedRoutes), nil)
                    }
                }
            } else {
                if (!self.cancelled) {
                    dispatch_sync(dispatch_get_main_queue()) {
                        handler(nil, error)
                    }
                }
            }
        }
        self.task!.resume()
    }

//    func calculateETAWithCompletionHandler(MBETAHandler!)

    func cancel() {
        self.cancelled = true
        self.task?.cancel()
    }

}
