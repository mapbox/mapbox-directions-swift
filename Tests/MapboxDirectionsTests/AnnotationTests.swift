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
            "annotations": "distance,duration,speed,congestion,maxspeed"
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
        options.attributeOptions = [.distance, .expectedTravelTime, .speed, .congestionLevel, .maximumSpeedLimit]
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
        XCTAssertEqual(route!.coordinates!.count, 171)
        XCTAssertEqual(route!.routeIdentifier, "cjz0ke3xu00367vs13pae5pgp")
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.segmentDistances!.count, 170)
        XCTAssertEqual(leg.segmentSpeeds!.count, 170)
        XCTAssertEqual(leg.expectedSegmentTravelTimes!.count, 170)
        XCTAssertEqual(leg.segmentCongestionLevels!.count, 170)
        XCTAssertEqual(leg.segmentCongestionLevels!.first!, .low)
        XCTAssertEqual(leg.segmentMaximumSpeedLimits!.count, 170)
        
        let maxSpeeds = leg.segmentMaximumSpeedLimits!
        
        XCTAssertEqual(maxSpeeds[0].value, 48)
        XCTAssertEqual(maxSpeeds[0].unit, .kilometersPerHour)
        
        XCTAssertEqual(maxSpeeds[3].value, -1)
        XCTAssertEqual(maxSpeeds[3].unit, .kilometersPerHour)
    }
    
    func testSpeedLimits() {
        XCTAssertEqual(Measurement<UnitSpeed>(json: ["speed": 55.0, "unit": "mph"])?.value, 55.0)
        XCTAssertEqual(Measurement<UnitSpeed>(json: ["speed": 55.0, "unit": "mph"])?.unit, .milesPerHour)
        
        XCTAssertEqual(Measurement<UnitSpeed>(json: ["speed": 80.0, "unit": "km/h"])?.value, 80.0)
        XCTAssertEqual(Measurement<UnitSpeed>(json: ["speed": 80.0, "unit": "km/h"])?.unit, .kilometersPerHour)
        
        XCTAssertNil(Measurement<UnitSpeed>(json: ["unknown": true]))
        
        XCTAssertEqual(Measurement<UnitSpeed>(json: ["none": true])?.value, .greatestFiniteMagnitude)
        XCTAssertEqual(Measurement<UnitSpeed>(json: ["none": true])?.unit, .kilometersPerHour)
    }
}
#endif
