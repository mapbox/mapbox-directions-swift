import XCTest
import CoreLocation
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
        let options = RouteOptions(coordinates: [CLLocationCoordinate2D(latitude: 0, longitude: 0), CLLocationCoordinate2D(latitude: 1, longitude: 1)])
        options.shapeFormat = .polyline
        
        let decoder = JSONDecoder()
        decoder.userInfo[.options] = options
        
        let step = try! decoder.decode(RouteStep.self, from: routeStepJSON.data(using: .utf8)!)
        
        let encoder = JSONEncoder()
        encoder.userInfo[.options] = options
        encoder.outputFormatting = [.prettyPrinted]
        let encoded = try! encoder.encode(step)
        let roundTripJSON = String(data: encoded, encoding: .utf8)
        
        XCTAssert(roundTripJSON == pass)
    }
}

fileprivate let routeStepJSON = """
{
    "intersections": [
      {
        "out": 1,
        "location": [ 13.424671, 52.508812 ],
        "bearings": [ 120, 210, 300 ],
        "entry": [ false, true, true ],
        "in": 0,
        "lanes": [
          {
            "valid": true,
            "indications": [ "left" ]
          },
          {
            "valid": true,
            "indications": [ "straight" ]
          },
          {
            "valid": false,
            "indications": [ "right" ]
          }
        ]
      }
    ],
    "geometry": "asn_Ie_}pAdKxG",
    "maneuver": {
      "bearing_after": 202,
      "type": "turn",
      "modifier": "left",
      "bearing_before": 299,
      "location": [ 13.424671, 52.508812 ],
      "instruction": "Turn left onto Adalbertstraße"
    },
    "duration": 59.1,
    "distance": 236.9,
    "driving_side": "right",
    "weight": 59.1,
    "name": "Adalbertstraße",
    "mode": "driving"
}
"""

fileprivate let pass = """
{
  \"intersections\" : [
    {
      \"entry\" : [
        false,
        true,
        true
      ],
      \"in\" : 0,
      \"out\" : 1,
      \"lanes\" : [
        {
          \"valid\" : true,
          \"indications\" : [
            \"left\"
          ]
        },
        {
          \"valid\" : true,
          \"indications\" : [
            \"straight\"
          ]
        },
        {
          \"valid\" : false,
          \"indications\" : [
            \"right\"
          ]
        }
      ],
      \"location\" : [
        13.424671,
        52.508811999999999
      ],
      \"bearings\" : [
        120,
        210,
        300
      ]
    }
  ],
  \"distance\" : 236.90000000000001,
  \"geometry\" : \"asn_Ie_}pAdKxG\",
  \"maneuver\" : {
    \"location\" : [
      13.424671,
      52.508811999999999
    ],
    \"bearing_after\" : 202,
    \"bearing_before\" : 299,
    \"type\" : \"turn\",
    \"modifier\" : \"left\",
    \"instruction\" : \"Turn left onto Adalbertstraße\"
  },
  \"driving_side\" : \"right\",
  \"duration\" : 59.100000000000001,
  \"name\" : \"Adalbertstraße\"
}
"""
