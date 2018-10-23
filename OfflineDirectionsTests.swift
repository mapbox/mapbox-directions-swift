import XCTest
import OHHTTPStubs
@testable import MapboxDirections


class OfflineDirectionsTests: XCTestCase {
    
    let token = "foo"
    
    func testAvailableVersions() {
        // TODO: Replace with production
        let host = "api-routing-tiles-staging-195264016.us-east-1.elb.amazonaws.com"
        let directions = OfflineDirections(accessToken: token, host: host)
        
        XCTAssertEqual(directions.accessToken, token)
        
        let versionsExpectation = expectation(description: "Fetching available versions should return results")
        
        stub(condition: isHost(host)) { _ in
            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: "versions", ofType: "json")
            let filePath = URL(fileURLWithPath: path!)
            let data = try! Data(contentsOf: filePath)
            let jsonObject = try! JSONSerialization.jsonObject(with: data, options: [])
            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        directions.availableVersions { (versions, error) in
            XCTAssertEqual(versions!.count, 1)
            XCTAssertEqual(versions!.first!.versionString, "2018-10-16")
            versionsExpectation.fulfill()
        }.resume()
        
        wait(for: [versionsExpectation], timeout: 2)
    }

    func testDownloadTiles() {
        let directions = OfflineDirections(accessToken: token, host: nil)
        
        let boundingBox = BoundingBox([CLLocationCoordinate2D(latitude: 37.7798, longitude: -122.5058),
                                       CLLocationCoordinate2D(latitude: 37.7362, longitude: -122.3947)])
        
        let version = Version("2018-10-16")
        
        _ = directions.downloadTiles(for: boundingBox, version: version, progressHandler: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            // TODO: Validate progress and resuming
        }, completionHandler: { (url, error) in
            // TODO: Validate unpacked data
        })
    }
}
