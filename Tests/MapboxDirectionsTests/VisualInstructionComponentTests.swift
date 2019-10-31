import XCTest
@testable import MapboxDirections

class VisualInstructionComponentTests: XCTestCase {
    func testJSONInitialization() {
        let componentJSON = [
            "type": "text",
            "text": "Take a hike",
            "imageBaseURL": "",
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .text(let text):
                XCTAssertEqual(text.text, "Take a hike")
            default:
                XCTFail("Text component should not be decoded as any other kind of component.")
            }
        }
    }
}
