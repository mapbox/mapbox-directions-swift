import XCTest
@testable import MapboxDirections

class CredentialsTests: XCTestCase {

    func testCredentialsCreation() {
        let testURL = URL(string: "https://example.com")!
        let subject = DirectionsCredentials(accessToken: "test", host: testURL)
        
        XCTAssertEqual(subject.accessToken, "test")
        XCTAssertEqual(subject.host, testURL)
    }
}
