import XCTest
@testable import MapboxDirections

class IntersectionTests: XCTestCase {
    func testCoding() {
        let json: JSONDictionary = [
            "classes": ["toll", "restricted"],
            "out": 0,
            "entry": [true],
            "bearings": [80.0],
            "location": [-122.420018, 37.78009],
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        let intersection: Intersection = Intersection.from(data: jsonData)!
        
        // Encode and decode the intersection securely.
        // This may raise an Objective-C exception if an error is encountered which will fail the tests.
        let data = try! JSONEncoder().encode(intersection)
        NSKeyedArchiver.archiveRootObject(data, toFile: "intersection")
        
        let unarchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: "intersection") as! Data
        let unarchivedIntersection = try! JSONDecoder().decode(Intersection.self, from: unarchivedData)
        
        XCTAssertNotNil(unarchivedIntersection)
        
        XCTAssertEqual(unarchivedIntersection.location.latitude, unarchivedIntersection.location.latitude)
        XCTAssertEqual(unarchivedIntersection.location.longitude, unarchivedIntersection.location.longitude)
        XCTAssertEqual(unarchivedIntersection.headings, unarchivedIntersection.headings)
        XCTAssertEqual(unarchivedIntersection.outletIndex, unarchivedIntersection.outletIndex)
        XCTAssertEqual(unarchivedIntersection.outletIndexes, unarchivedIntersection.outletIndexes)
        XCTAssertEqual(unarchivedIntersection.outletRoadClasses, unarchivedIntersection.outletRoadClasses)
    }
}
