import XCTest
import MapboxDirections

class AttributeOptionsTests: XCTestCase {
    func testInsertion() {
        var options = AttributeOptions()
        var options2merge = AttributeOptions(descriptions: ["speed"])!
        var optionsWithCustom = AttributeOptions()

        optionsWithCustom.update(customOption: (1<<7, "Custom7"))
        options.update(with: .distance)
        options.update(with: optionsWithCustom)
        options2merge.update(customOption: (1<<8, "Custom_8"))

        options.update(with: options2merge)
        
        // Check merged options are collected
        XCTAssertEqual(options.rawValue,
                       AttributeOptions.speed.rawValue + AttributeOptions.distance.rawValue + 1<<7 + 1<<8)
        XCTAssertEqual(options.description.split(separator: ",").count,
                       4)
        XCTAssertEqual(optionsWithCustom,
                       options.update(customOption: (1<<7, "Custom7")))
        
        // insert existing default
        XCTAssertFalse(options.insert(.distance).inserted)
        // insert existing custom
        XCTAssertFalse(options.insert(optionsWithCustom).inserted)
        // insert conflicting custom
        var optionsWithConflict = AttributeOptions()
        optionsWithConflict.update(customOption: (optionsWithCustom.rawValue, "Another custom name"))
        XCTAssertFalse(options.insert(optionsWithConflict).inserted)
        // insert custom with default raw
        optionsWithConflict.rawValue = AttributeOptions.distance.rawValue
        XCTAssertFalse(options.insert(optionsWithConflict).inserted)
    }
    
    func testContains() {
        var options = AttributeOptions()
        options.update(with: .expectedTravelTime)
        options.update(customOption: (1<<9, "Custom"))
        
        XCTAssertTrue(options.contains(.init(rawValue: AttributeOptions.expectedTravelTime.rawValue)))
        XCTAssertFalse(options.contains(.congestionLevel))
        
        var wrongCustomOption = AttributeOptions()
        wrongCustomOption.update(customOption: (1<<9, "Wrong name"))
        XCTAssertFalse(options.contains(wrongCustomOption))
        
        var correctCustomOption = AttributeOptions()
        correctCustomOption.update(customOption: (1<<9, "Custom"))
        XCTAssertTrue(options.contains(correctCustomOption))
        
        XCTAssertTrue(options.contains(.init(rawValue: 1<<9)))
    }
    
    func testRemove() {
        var preservedOption = AttributeOptions()
        preservedOption.update(customOption: (1<<12, "Should be preserved"))
        var options = AttributeOptions()
        options.update(with: .congestionLevel)
        options.update(with: .distance)
        options.update(customOption: (1<<10, "Custom"))
        options.update(with: preservedOption)
        
        // Removing default item
        let distance = options.remove(AttributeOptions(descriptions: ["distance"])!)
        
        XCTAssertEqual(distance?.rawValue, AttributeOptions.distance.rawValue)
        XCTAssertTrue(options.contains(.congestionLevel))
        XCTAssertTrue(options.contains(preservedOption))
        
        // Removing not existing item by raw value
        XCTAssertNil(options.remove(AttributeOptions(rawValue: 1)))
        XCTAssertTrue(options.contains(.congestionLevel))
        XCTAssertTrue(options.contains(preservedOption))
        
        // Removing custom option with incorrect name
        var wrongCustomOption = AttributeOptions()
        wrongCustomOption.update(customOption: (1<<10, "Wrong name"))
        
        XCTAssertNil(options.remove(wrongCustomOption))
        XCTAssertTrue(options.contains(.congestionLevel))
        XCTAssertTrue(options.contains(preservedOption))
        
        // Removing existing custom option
        var correctCustomOption = AttributeOptions()
        correctCustomOption.update(customOption: (1<<10, "Custom"))
        
        XCTAssertEqual(options.remove(correctCustomOption), correctCustomOption)
        XCTAssertTrue(options.contains(.congestionLevel))
        XCTAssertTrue(options.contains(preservedOption))
        
        // Removing custom option with default raw value
        var customOptionWithDefaultRaw = AttributeOptions()
        customOptionWithDefaultRaw.update(customOption: (AttributeOptions.distance.rawValue, "Not a distance"))
        XCTAssertNil(options.remove(customOptionWithDefaultRaw))
        
        // Removing custom option by raw value only
        options.update(with: correctCustomOption)
        XCTAssertEqual(options.remove(.init(rawValue: 1<<10)), correctCustomOption)
    }
}
