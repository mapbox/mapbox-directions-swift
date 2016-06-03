import XCTest
import OHHTTPStubs
@testable import MapboxDirections

let BogusToken = "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede"

class DirectionsTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testConfiguration() {
        let directions = Directions(accessToken: BogusToken)
        XCTAssertEqual(directions.accessToken, BogusToken)
        XCTAssertEqual(directions.apiEndpoint.absoluteString, "https://api.mapbox.com")
    }
}
