import XCTest
@testable import MapboxDirections

class IntersectionTests: XCTestCase {
    func testCoding() {
        
        let intersectionJSON =
"""
[
  {
    \"location\" : [
      13.426579,
      52.508068000000002
    ],
    \"in\" : -1,
    \"classes\" : [
      \"toll\",
      \"restricted\"
    ],
    \"usableApproachLanes\" : null,
    \"bearings\" : [
      80
    ],
    \"entry\" : [
        true
    ],
    \"out\" : 0,
    \"approachLanes\" : null
  },
  {
    \"location\" : [
      13.426688,
      52.508021999999997
    ],
    \"in\" : 2,
    \"usableApproachLanes\" : null,
    \"bearings\" : [
      30,
      120,
      300
    ],
    \"entry\" : [
        false,
        true,
        true
    ],
    \"out\" : 1,
    \"approachLanes\" : null
  }
]
"""
//        let json: JSONDictionary = [
//            "classes": ["toll", "restricted"],
//            "out": 0,
//            "entry": [true],
//            "bearings": [80.0],
//            "location": [-122.420018, 37.78009],
//        ]
        let intersections = try! JSONDecoder().decode([Intersection].self, from: intersectionJSON.data(using: .utf8)!)
        let intersection = intersections.first!
        
        XCTAssert(intersection.outletRoadClasses == [.toll, .restricted])
        XCTAssert(intersection.headings == [80.0])
        XCTAssert(intersection.location == CLLocationCoordinate2D(latitude:  52.508068, longitude: 13.426579) )
        let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
        let encoded = String(data: try! encoder.encode(intersections), encoding: .utf8)
        
        XCTAssert(encoded == intersectionJSON)
//    }
}
}
