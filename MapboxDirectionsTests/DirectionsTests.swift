import XCTest
import OHHTTPStubs
@testable import MapboxDirections

let BogusToken = "pk.feedCafeDadeDeadBeef-BadeBede.FadeCafeDadeDeed-BadeBede"

class DirectionsTests: XCTestCase {
    override func setUp() {
        // Make sure tests run in all time zones
        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: 0))
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testConfiguration() {
        let directions = Directions(accessToken: BogusToken)
        XCTAssertEqual(directions.accessToken, BogusToken)
        XCTAssertEqual(directions.apiEndpoint.absoluteString, "https://api.mapbox.com")
    }
    
    func testRateLimitErrorParsing() {
        let json = ["message" : "Hit rate limit"]
        
        let url = NSURL(string: "https://api.mapbox.com")!
        let headerFields = ["X-Rate-Limit-Interval" : "60", "X-Rate-Limit-Limit" : "600", "X-Rate-Limit-Reset" : "1479460584"]
        let response = NSHTTPURLResponse(URL: url, statusCode: 429, HTTPVersion: nil, headerFields: headerFields)
        
        let error: NSError? = nil
        
        let resultError = Directions.descriptiveError(json, response: response, underlyingError: error)
        
        XCTAssertEqual(resultError.localizedFailureReason, "More than 600 requests have been made with this access token within a period of 1 minute.")
        XCTAssertEqual(resultError.localizedRecoverySuggestion, "Wait until November 18, 2016 at 9:16:24 AM GMT before retrying.")
    }
}
