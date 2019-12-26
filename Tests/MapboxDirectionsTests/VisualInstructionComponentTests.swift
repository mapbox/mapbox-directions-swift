import XCTest
@testable import MapboxDirections

class VisualInstructionComponentTests: XCTestCase {
    func testTextComponent() {
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
    
    func testImageComponent() {
        let componentJSON = [
            "text": "US 42",
            "type": "icon",
            "imageBaseURL": "https://s3.amazonaws.com/mapbox/shields/v3/us-42",
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .image(let image, let alternativeText):
                XCTAssertEqual(image.imageBaseURL?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/us-42")
                XCTAssertEqual(image.imageURL(scale: 1, format: .svg)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/us-42@1x.svg")
                XCTAssertEqual(image.imageURL(scale: 3, format: .svg)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/us-42@3x.svg")
                XCTAssertEqual(image.imageURL(scale: 3, format: .png)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/us-42@3x.png")
                XCTAssertEqual(alternativeText.text, "US 42")
                XCTAssertNil(alternativeText.abbreviation)
                XCTAssertNil(alternativeText.abbreviationPriority)
            default:
                XCTFail("Image component should not be decoded as any other kind of component.")
            }
        }
        
        component = .image(image: .init(imageBaseURL: URL(string: "https://s3.amazonaws.com/mapbox/shields/v3/us-42")!),
                           alternativeText: .init(text: "US 42", abbreviation: nil, abbreviationPriority: nil))
        let encoder = JSONEncoder()
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try encoder.encode(component))
        XCTAssertNotNil(encodedData)
        
        if let encodedData = encodedData {
            var encodedComponentJSON: [String: Any?]?
            XCTAssertNoThrow(encodedComponentJSON = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any?])
            XCTAssertNotNil(encodedComponentJSON)
            
            XCTAssert(JSONSerialization.objectsAreEqual(componentJSON, encodedComponentJSON, approximate: false))
        }
    }
    
    func testLaneComponent() {
        let componentJSON: [String: Any?] = [
            "text": "",
            "type": "lane",
            "active": true,
            "directions": ["right", "straight"],
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            if case let .lane(indications, isUsable) = component {
                XCTAssertEqual(indications, [.straightAhead, .right])
                XCTAssertTrue(isUsable)
            } else {
                XCTFail("Lane component should not be decoded as any other kind of component.")
            }
        }
        
        component = .lane(indications: [.straightAhead, .right], isUsable: true)
        let encoder = JSONEncoder()
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try encoder.encode(component))
        XCTAssertNotNil(encodedData)
        
        if let encodedData = encodedData {
            var encodedComponentJSON: [String: Any?]?
            XCTAssertNoThrow(encodedComponentJSON = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any?])
            XCTAssertNotNil(encodedComponentJSON)
            
            XCTAssert(JSONSerialization.objectsAreEqual(componentJSON, encodedComponentJSON, approximate: false))
        }
    }
    
    func testUnrecognizedComponent() {
        let componentJSON = [
            "type": "emoji",
            "text": "👈",
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .text(let text):
                XCTAssertEqual(text.text, "👈")
            default:
                XCTFail("Component of unrecognized type should be decoded as text component.")
            }
        }
    }
}
