import XCTest
import Turf
@testable import MapboxDirections

class RouteLegTests: XCTestCase {
    func testSegmentRanges() {
        let departureStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 0, longitude: 0), maneuverType: .depart, instructions: "Depart", drivingSide: .right, distance: 10, expectedTravelTime: 10)
        departureStep.shape = LineString([
            LocationCoordinate2D(latitude: 0, longitude: 0),
            LocationCoordinate2D(latitude: 1, longitude: 1),
        ])
        let noShapeStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 1, longitude: 1), maneuverType: .continue, instructions: "Continue", drivingSide: .right, distance: 0, expectedTravelTime: 0)
        let turnStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 1, longitude: 1), maneuverType: .turn, maneuverDirection: .left, instructions: "Turn left at Albuquerque", drivingSide: .right, distance: 10, expectedTravelTime: 10)
        turnStep.shape = LineString([
            LocationCoordinate2D(latitude: 1, longitude: 1),
            LocationCoordinate2D(latitude: 2, longitude: 2),
            LocationCoordinate2D(latitude: 3, longitude: 3),
            LocationCoordinate2D(latitude: 4, longitude: 4),
        ])
        let typicalTravelTime = 10.0
        let arrivalStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 4, longitude: 4), maneuverType: .arrive, instructions: "Arrive at Elmer’s House", drivingSide: .right, distance: 0, expectedTravelTime: 0)
        arrivalStep.shape = LineString([
            LocationCoordinate2D(latitude: 4, longitude: 4),
            LocationCoordinate2D(latitude: 4, longitude: 4),
        ])
        let leg = RouteLeg(steps: [departureStep, noShapeStep, turnStep, arrivalStep], name: "", distance: 10, expectedTravelTime: 10, typicalTravelTime: typicalTravelTime, profileIdentifier: .automobile)
        leg.segmentDistances = [
            10,
            10, 20, 30,
        ]
        XCTAssertEqual(leg.segmentRangesByStep.count, leg.steps.count)
        XCTAssertEqual(leg.segmentRangesByStep, [0..<1, 1..<1, 1..<4, 4..<4])
        XCTAssertEqual(leg.segmentRangesByStep.last?.upperBound, leg.segmentDistances?.count)
        XCTAssertEqual(leg.typicalTravelTime, typicalTravelTime)
    }
    
    func testNotificationsCoding() {
        guard let fixtureURL = Bundle.module.url(forResource: "RouteResponseWithNotifications",
                                                 withExtension:"json") else {
            XCTFail()
            return
        }
        guard let fixtureData = try? Data(contentsOf: fixtureURL, options:.mappedIfSafe) else {
            XCTFail()
            return
        }
    
        var fixtureJSON: [String: Any?]?
        XCTAssertNoThrow(fixtureJSON = try JSONSerialization.jsonObject(with: fixtureData, options: []) as? [String: Any?])
        
        let options = RouteOptions(coordinates: [.init(latitude: 0,
                                                       longitude: 0),
                                                 .init(latitude: 1,
                                                       longitude: 1)])
        options.shapeFormat = .geoJSON
        let decoder = JSONDecoder()
        decoder.userInfo[.options] = options
        decoder.userInfo[.credentials] = BogusCredentials
        var response: RouteResponse?
        XCTAssertNoThrow(response = try decoder.decode(RouteResponse.self, from: fixtureData))
        
        let encoder = JSONEncoder()
        encoder.userInfo[.options] = options
        encoder.userInfo[.credentials] = BogusCredentials
        
        let notifications = response?.routes?.first?.legs.first?.notifications
        XCTAssertNotNil(notifications)
        XCTAssertEqual(notifications?.count, 5)
        
        var encodedResponse: Data?
        var encodedRouteResponseJSON: [String: Any?]?
        
        XCTAssertNoThrow(encodedResponse = try encoder.encode(response))
        XCTAssertNoThrow(encodedRouteResponseJSON = try JSONSerialization.jsonObject(with: encodedResponse!, options: []) as? [String: Any?])
        XCTAssertNotNil(encodedRouteResponseJSON)
        
        // Remove default keys not found in the original API response.
        if var encodedRoutesJSON = encodedRouteResponseJSON?["routes"] as? [[String: Any?]] {
            if var encodedLegJSON = encodedRoutesJSON[0]["legs"] as? [[String: Any?]] {
                encodedLegJSON[0].removeValue(forKey: "source")
                encodedLegJSON[0].removeValue(forKey: "destination")
                encodedLegJSON[0].removeValue(forKey: "profileIdentifier")
                
                encodedRoutesJSON[0]["legs"] = encodedLegJSON
                encodedRouteResponseJSON?["routes"] = encodedRoutesJSON
            }
        }
        if var encodedWaypointsJSON = encodedRouteResponseJSON?["waypoints"] as? [[String: Any?]] {
            encodedWaypointsJSON[0].removeValue(forKey: "separatesLegs")
            encodedWaypointsJSON[0].removeValue(forKey: "allowsArrivingOnOppositeSide")
            encodedWaypointsJSON[1].removeValue(forKey: "separatesLegs")
            encodedWaypointsJSON[1].removeValue(forKey: "allowsArrivingOnOppositeSide")
            
            encodedRouteResponseJSON?["waypoints"] = encodedWaypointsJSON
        }
        
        XCTAssertTrue(JSONSerialization.objectsAreEqual(fixtureJSON, encodedRouteResponseJSON, approximate: true))
    }
}
