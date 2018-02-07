import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class MatchTest: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func test() {
        let expectation = self.expectation(description: "calculating directions should return results")
        let locations = [CLLocation(coordinate: CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42)),
                         CLLocation(coordinate: CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03))]
        
        let timestamps = locations.map {
            String(describing: $0.timestamp.timeIntervalSince1970)
            }.joined(separator: ";")
        
        /**
         geometries=polyline
         overview=full
         steps=true
         language=en_US
         tidy=false
         timestamps=1516928313.42391;1516928313.42395
         */
        
        let queryParams: [String: String?] = [
            "geometries": "polyline",
            "overview": "full",
            "steps": "true",
            "tidy": "false",
            "access_token": BogusToken,
            ]
        stub(condition: isHost("api.mapbox.com")
            && isPath("/matching/v5/mapbox/driving/-122.42,37.78;-77.03,38.91.json")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "match", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        var match: Match?
        let matchOptions = MatchingOptions(locations: locations)
        matchOptions.includesSteps = true
        matchOptions.routeShapeResolution = .full
        
        let task = Directions(accessToken: BogusToken).match(matchOptions) { (tracePoints, matches, error) in
            XCTAssertNil(error, "Error: \(error!)")
            
            match = matches!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!)")
            XCTAssertEqual(task.state, .completed)
        }
        
        XCTAssertNotNil(match)
        XCTAssertNotNil(match!.coordinates)
        XCTAssertEqual(match!.coordinates!.count, 8)
        XCTAssertEqual(match!.accessToken, BogusToken)
        XCTAssertEqual(match!.apiEndpoint, URL(string: "https://api.mapbox.com"))
        XCTAssertEqual(match!.routeIdentifier, nil)

        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(match!.coordinates!.first!.latitude), 33)
        XCTAssertEqual(round(match!.coordinates!.first!.longitude), -117)
        XCTAssertEqual(match!.legs.count, 6)
        XCTAssertEqual(match!.confidence, 0.95)

        let opts = match!.routeOptions

        XCTAssertEqual(opts, matchOptions)

        let leg = match!.legs.first!
        XCTAssertEqual(leg.name, "North Harbor Drive")
        XCTAssertEqual(leg.steps.count, 2)

        let firstStep = leg.steps.first
        XCTAssertNotNil(firstStep)
        let firstStepIntersections = firstStep?.intersections
        XCTAssertNotNil(firstStepIntersections)
        let firstIntersection = firstStepIntersections?.first
        XCTAssertNotNil(firstIntersection)

        let step = leg.steps[0]
        XCTAssertEqual(round(step.distance), 25)
        XCTAssertEqual(round(step.expectedTravelTime), 3)
        XCTAssertEqual(step.instructions, "Head north on North Harbor Drive")

        XCTAssertEqual(step.maneuverType, .depart)
        XCTAssertEqual(step.maneuverDirection, .none)
        XCTAssertEqual(step.initialHeading, 0)
        XCTAssertEqual(step.finalHeading, 340)

        XCTAssertNotNil(step.coordinates)
        XCTAssertEqual(step.coordinates!.count, 4)
        XCTAssertEqual(step.coordinates!.count, Int(step.coordinateCount))
        let coordinate = step.coordinates!.first!
        XCTAssertEqual(round(coordinate.latitude), 33)
        XCTAssertEqual(round(coordinate.longitude), -117)
    }
}

