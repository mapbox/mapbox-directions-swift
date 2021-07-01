import XCTest
import Turf
#if !os(Linux)
import OHHTTPStubs
#if SWIFT_PACKAGE
import OHHTTPStubsSwift
#endif
#endif
@testable import MapboxDirections

class RouteRefreshTests: XCTestCase {
    #if !os(Linux)
    override func setUp() {
        stub(condition: isHost("api.mapbox.com")
            && isMethodGET()
            && pathStartsWith("/directions/v5/mapbox/driving-traffic")) { _ in
                let path = Bundle.module.path(forResource: "routeRefreshRoute", ofType: "json")
                return HTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        stub(condition: isHost("api.mapbox.com")
            && isMethodGET()
            && pathStartsWith("/directions-refresh/v1/mapbox/driving-traffic")) {
                switch Int($0.url!.lastPathComponent)! {
                case 0...1:
                    let path = Bundle.module.path(forResource: "routeRefreshResponse", ofType: "json")
                    return HTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
                default:
                    let path = Bundle.module.path(forResource: "incorrectRouteRefreshResponse", ofType: "json")
                    return HTTPStubsResponse(fileAtPath: path!, statusCode: 422, headers: ["Content-Type": "application/json"])
                }
        }
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func fetchStubbedRoute(_ completion: @escaping (RouteResponse) -> ()) {
        let routeOptions = RouteOptions(coordinates: [.init(latitude: 0, longitude: 0),
                                                      .init(latitude: 1, longitude: 1)])
        routeOptions.refreshingEnabled = true
        routeOptions.profileIdentifier = .automobileAvoidingTraffic
        
        Directions(credentials: BogusCredentials).calculate(routeOptions) { (session, result) in
            guard case let .success(response) = result else {
                XCTFail("Encountered unexpected error. \(result)")
                return
            }
            
            completion(response)
        }
    }
    
    func testRefreshRequest() {
        let refreshResponseExpectation = expectation(description: "Refresh responce failed.")
        
        fetchStubbedRoute { routeResponse in
            Directions(credentials: BogusCredentials).refreshRoute(responseIdentifier: routeResponse.identifier!, routeIndex: 0) {
                guard case let .success(refresh) = $1 else {
                    XCTFail("Refresh failed with unexpected error.")
                    return
                }
                
                XCTAssertNotNil(refresh.route, "Route legs are not refreshed")
                refreshResponseExpectation.fulfill()
            }
        }
        
        wait(for: [refreshResponseExpectation], timeout: 3)
    }
    
    func testIncorrectRefreshParameters() {
        let refreshResponseExpectation = expectation(description: "Refresh response with incorrect parameters failed.")
        
        fetchStubbedRoute { routeResponse in

            Directions(credentials: BogusCredentials).refreshRoute(responseIdentifier: routeResponse.identifier!, routeIndex: 10, fromLegAtIndex: 3) {
                guard case let .failure(error) = $1 else {
                    XCTFail("Refresh failed with unexpected error.")
                    return
                }
                
                if case .invalidInput(_) = error {
                    refreshResponseExpectation.fulfill()
                } else {
                    XCTFail("Wrong error returned.")
                }
            }
        }
        
        wait(for: [refreshResponseExpectation], timeout: 3)
    }
    
    func testRouteIsRefreshed() {
        let routeUpdatedExpectation = expectation(description: "Route is not refreshed.")
        let routeIndex = 0
        
        fetchStubbedRoute { routeResponse in
            Directions(credentials: BogusCredentials).refreshRoute(responseIdentifier: routeResponse.identifier!, routeIndex: routeIndex) {
                guard case let .success(refresh) = $1 else {
                    XCTFail("Refresh failed with unexpected error.")
                    return
                }
                
                let route = routeResponse.routes?[routeIndex]
                route?.refreshLegAttributes(from: refresh.route)
                
                XCTAssertEqual(refresh.route.legs[0].attributes, route?.legs[0].attributes, "Route legs are not refreshed")
                routeUpdatedExpectation.fulfill()
            }
        }
        
        wait(for: [routeUpdatedExpectation], timeout: 3)
    }
    
    func testMultiLegRouteIsRefreshed() {
        let routeUpdatedExpectation = expectation(description: "Route is not refreshed correctly.")
        let routeIndex = 0

        fetchStubbedRoute { routeResponse in
            Directions(credentials: BogusCredentials).refreshRoute(responseIdentifier: routeResponse.identifier!, routeIndex: routeIndex) {
                switch $1 {
                case let .success(response):
                    XCTAssertNotNil(response.route)
                    XCTAssertEqual(response.route.legs.count, 2)
                    let route = routeResponse.routes?[routeIndex]
                    route?.refreshLegAttributes(from: response.route)
                    XCTAssertEqual(route?.legs[0].attributes, response.route.legs[0].attributes, "Route legs are not refreshed correctly")
                    XCTAssertEqual(route?.legs[1].attributes, response.route.legs[1].attributes, "Route legs are not refreshed correctly")
                    routeUpdatedExpectation.fulfill()
                case let .failure(error):
                    XCTFail("Refresh failed with unexpected error: \(error).")
                }
            }
        }
        
        wait(for: [routeUpdatedExpectation], timeout: 3)
    }
    #endif
    
    func testDecoding() {
        let routeJSON = [
            "legs": [
                [
                    "annotation": [
                        "distance": [
                            0,
                        ],
                        "duration": [
                            0,
                        ],
                        "speed": [
                            0,
                        ],
                        "congestion": [
                            "severe",
                        ],
                    ],
                ],
            ],
        ] as [String : Any?]
        let routeData = try! JSONSerialization.data(withJSONObject: routeJSON, options: [])
        
        var route: RefreshedRoute?
        XCTAssertNoThrow(route = try JSONDecoder().decode(RefreshedRoute.self, from: routeData))
        XCTAssertNotNil(route)
        XCTAssertEqual(route?.legs.count, 1)
        
        if let leg = route?.legs.first {
            XCTAssertEqual(leg.attributes.segmentDistances, [0])
            XCTAssertEqual(leg.attributes.expectedSegmentTravelTimes, [0])
            XCTAssertEqual(leg.attributes.segmentSpeeds, [0])
            XCTAssertEqual(leg.attributes.segmentCongestionLevels, [.severe])
            XCTAssertNil(leg.attributes.segmentMaximumSpeedLimits)
        }
    }
    
    func testEncoding() {
        let leg = RefreshedRouteLeg(attributes:
            .init(segmentDistances: [0], expectedSegmentTravelTimes: [0], segmentSpeeds: [0], segmentCongestionLevels: [CongestionLevel.severe], segmentMaximumSpeedLimits: [Measurement(value: 1, unit: UnitSpeed.milesPerHour)]))
        let route = RefreshedRoute(legs: [leg])
        
        var encodedRouteData: Data?
        XCTAssertNoThrow(encodedRouteData = try JSONEncoder().encode(route))
        XCTAssertNotNil(encodedRouteData)
        
        if let encodedRouteData = encodedRouteData {
            var encodedRouteJSON: [String: Any?]?
            XCTAssertNoThrow(encodedRouteJSON = try JSONSerialization.jsonObject(with: encodedRouteData, options: []) as? [String: Any?])
            XCTAssertNotNil(encodedRouteJSON)
            
            let legsJSON = encodedRouteJSON?["legs"] as? [[String: Any?]]
            XCTAssertNotNil(legsJSON)
            XCTAssertEqual(legsJSON?.count, 1)
            if let legJSON = legsJSON?.first {
                let annotationJSON = legJSON["annotation"] as? [String: Any]
                XCTAssertNotNil(annotationJSON)
                if let annotationJSON = annotationJSON {
                    XCTAssertEqual(annotationJSON["distance"] as? [LocationDistance], [0])
                    XCTAssertEqual(annotationJSON["duration"] as? [TimeInterval], [0])
                    XCTAssertEqual(annotationJSON["speed"] as? [LocationSpeed], [0])
                    XCTAssertEqual(annotationJSON["congestion"] as? [String], ["severe"])
                    
                    let maxspeedsJSON = annotationJSON["maxspeed"] as? [[String: Any?]]
                    XCTAssertNotNil(maxspeedsJSON)
                    if let maxspeedJSON = maxspeedsJSON?.first {
                        XCTAssertEqual(maxspeedJSON["speed"] as? Double, 1)
                        XCTAssertEqual(maxspeedJSON["unit"] as? String, "mph")
                    }
                }
            }
        }
    }
}
