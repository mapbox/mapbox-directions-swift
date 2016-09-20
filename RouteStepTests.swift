import XCTest
@testable import MapboxDirections

class RouteStepTests: XCTestCase {
    func testCoding() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: -122.220694, longitude: 37.853913),
            CLLocationCoordinate2D(latitude: -122.22044, longitude: 37.854032),
            CLLocationCoordinate2D(latitude: -122.220168, longitude: 37.854149),
        ]
        let json = [
            "mode": "driving",
            "maneuver": [
                "instruction": "Keep left at the fork onto CA 24",
                "bearing_before": 55,
            ],
            "distance": 1669.7,
            "duration": 75.6,
        ]
        
        let step = RouteStep(finalHeading: 59, maneuverType: .ReachFork, maneuverDirection: .Left, maneuverLocation: CLLocationCoordinate2D(latitude: 37.853913, longitude: -122.220694), name: nil, coordinates: coordinates, json: json)
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(step)
        let unarchivedStep = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! RouteStep
        XCTAssertNotNil(unarchivedStep)
        
        XCTAssertEqual(unarchivedStep.coordinates?.count, step.coordinates?.count)
        XCTAssertEqual(unarchivedStep.coordinates?.first?.latitude, step.coordinates?.first?.latitude)
        XCTAssertEqual(unarchivedStep.coordinates?.first?.longitude, step.coordinates?.first?.longitude)
        XCTAssertEqual(unarchivedStep.instructions, step.instructions)
        XCTAssertEqual(unarchivedStep.initialHeading, step.initialHeading)
        XCTAssertEqual(unarchivedStep.finalHeading, step.finalHeading)
        XCTAssertEqual(unarchivedStep.maneuverType, step.maneuverType)
        XCTAssertEqual(unarchivedStep.maneuverDirection, step.maneuverDirection)
        XCTAssertEqual(unarchivedStep.maneuverLocation.latitude, step.maneuverLocation.latitude)
        XCTAssertEqual(unarchivedStep.maneuverLocation.longitude, step.maneuverLocation.longitude)
        XCTAssertEqual(unarchivedStep.exitIndex, step.exitIndex)
        XCTAssertEqual(unarchivedStep.distance, step.distance)
        XCTAssertEqual(unarchivedStep.expectedTravelTime, step.expectedTravelTime)
        XCTAssertEqual(unarchivedStep.name, step.name)
        XCTAssertEqual(unarchivedStep.transportType, step.transportType)
        XCTAssertEqual(unarchivedStep.destinations, step.destinations)
    }
}
