import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class SpokenInstructionsTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testInstructions() {
        let expectation = self.expectation(description: "calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "false",
            "geometries": "polyline",
            "overview": "full",
            "steps": "true",
            "continue_straight": "true",
            "access_token": BogusToken,
            "voice_instructions": "true",
            "voice_units": "imperial",
            "banner_instructions": "true"
        ]
        
        stub(condition: isHost("api.mapbox.com")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "instructions", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.780602, longitude: -122.431373),
            CLLocationCoordinate2D(latitude: 37.758859, longitude: -122.404058),
            ], profileIdentifier: .automobileAvoidingTraffic)
        options.shapeFormat = .polyline
        options.includesSteps = true
        options.includesAlternativeRoutes = false
        options.routeShapeResolution = .full
        options.includesSpokenInstructions = true
        options.distanceMeasurementSystem = .imperial
        options.includesVisualInstructions = true
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
        XCTAssertNotNil(route)
        XCTAssertEqual(route!.routeIdentifier, "cje68ha21000775o7je87k5em")
        
        let leg = route!.legs.first!
        let step = leg.steps[1]
        
        XCTAssertEqual(step.instructionsSpokenAlongStep!.count, 3)
        
        let spokenInstructions = step.instructionsSpokenAlongStep!
        
        XCTAssertEqual(spokenInstructions[0].distanceAlongStep, 1001.4)
        XCTAssertEqual(spokenInstructions[0].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">Continue on Baker Street for a half mile</prosody></amazon:effect></speak>")
        XCTAssertEqual(spokenInstructions[0].text, "Continue on Baker Street for a half mile")
        
        let visualInstructions = step.instructionsDisplayedAlongStep
        
        XCTAssertNotNil(visualInstructions)
        XCTAssertEqual(visualInstructions?.first?.primaryText, "Oak Street")
        XCTAssertEqual(visualInstructions?.first?.primaryTextComponents.first!.text, "Oak Street")
        XCTAssertEqual(visualInstructions?.first?.distanceAlongStep, 1001.4)
        XCTAssertEqual(visualInstructions?.first?.primaryTextComponents.first?.maneuverType, .turn)
        XCTAssertEqual(visualInstructions?.first?.primaryTextComponents.first?.maneuverDirection, .left)
        XCTAssertEqual(visualInstructions?.first?.primaryTextComponents.first?.type, .text)
        XCTAssertEqual(visualInstructions?.first?.drivingSide, .right)
        XCTAssertNil(visualInstructions?.first?.secondaryText)
        
        XCTAssertEqual(leg.steps[3].instructionsDisplayedAlongStep?.first?.primaryTextComponents[0].type, .image)
        XCTAssertEqual(leg.steps[3].instructionsDisplayedAlongStep?.first?.primaryTextComponents[1].type, .delimiter)
        XCTAssertEqual(leg.steps[3].instructionsDisplayedAlongStep?.first?.primaryTextComponents[2].type, .image)
    }
}
