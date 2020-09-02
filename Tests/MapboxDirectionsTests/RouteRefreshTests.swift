import XCTest
#if !SWIFT_PACKAGE
import OHHTTPStubs
@testable import MapboxDirections

class RouteRefreshTests: XCTestCase {
    override func setUp() {
        stub(condition: isHost("api.mapbox.com")
            && isMethodGET()
            && pathStartsWith("/directions/v5/mapbox/driving-traffic")) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "routeRefreshRoute", ofType: "json")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        stub(condition: isHost("api.mapbox.com")
            && isMethodGET()
            && pathStartsWith("/directions-refresh/v1/mapbox/driving-traffic")) {
                switch Int($0.url!.lastPathComponent)! {
                case 0...1:
                    let path = Bundle(for: type(of: self)).path(forResource: "routeRefreshResponse", ofType: "json")
                    return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
                default:
                    let path = Bundle(for: type(of: self)).path(forResource: "incorrectRouteRefreshResponse", ofType: "json")
                    return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 422, headers: ["Content-Type": "application/json"])
                }
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
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
        let refreshResponseExpectation = expectation(description: "Refresh responce with incorrect parameters failed.")
        
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
}
#endif
