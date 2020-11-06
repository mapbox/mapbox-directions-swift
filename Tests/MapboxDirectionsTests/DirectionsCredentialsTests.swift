import XCTest
#if !SWIFT_PACKAGE
import OHHTTPStubs
@testable import MapboxDirections

class DirectionsCredentialsTests: XCTestCase {
    func testDefaultConfiguration() {
        let credentials = DirectionsCredentials(accessToken: BogusToken)
        XCTAssertEqual(credentials.accessToken, BogusToken)
        XCTAssertEqual(credentials.host.absoluteString, "https://api.mapbox.com")
    }
    
    func testCustomConfiguration() {
        let token = "deadbeefcafebebe"
        let host = URL(string: "https://example.com")!
        let credentials = DirectionsCredentials(accessToken: token, host: host)
        XCTAssertEqual(credentials.accessToken, token)
        XCTAssertEqual(credentials.host, host)
    }
}
#endif
