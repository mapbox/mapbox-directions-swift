import XCTest
import CoreLocation
@testable import MapboxDirections

class WaypointTests: XCTestCase {
    func testCoding() {
        let originalWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), coordinateAccuracy: 5, name: "White House")
        originalWaypoint.targetCoordinate = CLLocationCoordinate2D(latitude: 38.8952261, longitude: -77.0327882)
        originalWaypoint.heading = 90
        originalWaypoint.headingAccuracy = 10
        originalWaypoint.allowsArrivingOnOppositeSide = false
  
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        
        let encodedData = try! encoder.encode(originalWaypoint)
        let encodedString = String(data: encodedData, encoding: .utf8)!
        
        XCTAssertEqual(encodedString, pass)
        
        
        let decoder = JSONDecoder()

        
        let decodedWaypoint = try! decoder.decode(Waypoint.self, from: encodedData)
        
        XCTAssertEqual(decodedWaypoint.coordinate.latitude, originalWaypoint.coordinate.latitude)
        XCTAssertEqual(decodedWaypoint.coordinate.longitude, originalWaypoint.coordinate.longitude)
        XCTAssertEqual(decodedWaypoint.coordinateAccuracy, originalWaypoint.coordinateAccuracy)
        XCTAssert(decodedWaypoint.targetCoordinate == originalWaypoint.targetCoordinate)

        XCTAssertEqual(decodedWaypoint.heading, originalWaypoint.heading)
        XCTAssertEqual(decodedWaypoint.headingAccuracy, originalWaypoint.headingAccuracy)
        XCTAssertEqual(decodedWaypoint.allowsArrivingOnOppositeSide, originalWaypoint.allowsArrivingOnOppositeSide)
        XCTAssertEqual(decodedWaypoint.separatesLegs, originalWaypoint.separatesLegs)
    }
    
    func testSeparatesLegs() {
        let one = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        let two = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 2, longitude: 2))
        let three = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 3, longitude: 3))
        let four = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 4, longitude: 4))
        
        let routeOptions = RouteOptions(waypoints: [one, two, three, four])
        let matchOptions = MatchOptions(waypoints: [one, two, three, four], profileIdentifier: nil)
        
        XCTAssertNil(routeOptions.urlQueryItems.first { $0.name == "waypoints" }?.value)
        XCTAssertNil(matchOptions.urlQueryItems.first { $0.name == "waypoints" }?.value)
        
        two.separatesLegs = false
        
        XCTAssertEqual(routeOptions.urlQueryItems.first { $0.name == "waypoints" }?.value, "0;2;3")
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "waypoints" }?.value, "0;2;3")
        
        two.separatesLegs = true
        matchOptions.waypointIndices = [0, 2, 3]
        
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "waypoints" }?.value, "0;2;3")
    }
}

fileprivate let pass = """
{
  \"headingAccuracy\" : 10,
  \"location\" : [
    -77.036500000000004,
    38.8977
  ],
  \"targetCoordinate\" : [
    -77.032788199999999,
    38.895226100000002
  ],
  \"coordinateAccuracy\" : 5,
  \"allowsArrivingOnOppositeSide\" : false,
  \"heading\" : 90,
  \"separatesLegs\" : true,
  \"name\" : \"White House\"
}
"""
