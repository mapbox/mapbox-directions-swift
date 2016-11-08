import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class V5Tests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func test(shapeFormat: RouteShapeFormat) {
        let expectation = self.expectation(description: "calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "true",
            "geometries": String(describing: shapeFormat),
            "overview": "full",
            "steps": "true",
            "continue_straight": "true",
            "access_token": BogusToken,
        ]
        stub(condition: isHost("api.mapbox.com")
            && isPath("/directions/v5/mapbox/driving/-122.42,37.78;-77.03,38.91.json")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "v5_driving_dc_\(shapeFormat)", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42),
            CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03),
        ])
        XCTAssertEqual(options.shapeFormat, .polyline, "Route shape format should be Polyline by default.")
        options.shapeFormat = shapeFormat
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        options.routeShapeResolution = .full
        var route: Route?
        let task = Directions(accessToken: BogusToken).calculate(options) { (waypoints, routes, error) in
            XCTAssertNil(error, "Error: \(error)")
            
            XCTAssertNotNil(routes)
            XCTAssertEqual(routes!.count, 1)
            route = routes!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error)")
            XCTAssertEqual(task.state, .completed)
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
        XCTAssertEqual(step.maneuverType, .takeOffRamp)
        XCTAssertEqual(step.maneuverDirection, .slightRight)
        XCTAssertEqual(step.initialHeading, 182)
        XCTAssertEqual(step.finalHeading, 196)
        
        XCTAssertNotNil(step.coordinates)
        XCTAssertEqual(step.coordinates!.count, 5)
        XCTAssertEqual(step.coordinates!.count, Int(step.coordinateCount))
        let coordinate = step.coordinates!.first!
        XCTAssertEqual(round(coordinate.latitude), 38)
        XCTAssertEqual(round(coordinate.longitude), -122)
        
        XCTAssertEqual(leg.steps[18].name, "Sycamore Valley Road West")
        
        let intersection = step.intersections!.first!
        XCTAssertEqual(intersection.outletIndexes, IndexSet(integersIn: 1...2))
        XCTAssertEqual(intersection.approachIndex, 0)
        XCTAssertEqual(intersection.outletIndex, 2)
        XCTAssertEqual(intersection.headings, [0, 180, 195])
        XCTAssertNotNil(intersection.location.latitude)
        XCTAssertNotNil(intersection.location.longitude)
        XCTAssertEqual(intersection.usableApproachLanes, IndexSet(integersIn: 0...1))
        
        let lane = intersection.approachLanes?.first
        let indications = lane?.indications
        XCTAssertNotNil(indications)
        XCTAssertTrue(indications!.contains(.left))
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
