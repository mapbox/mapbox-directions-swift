import XCTest
import OHHTTPStubs
@testable import MapboxDirections


class OfflineDirectionsTests: XCTestCase {
    
    let token = "foo"
    // TODO: replace with production
    let host = "api-routing-tiles-staging-195264016.us-east-1.elb.amazonaws.com"
    
    func testAvailableVersions() {
        let directions = Directions(accessToken: token, host: host)
        
        XCTAssertEqual(directions.accessToken, token)
        
        let versionsExpectation = expectation(description: "Fetching available versions should return results")
        
        let apiStub = stub(condition: isHost(host)) { _ in
            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: "versions", ofType: "json")
            let filePath = URL(fileURLWithPath: path!)
            let data = try! Data(contentsOf: filePath)
            let jsonObject = try! JSONSerialization.jsonObject(with: data, options: [])
            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        
        directions.availableOfflineVersions { (versions, error) in
            XCTAssertEqual(versions!.count, 1)
            XCTAssertEqual(versions!.first!.versionString, "2018-10-16")
            
            versionsExpectation.fulfill()
            OHHTTPStubs.removeStub(apiStub)
            
        }.resume()
        
        wait(for: [versionsExpectation], timeout: 2)
    }

    func testDownloadTiles() {
        
        let directions = Directions(accessToken: token, host: host)
        
        let boundingBox = BoundingBox([CLLocationCoordinate2D(latitude: 37.7890, longitude: -122.4337),
                                       CLLocationCoordinate2D(latitude: 37.7881, longitude: -122.4318)])
        
        let version = Version("2018-10-16")
        let downloadExpectation = self.expectation(description: "Download tile expectation")
        
        let apiStub = stub(condition: isHost(host)) { _ in
            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: "2018-10-16-Liechtenstein", ofType: "tar")

            let attributes = try! FileManager.default.attributesOfItem(atPath: path!)
            let fileSize = attributes[.size] as! UInt64
            
            var headers = [AnyHashable: Any]()
            headers["Content-Type"] = "application/x-gtar"
            headers["Content-Length"] = "\(fileSize)"
            
            return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: headers)
        }
        
        _ = directions.downloadTiles(for: boundingBox, version: version, progressHandler: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            
            let progress = totalBytesExpectedToWrite / totalBytesWritten
            print(progress)
            
        }, completionHandler: { (url, response, error) in
            
            XCTAssertNotNil(url, "url should point to the temporary local file")
            XCTAssertNil(error)
            
            downloadExpectation.fulfill()
            OHHTTPStubs.removeStub(apiStub)
            
        }).resume()
        
        wait(for: [downloadExpectation], timeout: 60)
    }
}
