
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
    
    func fetchStubbedRoute(_ completion: @escaping (Route) -> ()) {
        let routeOptions = RouteOptions(coordinates: [.init(latitude: 0, longitude: 0),
                                                      .init(latitude: 1, longitude: 1)])
        routeOptions.refreshingEnabled = true
        routeOptions.profileIdentifier = .automobileAvoidingTraffic
        
        Directions(credentials: BogusCredentials).calculate(routeOptions) { (session, result) in
            guard case let .success(resp) = result else {
                XCTFail("Encountered unexpected error. \(result)")
                return
            }
            
            completion(resp.routes!.first!)
        }
    }
    
    func fetchStubbedRefresh(_ route: Route, legIndex: Int, completion: @escaping Directions.RouteRefreshCompletionHandler) {
        Directions(credentials: BogusCredentials).refresh(route: route,
                                                          currentLegIndex: legIndex,
                                                          completionHandler: completion)
        
    }
    
    func testRefreshRequest() {
        let refreshResponseExpectation = expectation(description: "Refresh responce failed.")
        
        fetchStubbedRoute { route in
            Directions(credentials: BogusCredentials).refresh(route: route,
                                                              currentLegIndex: 0) {
                                                                guard case let .success(refresh) = $1 else {
                                                                    XCTFail("Refresh failed with unexpected error.")
                                                                    return
                                                                }
                                                                
                                                                if refresh.route != nil {
                                                                    refreshResponseExpectation.fulfill()
                                                                } else {
                                                                    XCTFail("Route Legs are not refreshed")
                                                                }
            }
        }
        
        wait(for: [refreshResponseExpectation], timeout: 3)
    }
    
    func testIncorrectRefreshParameters() {
        let refreshResponseExpectation = expectation(description: "Refresh responce with incorrect parameters failed.")
        
        fetchStubbedRoute { route in
            route.routeIdentifier = "incorrect_route_id"
            Directions(credentials: BogusCredentials).refresh(route: route,
                                                              currentLegIndex: 3) {
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
        
        fetchStubbedRoute { route in
            Directions(credentials: BogusCredentials).refresh(route: route,
                                                              currentLegIndex: 0) {
                                                                guard case let .success(refresh) = $1 else {
                                                                    XCTFail("Refresh failed with unexpected error.")
                                                                    return
                                                                }
                                                                
                                                                if refresh.route?.legs != route.legs {
                                                                    routeUpdatedExpectation.fulfill()
                                                                } else {
                                                                    XCTFail("Route Legs are not refreshed")
                                                                }
            }
        }
        
        wait(for: [routeUpdatedExpectation], timeout: 3)
    }
    
    func testMultiLegRouteIsRefreshed() {
        let routeUpdatedExpectation = expectation(description: "Route is not refreshed correctly.")
        
        fetchStubbedRoute { route in
            Directions(credentials: BogusCredentials).refresh(route: route,
                                                              currentLegIndex: 1) {
                                                                guard case let .success(refresh) = $1 else {
                                                                    XCTFail("Refresh failed with unexpected error.")
                                                                    return
                                                                }
                                                                
                                                                if refresh.route?.legs[0] == route.legs[0] &&
                                                                    refresh.route?.legs[1] != route.legs[1]  {
                                                                    routeUpdatedExpectation.fulfill()
                                                                } else {
                                                                    XCTFail("Route Legs are not refreshed correctly")
                                                                }
            }
        }
        
        wait(for: [routeUpdatedExpectation], timeout: 3)
    }
}
#endif
