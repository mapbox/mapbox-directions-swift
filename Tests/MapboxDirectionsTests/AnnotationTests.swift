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
        XCTAssertNotNil(route!.coordinates)
        XCTAssertEqual(route!.coordinates!.count, 128)
        XCTAssertEqual(route!.routeIdentifier, "cjeyp52zv00097iulwb4m8wiw")
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.segmentDistances!.count, 98)
        XCTAssertEqual(leg.segmentSpeeds!.count, 98)
        XCTAssertEqual(leg.expectedSegmentTravelTimes!.count, 98)
        XCTAssertEqual(leg.segmentCongestionLevels!.count, 98)
        XCTAssertEqual(leg.segmentCongestionLevels!.first!, .moderate)
        XCTAssertEqual(leg.segmentMaximumSpeedLimits!.count, 127)
        
        let maxSpeeds = leg.segmentMaximumSpeedLimits!
        
        XCTAssertEqual(maxSpeeds[0].value, 30)
        XCTAssertEqual(maxSpeeds[0].unit, .milesPerHour)
        
        XCTAssertEqual(maxSpeeds[3].value, MBSpeedIsInvalid)
        XCTAssertEqual(maxSpeeds[3].unit, .kilometersPerHour)
        
        XCTAssertEqual(maxSpeeds.last!.value, .greatestFiniteMagnitude)
        XCTAssertEqual(maxSpeeds.last!.unit, .kilometersPerHour)
    }
}
#endif
