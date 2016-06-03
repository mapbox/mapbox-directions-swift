import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class DrivingV5Tests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testDirections() {
        let expectation = expectationWithDescription("calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "true",
            "geometries": "polyline",
            "overview": "full",
            "steps": "true",
            "continue_straight": "true",
            "access_token": BogusToken,
        ]
        stub(isHost("api.mapbox.com")
            && isPath("/directions/v5/mapbox/driving/-122.42,37.78%3B-77.03,38.91.json")
            && containsQueryParams(queryParams)) { _ in
            let path = NSBundle(forClass: self.dynamicType).pathForResource("driving_dc_polyline", ofType: "json")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
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
        XCTAssertNotNil(route!.coordinates)
        XCTAssertEqual(route!.coordinates!.count, 28372)
        
        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(route!.coordinates!.first!.latitude), 38)
        XCTAssertEqual(round(route!.coordinates!.first!.longitude), -122)
        XCTAssertEqual(route!.legs.count, 1)
        XCTAssertEqual(route!.legs.first!.steps.count, 81)
        XCTAssertEqual(route!.legs.first!.steps[24].distance, 12_623.1)
        XCTAssertEqual(route!.legs.first!.steps[24].expectedTravelTime, 422.6)
        XCTAssertEqual(route!.legs.first!.steps[24].name, "I 80;US 93 ALT")
    }
}
