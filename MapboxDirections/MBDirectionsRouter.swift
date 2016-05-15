import Foundation
import CoreLocation
import RequestKit

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

internal enum MBDirectionsRouter: Router {
    enum InstructionFormat: String {
        case Text = "text"
        case HTML = "html"
    }
    
    enum GeometryFormatV4: String {
        case None = "false"
        case GeoJSON = "geojson"
        /// Encoded polyline; see <https://github.com/mapbox/polyline>.
        case Polyline = "polyline"
    }
    
    enum GeometryFormatV5: String {
        case GeoJSON = "geojson"
        /// Encoded polyline; see <https://github.com/mapbox/polyline>.
        case Polyline = "polyline"
    }
    
    enum OverviewGranularity: String {
        case None = "false"
        case Simplified = "simplified"
        case Full = "full"
    }
    
    case V4(config: Configuration, profileIdentifier: String, waypoints: [MBDirectionsWaypoint], includeAlternatives: Bool?, instructionFormat: InstructionFormat?, geometryFormat: GeometryFormatV4?, includeSteps: Bool?)
    case V5(config: Configuration, profileIdentifier: String, waypoints: [MBDirectionsWaypoint], includeAlternatives: Bool?, geometryFormat: GeometryFormatV5?, overviewGranularity: OverviewGranularity?, includeSteps: Bool?, allowUTurnAtWaypoint: Bool?)
    
    var method: HTTPMethod {
        return .GET
    }
    
    var encoding: HTTPEncoding {
        return .URL
    }
    
    var configuration: Configuration {
        switch self {
        case .V4(let config, _, _, _, _, _, _): return config
        case .V5(let config, _, _, _, _, _, _, _): return config
        }
    }
    
    var params: [String: String] {
        switch self {
        case .V4(_, _, _, let includeAlternatives, let instructionFormat, let geometryFormat, let includeSteps):
            var params: [String: String] = [
                "alternatives": String(includeAlternatives ?? false),
            ]
            if let instructionFormat = instructionFormat {
                params["instructions"] = instructionFormat.rawValue
            }
            if let geometryFormat = geometryFormat {
                params["geometry"] = geometryFormat.rawValue
            }
            if let includeSteps = includeSteps {
                params["steps"] = String(includeSteps)
            }
            return params
            
        case .V5(_, _, let waypoints, let includeAlternatives, let geometryFormat, let overviewGranularity, let includeSteps, let allowUTurnAtWaypoint):
            var params: [String: String] = [:]
            if let includeAlternatives = includeAlternatives {
                params["alternatives"] = String(includeAlternatives)
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
            if let allowUTurnAtWaypoint = allowUTurnAtWaypoint {
                params["continue_straight"] = String(!allowUTurnAtWaypoint)
            }
            return params
        }
    }
    
    var path: String {
        switch self {
        case .V4(_, let profileIdentifier, let waypoints, _, _, _, _):
            let coordinates = waypoints.map{ "\($0)" }.joinWithSeparator(";")
            return "v4/directions/\(profileIdentifier)/\(coordinates).json"
            
        case .V5(_, let profileIdentifier, let waypoints, _, _, _, _, _):
            let coordinates = waypoints.map{ "\($0)" }.joinWithSeparator(";")
            return "directions/v5/\(profileIdentifier)/\(coordinates).json"
        }
    }
}