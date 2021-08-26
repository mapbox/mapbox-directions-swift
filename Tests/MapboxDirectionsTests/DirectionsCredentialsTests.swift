import XCTest
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

    func testAccessTokenInjection() {
        let expected = "injected"
        UserDefaults.standard.set(expected, forKey: "MBXAccessToken")
        XCTAssertEqual(Directions.shared.credentials.accessToken, expected)
    }

#if !os(Linux)
    func testSkuToken() {
        let expectedToken = "a token"
        MBXAccounts.serviceSkuToken = expectedToken
        XCTAssertEqual(Directions.shared.credentials.skuToken, expectedToken)
        MBXAccounts.serviceSkuToken = nil
    }
#endif
}

#if !os(Linux)
@objc(MBXAccounts)
final class MBXAccounts: NSObject {
    @objc static var serviceSkuToken: String?
}
#endif
