import XCTest
import Turf
@testable import MapboxDirections

class RouteOptionsTests: XCTestCase {
    func testCoding() {
        let options = testRouteOptions
        
        let encoded: Data = try! JSONEncoder().encode(options)
        let optionsString: String = String(data: encoded, encoding: .utf8)!
        
        let unarchivedOptions: RouteOptions = try! JSONDecoder().decode(RouteOptions.self, from: optionsString.data(using: .utf8)!)
        
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
        XCTAssertEqual(unarchivedOptions.roadClassesToAllow, options.roadClassesToAllow)
        XCTAssertEqual(unarchivedOptions.initialManeuverAvoidanceRadius, options.initialManeuverAvoidanceRadius)
    }
    
    func testCodingWithRawCodingKeys() {
        let routeOptionsJSON: [String: Any?] = [
            "waypoints": [
                [
                "location": [-77.036500000000004, 38.8977],
                "name": "White House",
                ]
            ],
            "profile": "mapbox/driving-traffic",
            "steps": true,
            "geometries": "polyline",
            "overview": "simplified",
            "annotations": ["congestion"],
            "language": "en_US",
            "voice_instructions": true,
            "voice_units": "imperial",
            "banner_instructions": true,
            "continue_straight": true,
            "alternatives": false,
            "roundabout_exits": true,
            "exclude": ["toll"],
            "include": ["hov3", "hot"],
            "enable_refresh": false,
            "avoid_maneuver_radius": 300
        ]
        
        let routeOptionsData = try! JSONSerialization.data(withJSONObject: routeOptionsJSON, options: [])
        var routeOptions: RouteOptions!
        XCTAssertNoThrow(routeOptions = try! JSONDecoder().decode(RouteOptions.self, from: routeOptionsData))
        
        XCTAssertEqual(routeOptions.profileIdentifier, .automobileAvoidingTraffic)
        XCTAssertEqual(routeOptions.includesSteps, true)
        XCTAssertEqual(routeOptions.shapeFormat, .polyline)
        XCTAssertEqual(routeOptions.routeShapeResolution, .low)
        XCTAssertEqual(routeOptions.attributeOptions, .congestionLevel)
        XCTAssertEqual(routeOptions.locale, Locale(identifier: "en_US"))
        XCTAssertEqual(routeOptions.includesSpokenInstructions, true)
        XCTAssertEqual(routeOptions.distanceMeasurementSystem, .imperial)
        XCTAssertEqual(routeOptions.includesVisualInstructions, true)
        XCTAssertEqual(routeOptions.allowsUTurnAtWaypoint, true)
        XCTAssertEqual(routeOptions.includesAlternativeRoutes, false)
        XCTAssertEqual(routeOptions.includesExitRoundaboutManeuver, true)
        XCTAssertEqual(routeOptions.roadClassesToAvoid, .toll)
        XCTAssertEqual(routeOptions.roadClassesToAllow, [.highOccupancyVehicle3, .highOccupancyToll])
        XCTAssertEqual(routeOptions.refreshingEnabled, false)
        XCTAssertEqual(routeOptions.initialManeuverAvoidanceRadius, 300)
        
        let encodedRouteOptions: Data = try! JSONEncoder().encode(routeOptions)
        let optionsString: String = String(data: encodedRouteOptions, encoding: .utf8)!
        
        let unarchivedOptions: RouteOptions = try! JSONDecoder().decode(RouteOptions.self, from: optionsString.data(using: .utf8)!)
        
        XCTAssertNotNil(unarchivedOptions)
        XCTAssertEqual(unarchivedOptions.profileIdentifier, routeOptions.profileIdentifier)
        XCTAssertEqual(unarchivedOptions.includesSteps, routeOptions.includesSteps)
        XCTAssertEqual(unarchivedOptions.shapeFormat, routeOptions.shapeFormat)
        XCTAssertEqual(unarchivedOptions.routeShapeResolution, routeOptions.routeShapeResolution)
        XCTAssertEqual(unarchivedOptions.attributeOptions, routeOptions.attributeOptions)
        XCTAssertEqual(unarchivedOptions.locale, routeOptions.locale)
        XCTAssertEqual(unarchivedOptions.includesSpokenInstructions, routeOptions.includesSpokenInstructions)
        XCTAssertEqual(unarchivedOptions.distanceMeasurementSystem, routeOptions.distanceMeasurementSystem)
        XCTAssertEqual(unarchivedOptions.includesVisualInstructions, routeOptions.includesVisualInstructions)
        XCTAssertEqual(unarchivedOptions.allowsUTurnAtWaypoint, routeOptions.allowsUTurnAtWaypoint)
        XCTAssertEqual(unarchivedOptions.includesAlternativeRoutes, routeOptions.includesAlternativeRoutes)
        XCTAssertEqual(unarchivedOptions.includesExitRoundaboutManeuver, routeOptions.includesExitRoundaboutManeuver)
        XCTAssertEqual(unarchivedOptions.roadClassesToAvoid, routeOptions.roadClassesToAvoid)
        XCTAssertEqual(unarchivedOptions.roadClassesToAllow, routeOptions.roadClassesToAllow)
        XCTAssertEqual(unarchivedOptions.refreshingEnabled, routeOptions.refreshingEnabled)
        XCTAssertEqual(unarchivedOptions.initialManeuverAvoidanceRadius, routeOptions.initialManeuverAvoidanceRadius)
    }
    
