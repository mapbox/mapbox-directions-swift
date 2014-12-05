import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse!, NSError!) -> Void

//public typealias MBETAHandler = (MBETAResponse!, NSError!) -> Void

public struct MBPoint {

    public var name: String
    public var coordinate: CLLocationCoordinate2D

}

public class MBETAResponse {

    private(set) var sourceCoordinate: CLLocationCoordinate2D
    private(set) var destinationCoordinate: CLLocationCoordinate2D
    private(set) var expectedTravelTime: NSTimeInterval

    internal init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, expectedTravelTime: NSTimeInterval) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.expectedTravelTime = expectedTravelTime
    }

}

public class MBRouteStep {

    enum Direction: String {
        case N = "N"
        case NE = "NE"
        case E = "E"
        case SE = "SE"
        case S = "S"
        case SW = "SW"
        case W = "W"
        case NW = "NW"
    }

    enum ManeuverType: String {
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
    private(set) var instructions: String
//    var notice: String! { get }
    private(set) var distance: CLLocationDistance?
//    var transportType: MKDirectionsTransportType { get }

    // Mapbox-specific stuff
    private(set) var duration: NSTimeInterval?
    private(set) var way_name: String?
    private(set) var direction: Direction?
    private(set) var heading: CLLocationDegrees?
    private(set) var maneuverType: ManeuverType
    private(set) var maneuverLocation: CLLocationCoordinate2D

    internal init(json: JSON) {
        self.instructions = json["maneuver"]["instruction"].stringValue
        self.distance = json["distance"].double
        self.duration = json["duration"].double
        self.way_name = json["way_name"].string
        if let directionString = json["direction"].string? {
            self.direction = Direction(rawValue: json["direction"].stringValue)
        }
        self.heading = json["heading"].double
        self.maneuverType = ManeuverType(rawValue: json["maneuver"]["type"].stringValue)!
        self.maneuverLocation = {
            let coordinates = json["maneuver"]["location"]["coordinates"].arrayValue
            let location = CLLocationCoordinate2D(latitude: coordinates[1].doubleValue, longitude: coordinates[0].doubleValue)
            return location
            }()
    }

}

public class MBRoute {

//    var polyline: MKPolyline! { get }
    private(set) var steps: [MBRouteStep]
//    var name: String! { get }
//    var advisoryNotices: [AnyObject]! { get }
    private(set) var distance: CLLocationDistance
    private(set) var expectedTravelTime: NSTimeInterval
//    var transportType: MKDirectionsTransportType { get }

    // Mapbox-specific stuff
    private(set) var summary: String
    private(set) var geometry: [CLLocationCoordinate2D]

    private(set) var origin: MBPoint
    private(set) var destination: MBPoint

    internal init(origin: MBPoint, destination: MBPoint, json: JSON) {
        self.origin = origin
        self.destination = destination
        self.steps = {
            var steps = [MBRouteStep]()
            for step: JSON in json["steps"].arrayValue {
                steps.append(MBRouteStep(json: step))
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

public class MBDirectionsRequest {

    public var sourceCoordinate: CLLocationCoordinate2D
    public var destinationCoordinate: CLLocationCoordinate2D
    public var requestsAlternateRoutes = false
//    var transportType: MBDirectionsTransportType
//    var departureDate: NSDate
//    var arrivalDate: NSDate

//    class func isDirectionsRequestURL
//    func initWithContentsOfURL

    init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
    }

}

public class MBDirectionsResponse {

    private(set) var sourceCoordinate: CLLocationCoordinate2D
    private(set) var destinationCoordinate: CLLocationCoordinate2D
    private(set) var routes: [MBRoute]

    internal init(sourceCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, routes: [MBRoute]) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.routes = routes
    }

}

public class MBDirections: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    private var request: MBDirectionsRequest
    private var accessToken: NSString
    private var task: NSURLSessionDataTask?
    private(set) var calculating = false

    init(request: MBDirectionsRequest, accessToken: NSString) {
        self.request = request
        self.accessToken = accessToken
        super.init()
    }

    func calculateDirectionsWithCompletionHandler(handler: MBDirectionsHandler!) {

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
                handler(MBDirectionsResponse(sourceCoordinate: self.request.sourceCoordinate, destinationCoordinate: self.request.destinationCoordinate, routes: parsedRoutes), nil)
            } else {
                handler(nil, error)
            }
        }
        self.task!.resume()
    }

//    func calculateETAWithCompletionHandler(MBETAHandler!) {
//
//    }

    func cancel() {
        self.task?.cancel()
    }

}
