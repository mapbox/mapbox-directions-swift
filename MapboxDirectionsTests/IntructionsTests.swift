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
            "voice_units": "imperial"
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
        XCTAssertEqual(route!.routeIdentifier, "cja36hpse006a90nxslafkt4u")
        
        let leg = route!.legs.first!
        let step = leg.steps.first!
        
        XCTAssertEqual(step.instructionsSpokenAlongStep!.count, 3)
        
        let spokenInstructions = step.instructionsSpokenAlongStep!
        
        XCTAssertEqual(spokenInstructions[0].distanceAlongStep, 793.8)
        XCTAssertEqual(spokenInstructions[1].distanceAlongStep, 348.2)
        XCTAssertEqual(spokenInstructions[2].distanceAlongStep, 74.6)
        
        XCTAssertEqual(spokenInstructions[0].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">Head south on <say-as interpret-as=\"address\">8th</say-as> Avenue for a half mile</prosody></amazon:effect></speak>")
        XCTAssertEqual(spokenInstructions[1].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">In a quarter mile, turn left onto John F Kennedy Drive</prosody></amazon:effect></speak>")
        XCTAssertEqual(spokenInstructions[2].ssmlText, "<speak><amazon:effect name=\"drc\"><prosody rate=\"1.08\">Turn left onto John F Kennedy Drive</prosody></amazon:effect></speak>")
        
        XCTAssertEqual(spokenInstructions[0].text, "Head south on 8th Avenue for a half mile")
        XCTAssertEqual(spokenInstructions[1].text, "In a quarter mile, turn left onto John F Kennedy Drive")
        XCTAssertEqual(spokenInstructions[2].text, "Turn left onto John F Kennedy Drive")
        
        let visualInstructions = step.instructionsDisplayedAlongStep!
        
        XCTAssertEqual(visualInstructions.first!.primaryText, "John F Kennedy Drive")
        XCTAssertEqual(visualInstructions.first!.primaryTextComponents.first!.text, "John F Kennedy Drive")
        XCTAssertEqual(visualInstructions.first!.distanceAlongStep, 793.8)
        XCTAssertNil(visualInstructions.first!.secondaryText)
    }
}
