import XCTest
@testable import MapboxDirections

class RouteOptionsTests: XCTestCase {
    func testCoding() {
 
        let options = RouteOptions.testInstance
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
        
        let coordinates = RouteOptions.testCoordinates
        let unarchivedWaypoints = unarchivedOptions.waypoints
        XCTAssertEqual(unarchivedWaypoints.count, coordinates.count)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.latitude, coordinates[0].latitude)
        XCTAssertEqual(unarchivedWaypoints[0].coordinate.longitude, coordinates[0].longitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.latitude, coordinates[1].latitude)
        XCTAssertEqual(unarchivedWaypoints[1].coordinate.longitude, coordinates[1].longitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.latitude, coordinates[2].latitude)
        XCTAssertEqual(unarchivedWaypoints[2].coordinate.longitude, coordinates[2].longitude)
        
        XCTAssertEqual(unarchivedOptions.profileIdentifier, options.profileIdentifier)
        XCTAssertEqual(unarchivedOptions.locale, options.locale)
        XCTAssertEqual(unarchivedOptions.includesSpokenInstructions, options.includesSpokenInstructions)
        XCTAssertEqual(unarchivedOptions.distanceMeasurementSystem, options.distanceMeasurementSystem)
        XCTAssertEqual(unarchivedOptions.roadClassesToAvoid, options.roadClassesToAvoid)
    }
    func testCopying() {
        let testInstance = RouteOptions.testInstance
        guard let copy = testInstance.copy() as? RouteOptions else { return XCTFail("RouteOptions copy method should an object of same type") }
        XCTAssertNotNil(copy, "Copy should not be nil.")
        XCTAssertTrue(testInstance == copy, "Test Instance and copy should be semantically equivalent.")
        XCTAssertFalse(testInstance === copy, "Test Instance and copy should not be identical.")
        
    }
}

private extension RouteOptions {
    static var testCoordinates: [CLLocationCoordinate2D] {
        return [
            CLLocationCoordinate2D(latitude: 52.5109, longitude: 13.4301),
            CLLocationCoordinate2D(latitude: 52.5080, longitude: 13.4265),
            CLLocationCoordinate2D(latitude: 52.5021, longitude: 13.4316),
        ]
    }
    static var testInstance: RouteOptions {
        let opts = RouteOptions(coordinates: self.testCoordinates, profileIdentifier: .automobileAvoidingTraffic)
        opts.locale = Locale(identifier: "en_US")
        opts.allowsUTurnAtWaypoint = true
        opts.shapeFormat = .polyline
        opts.routeShapeResolution = .full
        opts.attributeOptions = [.congestionLevel]
        opts.includesExitRoundaboutManeuver = true
        opts.includesSpokenInstructions = true
        opts.distanceMeasurementSystem = .metric
        
        return opts
    }
}
