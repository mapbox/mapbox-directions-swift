import XCTest
import CoreLocation
@testable import MapboxDirections

class WaypointTests: XCTestCase {
    func testCopying() {
        let originalWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), coordinateAccuracy: 5, name: "White House")
        originalWaypoint.targetCoordinate = CLLocationCoordinate2D(latitude: 38.8952261, longitude: -77.0327882)
        originalWaypoint.heading = 90
        originalWaypoint.headingAccuracy = 10
        originalWaypoint.allowsArrivingOnOppositeSide = false
        
        guard let copy = originalWaypoint.copy() as? Waypoint else {
            return XCTFail("Waypoint copy method should an object of same type")
        }
        
        XCTAssertEqual(copy.coordinate.latitude, originalWaypoint.coordinate.latitude)
        XCTAssertEqual(copy.coordinate.longitude, originalWaypoint.coordinate.longitude)
        XCTAssertEqual(copy.coordinateAccuracy, originalWaypoint.coordinateAccuracy)
        XCTAssertEqual(copy.targetCoordinate.latitude, originalWaypoint.targetCoordinate.latitude)
        XCTAssertEqual(copy.targetCoordinate.longitude, originalWaypoint.targetCoordinate.longitude)
        XCTAssertEqual(copy.heading, originalWaypoint.heading)
        XCTAssertEqual(copy.headingAccuracy, originalWaypoint.headingAccuracy)
        XCTAssertEqual(copy.allowsArrivingOnOppositeSide, originalWaypoint.allowsArrivingOnOppositeSide)
        XCTAssertEqual(copy.separatesLegs, originalWaypoint.separatesLegs)
    }
    
    func testCoding() {
        let originalWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), coordinateAccuracy: 5, name: "White House")
        originalWaypoint.targetCoordinate = CLLocationCoordinate2D(latitude: 38.8952261, longitude: -77.0327882)
        originalWaypoint.heading = 90
        originalWaypoint.headingAccuracy = 10
        originalWaypoint.allowsArrivingOnOppositeSide = false
        
        let encodedData = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: encodedData)
        coder.requiresSecureCoding = true
        coder.encode(originalWaypoint, forKey: "waypoint")
        coder.finishEncoding()
        
        let decoder = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
        decoder.requiresSecureCoding = true
        defer {
            decoder.finishDecoding()
        }
        guard let decodedWaypoint = decoder.decodeObject(of: Waypoint.self, forKey: "waypoint") else {
            return XCTFail("Unable to decode waypoint")
        }
        
        XCTAssertEqual(decodedWaypoint.coordinate.latitude, originalWaypoint.coordinate.latitude)
        XCTAssertEqual(decodedWaypoint.coordinate.longitude, originalWaypoint.coordinate.longitude)
        XCTAssertEqual(decodedWaypoint.coordinateAccuracy, originalWaypoint.coordinateAccuracy)
        XCTAssertEqual(decodedWaypoint.targetCoordinate.latitude, originalWaypoint.targetCoordinate.latitude)
        XCTAssertEqual(decodedWaypoint.targetCoordinate.longitude, originalWaypoint.targetCoordinate.longitude)
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
