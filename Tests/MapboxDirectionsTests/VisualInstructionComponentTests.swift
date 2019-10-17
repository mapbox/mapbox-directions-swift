import XCTest
@testable import MapboxDirections

let componentJSON = """
{
"text": "Take a hike",
"imageBaseURL: "",
}
"""
class VisualInstructionComponentTests: XCTestCase {
    func testJSONInitialization() {
        let component = try! JSONDecoder().decode(Component.self, from: componentJSON.data(using:.utf8)!).component as! VisualInstructionComponent
        XCTAssertEqual(component.text, "Take a hike")
        XCTAssertNil(component.imageURL)
    }
}
