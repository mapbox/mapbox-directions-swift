import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse?, NSError?) -> Void
internal typealias JSON = [String: AnyObject]

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

    internal init?(json: JSON) {
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
            if let jsonSteps = json["steps"] as? [JSON] {
                for jsonStep in jsonSteps {
                    if let routeStep = MBRouteStep(json: jsonStep) {
                        steps.append(routeStep)
                    }
                }
            }
            return steps
            }()
        self.distance = json["distance"] as! Double
        self.expectedTravelTime = json["duration"] as! Double
        self.summary = json["summary"] as! String
        self.geometry = {
            var points = [CLLocationCoordinate2D]()
            if let geometry = json["geometry"] as? JSON,
              let coordinates = geometry["coordinates"] as? [[Double]] {
                for coordinate in coordinates {
                    points.append(CLLocationCoordinate2D(latitude: coordinate[1], longitude: coordinate[0]))
                }
            }
            return points
            }()
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

        var serverRequestString = "https://api.mapbox.com/v4/directions/\(request.profileIdentifier)/\(self.request.sourceCoordinate.longitude),\(self.request.sourceCoordinate.latitude);\(self.request.destinationCoordinate.longitude),\(self.request.destinationCoordinate.latitude).json?access_token=\(self.accessToken)"

        if self.request.requestsAlternateRoutes {
            serverRequestString += "&alternatives=true"
        }

        let serverRequest = NSURLRequest(URL: NSURL(string: serverRequestString)!)

        self.calculating = true

        self.task = NSURLSession.sharedSession().dataTaskWithRequest(serverRequest) { [weak self] (data, response, error) in
            if let dataTaskSelf = self {
                dataTaskSelf.calculating = false

                if let data = data {
                    var parsedRoutes = [MBRoute]()
                    if let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? JSON,
                      let routes = json["routes"] as? [JSON] {
                        for route in routes {
                            if let origin = json["origin"] as? JSON,
                              let originProperties = origin["properties"] as? JSON,
                              let originName = originProperties["name"] as? String,
                              let originGeometry = origin["geometry"] as? JSON,
                              let originCoordinates = originGeometry["coordinates"] as? [Double],
                              let destination = json["destination"] as? JSON,
                              let destinationProperties = destination["properties"] as? JSON,
                              let destinationName = destinationProperties["name"] as? String,
                              let destinationGeometry = destination["geometry"] as? JSON,
                              let destinationCoordinates = destinationGeometry["coordinates"] as? [Double] {
                                let routeOrigin = MBPoint(name: originName,
                                    coordinate: CLLocationCoordinate2D(latitude: originCoordinates[1],
                                        longitude: originCoordinates[0]))
                                let routeDestination = MBPoint(name: destinationName,
                                    coordinate: CLLocationCoordinate2D(latitude: destinationCoordinates[1],
                                        longitude: destinationCoordinates[0]))
                                parsedRoutes.append(MBRoute(origin: routeOrigin, destination: routeDestination, json: route))
                            }
                        }
                        if !dataTaskSelf.cancelled {
                            dispatch_sync(dispatch_get_main_queue()) { [weak dataTaskSelf] in
                                if let completionSelf = dataTaskSelf {
                                    completionHandler(MBDirectionsResponse(sourceCoordinate: completionSelf.request.sourceCoordinate,
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
        self.task!.resume()
    }

    //    public func calculateETAWithCompletionHandler(MBETAHandler!)

    public func cancel() {
        self.cancelled = true
        self.task?.cancel()
    }

}
