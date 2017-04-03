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
        let segmentAttributes = leg.segmentAttributes!
        XCTAssertEqual(segmentAttributes.count, 3)
        XCTAssertNotNil(segmentAttributes[.distance])
        XCTAssertNotNil(segmentAttributes[.expectedTravelTime])
        XCTAssertNotNil(segmentAttributes[.speed])
        
        let nodeAttributes = leg.nodeAttributes!
        XCTAssertNotNil(nodeAttributes[.openStreetMapNodeIdentifier])
        
        let nodes = nodeAttributes[.openStreetMapNodeIdentifier]!.count
        XCTAssertEqual(nodes, 93)
        
        XCTAssertEqual(segmentAttributes[.speed]!.count, nodes - 1)
        XCTAssertEqual(segmentAttributes[.distance]!.count, nodes - 1)
        XCTAssertEqual(segmentAttributes[.expectedTravelTime]!.count, nodes - 1)
    }
}
