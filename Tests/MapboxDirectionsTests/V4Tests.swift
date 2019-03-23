import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class V4Tests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func test(shapeFormat: RouteShapeFormat) {
        let expectation = self.expectation(description: "calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "true",
            "instructions": "text",
            "geometry": String(describing: shapeFormat),
            "steps": "true",
            "access_token": BogusToken,
        ]
        stub(condition: isHost("api.mapbox.com")
            && isPath("/v4/directions/mapbox.driving/-122.42,37.78;-77.03,38.91.json")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "v4_driving_dc_\(shapeFormat)", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptionsV4(coordinates: [
            CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42),
            CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03),
        ])
        XCTAssertEqual(options.shapeFormat, .polyline, "Route shape format should be Polyline by default.")
        options.shapeFormat = shapeFormat
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        var route: Route?
        let task = Directions(accessToken: BogusToken).calculate(options) { (waypoints, routes, error) in
            XCTAssertNil(error, "Error: \(error!)")
            
            XCTAssertNotNil(routes)
            XCTAssertEqual(routes!.count, 2)
            route = routes!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!)")
            XCTAssertEqual(task.state, .completed)
        }
        
        XCTAssertNotNil(route)
        XCTAssertNotNil(route!.coordinates)
        XCTAssertEqual(route!.coordinates!.count, 28375)
        XCTAssertEqual(route!.accessToken, BogusToken)
        XCTAssertEqual(route!.apiEndpoint, URL(string: "https://api.mapbox.com"))
        
        XCTAssertEqual(round(route!.coordinates!.first!.latitude), 38)
        XCTAssertEqual(round(route!.coordinates!.first!.longitude), -122)
        XCTAssertEqual(route!.legs.count, 1)
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.name, "I 80, I 80;US 30")
        XCTAssertEqual(leg.steps.count, 80)
        
        let step = leg.steps[24]
        XCTAssertEqual(step.distance, 223582.0)
        XCTAssertEqual(step.expectedTravelTime, 7219.0)
        XCTAssertEqual(step.instructions, "Go straight onto I 80;US 93 Alternate, I 80;US 93 ALT becomes I 80;US 93 Alternate")
        XCTAssertNotNil(step.names)
        XCTAssertEqual(step.names ?? [], ["I 80", "US 93 Alternate"])
        XCTAssertEqual(step.maneuverType, .continue)
        XCTAssert(step.maneuverDirection == .none)
        XCTAssertNil(step.initialHeading)
        XCTAssertNil(step.finalHeading)
        
        XCTAssertNil(step.coordinates)
        XCTAssertEqual(step.coordinateCount, 0)
    }
    
    func testGeoJSON() {
        XCTAssertEqual(String(describing: RouteShapeFormat.geoJSON), "geojson")
        test(shapeFormat: .geoJSON)
    }
    
    func testPolyline() {
        XCTAssertEqual(String(describing: RouteShapeFormat.polyline), "polyline")
        test(shapeFormat: .polyline)
    }
}
