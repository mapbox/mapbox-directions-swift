import XCTest
@testable import MapboxDirections

class IntersectionTests: XCTestCase {
    
    let intersectionJSON =
    """
    [
      {
        "location" : [
          13.426579,
          52.508068
        ],
        "in" : -1,
        "classes" : [
          "toll",
          "restricted"
        ],
        "usableApproachLanes" : null,
        "bearings" : [
          80
        ],
        "entry" : [
            true
        ],
        "out" : 0,
        "approachLanes" : null
      },
      {
        "location" : [
          13.426688,
          52.508022
        ],
        "in" : 2,
        "usableApproachLanes" : null,
        "bearings" : [
          30,
          120,
          300
        ],
        "entry" : [
            false,
            true,
            true
        ],
        "out" : 1,
        "approachLanes" : null
      }
    ]
    """
    
    let pass = """
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
        \"bearings\" : [
          80
        ],
        \"entry\" : [
          true
        ],
        \"lanes\" : null,
        \"out\" : 0
      },
      {
        \"entry\" : [
          false,
          true,
          true
        ],
        \"in\" : 2,
        \"out\" : 1,
        \"lanes\" : null,
        \"location\" : [
          13.426688,
          52.508021999999997
        ],
        \"bearings\" : [
          30,
          120,
          300
        ]
      }
    ]
    """
    
    func testCoding() {
        
        let intersections = try! JSONDecoder().decode([Intersection].self, from: intersectionJSON.data(using: .utf8)!)
        let intersection = intersections.first!
        
        XCTAssert(intersection.outletRoadClasses == [.toll, .restricted])
        XCTAssert(intersection.headings == [80.0])
        XCTAssert(intersection.location == CLLocationCoordinate2D(latitude:  52.508068, longitude: 13.426579) )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let encoded = String(data: try! encoder.encode(intersections), encoding: .utf8)
        
        XCTAssert(encoded == pass)
    }
}
