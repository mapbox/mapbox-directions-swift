import XCTest
#if !SWIFT_PACKAGE
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
        if let route = route {
            XCTAssertNotNil(route.shape)
            XCTAssertEqual(route.shape?.coordinates.count, 155)
            XCTAssertEqual(route.routeIdentifier, "ck2l3ymrx18ws68qo1ukqt9p1")
        }
        
        if let leg = route?.legs.first {
            XCTAssertEqual(leg.segmentDistances?.count, 154)
            XCTAssertEqual(leg.segmentSpeeds?.count, 154)
            XCTAssertEqual(leg.expectedSegmentTravelTimes?.count, 154)
            XCTAssertEqual(leg.segmentCongestionLevels?.count, 154)
            XCTAssertEqual(leg.segmentCongestionLevels?.firstIndex(of: .unknown), 134)
            XCTAssertEqual(leg.segmentCongestionLevels?.firstIndex(of: .low), 0)
            XCTAssertEqual(leg.segmentCongestionLevels?.firstIndex(of: .moderate), 19)
            XCTAssertEqual(leg.segmentCongestionLevels?.firstIndex(of: .heavy), 29)
            XCTAssertFalse(leg.segmentCongestionLevels?.contains(.severe) ?? true)
        }
    }
}
#endif
