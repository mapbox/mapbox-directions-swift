import XCTest
@testable import MapboxDirections

class RouteOptionsTests: XCTestCase {
    func testCoding() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 52.5109, longitude: 13.4301),
            CLLocationCoordinate2D(latitude: 52.5080, longitude: 13.4265),
            CLLocationCoordinate2D(latitude: 52.5021, longitude: 13.4316),
        ]
        
        let options = RouteOptions(coordinates: coordinates, profileIdentifier: .automobileAvoidingTraffic)
        
        let encodedData = NSMutableData()
        let keyedArchiver = NSKeyedArchiver(forWritingWith: encodedData)
        keyedArchiver.requiresSecureCoding = true
        keyedArchiver.encode(options, forKey: "options")
        keyedArchiver.finishEncoding()
        
        let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
        keyedUnarchiver.requiresSecureCoding = true
        let unarchivedOptions = keyedUnarchiver.decodeObject(of: RouteOptions.self, forKey: "options")!
        keyedUnarchiver.finishDecoding()
        
        XCTAssertNotNil(unarchivedOptions)
        
        let unarchivedWaypoints = unarchivedOptions.waypoints
        XCTAssertEqual(unarchivedWaypoints.count, coordinates.count)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.latitude, coordinates[0].latitude)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.longitude, coordinates[0].longitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.latitude, coordinates[1].latitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.longitude, coordinates[1].longitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.latitude, coordinates[2].latitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.longitude, coordinates[2].longitude)
        
        XCTAssertEqual(unarchivedOptions.profileIdentifier, options.profileIdentifier)
    }
}
