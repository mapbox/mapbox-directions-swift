import XCTest
import OHHTTPStubs
@testable import MapboxDirections

class SpokenInstructionsTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testPrimaryAndSecondaryInstructions() {
        let expectation = self.expectation(description: "calculating directions with primary and secondary instructions should return results")
        
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
        
        let visualInstructions = step.instructionsDisplayedAlongStep
        let visualInstructionComponent = visualInstructions?.first?.primaryInstruction.components.first as! VisualInstructionComponent
        
        XCTAssertNotNil(visualInstructions)
        XCTAssertNotNil(visualInstructionComponent)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.text, "Page Street")
        XCTAssertEqual(visualInstructionComponent.text, "Page Street")
        XCTAssertEqual(visualInstructions?.first?.distanceAlongStep, 1107.1)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.finalHeading, 180.0)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.maneuverType, .turn)
        XCTAssertEqual(visualInstructions?.first?.primaryInstruction.maneuverDirection, .left)
        XCTAssertEqual(visualInstructionComponent.type, .text)
        XCTAssertEqual(visualInstructionComponent.abbreviation, "Page St")
        XCTAssertEqual(visualInstructionComponent.abbreviationPriority, 0)
        XCTAssertEqual(visualInstructions?.first?.drivingSide, .right)
        XCTAssertNil(visualInstructions?.first?.secondaryInstruction)
        
        let arrivalVisualInstructions = arrivalStep.instructionsDisplayedAlongStep!
        XCTAssertEqual(arrivalVisualInstructions.first?.secondaryInstruction?.text, "the gym")
    }
    
    func testSubWithLaneInstructions() {
        let expectation = self.expectation(description: "calculating directions with tertiary lane instructions should return results")
        let queryParams: [String: String?] = [
            "geometries": "polyline",
            "steps": "true",
            "access_token": BogusToken,
            "banner_instructions": "true"
        ]
        
        stub(condition: isHost("api.mapbox.com") && containsQueryParams(queryParams)) { _ in
            let path = Bundle(for: type(of: self)).path(forResource: "subLaneInstructions", ofType: "json")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let startWaypoint =  Waypoint(coordinate: CLLocationCoordinate2D(latitude: 39.132063, longitude: -84.531074))
        let endWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 39.138953, longitude: -84.532934))
        
        let options = RouteOptions(waypoints: [startWaypoint, endWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        options.shapeFormat = .polyline
        options.includesSteps = true
        options.includesAlternativeRoutes = false
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
        XCTAssertEqual(route!.routeIdentifier, "cjikck25m00v279ms1knttdgc")
        
        let step = route!.legs.first!.steps.first!
        let visualInstructions = step.instructionsDisplayedAlongStep
        
        let tertiaryInstruction = visualInstructions?.first?.tertiaryInstruction
        XCTAssertNotNil(tertiaryInstruction)
        XCTAssertEqual(tertiaryInstruction?.text, "")
        
        let tertiaryInstructionComponents = tertiaryInstruction?.components
        XCTAssertNotNil(tertiaryInstructionComponents)
        let laneIndicationComponents = tertiaryInstructionComponents?.compactMap { $0 as? LaneIndicationComponent }
        XCTAssertEqual(laneIndicationComponents?.count, 2)
        
        if let laneIndicationComponents = laneIndicationComponents {
            
            let inActiveLane = laneIndicationComponents[0]
            XCTAssertEqual(inActiveLane.isUsable, false)
            XCTAssertEqual(inActiveLane.indications, [.straightAhead])
            
            let activeLane = laneIndicationComponents[1]
            XCTAssertEqual(activeLane.isUsable, true)
            XCTAssertEqual(activeLane.indications, [.right])
        }
    }
    
    func testSubWithVisualInstructions() {
        let expectation = self.expectation(description: "calculating directions with tertiary visual instructions should return results")
        let queryParams: [String: String?] = [
            "geometries": "polyline",
            "steps": "true",
            "access_token": BogusToken,
            "banner_instructions": "true"
        ]
        
        stub(condition: isHost("api.mapbox.com") && containsQueryParams(queryParams)) { _ in
            let path = Bundle(for: type(of: self)).path(forResource: "subVisualInstructions", ofType: "json")
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let startWaypoint =  Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.775469, longitude: -122.449158))
        let endWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.347439837741376, longitude: -121.92883115196378))
        
        let options = RouteOptions(waypoints: [startWaypoint, endWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        options.shapeFormat = .polyline
        options.includesSteps = true
        options.includesAlternativeRoutes = false
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
        XCTAssertEqual(route!.routeIdentifier, "cjilrvx2200447omltwdayvm4")
        
        let step = route!.legs.first!.steps.first!
        let visualInstructions = step.instructionsDisplayedAlongStep
        
        let tertiaryInstruction = visualInstructions?.first?.tertiaryInstruction
        let tertiaryInstructionComponent = tertiaryInstruction?.components.first as! VisualInstructionComponent
        
        XCTAssertNotNil(tertiaryInstruction)
        XCTAssertEqual(tertiaryInstruction?.text, "Grove Street")
        XCTAssertEqual(tertiaryInstruction?.maneuverType, .turn)
        XCTAssertEqual(tertiaryInstruction?.maneuverDirection, .left)
        
        XCTAssertNotNil(tertiaryInstructionComponent)
        XCTAssertEqual(tertiaryInstructionComponent.text, "Grove Street")
        XCTAssertEqual(tertiaryInstructionComponent.type, .text)
        XCTAssertEqual(tertiaryInstructionComponent.abbreviation, "Grove St")
        XCTAssertEqual(tertiaryInstructionComponent.abbreviationPriority, 0)
    }
}
