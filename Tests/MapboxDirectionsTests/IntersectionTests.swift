import XCTest
@testable import MapboxDirections

class IntersectionTests: XCTestCase {
    func testCoding() {
        let intersectionsJSON: [[String: Any?]] = [
            [
                "location": [13.426579, 52.508068],
                "in": -1,
                "classes": ["toll", "restricted"],
                "usableApproachLanes": nil,
                "bearings": [80],
                "entry": [true],
                "out": 0,
                "approachLanes": nil,
            ],
            [
                "location": [13.426688, 52.508022],
                "in": 2,
                "usableApproachLanes": nil,
                "bearings": [30, 120, 300],
                "entry": [false, true, true],
                "out": 1,
                "approachLanes": nil,
            ],
        ]
        let intersectionsData = try! JSONSerialization.data(withJSONObject: intersectionsJSON, options: [])
        var intersections: [Intersection]?
        XCTAssertNoThrow(intersections = try JSONDecoder().decode([Intersection].self, from: intersectionsData))
        XCTAssertEqual(intersections?.count, 2)
        
        if let intersection = intersections?.first {
            XCTAssert(intersection.outletRoadClasses == [.toll, .restricted])
            XCTAssert(intersection.headings == [80.0])
            XCTAssert(intersection.location == CLLocationCoordinate2D(latitude: 52.508068, longitude: 13.426579))
        }
        
        intersections = [
            Intersection(location: CLLocationCoordinate2D(latitude: 52.508068, longitude: 13.426579),
                         headings: [80.0],
                         approachIndex: -1,
                         outletIndex: 0,
                         outletIndexes: IndexSet([0]),
                         approachLanes: nil,
                         usableApproachLanes: nil,
                         outletRoadClasses: [.toll, .restricted]),
            Intersection(location: CLLocationCoordinate2D(latitude: 52.508022, longitude: 13.426688),
                         headings: [30.0, 120.0, 300.0],
                         approachIndex: 2,
                         outletIndex: 1,
                         outletIndexes: IndexSet([1, 2]),
                         approachLanes: nil,
                         usableApproachLanes: nil,
                         outletRoadClasses: nil)
        ]
        
        let encoder = JSONEncoder()
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try encoder.encode(intersections))
        XCTAssertNotNil(encodedData)
        
        if let encodedData = encodedData {
            var encodedIntersectionsJSON: [[String: Any?]]?
            XCTAssertNoThrow(encodedIntersectionsJSON = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [[String: Any?]])
            XCTAssertNotNil(encodedIntersectionsJSON)
            if let encodedIntersectionsJSON = encodedIntersectionsJSON {
                XCTAssert(JSONSerialization.objectsAreEqual(intersectionsJSON, encodedIntersectionsJSON, approximate: true))
            }
        }
    }
}
