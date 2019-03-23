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
        let intersection = Intersection(json: json)
        
        // Encode and decode the intersection securely.
        // This may raise an Objective-C exception if an error is encountered which will fail the tests.
        
        let encodedData = NSMutableData()
        let keyedArchiver = NSKeyedArchiver(forWritingWith: encodedData)
        keyedArchiver.requiresSecureCoding = true
        keyedArchiver.encode(intersection, forKey: "intersection")
        keyedArchiver.finishEncoding()
        
        let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: encodedData as Data)
        keyedUnarchiver.requiresSecureCoding = true
        let unarchivedIntersection = keyedUnarchiver.decodeObject(of: Intersection.self, forKey: "intersection")!
        keyedUnarchiver.finishDecoding()
        
        XCTAssertNotNil(unarchivedIntersection)
        
        XCTAssertEqual(unarchivedIntersection.location.latitude, unarchivedIntersection.location.latitude)
        XCTAssertEqual(unarchivedIntersection.location.longitude, unarchivedIntersection.location.longitude)
        XCTAssertEqual(unarchivedIntersection.headings, unarchivedIntersection.headings)
        XCTAssertEqual(unarchivedIntersection.outletIndex, unarchivedIntersection.outletIndex)
        XCTAssertEqual(unarchivedIntersection.outletIndexes, unarchivedIntersection.outletIndexes)
        XCTAssertEqual(unarchivedIntersection.outletRoadClasses, unarchivedIntersection.outletRoadClasses)
    }
}
