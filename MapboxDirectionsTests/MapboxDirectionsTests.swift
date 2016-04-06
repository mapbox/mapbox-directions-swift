import XCTest
import Nocilla
@testable import MapboxDirections

class MapboxDirectionsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }
    
    override func tearDown() {
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
        super.tearDown()
    }

    func testV4Router() {
        let json = Fixture.stringFromFileNamed("driving_dc_polyline")
        stubRequest("GET", "https://api.mapbox.com/v4/directions/mapbox.driving/-122.42,37.78;-77.03,38.91.json?access_token=\(BogusToken)&alternatives=true&geometry=polyline").andReturn(200).withHeaders(["Content-Type": "application/json"]).withBody(json)
        
        let expectation = expectationWithDescription("v4")
        let request = MBDirectionsRequest(sourceCoordinate: CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42), destinationCoordinate: CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03))
        request.version = .Four
        request.requestsAlternateRoutes = true
        let directions = MBDirections(request: request, accessToken: BogusToken)
        var routes: [MBRoute] = []
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            XCTAssertNil(error, "Error: \(error)")
            XCTAssertFalse(directions.calculating)
            
            XCTAssertNotNil(response)
            routes = response!.routes
            
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) { (error) in
            XCTAssertNil(error, "Error: \(error)")
            XCTAssertFalse(directions.calculating)
        }
        
        XCTAssertEqual(routes.count, 2)
        XCTAssertEqual(routes.first!.geometry!.count, 28268)
        
        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(routes.first!.geometry!.first!.latitude), 38)
        XCTAssertEqual(round(routes.first!.geometry!.first!.longitude), -122)
        XCTAssertEqual(routes.first!.legs.count, 1)
        XCTAssertEqual(routes.first!.legs.first!.steps.count, 136)
        XCTAssertEqual(routes.first!.legs.first!.steps[24].distance, 106_258)
        XCTAssertEqual(routes.first!.legs.first!.steps[24].duration, 3_929)
        XCTAssertEqual(routes.first!.legs.first!.steps[24].name, "I 80")
    }
}
