import Foundation
import CoreLocation

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
    }

    public let sourceCoordinate: CLLocationCoordinate2D
    public let sourceHeading: CLLocationDirection?
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

    public init(sourceCoordinate: CLLocationCoordinate2D, waypointCoordinates: [CLLocationCoordinate2D] = [], destinationCoordinate: CLLocationCoordinate2D, sourceHeading: CLLocationDirection? = nil) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.waypointCoordinates = waypointCoordinates
        self.sourceHeading = sourceHeading
    }
}