    // MARK: API name-handling tests
    
    private static var testWaypoints: [Waypoint] {
        return [
            Waypoint(coordinate: LocationCoordinate2D(latitude: 39.27664, longitude:-84.41139)),
            Waypoint(coordinate: LocationCoordinate2D(latitude: 39.27277, longitude:-84.41226)),
        ]
    }
    
    private func response(for fixtureName: String, waypoints: [Waypoint] = testWaypoints) -> (waypoints:[Waypoint], route:Route)? {
        let testBundle = Bundle.module
        guard let fixtureURL = testBundle.url(forResource:fixtureName, withExtension:"json") else {
            XCTFail()
            return nil
        }
        guard let fixtureData = try? Data(contentsOf: fixtureURL, options:.mappedIfSafe) else {
            XCTFail()
            return nil
        }
    
        let subject = RouteOptions(waypoints: waypoints)
        let decoder = JSONDecoder()
        decoder.userInfo[.options] = subject
        decoder.userInfo[.credentials] = DirectionsCredentials(accessToken: "foo", host: URL(string: "https://test.website")!)
        var response: RouteResponse?
        XCTAssertNoThrow(response = try decoder.decode(RouteResponse.self, from: fixtureData))
        XCTAssertNotNil(response)
        
        if let response = response {
            XCTAssertNotNil(response.waypoints)
            XCTAssertNotNil(response.routes)
        }
        guard let waypoints = response?.waypoints, let route = response?.routes?.first else {
            return nil
        }
        return (waypoints: waypoints, route: route)
    }
    
    func testResponseWithoutDestinationName() {
        // https://api.mapbox.com/directions/v5/mapbox/driving/-84.411389,39.27665;-84.412115,39.272675.json?overview=false&steps=false&access_token=pk.feedcafedeadbeef
        let response = self.response(for: "noDestinationName")!
        XCTAssertNil(response.route.legs.last?.destination?.name, "Empty-string waypoint name in API responds should be represented as nil.")
    }
    
    func testResponseWithDestinationName() {
        // https://api.mapbox.com/directions/v5/mapbox/driving/-84.411389,39.27665;-84.41195,39.27260.json?overview=false&steps=false&access_token=pk.feedcafedeadbeef
        let response = self.response(for: "apiDestinationName")!
        XCTAssertEqual(response.route.legs.last?.destination?.name, "Reading Road", "Waypoint name in fixture response not parsed correctly.")
    }
    
    func testResponseWithManuallySetDestinationName() {
        let manuallySet = RouteOptionsTests.testWaypoints
        manuallySet.last!.name = "manuallyset"
        
        let response = self.response(for: "apiDestinationName", waypoints: manuallySet)!
        XCTAssertEqual(response.route.legs.last?.destination?.name, "manuallyset", "Waypoint with manually set name should override any computed name.")
    }
    
    func testApproachesURLQueryParams() {
        let coordinate = LocationCoordinate2D(latitude: 0, longitude: 0)
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
        let coordinate = LocationCoordinate2D(latitude: 0, longitude: 0)
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
        let start = LocationCoordinate2D(latitude: 9.945497000000003, longitude: 53.03218800000006)
        let end = LocationCoordinate2D(latitude: 10.945497000000003, longitude: 54.03218800000006)
        
        let answer = [start.requestDescription, end.requestDescription]
        let correct = ["53.032188,9.945497", "54.032188,10.945497"]
        XCTAssert(answer == correct, "Coordinates should be truncated.")
    }
    
    func testWaypointSerialization() {
        let origin = Waypoint(coordinate: LocationCoordinate2D(latitude: 39.15031, longitude: -84.47182), name: "XU")
        let destination = Waypoint(coordinate: LocationCoordinate2D(latitude: 39.12971, longitude: -84.51638), name: "UC")
        destination.targetCoordinate = LocationCoordinate2D(latitude: 39.13115, longitude: -84.51619)
        let options = RouteOptions(waypoints: [origin, destination])
        XCTAssertEqual(options.coordinates, "-84.47182,39.15031;-84.51638,39.12971")
        XCTAssertTrue(options.urlQueryItems.contains(URLQueryItem(name: "waypoint_names", value: "XU;UC")))
        XCTAssertTrue(options.urlQueryItems.contains(URLQueryItem(name: "waypoint_targets", value: ";-84.51619,39.13115")))
    }
    
    func testInitialManeuverAvoidanceRadiusSerialization() {
        let options = RouteOptions(coordinates: [])
        
        options.initialManeuverAvoidanceRadius = 123.456
        
        XCTAssertTrue(options.urlQueryItems.contains(URLQueryItem(name: "avoid_maneuver_radius", value: "123.456")))
        
        options.initialManeuverAvoidanceRadius = nil
        
        XCTAssertFalse(options.urlQueryItems.contains(URLQueryItem(name: "avoid_maneuver_radius", value: nil)))
    }
}

fileprivate let testCoordinates = [
    LocationCoordinate2D(latitude: 52.5109, longitude: 13.4301),
    LocationCoordinate2D(latitude: 52.5080, longitude: 13.4265),
    LocationCoordinate2D(latitude: 52.5021, longitude: 13.4316),
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
    opts.roadClassesToAllow = [.highOccupancyVehicle3, .highOccupancyToll]
    opts.initialManeuverAvoidanceRadius = 100

    return opts
}
