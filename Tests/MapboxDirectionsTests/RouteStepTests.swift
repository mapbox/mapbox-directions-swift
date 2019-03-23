import XCTest
@testable import MapboxDirections

class RoadTests: XCTestCase {
    func testEmpty() {
        let r = Road(name: "", ref: nil, exits: nil, destination: nil, rotaryName: nil)
        XCTAssertNil(r.names)
        XCTAssertNil(r.codes)
        XCTAssertNil(r.exitCodes)
        XCTAssertNil(r.destinations)
        XCTAssertNil(r.destinationCodes)
        XCTAssertNil(r.rotaryNames)
        
    }

    func testNamesCodes() {
        var r: Road

        // Name only
        r = Road(name: "Way Name", ref: nil, exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name" ])
        XCTAssertNil(r.codes)
        r = Road(name: "Way Name 1; Way Name 2", ref: nil, exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name 1", "Way Name 2" ])
        XCTAssertNil(r.codes)

        // Ref only
        r = Road(name: "", ref: "Ref 1", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertNil(r.names)
        XCTAssertEqual(r.codes ?? [], [ "Ref 1" ])
        r = Road(name: "", ref: "Ref 1; Ref 2", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertNil(r.names)
        XCTAssertEqual(r.codes ?? [], [ "Ref 1", "Ref 2" ])

        // Separate Name and Ref
        r = Road(name: "Way Name", ref: "Ref 1", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name" ])
        XCTAssertEqual(r.codes ?? [], [ "Ref 1" ])
        r = Road(name: "Way Name 1; Way Name 2", ref: "Ref 1; Ref 2", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name 1", "Way Name 2" ])
        XCTAssertEqual(r.codes ?? [], [ "Ref 1", "Ref 2" ])
        r = Road(name: "Way Name 1;Way Name 2", ref: "Ref 1;Ref 2", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name 1", "Way Name 2" ])
        XCTAssertEqual(r.codes ?? [], [ "Ref 1", "Ref 2" ])

        // Name in Ref (Mapbox Directions API v4)
        r = Road(name: "Way Name (Ref)", ref: nil, exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name" ])
        XCTAssertEqual(r.codes ?? [], [ "Ref" ])
        r = Road(name: "Way Name 1; Way Name 2 (Ref 1; Ref 2)", ref: nil, exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name 1", "Way Name 2"])
        XCTAssertEqual(r.codes ?? [], [ "Ref 1", "Ref 2" ])

        // Ref duplicated in Name (Mapbox Directions API v5)
        r = Road(name: "Way Name (Ref)", ref: "Ref", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name" ])
        XCTAssertEqual(r.codes ?? [], [ "Ref" ])
        r = Road(name: "Way Name 1; Way Name 2 (Ref 1; Ref 2)", ref: "Ref 1; Ref 2", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertEqual(r.names ?? [], [ "Way Name 1", "Way Name 2"])
        XCTAssertEqual(r.codes ?? [], [ "Ref 1", "Ref 2" ])
        r = Road(name: "Ref 1; Ref 2", ref: "Ref 1; Ref 2", exits: nil, destination: nil, rotaryName: nil)
        XCTAssertNil(r.names)
        XCTAssertEqual(r.codes ?? [], [ "Ref 1", "Ref 2" ])
    }

    func testRotaryNames() {
        var r: Road

        r = Road(name: "", ref: nil, exits: nil, destination: nil, rotaryName: "Rotary Name")
        XCTAssertEqual(r.rotaryNames ?? [], [ "Rotary Name" ])
        r = Road(name: "", ref: nil, exits: nil
            , destination: nil, rotaryName: "Rotary Name 1;Rotary Name 2")
        XCTAssertEqual(r.rotaryNames ?? [], [ "Rotary Name 1", "Rotary Name 2" ])
    }

    func testExitCodes() {
        var r: Road

        r = Road(name: "", ref: nil, exits: "123 A", destination: nil, rotaryName: nil)
        XCTAssertEqual(r.exitCodes ?? [], [ "123 A" ])
        r = Road(name: "", ref: nil, exits: "123A;123B", destination: nil, rotaryName: nil)
        XCTAssertEqual(r.exitCodes ?? [], [ "123A", "123B" ])
    }

    func testDestinations() {
        var r: Road

        // No ref
        r = Road(name: "", ref: nil, exits: nil, destination: "Destination", rotaryName: nil)
        XCTAssertEqual(r.destinations ?? [], [ "Destination" ])
        XCTAssertNil(r.destinationCodes)
        r = Road(name: "", ref: nil, exits: nil, destination: "Destination 1, Destination 2", rotaryName: nil)
        XCTAssertEqual(r.destinations ?? [], [ "Destination 1", "Destination 2" ])
        XCTAssertNil(r.destinationCodes)

        // With ref
        r = Road(name: "", ref: nil, exits: nil, destination: "Ref 1: Destination", rotaryName: nil)
        XCTAssertEqual(r.destinations ?? [], [ "Destination" ])
        XCTAssertEqual(r.destinationCodes ?? [], [ "Ref 1" ])
        r = Road(name: "", ref: nil, exits: nil, destination: "Ref 1, Ref 2: Destination 1, Destination 2, Destination 3", rotaryName: nil)
        XCTAssertEqual(r.destinations ?? [], [ "Destination 1", "Destination 2", "Destination 3" ])
        XCTAssertEqual(r.destinationCodes ?? [], [ "Ref 1", "Ref 2" ])
    }
}

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
            "pronunciation": "ˈaɪˌfoʊ̯n ˈtɛn",
        ] as [String: Any]
        
        let step = RouteStep(finalHeading: 59, maneuverType: .reachFork, maneuverDirection: .left, drivingSide: .left, maneuverLocation: CLLocationCoordinate2D(latitude: 37.853913, longitude: -122.220694), name: "", coordinates: coordinates, json: json)
        
        // Encode and decode the route step securely
        // This may raise an Obj-C exception if an error is encountered which will fail the tests
        
        let encodedData = NSMutableData()
        let keyedArchiver = NSKeyedArchiver(forWritingWith: encodedData)
        keyedArchiver.requiresSecureCoding = true
        keyedArchiver.encode(step, forKey: "step")
        keyedArchiver.finishEncoding()
        
        let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
        keyedUnarchiver.requiresSecureCoding = true
        let unarchivedStep = keyedUnarchiver.decodeObject(of: RouteStep.self, forKey: "step")!
        keyedUnarchiver.finishDecoding()
        
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
        XCTAssertEqual(unarchivedStep.names ?? [], step.names ?? [])
        XCTAssertEqual(unarchivedStep.phoneticNames ?? [], step.phoneticNames ?? [])
        XCTAssertEqual(unarchivedStep.transportType, step.transportType)
        XCTAssertEqual(unarchivedStep.destinations ?? [], step.destinations ?? [])
        XCTAssertEqual(unarchivedStep.instructionsSpokenAlongStep ?? [], step.instructionsSpokenAlongStep ?? [])
        XCTAssertEqual(unarchivedStep.instructionsDisplayedAlongStep ?? [], step.instructionsDisplayedAlongStep ?? [])
        XCTAssertEqual(unarchivedStep.drivingSide, DrivingSide.left)
    }
}
