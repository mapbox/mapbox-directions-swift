import XCTest
import CoreLocation
@testable import MapboxDirections

class WaypointTests: XCTestCase {
    func testCoding() {
        let waypointJSON: [String: Any?] = [
            "location": [-77.036500000000004, 38.8977],
            "name": "White House",
        ]
        let waypointData = try! JSONSerialization.data(withJSONObject: waypointJSON, options: [])
        var waypoint: Waypoint?
        XCTAssertNoThrow(waypoint = try JSONDecoder().decode(Waypoint.self, from: waypointData))
        XCTAssertNotNil(waypoint)
        
        if let waypoint = waypoint {
            XCTAssertEqual(waypoint.coordinate.latitude, 38.8977, accuracy: 1e-5)
            XCTAssertEqual(waypoint.coordinate.longitude, -77.03650, accuracy: 1e-5)
            XCTAssertNil(waypoint.coordinateAccuracy)
            XCTAssertNil(waypoint.targetCoordinate)

            XCTAssertNil(waypoint.heading)
            XCTAssertNil(waypoint.headingAccuracy)
            XCTAssertTrue(waypoint.allowsArrivingOnOppositeSide)
            XCTAssertTrue(waypoint.separatesLegs)
        }
        
        waypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), coordinateAccuracy: 5, name: "White House")
        waypoint?.targetCoordinate = CLLocationCoordinate2D(latitude: 38.8952261, longitude: -77.0327882)
        waypoint?.heading = 90
        waypoint?.headingAccuracy = 10
        waypoint?.allowsArrivingOnOppositeSide = false
        
        let encoder = JSONEncoder()
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try encoder.encode(waypoint))
        XCTAssertNotNil(encodedData)
        
        if let encodedData = encodedData {
            var encodedWaypointJSON: [String: Any?]?
            XCTAssertNoThrow(encodedWaypointJSON = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any?])
            XCTAssertNotNil(encodedWaypointJSON)
            
            // Verify then remove keys that wouldn’t be part of a Waypoint object in the Directions API response.
            XCTAssertEqual(encodedWaypointJSON?["headingAccuracy"] as? CLLocationDirection, waypoint?.headingAccuracy)
            encodedWaypointJSON?.removeValue(forKey: "headingAccuracy")
            XCTAssertEqual(encodedWaypointJSON?["coordinateAccuracy"] as? CLLocationAccuracy, waypoint?.coordinateAccuracy)
            encodedWaypointJSON?.removeValue(forKey: "coordinateAccuracy")
            XCTAssertEqual(encodedWaypointJSON?["allowsArrivingOnOppositeSide"] as? Bool, waypoint?.allowsArrivingOnOppositeSide)
            encodedWaypointJSON?.removeValue(forKey: "allowsArrivingOnOppositeSide")
            XCTAssertEqual(encodedWaypointJSON?["heading"] as? CLLocationDirection, waypoint?.heading)
            encodedWaypointJSON?.removeValue(forKey: "heading")
            XCTAssertEqual(encodedWaypointJSON?["separatesLegs"] as? Bool, waypoint?.separatesLegs)
            encodedWaypointJSON?.removeValue(forKey: "separatesLegs")
           
            let targetCoordinateJSON = encodedWaypointJSON?["targetCoordinate"] as? [CLLocationDegrees]
            XCTAssertNotNil(targetCoordinateJSON)
            XCTAssertEqual(targetCoordinateJSON?.count, 2)
            XCTAssertEqual(targetCoordinateJSON?[0] ?? 0, waypoint?.targetCoordinate?.longitude ?? 0, accuracy: 1e-5)
            XCTAssertEqual(targetCoordinateJSON?[1] ?? 0, waypoint?.targetCoordinate?.latitude ?? 0, accuracy: 1e-5)
            encodedWaypointJSON?.removeValue(forKey: "targetCoordinate")
            
            XCTAssert(JSONSerialization.objectsAreEqual(waypointJSON, encodedWaypointJSON, approximate: true))
        }
    }
    
    func testSeparatesLegs() {
        let one = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        let two = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 2, longitude: 2))
        let three = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 3, longitude: 3))
        let four = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 4, longitude: 4))
        
        let routeOptions = RouteOptions(waypoints: [one, two, three, four])
        let matchOptions = MatchOptions(waypoints: [one, two, three, four], profileIdentifier: nil)
        
        XCTAssertNil(routeOptions.urlQueryItems.first { $0.name == "waypoints" }?.value)
        XCTAssertNil(matchOptions.urlQueryItems.first { $0.name == "waypoints" }?.value)
        
        two.separatesLegs = false
        
        XCTAssertEqual(routeOptions.urlQueryItems.first { $0.name == "waypoints" }?.value, "0;2;3")
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "waypoints" }?.value, "0;2;3")
        
        two.separatesLegs = true
        matchOptions.waypointIndices = [0, 2, 3]
        
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "waypoints" }?.value, "0;2;3")
    }
    
    func testHeading() {
        let waypoint = Waypoint(coordinate: kCLLocationCoordinate2DInvalid)
        XCTAssertEqual(waypoint.headingDescription, "")
        
        waypoint.heading = 0
        XCTAssertEqual(waypoint.headingDescription, "")
        
        waypoint.headingAccuracy = 0
        XCTAssertEqual(waypoint.headingDescription, "0.0,0.0")
        
        waypoint.heading = 810.5
        XCTAssertEqual(waypoint.headingDescription, "90.5,0.0")
        
        waypoint.headingAccuracy = 720
        XCTAssertEqual(waypoint.headingDescription, "90.5,180.0")
    }
    
    func testEquality() {
        let left = Waypoint(coordinate: CLLocationCoordinate2D(), coordinateAccuracy: nil, name: nil)
        XCTAssertEqual(left, left)
        
        var right = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1), coordinateAccuracy: nil, name: nil)
        XCTAssertNotEqual(left, right)
        
        right = Waypoint(coordinate: CLLocationCoordinate2D(), coordinateAccuracy: 0, name: nil)
        XCTAssertNotEqual(left, right)
        
        right = Waypoint(coordinate: CLLocationCoordinate2D(), coordinateAccuracy: nil, name: "")
        XCTAssertNotEqual(left, right)
    }
    
    func testTracepointEquality() {
        let left = Tracepoint(coordinate: CLLocationCoordinate2D(), countOfAlternatives: 0, name: nil)
        XCTAssertEqual(left, left)
        
        let right = Tracepoint(coordinate: CLLocationCoordinate2D(), countOfAlternatives: 0, name: nil)
        XCTAssertEqual(left, right)
        
        // FIXME: Only Waypoint.==(_:_:) ever gets called: <https://stackoverflow.com/a/28794214/4585461>. This will be moot once Tracepoint becomes a struct that doesn’t inherit from Waypoint: <https://github.com/mapbox/MapboxDirections.swift/pull/388>.
//        right = Tracepoint(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1), countOfAlternatives: 0, name: nil)
//        XCTAssertNotEqual(left, right)
//
//        right = Tracepoint(coordinate: CLLocationCoordinate2D(), countOfAlternatives: 1, name: nil)
//        XCTAssertNotEqual(left, right)
//
//        right = Tracepoint(coordinate: CLLocationCoordinate2D(), countOfAlternatives: 0, name: "")
//        XCTAssertNotEqual(left, right)
    }
}
