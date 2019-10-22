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
  
        let coded = try! JSONEncoder().encode(originalWaypoint)
        let codedString = String(data: coded, encoding: .utf8)
        XCTFail("finish this")
//        let encodedData = NSMutableData()
//        let coder = NSKeyedArchiver(forWritingWith: encodedData)
//        coder.requiresSecureCoding = true
//        coder.encode(originalWaypoint, forKey: "waypoint")
//        coder.finishEncoding()
        
//        let decoder = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
//        decoder.requiresSecureCoding = true
//        defer {
//            decoder.finishDecoding()
//        }
//        guard let decodedWaypoint = decoder.decodeObject(of: Waypoint.self, forKey: "waypoint") else {
//            return XCTFail("Unable to decode waypoint")
//        }
        
        let decodedWaypoint = try! JSONDecoder().decode(Waypoint.self, from: (codedString?.data(using: .utf8))!)
        
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
