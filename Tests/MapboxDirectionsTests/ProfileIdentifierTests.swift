@testable import MapboxDirections
import Turf
import XCTest

final class ProfileIdentifierTests: XCTestCase {
    let customAutomobileAvoidingTraffic = ProfileIdentifier(rawValue: "custom/driving-traffic")
    let customAutomobile = ProfileIdentifier(rawValue: "custom/driving")
    let customWalking = ProfileIdentifier(rawValue: "custom/walking")
    let unexpected = ProfileIdentifier(rawValue: "not-a-valid-profile")

    func testIsAutomobileAvoidingTraffic() {
        XCTAssertTrue(ProfileIdentifier.automobileAvoidingTraffic.isAutomobileAvoidingTraffic)
        XCTAssertFalse(ProfileIdentifier.automobile.isAutomobileAvoidingTraffic)
        XCTAssertFalse(ProfileIdentifier.cycling.isAutomobileAvoidingTraffic)
        XCTAssertFalse(ProfileIdentifier.walking.isAutomobileAvoidingTraffic)

        XCTAssertTrue(customAutomobileAvoidingTraffic.isAutomobileAvoidingTraffic)
        XCTAssertFalse(customAutomobile.isAutomobileAvoidingTraffic)
        XCTAssertFalse(customWalking.isAutomobileAvoidingTraffic)
        XCTAssertFalse(unexpected.isAutomobileAvoidingTraffic)

        let custom = ProfileIdentifier(rawValue: "custom/driving-traffic-suffix")
        XCTAssertFalse(custom.isAutomobileAvoidingTraffic)
    }

    func testIsAutomobile() {
        XCTAssertTrue(ProfileIdentifier.automobile.isAutomobile)
        XCTAssertFalse(ProfileIdentifier.automobileAvoidingTraffic.isAutomobile)
        XCTAssertFalse(ProfileIdentifier.cycling.isAutomobile)
        XCTAssertFalse(ProfileIdentifier.walking.isAutomobile)

        XCTAssertTrue(customAutomobile.isAutomobile)
        XCTAssertFalse(customAutomobileAvoidingTraffic.isAutomobile)
        XCTAssertFalse(customWalking.isAutomobile)
        XCTAssertFalse(unexpected.isAutomobile)

        let custom = ProfileIdentifier(rawValue: "custom/driving-suffix")
        XCTAssertFalse(custom.isAutomobile)
    }

    func testIsWalkable() {
        XCTAssertTrue(ProfileIdentifier.walking.isWalking)
        XCTAssertFalse(ProfileIdentifier.automobile.isWalking)
        XCTAssertFalse(ProfileIdentifier.automobileAvoidingTraffic.isWalking)
        XCTAssertFalse(ProfileIdentifier.cycling.isWalking)

        XCTAssertTrue(customWalking.isWalking)
        XCTAssertFalse(customAutomobile.isWalking)
        XCTAssertFalse(customAutomobileAvoidingTraffic.isWalking)
        XCTAssertFalse(unexpected.isWalking)

        let custom = ProfileIdentifier(rawValue: "custom/walking-suffix")
        XCTAssertFalse(custom.isWalking)
    }
}
