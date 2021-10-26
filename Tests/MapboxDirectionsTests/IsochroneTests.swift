import Foundation
@testable import MapboxDirections
#if !os(Linux)
import OHHTTPStubs
#if SWIFT_PACKAGE
import OHHTTPStubsSwift
#endif
#endif
import Turf
import XCTest

let IsochroneBogusCredentials = IsochroneCredentials(accessToken: BogusToken)

let minimalValidResponse = """
{
    "features": [],
    "type": "FeatureCollection"
}
"""

class IsochroneTests: XCTestCase {
    
    override func tearDown() {
        #if !os(Linux)
        HTTPStubs.removeAllStubs()
        #endif
        super.tearDown()
    }
    
    func testConfiguration() {
        let isochrone = Isochrone(credentials: IsochroneBogusCredentials)
        XCTAssertEqual(isochrone.credentials, IsochroneBogusCredentials)
    }
    
    func testRequest() {
        let location = LocationCoordinate2D(latitude: 0, longitude: 1)
        let options = IsochroneOptions(location: location,
                                       contours: .distance([99.5, 200.44]))
        #if !os(Linux)
        options.colors = [IsochroneOptions.Color(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0),
                          IsochroneOptions.Color(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)]
        #else
        options.colors = [IsochroneOptions.Color(red: 25, green: 51, blue: 76, alpha: 255),
                          IsochroneOptions.Color(red: 102, green: 127, blue: 153, alpha: 255)]
        #endif
        options.contoursPolygons = true
        options.denoiseFactor = 0.5
        options.generalizeTolerance = 13
        
        let isochrone = Isochrone(credentials: IsochroneBogusCredentials)
        var url = isochrone.url(forCalculating: options)
        let request = isochrone.urlRequest(forCalculating: options)
        
        guard let components = URLComponents(string: url.absoluteString),
              let queryItems = components.queryItems else {
            XCTFail("Invalid url"); return
        }
        XCTAssertEqual(queryItems.count, 6)
        XCTAssertTrue(components.path.contains(location.requestDescription) )
        XCTAssertTrue(queryItems.contains(where: { $0.name == "access_token" && $0.value == BogusToken }))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "contours_meters" && $0.value == "100;200"}))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "contours_colors" && $0.value == "19334C;667F99"}))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "polygons" && $0.value == "true"}))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "denoise" && $0.value == "0.5"}))
        XCTAssertTrue(queryItems.contains(where: { $0.name == "generalize" && $0.value == "13.0"}))

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url, url)
        
        options.contours = .expectedTravelTime([31, 149])
        
        url = isochrone.url(forCalculating: options)
        
        guard let components = URLComponents(string: url.absoluteString),
              let queryItems = components.queryItems else {
            XCTFail("Invalid url"); return
        }
        
        XCTAssertTrue(queryItems.contains(where: { $0.name == "contours_minutes" && $0.value == "1;2"}))
    }
    
    #if !os(Linux)
    func testMinimalValidResponse() {
        HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/isochrone")
        }) { (_) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: minimalValidResponse.data(using: .utf8)!, statusCode: 200, headers: ["Content-Type" : "text/html"])
        }
        let expectation = self.expectation(description: "Async callback")
        let isochrone = Isochrone(credentials: IsochroneBogusCredentials)
        let options = IsochroneOptions(location: LocationCoordinate2D(latitude: 0, longitude: 1),
                                       contours: .distance([100]))
        isochrone.calculate(options, completionHandler: { (session, result) in
            defer { expectation.fulfill() }
                
            guard case let .success(featureCollection) = result else {
                XCTFail("Expecting success, error returned. \(result)")
                return
            }

            guard featureCollection.features.isEmpty else {
                XCTFail("Wrong feature decoding.")
                return
            }
        })
        wait(for: [expectation], timeout: 2.0)
    }

    func testUnknownBadResponse() {
        let message = "Lorem ipsum."
        HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/isochrone")
        }) { (_) -> HTTPStubsResponse in
            return HTTPStubsResponse(data: message.data(using: .utf8)!, statusCode: 420, headers: ["Content-Type" : "text/plain"])
        }
        let expectation = self.expectation(description: "Async callback")
        let isochrone = Isochrone(credentials: IsochroneBogusCredentials)
        let options = IsochroneOptions(location: LocationCoordinate2D(latitude: 0, longitude: 1),
                                       contours: .distance([100]))
        isochrone.calculate(options, completionHandler: { (session, result) in
            defer { expectation.fulfill() }

            guard case let .failure(error) = result else {
                XCTFail("Expecting an error, none returned. \(result)")
                return
            }

            guard case .invalidResponse(_) = error else {
                XCTFail("Wrong error type returned.")
                return
            }
        })
        wait(for: [expectation], timeout: 2.0)
    }

    func testDownNetwork() {
        let notConnected = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue) as! URLError

        HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url!.absoluteString.contains("https://api.mapbox.com/isochrone")
        }) { (_) -> HTTPStubsResponse in
            return HTTPStubsResponse(error: notConnected)
        }

        let expectation = self.expectation(description: "Async callback")
        let isochrone = Isochrone(credentials: IsochroneBogusCredentials)
        let options = IsochroneOptions(location: LocationCoordinate2D(latitude: 0, longitude: 1),
                                       contours: .distance([100]))
        isochrone.calculate(options, completionHandler: { (session, result) in
            defer { expectation.fulfill() }

            guard case let .failure(error) = result else {
                XCTFail("Error expected, none returned. \(result)")
                return
            }

            guard case let .network(err) = error else {
                XCTFail("Wrong error type returned. \(error)")
                return
            }

            // Comparing just the code and domain to avoid comparing unessential `UserInfo` that might be added.
            XCTAssertEqual(type(of: err).errorDomain, type(of: notConnected).errorDomain)
            XCTAssertEqual(err.code, notConnected.code)
        })
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRateLimitErrorParsing() {
        let url = URL(string: "https://api.mapbox.com")!
        let headerFields = ["X-Rate-Limit-Interval" : "60", "X-Rate-Limit-Limit" : "600", "X-Rate-Limit-Reset" : "1479460584"]
        let response = HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: headerFields)

        let resultError = IsochroneError(code: "429", message: "Hit rate limit", response: response, underlyingError: nil)
        if case let .rateLimited(rateLimitInterval, rateLimit, resetTime) = resultError {
            XCTAssertEqual(rateLimitInterval, 60.0)
            XCTAssertEqual(rateLimit, 600)
            XCTAssertEqual(resetTime, Date(timeIntervalSince1970: 1479460584))
        } else {
            XCTFail("Code 429 should be interpreted as a rate limiting error.")
        }
    }
    #endif
}
