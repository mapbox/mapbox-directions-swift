import XCTest
import Nocilla
@testable import MapboxDirections

let BogusToken = "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede"

class MapboxDirectionsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }
    
    override func tearDown() {
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
        super.tearDown()
    }

    func testDriving() {
        let json = Fixture.stringFromFileNamed("driving_dc_polyline")
        stubRequest("GET", "https://api.mapbox.com/directions/v5/mapbox/driving/-122.42,37.78%3B-77.03,38.91.json?alternatives=true&geometries=polyline&overview=full&steps=true&continue_straight=false&access_token=\(BogusToken)").andReturn(200).withHeaders(["Content-Type": "application/json"]).withBody(json)
        
        let expectation = expectationWithDescription("v4")
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42),
            CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03),
        ])
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        options.routeShapeResolution = .Full
        var route: Route?
        let task = Directions(accessToken: BogusToken).calculateDirections(options: options) { (waypoints, routes, error) in
            XCTAssertNil(error, "Error: \(error)")
            
            XCTAssertNotNil(routes)
            XCTAssertEqual(routes!.count, 2)
            route = routes!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectationsWithTimeout(2) { (error) in
            XCTAssertNil(error, "Error: \(error)")
            XCTAssertEqual(task.state, NSURLSessionTaskState.Completed)
        }
        
        XCTAssertNotNil(route)
        XCTAssertEqual(route!.coordinates.count, 28372)
        
        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(route!.coordinates.first!.latitude), 38)
        XCTAssertEqual(round(route!.coordinates.first!.longitude), -122)
        XCTAssertEqual(route!.legs.count, 1)
        XCTAssertEqual(route!.legs.first!.steps.count, 81)
        XCTAssertEqual(route!.legs.first!.steps[24].distance, 12_623.1)
        XCTAssertEqual(route!.legs.first!.steps[24].expectedTravelTime, 422.6)
        XCTAssertEqual(route!.legs.first!.steps[24].name, "I 80;US 93 ALT")
    }
}
