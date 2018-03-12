import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class MatchTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func TestMatch() {
        let expectation = self.expectation(description: "calculating directions should return results")
        let locations = [CLLocationCoordinate2D(latitude: 32.712041, longitude: -117.172836),
                         CLLocationCoordinate2D(latitude: 32.712256, longitude: -117.17291),
                         CLLocationCoordinate2D(latitude: 32.712444, longitude: -117.17292),
                         CLLocationCoordinate2D(latitude: 32.71257, longitude: -117.172922),
                         CLLocationCoordinate2D(latitude: 32.7126, longitude: -117.172985),
                         CLLocationCoordinate2D(latitude: 32.712597, longitude: -117.173143),
                         CLLocationCoordinate2D(latitude: 32.712546, longitude: -117.173345)]
        
        stub(condition: isHost("api.mapbox.com")
            && isMethodPOST()
            && isPath("/matching/v5/mapbox/driving")) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "match", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        var match: Match!
        let matchOptions = MatchingOptions(coordinates: locations)
        matchOptions.includesSteps = true
        matchOptions.routeShapeResolution = .full
        
        let task = Directions(accessToken: BogusToken).calculate(matchOptions) { (matches, error) in
            XCTAssertNil(error, "Error: \(error!)")
            
            match = matches!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!)")
            XCTAssertEqual(task.state, .completed)
        }
        
        let opts = match.matchOptions
        XCTAssertEqual(opts, matchOptions)
        
        XCTAssertNotNil(match)
        XCTAssertNotNil(match.coordinates)
        XCTAssertEqual(match.coordinates!.count, 8)
        XCTAssertEqual(match.accessToken, BogusToken)
        XCTAssertEqual(match.apiEndpoint, URL(string: "https://api.mapbox.com"))
        XCTAssertEqual(match.routeIdentifier, nil)
        
        let tracePoints = match.tracepoints!
        XCTAssertNotNil(tracePoints)
        XCTAssertEqual(tracePoints.first!.alternateCount, 0)
        XCTAssertEqual(tracePoints.first!.waypointIndex, 0)
        
        XCTAssertEqual(tracePoints.last!.name, "West G Street")
        XCTAssertEqual(tracePoints.last!.waypointIndex, 6)

        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(match!.coordinates!.first!.latitude), 33)
        XCTAssertEqual(round(match!.coordinates!.first!.longitude), -117)
        XCTAssertEqual(match!.legs.count, 6)
        XCTAssertEqual(match!.confidence, 0.95)

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

