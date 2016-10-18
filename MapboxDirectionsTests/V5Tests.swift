import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class V5Tests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testWithFormat(shapeFormat: RouteShapeFormat) {
        let expectation = expectationWithDescription("calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "true",
            "geometries": String(shapeFormat),
            "overview": "full",
            "steps": "true",
            "continue_straight": "true",
            "access_token": BogusToken,
        ]
        stub(isHost("api.mapbox.com")
            && isPath("/directions/v5/mapbox/driving/-122.42,37.78;-77.03,38.91.json")
            && containsQueryParams(queryParams)) { _ in
                let path = NSBundle(forClass: self.dynamicType).pathForResource("v5_driving_dc_\(shapeFormat)", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42),
            CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03),
        ])
        XCTAssertEqual(options.shapeFormat, RouteShapeFormat.Polyline, "Route shape format should be Polyline by default.")
        options.shapeFormat = shapeFormat
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        options.routeShapeResolution = .Full
        var route: Route?
        let task = Directions(accessToken: BogusToken).calculateDirections(options: options) { (waypoints, routes, error) in
            XCTAssertNil(error, "Error: \(error)")
            
            XCTAssertNotNil(routes)
            XCTAssertEqual(routes!.count, 1)
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
        XCTAssertEqual(route!.coordinates!.count, 842)
        
        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(route!.coordinates!.first!.latitude), 38)
        XCTAssertEqual(round(route!.coordinates!.first!.longitude), -122)
        XCTAssertEqual(route!.legs.count, 1)
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.name, "CA 24, Camino Tassajara")
        XCTAssertEqual(leg.steps.count, 22)
        
        let step = leg.steps[16]
        XCTAssertEqual(round(step.distance), 166)
        XCTAssertEqual(round(step.expectedTravelTime), 13)
        XCTAssertEqual(step.instructions, "Take the ramp on the right")
        
        XCTAssertEqual(step.name, "")
        XCTAssertEqual(step.destinations, "Sycamore Valley Road")
        XCTAssertEqual(step.maneuverType, ManeuverType.TakeOffRamp)
        XCTAssertEqual(step.maneuverDirection, ManeuverDirection.SlightRight)
        XCTAssertEqual(step.initialHeading, 182)
        XCTAssertEqual(step.finalHeading, 196)
        
        XCTAssertNotNil(step.coordinates)
        XCTAssertEqual(step.coordinates!.count, 5)
        XCTAssertEqual(step.coordinates!.count, Int(step.coordinateCount))
        let coordinate = step.coordinates!.first!
        XCTAssertEqual(round(coordinate.latitude), 38)
        XCTAssertEqual(round(coordinate.longitude), -122)
        
        XCTAssertEqual(leg.steps[18].name, "Sycamore Valley Road West")
        
        let intersection = step.intersections![0]
        XCTAssertEqual(intersection.entry, [false, true, true])
        XCTAssertEqual(intersection.inIndex, 0)
        XCTAssertEqual(intersection.outIndex, 2)
        XCTAssertEqual(intersection.headings, [0, 180, 195])
        XCTAssertNotNil(intersection.location.latitude)
        XCTAssertNotNil(intersection.location.longitude)
        
        let lane = intersection.lanes!.first
        XCTAssertEqual(lane?.indications.first, LaneIndicationType.Left)
        XCTAssertEqual(lane?.validTurn, true)
    }
    
    func testGeoJSON() {
        XCTAssertEqual(String(RouteShapeFormat.GeoJSON), "geojson")
        testWithFormat(.GeoJSON)
    }
    
    func testPolyline() {
        XCTAssertEqual(String(RouteShapeFormat.Polyline), "polyline")
        testWithFormat(.Polyline)
    }
}
