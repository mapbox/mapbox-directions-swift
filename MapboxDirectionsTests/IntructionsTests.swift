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
            "banner_instructions": "true",
            "waypoint_names": "the hotel;the gym"
        ]
        
        stub(condition: isHost("api.mapbox.com")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "instructions", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let startWaypoint = Waypoint(location:  CLLocation(latitude: 37.780602, longitude: -122.431373), heading: nil, name: "the hotel")
        let endWaypoint = Waypoint(location: CLLocation(latitude: 37.758859, longitude: -122.404058), heading: nil, name: "the gym")
        
        let options = RouteOptions(waypoints: [startWaypoint, endWaypoint], profileIdentifier: .automobileAvoidingTraffic)
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
        XCTAssertEqual(route!.routeIdentifier, "cjgy4xps418g17mo7l2pdm734")
        
        let leg = route!.legs.first!
        let step = leg.steps[1]
        
        XCTAssertEqual(step.instructionsSpokenAlongStep!.count, 3)
        
        let spokenInstructions = step.instructionsSpokenAlongStep!
        
        XCTAssertEqual(spokenInstructions[0].distanceAlongStep, 1107.1)
        XCTAssertEqual(spokenInstructions[0].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">Continue on Baker Street for a half mile</prosody></amazon:effect></speak>")
        XCTAssertEqual(spokenInstructions[0].text, "Continue on Baker Street for a half mile")
        XCTAssertEqual(spokenInstructions[1].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">In 900 feet, turn left onto Page Street</prosody></amazon:effect></speak>")
        XCTAssertEqual(spokenInstructions[1].text, "In 900 feet, turn left onto Page Street")
        XCTAssertEqual(spokenInstructions[2].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">Turn left onto Page Street</prosody></amazon:effect></speak>")
        XCTAssertEqual(spokenInstructions[2].text, "Turn left onto Page Street")
        
        let arrivalStep = leg.steps[leg.steps.endIndex - 2]
        XCTAssertEqual(arrivalStep.instructionsSpokenAlongStep!.count, 1)
        
        let arrivalSpokenInstructions = arrivalStep.instructionsSpokenAlongStep!
        XCTAssertEqual(arrivalSpokenInstructions[0].text, "You have arrived at the gym")
        XCTAssertEqual(arrivalSpokenInstructions[0].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">You have arrived at the gym</prosody></amazon:effect></speak>")
        
        var visualInstructions = step.instructionsDisplayedAlongStep
        
        XCTAssertNotNil(visualInstructions)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.text, "Page Street")
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.textComponents.first!.text, "Page Street")
        XCTAssertEqual(visualInstructions?.first?.distanceAlongStep, 1107.1)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.finalHeading, 180.0)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.maneuverType, .turn)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.maneuverDirection, .left)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.textComponents.first?.type, .text)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.textComponents.first?.abbreviation, "Page St")
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.textComponents.first?.abbreviationPriority, 0)
        XCTAssertEqual(visualInstructions?.first?.drivingSide, .right)
        XCTAssertNil(visualInstructions?.first?.secondaryInstruction)
        
        let arrivalVisualInstructions = arrivalStep.instructionsDisplayedAlongStep!
        XCTAssertEqual(arrivalVisualInstructions.first?.secondaryInstruction?.text, "the gym")
        
        // Tertiary Visual Instructions
        visualInstructions = leg.steps[5].instructionsDisplayedAlongStep
        XCTAssertNotNil(visualInstructions)
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.text, "Bayshore Boulevard")
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.textComponents.first?.text, "Bayshore Boulevard")
        XCTAssertEqual(visualInstructions?.first?.distanceAlongStep, 120.7)
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.finalHeading, 180.0)
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.maneuverType, .reachFork)
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.maneuverDirection, .right)
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.textComponents.first?.abbreviation, "Bayshore Blvd")
        XCTAssertEqual(visualInstructions?.first?.tertiaryInstruction?.textComponents.first?.abbreviationPriority, 0)
        XCTAssertEqual(visualInstructions?.first?.drivingSide, .right)
    }
}
