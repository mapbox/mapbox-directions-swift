import XCTest
import CoreLocation
@testable import MapboxDirections


class RouteOptionsTests: XCTestCase {
    func testCoding() {
        let options = testRouteOptions
        let encodedData = NSMutableData()
        let keyedArchiver = NSKeyedArchiver(forWritingWith: encodedData)
        keyedArchiver.requiresSecureCoding = true
        keyedArchiver.encode(options, forKey: "options")
        keyedArchiver.finishEncoding()
        
        let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
        keyedUnarchiver.requiresSecureCoding = true
        let unarchivedOptions = keyedUnarchiver.decodeObject(of: RouteOptions.self, forKey: "options")!
        keyedUnarchiver.finishDecoding()
        
        XCTAssertNotNil(unarchivedOptions)
        
        let coordinates = testCoordinates
        let unarchivedWaypoints = unarchivedOptions.waypoints
        XCTAssertEqual(unarchivedWaypoints.count, coordinates.count)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.latitude, coordinates[0].latitude)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.longitude, coordinates[0].longitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.latitude, coordinates[1].latitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.longitude, coordinates[1].longitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.latitude, coordinates[2].latitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.longitude, coordinates[2].longitude)
        
        XCTAssertEqual(unarchivedOptions.profileIdentifier, options.profileIdentifier)
        XCTAssertEqual(unarchivedOptions.locale, options.locale)
        XCTAssertEqual(unarchivedOptions.includesSpokenInstructions, options.includesSpokenInstructions)
        XCTAssertEqual(unarchivedOptions.distanceMeasurementSystem, options.distanceMeasurementSystem)
        XCTAssertEqual(unarchivedOptions.includesVisualInstructions, options.includesVisualInstructions)
        XCTAssertEqual(unarchivedOptions.roadClassesToAvoid, options.roadClassesToAvoid)
    }
    
    func testCodingV4() {
        let options = testRouteOptionsV4
        let encodedData = NSMutableData()
        let keyedArchiver = NSKeyedArchiver(forWritingWith: encodedData)
        keyedArchiver.requiresSecureCoding = true
        keyedArchiver.encode(options, forKey: "options")
        keyedArchiver.finishEncoding()
        
        let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
        keyedUnarchiver.requiresSecureCoding = true
        let unarchivedOptions = keyedUnarchiver.decodeObject(of: RouteOptionsV4.self, forKey: "options")!
        keyedUnarchiver.finishDecoding()
        
        XCTAssertNotNil(unarchivedOptions)
        
        let coordinates = testCoordinates
        let unarchivedWaypoints = unarchivedOptions.waypoints
        XCTAssertEqual(unarchivedWaypoints.count, coordinates.count)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.latitude, coordinates[0].latitude)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.longitude, coordinates[0].longitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.latitude, coordinates[1].latitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.longitude, coordinates[1].longitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.latitude, coordinates[2].latitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.longitude, coordinates[2].longitude)
        
        XCTAssertEqual(unarchivedOptions.profileIdentifier, options.profileIdentifier)
        XCTAssertEqual(unarchivedOptions.instructionFormat, options.instructionFormat)
        XCTAssertEqual(unarchivedOptions.includesShapes, options.includesShapes)
        XCTAssertEqual(unarchivedOptions.includesSteps, options.includesSteps)
    }
    
    func testCopying() {
        let testInstance = testRouteOptions
        guard let copy = testInstance.copy() as? RouteOptions else { return XCTFail("RouteOptions copy method should an object of same type") }
        XCTAssertNotNil(copy, "Copy should not be nil.")
        XCTAssertTrue(testInstance == copy, "Test Instance and copy should be semantically equivalent.")
        XCTAssertFalse(testInstance === copy, "Test Instance and copy should not be identical.")
        
    }
    
    //MARK: API Name Handling Tests
    private static var testWaypoints: [Waypoint] { return [Waypoint(coordinate: CLLocationCoordinate2D(latitude: 39.27664, longitude:-84.41139)),
                                                        Waypoint(coordinate: CLLocationCoordinate2D(latitude: 39.27277, longitude:-84.41226))]}
   
   
    private func response(for fixtureName: String, waypoints: [Waypoint] = testWaypoints) -> (waypoints:[Waypoint], route:Route)? {
        let testBundle = Bundle(for: type(of: self))
        guard let fixtureURL = testBundle.url(forResource:fixtureName, withExtension:"json") else { XCTFail(); return nil }
        guard let fixtureData = try? Data(contentsOf: fixtureURL, options:.mappedIfSafe) else {XCTFail(); return nil }
        guard let fixtureOpaque = try? JSONSerialization.jsonObject(with: fixtureData), let fixture = fixtureOpaque as? JSONDictionary  else { XCTFail(); return nil }

        let subject = RouteOptions(waypoints: waypoints)
        let response = subject.response(from: fixture)
        
        guard let waypoints = response.0, let routes = response.1 else { XCTFail("Expected responses not returned from service"); return nil}
        guard let primary = routes.first else {XCTFail("Expected a route in response"); return nil}
        return (waypoints:waypoints, route:primary)
    }
    
    func testResponseWithoutDestinationName() {
        let response = self.response(for: "noDestinationName")!
        XCTAssert(response.route.legs.last!.destination.name == nil, "API waypoint with no name (aka \"\") needs to be represented as `nil`.")
    }
    
    func testResponseWithDestinationName() {
        let response = self.response(for: "apiDestinationName")!
        XCTAssert(response.route.legs.last!.destination.name == "testpass", "Waypoint name in fixture response not parsed correctly.")
    }
    
    func testResponseWithManuallySetDestinationName() {
        let manuallySet = RouteOptionsTests.testWaypoints
        manuallySet.last!.name = "manuallyset"
        
        let response = self.response(for: "apiDestinationName", waypoints: manuallySet)!
        XCTAssert(response.route.legs.last!.destination.name == "manuallyset", "Waypoint with manually set name should override any computed name.")
    }
    
    func testApproachesURLQueryParams() {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let wp1 = Waypoint(coordinate: coordinate, coordinateAccuracy: 0)
        wp1.allowsArrivingOnOppositeSide = false
        let waypoints = [
            Waypoint(coordinate: coordinate, coordinateAccuracy: 0),
            wp1,
            Waypoint(coordinate: coordinate, coordinateAccuracy: 0)
        ]
        
        let routeOptions = RouteOptions(waypoints: waypoints)
        routeOptions.includesSteps = true
        let urlQueryItems = routeOptions.urlQueryItems
        let approaches = urlQueryItems.filter { $0.name == "approaches" }.first!
        XCTAssertEqual(approaches.value!, "unrestricted;curb;unrestricted", "waypoints[1] should be restricted to curb")
    }
    
    func testMissingApproaches() {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let waypoints = [
            Waypoint(coordinate: coordinate, coordinateAccuracy: 0),
            Waypoint(coordinate: coordinate, coordinateAccuracy: 0),
            Waypoint(coordinate: coordinate, coordinateAccuracy: 0)
        ]
        
        let routeOptions = RouteOptions(waypoints: waypoints)
        routeOptions.includesSteps = true
        let urlQueryItems = routeOptions.urlQueryItems
        let hasApproaches = !urlQueryItems.filter { $0.name == "approaches" }.isEmpty
        XCTAssertFalse(hasApproaches, "approaches query param should be omitted unless any waypoint is restricted to curb")
    }
    
    func testDecimalPrecision() {
        let start = CLLocationCoordinate2D(latitude: 9.945497000000003, longitude: 53.03218800000006)
        let end = CLLocationCoordinate2D(latitude: 10.945497000000003, longitude: 54.03218800000006)

        let wpts = [start, end].map { Waypoint(coordinate: $0) }

        let subject = DirectionsOptions(waypoints: wpts)
        
        let answer = subject.queries
        let correct = ["53.032188,9.945497", "54.032188,10.945497"]
        XCTAssert(answer == correct, "Coordinates should be truncated.")
        
    }
    
    func testWaypointSerialization() {
        let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 39.15031, longitude: -84.47182), name: "XU")
        let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 39.12971, longitude: -84.51638), name: "UC")
        destination.targetCoordinate = CLLocationCoordinate2D(latitude: 39.13115, longitude: -84.51619)
        let options = RouteOptions(waypoints: [origin, destination])
        
        XCTAssertEqual(options.queries, ["-84.47182,39.15031", "-84.51638,39.12971"])
        XCTAssertTrue(options.urlQueryItems.contains(URLQueryItem(name: "waypoint_names", value: "XU;UC")))
        XCTAssertTrue(options.urlQueryItems.contains(URLQueryItem(name: "waypoint_targets", value: ";-84.51619,39.13115")))
    }
}

let testCoordinates = [
    CLLocationCoordinate2D(latitude: 52.5109, longitude: 13.4301),
    CLLocationCoordinate2D(latitude: 52.5080, longitude: 13.4265),
    CLLocationCoordinate2D(latitude: 52.5021, longitude: 13.4316),
]

var testRouteOptions: RouteOptions {
    let opts = RouteOptions(coordinates: testCoordinates, profileIdentifier: .automobileAvoidingTraffic)
    opts.locale = Locale(identifier: "en_US")
    opts.allowsUTurnAtWaypoint = true
    opts.shapeFormat = .polyline
    opts.routeShapeResolution = .full
    opts.attributeOptions = [.congestionLevel]
    opts.includesExitRoundaboutManeuver = true
    opts.includesSpokenInstructions = true
    opts.distanceMeasurementSystem = .metric
    opts.includesVisualInstructions = true
    opts.roadClassesToAvoid = .toll
    
    return opts
}

var testRouteOptionsV4: RouteOptionsV4 {
    let options = RouteOptionsV4(coordinates: testCoordinates, profileIdentifier: .automobileAvoidingTraffic)
    options.instructionFormat = .html
    options.includesShapes = true
    options.includesSteps = true
    return options
}
