import Foundation
import CoreLocation

public typealias MBDirectionsHandler = (MBDirectionsResponse?, NSError?) -> Void
public typealias MBETAHandler = (MBETAResponse?, NSError?) -> Void
internal typealias JSON = [String: AnyObject]

public let MBDirectionsErrorDomain = "MBDirectionsErrorDomain"

public enum MBDirectionsErrorCode: UInt {
    case DirectionsNotFound = 200
    case ProfileNotFound = 404
    case InvalidInput = 422
}

public class MBPoint {

    public let name: String?
    public let coordinate: CLLocationCoordinate2D

    internal init(name: String?, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }

}

extension CLLocationCoordinate2D {
    internal init(JSONArray array: [Double]) {
        assert(array.count == 2)
        self.init(latitude: array[1], longitude: array[0])
    }
}

public class MBDirections: NSObject {

    private let request: MBDirectionsRequest
    private let configuration: MBDirectionsConfiguration
    private var task: NSURLSessionDataTask?
    public var calculating: Bool {
        return task?.state == .Running
    }
    
    private var errorForSimultaneousRequests: NSError {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: "Cannot calculate directions on an MBDirections object that is already calculating.",
        ]
        return NSError(domain: MBDirectionsErrorDomain, code: -1, userInfo: userInfo)
    }

    public init(request: MBDirectionsRequest, accessToken: String) {
        self.request = request
        configuration = MBDirectionsConfiguration(accessToken)
        super.init()
    }

    public func calculateDirectionsWithCompletionHandler(completionHandler: MBDirectionsHandler) {
        guard !calculating else {
            completionHandler(nil, errorForSimultaneousRequests)
            return
        }
        
        var profileIdentifier = request.profileIdentifier
        let version = request.version
        let router: MBDirectionsRouter
        switch version {
        case .Four:
            profileIdentifier = profileIdentifier.stringByReplacingOccurrencesOfString("/", withString: ".")
            router = MBDirectionsRouter.V4(configuration, profileIdentifier, waypointsForDirections, request.requestsAlternateRoutes, nil, .Polyline, nil)
        case .Five:
            router = MBDirectionsRouter.V5(configuration, profileIdentifier, waypointsForDirections, request.requestsAlternateRoutes, .Polyline, .Full, true, nil)
        }
        
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
        guard !calculating else {
            completionHandler(nil, errorForSimultaneousRequests)
            return
        }
        
        let router: MBDirectionsRouter
        switch request.version {
        case .Four:
            let profileIdentifier = request.profileIdentifier.stringByReplacingOccurrencesOfString("/", withString: ".")
            router = MBDirectionsRouter.V4(configuration, profileIdentifier, waypointsForDirections, false, nil, .None, false)
        case .Five:
            router = MBDirectionsRouter.V5(configuration, request.profileIdentifier, waypointsForDirections, false, .GeoJSON, .None, false, nil)
        }
        
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
    
    private var waypointsForDirections: [MBDirectionsWaypoint] {
        var sourceHeading: MBDirectionsWaypoint.Heading? = nil
        if let heading = request.sourceHeading {
            sourceHeading = MBDirectionsWaypoint.Heading(heading: heading, headingAccuracy: 90)
        }
        let intermediateWaypoints = request.waypointCoordinates.map { MBDirectionsWaypoint(coordinate: $0, accuracy: nil, heading: nil) }
        return [[MBDirectionsWaypoint(coordinate: request.sourceCoordinate, accuracy: nil, heading: sourceHeading)],
            intermediateWaypoints,
            [MBDirectionsWaypoint(coordinate: request.destinationCoordinate, accuracy: nil, heading: nil)]].flatMap{ $0 }
    }
    
    private func taskWithRouter(router: MBDirectionsRouter, completionHandler completion: (MBPoint, [MBPoint], MBPoint, [JSON], NSError?) -> Void, errorHandler: (NSError?) -> Void) -> NSURLSessionDataTask? {
        return router.loadJSON(JSON.self) { [weak self] (json, error) in
            guard let dataTaskSelf = self where dataTaskSelf.task?.state == .Completed else {
                return
            }
            
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
                    errorMessage = json!["message"] as? String
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
                let originCoordinate = CLLocationCoordinate2D(JSONArray: originGeometry["coordinates"] as! [Double])
                let originPoint = MBPoint(name: originProperties["name"] as? String, coordinate: originCoordinate)
                
                let destination = json!["destination"] as! JSON
                let destinationProperties = destination["properties"] as! JSON
                let destinationGeometry = destination["geometry"] as! JSON
                let destinationCoordinate = CLLocationCoordinate2D(JSONArray: destinationGeometry["coordinates"] as! [Double])
                let destinationPoint = MBPoint(name: destinationProperties["name"] as? String, coordinate: destinationCoordinate)
                
                let waypoints = json!["waypoints"] as? [JSON] ?? []
                let waypointPoints = waypoints.map { $0["geometry"] as! JSON }.map {
                    MBPoint(name: nil, coordinate: CLLocationCoordinate2D(JSONArray: $0["coordinates"] as! [Double]))
                }
                
                points = [[originPoint], waypointPoints, [destinationPoint]].flatMap{ $0 }
            case .Five:
                points = (json!["waypoints"] as? [JSON] ?? []).map { waypoint -> MBPoint in
                    let location = waypoint["location"] as! [Double]
                    let coordinate = CLLocationCoordinate2D(JSONArray: location)
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
        self.task?.cancel()
    }

}
