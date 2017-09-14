import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class VoiceInstructionsTest: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testVoiceInstructions() {
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
                let path = Bundle(for: type(of: self)).path(forResource: "voiceInstructions", ofType: "json")
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
        options.includesVoiceInstructions = true
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
        XCTAssertNotNil(route!.coordinates)
        XCTAssertEqual(route!.coordinates!.count, 177)
        XCTAssertEqual(route!.routeIdentifier, "cj7krdz9e039sy8mej9uiw252")
        
        let leg = route!.legs.first!
        let step = leg.steps.first!
        
        XCTAssertEqual(step.instructionsSpokenAlongStep!.count, 3)
        
        let voiceInstructions = step.instructionsSpokenAlongStep!
        
        XCTAssertEqual(voiceInstructions[0].distanceAlongStep, 793.8)
        XCTAssertEqual(voiceInstructions[1].distanceAlongStep, 304.0)
        XCTAssertEqual(voiceInstructions[2].distanceAlongStep, 65.1)
        
        XCTAssertEqual(voiceInstructions[0].ssmlText, "<speak>Head south on 8th Avenue</speak>")
        XCTAssertEqual(voiceInstructions[1].ssmlText, "<speak>In 1000 feet, turn left onto John F Kennedy Drive</speak>")
        XCTAssertEqual(voiceInstructions[2].ssmlText, "<speak>Turn left onto John F Kennedy Drive</speak>")
        
        XCTAssertEqual(voiceInstructions[0].text, "Head south on 8th Avenue")
        XCTAssertEqual(voiceInstructions[1].text, "In 1000 feet, turn left onto John F Kennedy Drive")
        XCTAssertEqual(voiceInstructions[2].text, "Turn left onto John F Kennedy Drive")
    }
}
