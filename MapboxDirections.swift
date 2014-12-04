import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse!, NSError!) -> Void

//public typealias MBETAHandler = (MBETAResponse!, NSError!) -> Void

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

//    var polyline: MKPolyline! { get }
    private(set) var instructions: String
//    var notice: String! { get }
    private(set) var distance: CLLocationDistance
//    var transportType: MKDirectionsTransportType { get }

    internal init(instructions: String, distance: CLLocationDistance) {
        self.instructions = instructions
        self.distance = distance
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

    internal init(steps: [MBRouteStep], distance: CLLocationDistance, expectedTravelTime: NSTimeInterval) {
        self.steps = steps
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
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
                    var parsedSteps = [MBRouteStep]()
                    for step: JSON in route["steps"].arrayValue {
                        parsedSteps.append(MBRouteStep(instructions: step["maneuver"]["instruction"].stringValue, distance: step["distance"].doubleValue))
                    }
                    parsedRoutes.append(MBRoute(steps: parsedSteps, distance: route["distance"].doubleValue, expectedTravelTime: route["duration"].doubleValue))
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
