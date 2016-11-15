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
        XCTAssertEqual(route!.coordinates!.count, 28_442)
        
        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(route!.coordinates!.first!.latitude), 38)
        XCTAssertEqual(round(route!.coordinates!.first!.longitude), -122)
        XCTAssertEqual(route!.legs.count, 1)
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.name, "I 80, I 80;US 30")
        XCTAssertEqual(leg.steps.count, 59)
        
        let step = leg.steps[43]
        XCTAssertEqual(round(step.distance), 688)
        XCTAssertEqual(round(step.expectedTravelTime), 30)
        XCTAssertEqual(step.instructions, "Take the ramp on the right towards Washington")
        
        XCTAssertNil(step.names)
        XCTAssertNotNil(step.destinations)
        XCTAssertEqual(step.destinations ?? [], ["Washington"])
        XCTAssertEqual(step.maneuverType, ManeuverType.TakeOffRamp)
        XCTAssertEqual(step.maneuverDirection, ManeuverDirection.SlightRight)
        XCTAssertEqual(step.initialHeading, 90)
        XCTAssertEqual(step.finalHeading, 96)
        
        XCTAssertNotNil(step.coordinates)
        XCTAssertEqual(step.coordinates!.count, 17)
        XCTAssertEqual(step.coordinates!.count, Int(step.coordinateCount))
        let coordinate = step.coordinates!.first!
        XCTAssertEqual(round(coordinate.latitude), 39)
        XCTAssertEqual(round(coordinate.longitude), -77)
        
        XCTAssertNil(leg.steps[28].names)
        XCTAssertEqual(leg.steps[28].codes ?? [], ["I 80"])
        XCTAssertEqual(leg.steps[28].destinationCodes ?? [], ["I 80 East", "I 90"])
        XCTAssertEqual(leg.steps[28].destinations ?? [], ["Toll Road"])
        
        XCTAssertEqual(leg.steps[30].names ?? [], ["Ohio Turnpike"])
        XCTAssertEqual(leg.steps[30].codes ?? [], ["I 80", "I 90"])
        XCTAssertNil(leg.steps[30].destinationCodes)
        XCTAssertNil(leg.steps[30].destinations)
        
        let intersections = leg.steps[40].intersections
        XCTAssertNotNil(intersections)
        XCTAssertEqual(intersections?.count, 7)
        let intersection = intersections?[2]
        XCTAssertEqual(intersection?.outletIndexes.containsIndex(0), true)
        XCTAssertEqual(intersection?.outletIndexes.containsIndexesInRange(NSRange(location: 2, length: 2)), true)
        XCTAssertEqual(intersection?.approachIndex, 1)
        XCTAssertEqual(intersection?.outletIndex, 3)
        XCTAssertEqual(intersection?.headings ?? [], [15, 90, 195, 270])
        XCTAssertNotNil(intersection?.location.latitude)
        XCTAssertNotNil(intersection?.location.longitude)
        XCTAssertEqual(intersection?.usableApproachLanes ?? [], NSIndexSet(indexesInRange: NSRange(location: 1, length: 3)))
        
        XCTAssertEqual(leg.steps[57].names ?? [], ["Logan Circle Northwest"])
        XCTAssertNil(leg.steps[57].codes)
        XCTAssertNil(leg.steps[57].destinationCodes)
        XCTAssertNil(leg.steps[57].destinations)
        
        let lane = intersection?.approachLanes?.first
        let indications = lane?.indications
        XCTAssertNotNil(indications)
        XCTAssertTrue(indications!.contains(.Left))
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
