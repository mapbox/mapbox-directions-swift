public class MBDirectionsRequest {
    public enum APIVersion: UInt {
        case Four = 4
        case Five = 5
    }
    public var version: APIVersion = .Five
    
    public enum TransportType: String {
        case Automobile = "mapbox/driving"
        case Walking    = "mapbox/walking"
        case Cycling    = "mapbox/cycling"
//        case Any        = ""
    }

    public let sourceCoordinate: CLLocationCoordinate2D
    public let sourceHeading: CLLocationDirection?
    public let waypointCoordinates: [CLLocationCoordinate2D]
    public let destinationCoordinate: CLLocationCoordinate2D
    public var requestsAlternateRoutes = false
    public var transportType: TransportType {
        get {
            return TransportType(rawValue: profileIdentifier) ?? .Automobile
        }
        set {
            profileIdentifier = newValue.rawValue
        }
    }
    public var profileIdentifier: String = TransportType.Automobile.rawValue
    //    var departureDate: NSDate!
    //    var arrivalDate: NSDate!

    //    class func isDirectionsRequestURL
    //    func initWithContentsOfURL

    public init(sourceCoordinate: CLLocationCoordinate2D, waypointCoordinates: [CLLocationCoordinate2D] = [], destinationCoordinate: CLLocationCoordinate2D, sourceHeading: CLLocationDirection? = nil) {
        self.sourceCoordinate = sourceCoordinate
        self.destinationCoordinate = destinationCoordinate
        self.waypointCoordinates = waypointCoordinates
        self.sourceHeading = sourceHeading
    }
}
