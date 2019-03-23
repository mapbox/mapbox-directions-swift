import XCTest
import MapboxDirections

class VisualInstructionComponentTests: XCTestCase {
    func testJSONInitialization() {
        let component = VisualInstructionComponent(json: [
            "text": "Take a hike",
            "imageBaseURL": "",
        ])
        XCTAssertEqual(component.text, "Take a hike")
        XCTAssertNil(component.imageURL)
    }
}
