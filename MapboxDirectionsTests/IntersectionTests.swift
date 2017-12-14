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
        
        XCTAssertEqual(unarchivedIntersection.location.latitude, intersection.location.latitude)
        XCTAssertEqual(unarchivedIntersection.location.longitude, intersection.location.longitude)
        XCTAssertEqual(unarchivedIntersection.headings, intersection.headings)
        XCTAssertEqual(unarchivedIntersection.outletIndex, intersection.outletIndex)
        XCTAssertEqual(unarchivedIntersection.outletIndexes, intersection.outletIndexes)
        XCTAssertEqual(unarchivedIntersection.outletRoadClasses, intersection.outletRoadClasses)
    }
}
