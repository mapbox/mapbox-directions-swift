import XCTest
import Turf
@testable import MapboxDirections

class RouteResponseTests: XCTestCase {
    
    func testRouteResponseEncodingAndDecoding() {
        let originCoordinate = LocationCoordinate2D(latitude: 39.15031, longitude: -84.47182)
        let originWaypoint = Waypoint(coordinate: originCoordinate, name: "Test waypoint")
        originWaypoint.targetCoordinate = originCoordinate
        originWaypoint.coordinateAccuracy = 1.0
        originWaypoint.heading = 120.0
        originWaypoint.headingAccuracy = 1.0
        originWaypoint.separatesLegs = false
        originWaypoint.allowsArrivingOnOppositeSide = false
        
        let waypoints = [originWaypoint]
        let routeOptions = RouteOptions(waypoints: waypoints)
        let responseOptions = ResponseOptions.route(routeOptions)
        let accessToken = "deadbeefcafebebe"
        let host = URL(string: "https://example.com")!
        let directionsCredentials = Credentials(accessToken: accessToken, host: host)
        
        let routeResponse = RouteResponse(httpResponse: nil,
                                          waypoints: waypoints,
                                          options: responseOptions,
                                          credentials: directionsCredentials)
        
        do {
            let encodedRouteResponse = try JSONEncoder().encode(routeResponse)
            
            let decoder = JSONDecoder()
            decoder.userInfo[.options] = routeOptions
            decoder.userInfo[.credentials] = directionsCredentials
            
            let decodedRouteResponse = try decoder.decode(RouteResponse.self, from: encodedRouteResponse)
            
            guard let waypoint = decodedRouteResponse.waypoints?.first else {
                XCTFail("Decoded route response should contain one waypoint.")
                return
            }
            
            let decodedCoordinate = waypoint.coordinate
            let decodedName = waypoint.name
            let decodedTargetCoordinate = waypoint.targetCoordinate
            let decodedCoordinateAccuracy = waypoint.coordinateAccuracy
            let decodedHeading = waypoint.heading
            let decodedHeadingAccuracy = waypoint.headingAccuracy
            let decodedSeparatesLegs = waypoint.separatesLegs
            let decodedAllowsArrivingOnOppositeSide = waypoint.allowsArrivingOnOppositeSide
            
            XCTAssertEqual(originWaypoint.coordinate, decodedCoordinate, "Original and decoded coordinates should be equal.")
            XCTAssertEqual(originWaypoint.name, decodedName, "Original and decoded names should be equal.")
            XCTAssertEqual(originWaypoint.targetCoordinate, decodedTargetCoordinate, "Original and decoded targetCoordinates should be equal.")
            XCTAssertEqual(originWaypoint.coordinateAccuracy, decodedCoordinateAccuracy, "Original and decoded coordinateAccuracies should be equal.")
            XCTAssertEqual(originWaypoint.heading, decodedHeading, "Original and decoded headings should be equal.")
            XCTAssertEqual(originWaypoint.headingAccuracy, decodedHeadingAccuracy, "Original and decoded headingAccuracies should be equal.")
            XCTAssertEqual(originWaypoint.separatesLegs, false, "originWaypoint should have separatesLegs set to false.")
            XCTAssertEqual(decodedSeparatesLegs, true, "First and last decoded waypoints should have separatesLegs value set to true.")
            XCTAssertEqual(originWaypoint.allowsArrivingOnOppositeSide, decodedAllowsArrivingOnOppositeSide, "Original and decoded allowsArrivingOnOppositeSides should be equal.")
        } catch {
            XCTFail("Failed with error: \(error)")
        }
    }
}
