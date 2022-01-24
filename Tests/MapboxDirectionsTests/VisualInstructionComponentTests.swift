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
        let componentJSON: [String : Any] = [
            "text": "I 95",
            "type": "icon",
            "imageBaseURL": "https://s3.amazonaws.com/mapbox/shields/v3/i-95",
            "mapbox_shield": [
                "base_url": "https://api.mapbox.com/styles/v1/",
                "name": "us-interstate",
                "text_color": "black",
                "display_ref": "242"
            ]
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .image(let image, let alternativeText, let mapboxShield):
                XCTAssertEqual(image.imageBaseURL?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95")
                XCTAssertEqual(image.imageURL(scale: 1, format: .svg)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95@1x.svg")
                XCTAssertEqual(image.imageURL(scale: 3, format: .svg)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95@3x.svg")
                XCTAssertEqual(image.imageURL(scale: 3, format: .png)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95@3x.png")
                XCTAssertEqual(alternativeText.text, "I 95")
                XCTAssertNil(alternativeText.abbreviation)
                XCTAssertNil(alternativeText.abbreviationPriority)
                XCTAssertEqual(mapboxShield?.baseURL, URL(string: "https://api.mapbox.com/styles/v1/")!)
                XCTAssertEqual(mapboxShield?.name, "us-interstate")
                XCTAssertEqual(mapboxShield?.textColor, "black")
                XCTAssertEqual(mapboxShield?.displayRef, "242")
            default:
                XCTFail("Image component should not be decoded as any other kind of component.")
            }
        }
        
        component = .image(image: .init(imageBaseURL: URL(string: "https://s3.amazonaws.com/mapbox/shields/v3/i-95")!),
                           alternativeText: .init(text: "I 95", abbreviation: nil, abbreviationPriority: nil),
                           mapboxShield: .init(baseURL: URL(string: "https://api.mapbox.com/styles/v1/")!, name: "us-interstate", textColor: "black", displayRef: "242"))
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
    
    func testShield() {
        let shieldJSON = [
            "base_url": "https://api.mapbox.com/styles/v1/",
            "name": "us-interstate",
            "text_color": "black",
            "display_ref": "242",
        ]
        
        let shieldData = try! JSONSerialization.data(withJSONObject: shieldJSON, options: [])
        var shield: MapboxShield?
        XCTAssertNoThrow(shield = try JSONDecoder().decode(MapboxShield.self, from: shieldData))
        XCTAssertNotNil(shield)
        let url = URL(string: "https://api.mapbox.com/styles/v1/")
        if let shield = shield {
            XCTAssertEqual(shield.baseURL, url)
            XCTAssertEqual(shield.name, "us-interstate")
            XCTAssertEqual(shield.textColor, "black")
            XCTAssertEqual(shield.displayRef, "242")
        }
        shield = .init(baseURL: url!, name: "us-interstate", textColor: "black", displayRef: "242")
        
        let encoder = JSONEncoder()
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try encoder.encode(shield))
        XCTAssertNotNil(encodedData)
        
        if let encodedData = encodedData {
            var encodedShieldJSON: [String: Any]?
            XCTAssertNoThrow(encodedShieldJSON = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any])
            XCTAssertNotNil(encodedShieldJSON)
            
            XCTAssert(JSONSerialization.objectsAreEqual(shieldJSON, encodedShieldJSON, approximate: false))
        }
    }
    
    func testShieldImageComponent() {
        let componentJSON: [String : Any] = [
            "text": "I 95",
            "type": "icon",
            "mapbox_shield": [
                "base_url": "https://api.mapbox.com/styles/v1/",
                "name": "us-interstate",
                "text_color": "black",
                "display_ref": "242"
            ]
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .image(let image, let alternativeText, let mapboxShield):
                XCTAssertNil(image.imageBaseURL?.absoluteString)
                XCTAssertEqual(alternativeText.text, "I 95")
                XCTAssertNil(alternativeText.abbreviation)
                XCTAssertNil(alternativeText.abbreviationPriority)
                XCTAssertEqual(mapboxShield?.baseURL, URL(string: "https://api.mapbox.com/styles/v1/")!)
                XCTAssertEqual(mapboxShield?.name, "us-interstate")
                XCTAssertEqual(mapboxShield?.textColor, "black")
                XCTAssertEqual(mapboxShield?.displayRef, "242")
            default:
                XCTFail("Image component should not be decoded as any other kind of component.")
            }
        }
        
        component = .image(image: .init(imageBaseURL: nil),
                           alternativeText: .init(text: "I 95", abbreviation: nil, abbreviationPriority: nil),
                           mapboxShield: .init(baseURL: URL(string: "https://api.mapbox.com/styles/v1/")!, name: "us-interstate", textColor: "black", displayRef: "242"))
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
            "active_direction": "right",
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            if case let .lane(indications, isUsable, preferredDirection) = component {
                XCTAssertEqual(indications, [.straightAhead, .right])
                XCTAssertTrue(isUsable)
                XCTAssertEqual(preferredDirection, .right)
            } else {
                XCTFail("Lane component should not be decoded as any other kind of component.")
            }
        }
        
        component = .lane(indications: [.straightAhead, .right], isUsable: true, preferredDirection: .right)
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
