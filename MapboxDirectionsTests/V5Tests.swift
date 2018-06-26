import XCTest
import OHHTTPStubs
import Polyline
@testable import MapboxDirections

class V5Tests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    typealias JSONTransformer = ((JSONDictionary) -> JSONDictionary)
    
    func test(shapeFormat: RouteShapeFormat, transformer: JSONTransformer? = nil, filePath: String? = nil) {
        let expectation = self.expectation(description: "calculating directions should return results")
        
        let queryParams: [String: String?] = [
            "alternatives": "true",
            "geometries": String(describing: shapeFormat),
            "overview": "full",
            "steps": "true",
            "continue_straight": "true",
            "access_token": BogusToken,
        ]
        stub(condition: isHost("api.mapbox.com")
            && isPath("/directions/v5/mapbox/driving/-122.42,37.78;-77.03,38.91.json")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: filePath ?? "v5_driving_dc_\(shapeFormat)", ofType: "json")
                let filePath = URL(fileURLWithPath: path!)
                let data = try! Data(contentsOf: filePath, options: [])
                let jsonObject = try! JSONSerialization.jsonObject(with: data, options: [])
                let transformedData = transformer?(jsonObject as! JSONDictionary) ?? jsonObject
                return OHHTTPStubsResponse(jsonObject: transformedData, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        let options = RouteOptions(coordinates: [
            CLLocationCoordinate2D(latitude: 37.78, longitude: -122.42),
            CLLocationCoordinate2D(latitude: 38.91, longitude: -77.03),
        ])
        XCTAssertEqual(options.shapeFormat, .polyline, "Route shape format should be Polyline by default.")
        options.shapeFormat = shapeFormat
        options.includesSteps = true
        options.includesAlternativeRoutes = true
        options.routeShapeResolution = .full
        var route: Route?
        let task = Directions(accessToken: BogusToken).calculate(options) { (waypoints, routes, error) in
            XCTAssertNil(error, "Error: \(error!)")
            
            XCTAssertNotNil(routes)
            XCTAssertEqual(routes!.count, 2)
            route = routes!.first!
            
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!)")
            XCTAssertEqual(task.state, .completed)
        }
        
        XCTAssertNotNil(route)
        XCTAssertNotNil(route!.coordinates)
        XCTAssertEqual(route!.coordinates!.count, 28_442)
        XCTAssertEqual(route!.accessToken, BogusToken)
        XCTAssertEqual(route!.apiEndpoint, URL(string: "https://api.mapbox.com"))
        XCTAssertEqual(route!.routeIdentifier, "cj725hpi30yp2ztm2ehbcipmh")
        XCTAssertEqual(route!.speechLocale!.identifier, "en-US")
        
        
        // confirming actual decoded values is important because the Directions API
        // uses an atypical precision level for polyline encoding
        XCTAssertEqual(round(route!.coordinates!.first!.latitude), 38)
        XCTAssertEqual(round(route!.coordinates!.first!.longitude), -122)
        XCTAssertEqual(route!.legs.count, 1)
        
        let opts = route!.routeOptions
        XCTAssertEqual(opts, options)
        
        let leg = route!.legs.first!
        XCTAssertEqual(leg.name, "I 80, I 80;US 30")
        XCTAssertEqual(leg.steps.count, 59)
        
        let firstStep = leg.steps.first
        XCTAssertNotNil(firstStep)
        let firstStepIntersections = firstStep?.intersections
        XCTAssertNotNil(firstStepIntersections)
        let firstIntersection = firstStepIntersections?.first
        XCTAssertNotNil(firstIntersection)
        let roadClasses = firstIntersection?.outletRoadClasses
        XCTAssertNotNil(roadClasses)
        XCTAssertTrue(roadClasses?.contains([.toll, .restricted]) ?? false)
        
        let step = leg.steps[43]
        XCTAssertEqual(round(step.distance), 688)
        XCTAssertEqual(round(step.expectedTravelTime), 30)
        XCTAssertEqual(step.instructions, "Take the ramp on the right towards Washington")
        
        XCTAssertNil(step.names)
        XCTAssertNotNil(step.destinations)
        XCTAssertEqual(step.destinations ?? [], ["Washington"])
        XCTAssertEqual(step.maneuverType, .takeOffRamp)
        XCTAssertEqual(step.maneuverDirection, .slightRight)
        XCTAssertEqual(step.initialHeading, 90)
        XCTAssertEqual(step.finalHeading, 96)
        
        XCTAssertNotNil(step.coordinates)
        XCTAssertEqual(step.coordinates!.count, 17)
        XCTAssertEqual(step.coordinates!.count, Int(step.coordinateCount))
        let coordinate = step.coordinates!.first!
        XCTAssertEqual(round(coordinate.latitude), 39)
        XCTAssertEqual(round(coordinate.longitude), -77)
        
        XCTAssertNil(leg.steps[28].names)
        XCTAssertEqual(leg.steps[28].codes ?? [], ["I 80"])
        XCTAssertEqual(leg.steps[28].destinationCodes ?? [], ["I 80 East", "I 90"])
        XCTAssertEqual(leg.steps[28].destinations ?? [], ["Toll Road"])
        
        XCTAssertEqual(leg.steps[30].names ?? [], ["Ohio Turnpike"])
        XCTAssertEqual(leg.steps[30].codes ?? [], ["I 80", "I 90"])
        XCTAssertNil(leg.steps[30].destinationCodes)
        XCTAssertNil(leg.steps[30].destinations)
        
        let intersections = leg.steps[40].intersections
        XCTAssertNotNil(intersections)
        XCTAssertEqual(intersections?.count, 7)
        let intersection = intersections?[2]
        XCTAssertEqual(intersection?.outletIndexes.contains(0), true)
        XCTAssertEqual(intersection?.outletIndexes.contains(integersIn: 2...3), true)
        XCTAssertEqual(intersection?.approachIndex, 1)
        XCTAssertEqual(intersection?.outletIndex, 3)
        XCTAssertEqual(intersection?.headings ?? [], [15, 90, 195, 270])
        XCTAssertNotNil(intersection?.location.latitude)
        XCTAssertNotNil(intersection?.location.longitude)
        XCTAssertEqual(intersection?.usableApproachLanes, IndexSet(integersIn: 1...3))
        
        XCTAssertNil(leg.steps[57].names)
        XCTAssertEqual(leg.steps[57].exitNames ?? [], ["Logan Circle Northwest"])
        XCTAssertNil(leg.steps[57].codes)
        XCTAssertNil(leg.steps[57].destinationCodes)
        XCTAssertNil(leg.steps[57].destinations)
        
        let lane = intersection?.approachLanes?.first
        let indications = lane?.indications
        XCTAssertNotNil(indications)
        XCTAssertTrue(indications!.contains(.left))
    }
    
    func testGeoJSON() {
        XCTAssertEqual(String(describing: RouteShapeFormat.geoJSON), "geojson")
        test(shapeFormat: .geoJSON)
    }
    
    func testPolyline() {
        XCTAssertEqual(String(describing: RouteShapeFormat.polyline), "polyline")
        test(shapeFormat: .polyline)
    }
    
    func testPolyline6() {
        XCTAssertEqual(String(describing: RouteShapeFormat.polyline6), "polyline6")
        
        // Transform polyline5 to polyline6
        let transformer: JSONTransformer = { json in
            var transformed = json
            var route = (transformed["routes"] as! [JSONDictionary])[0]
            let polyline = route["geometry"] as! String
            
            let decodedCoordinates: [CLLocationCoordinate2D] = decodePolyline(polyline, precision: 1e5)!
            route["geometry"] = Polyline(coordinates: decodedCoordinates, levels: nil, precision: 1e6).encodedPolyline
            
            let legs = route["legs"] as! [JSONDictionary]
            var newLegs = [JSONDictionary]()
            for var leg in legs {
                let steps = leg["steps"] as! [JSONDictionary]
                
                var newSteps = [JSONDictionary]()
                for var step in steps {
                    let geometry = step["geometry"] as! String
                    let coords: [CLLocationCoordinate2D] = decodePolyline(geometry, precision: 1e5)!
                    step["geometry"] = Polyline(coordinates: coords, precision: 1e6).encodedPolyline
                    newSteps.append(step)
                }
                
                leg["steps"] = newSteps
                newLegs.append(leg)
            }
            
            route["legs"] = newLegs
            
            let secondRoute = (json["routes"] as! [JSONDictionary])[1]
            transformed["routes"] = [route, secondRoute]
            
            return transformed
        }
        
        test(shapeFormat: .polyline6, transformer: transformer, filePath: "v5_driving_dc_polyline")
    }
}
