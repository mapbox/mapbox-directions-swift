import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class AnnotationTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testAnnotation() {
        let expectation = self.expectation(description: "calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "false",
            "geometries": "polyline",
            "overview": "full",
            "steps": "false",
            "continue_straight": "true",
            "access_token": BogusToken,
            "annotations": "distance,duration,speed,congestion"
            ]
        
        stub(condition: isHost("api.mapbox.com")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "annotation", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.780602, longitude: -122.431373),
            CLLocationCoordinate2D(latitude: 37.758859, longitude: -122.404058),
            ], profileIdentifier: .automobileAvoidingTraffic)
        options.shapeFormat = .polyline
        options.includesSteps = false
        options.includesAlternativeRoutes = false
        options.routeShapeResolution = .full
        options.attributeOptions = [.distance, .expectedTravelTime, .speed, .congestionLevel]
        var route: Route?
        let task = Directions(accessToken: BogusToken).calculate(options) { (waypoints, routes, error) in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            
            XCTAssertNotNil(routes)
            XCTAssertEqual(routes!.count, 1)
            route = routes!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!.localizedDescription)")
            XCTAssertEqual(task.state, .completed)
        }
        
        XCTAssertNotNil(route)
        XCTAssertNotNil(route!.coordinates)
        XCTAssertEqual(route!.coordinates!.count, 99)
        XCTAssertEqual(route!.routeIdentifier, "cj725hpi30yp2ztm2ehbcipmh")
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.segmentDistances!.count, 98)
        XCTAssertEqual(leg.segmentSpeeds!.count, 98)
        XCTAssertEqual(leg.expectedSegmentTravelTimes!.count, 98)
        XCTAssertEqual(leg.segmentCongestionLevels!.count, 98)
        XCTAssertEqual(leg.segmentCongestionLevels!.first!, .moderate)
        XCTAssertEqual(leg.segmentCongestionLevels!.last!, .low)
    }
}
