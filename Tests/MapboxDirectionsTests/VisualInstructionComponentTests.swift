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
        var component: Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(ComponentSerializer.self, from: componentData).component)
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .lane(_):
                XCTFail("Text component should not be interpreted as lane component.")
            case let .visual(component):
                XCTAssertEqual(component.text, "Take a hike")
                XCTAssertNil(component.imageURL)
            }
        }
    }
}
