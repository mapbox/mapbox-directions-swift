import Foundation
import CoreLocation
import Alamofire

internal struct MBDirectionsWaypoint: CustomStringConvertible {
    struct Heading: CustomStringConvertible {
        let heading: CLLocationDirection
        /// The maximum allowable deviation (measured in degrees) between `heading` and the heading of a returned step in either direction.
        let headingAccuracy: CLLocationDirection
        
        var description: String {
            return "\(heading),\(headingAccuracy)"
        }
    }
    
    let coordinate: CLLocationCoordinate2D
    /// The radius (measured in meters) of the area to search for a routable way.
    let accuracy: CLLocationAccuracy?
    let heading: Heading?
    
    var description: String {
        return "\(coordinate.longitude),\(coordinate.latitude)"
    }
}

internal enum MBDirectionsRouter: URLRequestConvertible {
    
    enum InstructionFormat: String {
        case Text = "text"
        case HTML = "html"
    }
    
    enum GeometryFormatV4: String {
        case None = "false"
        case GeoJSON = "geojson"
        case Polyline = "polyline"
    }
    
    enum GeometryFormatV5: String {
        case GeoJSON = "geojson"
        case Polyline = "polyline"
    }
    
    enum OverviewGranularity: String {
        case None = "false"
        case Simplified = "simplified"
        case Full = "full"
    }
    
    case V4(MBDirectionsConfiguration, String, [MBDirectionsWaypoint], Bool?, InstructionFormat?, GeometryFormatV4?, Bool?)
    case V5(MBDirectionsConfiguration, String, [MBDirectionsWaypoint], Bool?, GeometryFormatV5?, OverviewGranularity?, Bool?, Bool?)
    
    var URLRequest: NSMutableURLRequest {
        let result: (configuration: MBDirectionsConfiguration, path: String, parameters: [String: AnyObject])
        switch self {
        case .V4(let configuration, let profileIdentifier, let waypoints, let includeAlternatives, let instructionFormat, let geometryFormat, let includeSteps):
            var params: [String:AnyObject] = ["access_token": configuration.accessToken!]
            let coordinates = waypoints.map{ "\($0)" }.joinWithSeparator(";")
            params["alternatives"] = String(includeAlternatives ?? false)
            if let instructionFormat = instructionFormat {
                params["instructions"] = instructionFormat.rawValue
            }
            if let geometryFormat = geometryFormat {
                params["geometry"] = geometryFormat.rawValue
            }
            if let includeSteps = includeSteps {
                params["steps"] = String(includeSteps)
            }
            result = (configuration, "/v4/directions/\(profileIdentifier)/\(coordinates).json", params)
            
        case .V5(let configuration, let profileIdentifier, let waypoints, let includeAlternative, let geometryFormat, let overviewGranularity, let includeSteps, let allowPointUTurns):
            var params: [String:AnyObject] = ["access_token": configuration.accessToken!]
            let coordinates = waypoints.map{ "\($0)" }.joinWithSeparator(";")
            if let includeAlternative = includeAlternative {
                params["alternative"] = String(includeAlternative)
            }
            let hasHeadings = !(waypoints.flatMap { $0.heading }.isEmpty)
            if hasHeadings {
                params["bearings"] = waypoints.map {
                    return $0.heading != nil ? "\($0.heading!)" : ""
                    }.joinWithSeparator(";")
            }
            if let geometryFormat = geometryFormat {
                params["geometries"] = geometryFormat.rawValue
            }
            if let overviewGranularity = overviewGranularity {
                params["overview"] = overviewGranularity.rawValue
            }
            let hasAccuracies = !(waypoints.flatMap { $0.accuracy }.isEmpty)
            if hasAccuracies {
                params["radiuses"] = waypoints.map {
                    return $0.accuracy != nil ? "\($0.accuracy!)" : ""
                    }.joinWithSeparator(";")
            }
            if let includeSteps = includeSteps {
                params["steps"] = String(includeSteps)
            }
            if let allowPointUTurns = allowPointUTurns {
                params["uturns"] = String(allowPointUTurns)
            }
            result = (configuration, "/directions/v5/\(profileIdentifier)/\(coordinates).json", params)
        }
        
        let URL = NSURL(string: result.configuration.apiEndpoint + result.path)!
        let URLRequest = NSURLRequest(URL: URL)
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}