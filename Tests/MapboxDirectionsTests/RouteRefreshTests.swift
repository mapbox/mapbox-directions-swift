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
        
        stub(condition: isHost("api.mapbox.com")
            && isMethodGET()
            && containsQueryParams(["current_route_geometry_index": "9"])
            && pathStartsWith("/directions-refresh/v1/mapbox/driving-traffic")) { _ in
            let path = Bundle.module.path(forResource: "partialRouteRefreshResponse", ofType: "json")
            return HTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: ["Content-Type": "application/json"])
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
                route?.refresh(from: refresh.route)
                
                XCTAssertEqual(refresh.route.legs[0].attributes, route?.legs[0].attributes, "Route legs attributes are not refreshed")
                XCTAssertEqual(refresh.route.legs[0].incidents, route?.legs[0].incidents, "Route legs incidents are not refreshed")
                XCTAssertEqual(refresh.route.legs[0].closures, route?.legs[0].closures, "Route legs closures are not refreshed")
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
                    route?.refresh(from: response.route)
                    XCTAssertEqual(route?.legs[0].attributes, response.route.legs[0].attributes, "Route legs attributes are not refreshed correctly")
                    XCTAssertEqual(route?.legs[1].attributes, response.route.legs[1].attributes, "Route legs attributes are not refreshed correctly")
                    XCTAssertEqual(route?.legs[0].incidents, response.route.legs[0].incidents, "Route legs incidents are not refreshed correctly")
                    XCTAssertEqual(route?.legs[1].incidents, response.route.legs[1].incidents, "Route legs incidents are not refreshed correctly")
                    XCTAssertEqual(route?.legs[0].closures, response.route.legs[0].closures, "Route legs closures are not refreshed correctly")
                    XCTAssertEqual(route?.legs[1].closures, response.route.legs[1].closures, "Route legs closures are not refreshed correctly")
                    routeUpdatedExpectation.fulfill()
                case let .failure(error):
                    XCTFail("Refresh failed with unexpected error: \(error).")
                }
            }
        }
        
        wait(for: [routeUpdatedExpectation], timeout: 3)
    }
    
    func testRouteIsRefreshedFromGeometryIndex() {
        let routeUpdatedExpectation = expectation(description: "Route is not refreshed.")
        let routeIndex = 0
        let legIndex = 0
        let geometryIndex = 9
        
        fetchStubbedRoute { routeResponse in
            Directions(credentials: BogusCredentials).refreshRoute(responseIdentifier: routeResponse.identifier!,
                                                                   routeIndex: routeIndex,
                                                                   fromLegAtIndex: legIndex,
                                                                   currentRouteShapeIndex: geometryIndex) {
                guard case let .success(refresh) = $1 else {
                    XCTFail("Refresh failed with unexpected error.")
                    return
                }
                
                let route = routeResponse.routes?[routeIndex]
                let originalCongestions = route!.legs[0].attributes.segmentCongestionLevels!
                let originalIncidents = route!.legs.map(\.incidents)
                let originalClosures = route!.legs.map(\.closures)
                
                route?.refresh(from: refresh.route,
                               refreshParameters: .init(startingIndex: .init(legIndex: legIndex,
                                                                             legShapeIndex: geometryIndex)))
                
                let refreshCongestions = refresh.route.legs[0].attributes.segmentCongestionLevels!
                let refreshedCongestions = route!.legs[0].attributes.segmentCongestionLevels!
                let refreshIncidents = refresh.route.legs.map(\.incidents)
                let refreshedIncidents = route!.legs.map(\.incidents)
                let refreshClosures = refresh.route.legs.map(\.closures)
                let refreshedClosures = route!.legs.map(\.closures)
                
                XCTAssertEqual(originalCongestions[PartialRangeUpTo(geometryIndex)],
                               refreshedCongestions[PartialRangeUpTo(geometryIndex)],
                               "Traversed portions of legs attributes should remain equal")
                XCTAssertNotEqual(originalCongestions[PartialRangeFrom(geometryIndex)],
                                  refreshedCongestions[PartialRangeFrom(geometryIndex)],
                                  "Future portions of legs attributes should be refreshed")
                XCTAssertEqual(refreshCongestions[PartialRangeFrom(0)],
                               refreshedCongestions[PartialRangeFrom(geometryIndex)],
                               "Route legs attributes are not refreshed")
                
                XCTAssertNotEqual(originalIncidents,
                                  refreshedIncidents,
                                  "Incidents should be refreshed")
                XCTAssertNotEqual(originalClosures,
                                  refreshedClosures,
                                  "Closures should be refreshed")
                for leg in zip(refreshIncidents, refreshedIncidents).enumerated() {
                    let (new, updated) = leg.element
                    if leg.offset == legIndex {
                        XCTAssertEqual(new != nil, updated != nil)

                        if let new = new, let updated = updated {
                            for incident in zip(new, updated) {
                                var offsetNewIncident = incident.0
                                // refreshed ranges should be offset by leg shape index
                                let startIndex = offsetNewIncident.shapeIndexRange.lowerBound + geometryIndex
                                let endIndex = offsetNewIncident.shapeIndexRange.upperBound + geometryIndex
                                offsetNewIncident.shapeIndexRange = startIndex..<endIndex
                                XCTAssertEqual(offsetNewIncident, incident.1, "Incidents are not refreshed")
                            }
                        }
                    } else {
                        XCTAssertEqual(new, updated, "Incidents are not refreshed")
                    }
                }
                for leg in zip(refreshClosures, refreshedClosures).enumerated() {
                    let (new, updated) = leg.element
                    if leg.offset == legIndex {
                        XCTAssertEqual(new != nil, updated != nil)

                        if let new = new, let updated = updated {
                            for closure in zip(new, updated) {
                                var offsetNewClosure = closure.0
                                // refreshed ranges should be offset by leg shape index
                                let startIndex = offsetNewClosure.shapeIndexRange.lowerBound + geometryIndex
                                let endIndex = offsetNewClosure.shapeIndexRange.upperBound + geometryIndex
                                offsetNewClosure.shapeIndexRange = startIndex..<endIndex
                                XCTAssertEqual(offsetNewClosure, closure.1, "Closures are not refreshed")
                            }
                        }
                    } else {
                        XCTAssertEqual(new, updated, "Closures are not refreshed")
                    }
                }
                
                routeUpdatedExpectation.fulfill()
            }
        }
        
        wait(for: [routeUpdatedExpectation], timeout: 3)
    }
    
    func testRouteRefreshedFromIncorrectGeometryIndex() {
        let routeUpdatedExpectation = expectation(description: "Route is not refreshed.")
        let routeIndex = 0
        let legIndex = 0
        let geometryIndex = 9
        
        fetchStubbedRoute { routeResponse in
            Directions(credentials: BogusCredentials).refreshRoute(responseIdentifier: routeResponse.identifier!,
                                                                   routeIndex: routeIndex,
                                                                   fromLegAtIndex: legIndex,
                                                                   currentRouteShapeIndex: geometryIndex) {
                guard case let .success(refresh) = $1 else {
                    XCTFail("Refresh failed with unexpected error.")
                    return
                }
                
                let route = routeResponse.routes?[routeIndex]
                let originalCongestions = route!.legs[0].attributes.segmentCongestionLevels!
                
                // should remain the same
                route?.refreshLegAttributes(from: refresh.route,
                                            legIndex: legIndex,
                                            legShapeIndex: geometryIndex + 1)
                
                var refreshedCongestions = route!.legs[0].attributes.segmentCongestionLevels!
                
                XCTAssertEqual(originalCongestions,
                               refreshedCongestions,
                               "Too long refreshed annotations should be skipped.")
                
                // should still apply
                route?.refreshLegAttributes(from: refresh.route,
                                            legIndex: legIndex,
                                            legShapeIndex: geometryIndex - 1)
                
                let refreshCongestions = refresh.route.legs[0].attributes.segmentCongestionLevels!
                refreshedCongestions = route!.legs[0].attributes.segmentCongestionLevels!
                
                XCTAssertEqual(originalCongestions[PartialRangeUpTo(geometryIndex - 1)],
                               refreshedCongestions[PartialRangeUpTo(geometryIndex - 1)],
                               "Traversed portions of legs attributes should remain equal")
                XCTAssertNotEqual(originalCongestions[PartialRangeFrom(geometryIndex - 1)],
                                  refreshedCongestions[PartialRangeFrom(geometryIndex - 1)],
                                  "Future portions of legs attributes should be refreshed")
                XCTAssertEqual(refreshCongestions[PartialRangeFrom(0)],
                               refreshedCongestions[(geometryIndex - 1)..<(refreshCongestions.count + (geometryIndex - 1))],
                               "Route legs attributes are not refreshed")
                
                routeUpdatedExpectation.fulfill()
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
                        "congestion_numeric": [
                            100,
                        ],
                        "traffic_tendency": [
                            0,
                        ]
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
            XCTAssertEqual(leg.attributes.segmentNumericCongestionLevels, [100])
            XCTAssertEqual(leg.attributes.trafficTendencies, [.unknown])
            XCTAssertNil(leg.attributes.segmentMaximumSpeedLimits)
        }
    }
    
    func testEncoding() {
        let leg = RefreshedRouteLeg(attributes:
                .init(segmentDistances: [0],
                      expectedSegmentTravelTimes: [0],
                      segmentSpeeds: [0],
                      segmentCongestionLevels: [CongestionLevel.severe],
                      segmentMaximumSpeedLimits: [Measurement(value: 1, unit: UnitSpeed.milesPerHour)],
                      trafficTendencies: [.constant]))
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
                    XCTAssertEqual(annotationJSON["traffic_tendency"] as? [Int], [TrafficTendency.constant.rawValue])
                    
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
