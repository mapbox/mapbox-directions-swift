import XCTest
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
            "alternatives": "true",
            "geometries": "polyline",
            "overview": "full",
            "steps": "true",
            "continue_straight": "true",
            "access_token": BogusToken,
            "annotations": "distance,duration,nodes,speed"
            ]
    
        stub(condition: isHost("api.mapbox.com")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "annotation", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.780602, longitude: -122.431373),
            CLLocationCoordinate2D(latitude: 37.758859, longitude: -122.404058),
            ])
        options.shapeFormat = .polyline
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        options.routeShapeResolution = .full
        options.segmentAttributes = [.distance, .expectedTravelTime, .openStreetMapNodeIdentifier, .speed]
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
        XCTAssertEqual(route!.coordinates!.count, 93)
        
        let leg = route!.legs.first!
        let annotation = leg.segmentAttributes!
        XCTAssertEqual(annotation.count, 4)
        XCTAssertNotNil(annotation[.distance])
        XCTAssertNotNil(annotation[.expectedTravelTime])
        XCTAssertNotNil(annotation[.openStreetMapNodeIdentifier])
        XCTAssertNotNil(annotation[.speed])
        
        let nodes = annotation[.openStreetMapNodeIdentifier]!.count
        
        XCTAssertEqual(annotation[.speed]!.count, nodes - 1)
        XCTAssertEqual(annotation[.distance]!.count, nodes - 1)
        XCTAssertEqual(annotation[.expectedTravelTime]!.count, nodes - 1)
    }
}
