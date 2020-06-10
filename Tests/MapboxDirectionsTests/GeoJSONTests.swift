import XCTest
@testable import MapboxDirections
import Turf

class GeoJSONTests: XCTestCase {
    func testInitialization() {
        XCTAssertThrowsError(try LineString(encodedPolyline: ">==========>", precision: 1e6))
        
        var lineString: LineString? = nil
        XCTAssertNoThrow(lineString = try LineString(encodedPolyline: "afvnFdrebO@o@", precision: 1e5))
        XCTAssertNotNil(lineString)
        XCTAssertEqual(lineString?.coordinates.count, 2)
        XCTAssertEqual(lineString?.coordinates.first?.latitude ?? 0.0, 39.27665, accuracy: 1e-5)
        XCTAssertEqual(lineString?.coordinates.first?.longitude ?? 0.0, -84.411389, accuracy: 1e-5)
        XCTAssertEqual(lineString?.coordinates.last?.latitude ?? 0.0, 39.276635, accuracy: 1e-5)
        XCTAssertEqual(lineString?.coordinates.last?.longitude ?? 0.0, -84.411148, accuracy: 1e-5)
    }
}
