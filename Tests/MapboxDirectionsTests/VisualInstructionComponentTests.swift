import XCTest
@testable import MapboxDirections
import Turf

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
                "text_color": "white",
                "display_ref": "95"
            ]
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .image(let image, let alternativeText):
                XCTAssertEqual(image.imageBaseURL?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95")
                XCTAssertEqual(image.imageURL(scale: 1, format: .svg)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95@1x.svg")
                XCTAssertEqual(image.imageURL(scale: 3, format: .svg)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95@3x.svg")
                XCTAssertEqual(image.imageURL(scale: 3, format: .png)?.absoluteString, "https://s3.amazonaws.com/mapbox/shields/v3/i-95@3x.png")
                XCTAssertEqual(alternativeText.text, "I 95")
                XCTAssertNil(alternativeText.abbreviation)
                XCTAssertNil(alternativeText.abbreviationPriority)
                XCTAssertEqual(image.shield?.baseURL, URL(string: "https://api.mapbox.com/styles/v1/")!)
                XCTAssertEqual(image.shield?.name, "us-interstate")
                XCTAssertEqual(image.shield?.textColor, "white")
                XCTAssertEqual(image.shield?.text, "95")
            default:
                XCTFail("Image component should not be decoded as any other kind of component.")
            }
        }
        let shield = VisualInstruction.Component.ShieldRepresentation(baseURL: URL(string: "https://api.mapbox.com/styles/v1/")!, name: "us-interstate", textColor: "white", text: "95")
        component = .image(image: .init(imageBaseURL: URL(string: "https://s3.amazonaws.com/mapbox/shields/v3/i-95")!, shield: shield),
                           alternativeText: .init(text: "I 95", abbreviation: nil, abbreviationPriority: nil))
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
            "text_color": "white",
            "display_ref": "95",
        ]
        
        let shieldData = try! JSONSerialization.data(withJSONObject: shieldJSON, options: [])
        var shield: VisualInstruction.Component.ShieldRepresentation?
        XCTAssertNoThrow(shield = try JSONDecoder().decode(VisualInstruction.Component.ShieldRepresentation.self, from: shieldData))
        XCTAssertNotNil(shield)
        let url = URL(string: "https://api.mapbox.com/styles/v1/")
        if let shield = shield {
            XCTAssertEqual(shield.baseURL, url)
            XCTAssertEqual(shield.name, "us-interstate")
            XCTAssertEqual(shield.textColor, "white")
            XCTAssertEqual(shield.text, "95")
        }
        shield = .init(baseURL: url!, name: "us-interstate", textColor: "white", text: "95")
        
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
                "text_color": "white",
                "display_ref": "95"
            ]
        ]
        let componentData = try! JSONSerialization.data(withJSONObject: componentJSON, options: [])
        var component: VisualInstruction.Component?
        XCTAssertNoThrow(component = try JSONDecoder().decode(VisualInstruction.Component.self, from: componentData))
        XCTAssertNotNil(component)
        if let component = component {
            switch component {
            case .image(let image, let alternativeText):
                XCTAssertNil(image.imageBaseURL?.absoluteString)
                XCTAssertEqual(alternativeText.text, "I 95")
                XCTAssertNil(alternativeText.abbreviation)
                XCTAssertNil(alternativeText.abbreviationPriority)
                XCTAssertEqual(image.shield?.baseURL, URL(string: "https://api.mapbox.com/styles/v1/")!)
                XCTAssertEqual(image.shield?.name, "us-interstate")
                XCTAssertEqual(image.shield?.textColor, "white")
                XCTAssertEqual(image.shield?.text, "95")
            default:
                XCTFail("Image component should not be decoded as any other kind of component.")
            }
        }
        
        let shield = VisualInstruction.Component.ShieldRepresentation(baseURL: URL(string: "https://api.mapbox.com/styles/v1/")!, name: "us-interstate", textColor: "white", text: "95")
        component = .image(image: .init(imageBaseURL: nil, shield: shield),
                           alternativeText: .init(text: "I 95", abbreviation: nil, abbreviationPriority: nil))
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
    
    func testInstructionComponentsWithSubTypes() {
        let routeData = try! Data(contentsOf: URL(fileURLWithPath: Bundle.module.path(forResource: "instructionComponentsWithSubType",
                                                                                      ofType: "json")!))
        let routeOptions = RouteOptions(coordinates: [
            LocationCoordinate2D(latitude: 35.652935, longitude: 139.745061),
            LocationCoordinate2D(latitude: 35.650312, longitude: 139.737655),
        ])
        
        let decoder = JSONDecoder()
        decoder.userInfo[.options] = routeOptions
        decoder.userInfo[.credentials] = Credentials(accessToken: "access_token",
                                                     host: URL(string: "http://test_host.com"))
        
        let routeResponse = try! decoder.decode(RouteResponse.self, from: routeData)
        
        guard let leg = routeResponse.routes?.first?.legs.first else {
            XCTFail("Route leg should be valid.")
            return
        }
        
        let expectedStepsCount = 5
        if leg.steps.count != expectedStepsCount {
            XCTFail("Route should have two steps.")
            return
        }
        
        guard case let .guidanceView(_, _, firstStepSubType) = leg.steps[0].instructionsDisplayedAlongStep?.first?.quaternaryInstruction?.components.first else {
            XCTFail("Component should be valid.")
            return
        }
        
        XCTAssertEqual(firstStepSubType, .cityReal)
        
        guard case let .guidanceView(_, _, secondStepSubType) = leg.steps[1].instructionsDisplayedAlongStep?.first?.quaternaryInstruction?.components.first else {
            XCTFail("Component should be valid.")
            return
        }
        
        XCTAssertEqual(secondStepSubType, .expresswayEntrance)
        
        guard case let .guidanceView(_, _, thirdStepSubType) = leg.steps[2].instructionsDisplayedAlongStep?.first?.quaternaryInstruction?.components.first else {
            XCTFail("Component should be valid.")
            return
        }
        
        XCTAssertEqual(thirdStepSubType, .jct)
    }
    
    func testInstructionComponentsSubTypeEncoding() {
        let subTypes: [VisualInstruction.Component.SubType] = VisualInstruction.Component.SubType.allCases
        
        subTypes.forEach { subType in
            let guideViewComponent = VisualInstruction.Component.guidanceView(image: GuidanceViewImageRepresentation(imageURL: URL(string: "https://www.mapbox.com/navigation")),
                                                                              alternativeText: VisualInstruction.Component.TextRepresentation(text: "CA01610_1_E", abbreviation: nil, abbreviationPriority: nil),
                                                                              subType: subType)
            let encodedGuideViewComponent = encode(guideViewComponent)
            XCTAssertEqual(subType.rawValue, encodedGuideViewComponent?["subType"] as? String)
        }
    }
    
    func encode(_ component: VisualInstruction.Component) -> [String: Any]? {
        var jsonData: Data?
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        XCTAssertNoThrow(jsonData = try encoder.encode(component))
        XCTAssertNotNil(jsonData)
        
        guard let jsonData = jsonData else {
            XCTFail("Encoded component should be valid.")
            return nil
        }
        
        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
            XCTFail("Encoded component should be valid.")
            return nil
        }
        
        return jsonDictionary
    }
}
