import XCTest
import Turf
@testable import MapboxDirections

class WaypointTests: XCTestCase {
    func testCoding() {
        let waypointJSON: [String: Any?] = [
            "location": [-77.036500000000004, 38.8977],
            "name": "White House",
            "distance": 7,
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
            XCTAssertEqual(waypoint.snappedDistance, 7.0)
            XCTAssertNil(waypoint.layer)
        }
        
        waypoint = Waypoint(coordinate: LocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), coordinateAccuracy: 5, name: "White House")
        waypoint?.targetCoordinate = LocationCoordinate2D(latitude: 38.8952261, longitude: -77.0327882)
        waypoint?.heading = 90
        waypoint?.headingAccuracy = 10
        waypoint?.allowsArrivingOnOppositeSide = false
        waypoint?.snappedDistance = 7
        waypoint?.layer = -1
        
        let encoder = JSONEncoder()
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try encoder.encode(waypoint))
        XCTAssertNotNil(encodedData)
        
        if let encodedData = encodedData {
            var encodedWaypointJSON: [String: Any?]?
            XCTAssertNoThrow(encodedWaypointJSON = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any?])
            XCTAssertNotNil(encodedWaypointJSON)
            
            // Verify then remove keys that wouldn’t be part of a Waypoint object in the Directions API response.
            XCTAssertEqual(encodedWaypointJSON?["headingAccuracy"] as? LocationDirection, waypoint?.headingAccuracy)
            encodedWaypointJSON?.removeValue(forKey: "headingAccuracy")
            XCTAssertEqual(encodedWaypointJSON?["coordinateAccuracy"] as? LocationAccuracy, waypoint?.coordinateAccuracy)
            encodedWaypointJSON?.removeValue(forKey: "coordinateAccuracy")
            XCTAssertEqual(encodedWaypointJSON?["allowsArrivingOnOppositeSide"] as? Bool, waypoint?.allowsArrivingOnOppositeSide)
            encodedWaypointJSON?.removeValue(forKey: "allowsArrivingOnOppositeSide")
            XCTAssertEqual(encodedWaypointJSON?["heading"] as? LocationDirection, waypoint?.heading)
            encodedWaypointJSON?.removeValue(forKey: "heading")
            XCTAssertEqual(encodedWaypointJSON?["separatesLegs"] as? Bool, waypoint?.separatesLegs)
            encodedWaypointJSON?.removeValue(forKey: "separatesLegs")
            XCTAssertEqual(encodedWaypointJSON?["layer"] as? Int, waypoint?.layer)
            encodedWaypointJSON?.removeValue(forKey: "layer")
           
            let targetCoordinateJSON = encodedWaypointJSON?["targetCoordinate"] as? [LocationDegrees]
            XCTAssertNotNil(targetCoordinateJSON)
            XCTAssertEqual(targetCoordinateJSON?.count, 2)
            XCTAssertEqual(targetCoordinateJSON?[0] ?? 0, waypoint?.targetCoordinate?.longitude ?? 0, accuracy: 1e-5)
            XCTAssertEqual(targetCoordinateJSON?[1] ?? 0, waypoint?.targetCoordinate?.latitude ?? 0, accuracy: 1e-5)
            encodedWaypointJSON?.removeValue(forKey: "targetCoordinate")
            
            XCTAssert(JSONSerialization.objectsAreEqual(waypointJSON, encodedWaypointJSON, approximate: true))
        }
    }
    
    func testSeparatesLegs() {
        let one = Waypoint(coordinate: LocationCoordinate2D(latitude: 1, longitude: 1))
        let two = Waypoint(coordinate: LocationCoordinate2D(latitude: 2, longitude: 2))
        let three = Waypoint(coordinate: LocationCoordinate2D(latitude: 3, longitude: 3))
        let four = Waypoint(coordinate: LocationCoordinate2D(latitude: 4, longitude: 4))
        
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
        let waypoint = Waypoint(coordinate: LocationCoordinate2D(latitude: -180, longitude: -180))
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
        let left = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), coordinateAccuracy: nil, name: nil)
        XCTAssertEqual(left, left)
        
        var right = Waypoint(coordinate: LocationCoordinate2D(latitude: 1, longitude: 1), coordinateAccuracy: nil, name: nil)
        XCTAssertNotEqual(left, right)
        
        right = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), coordinateAccuracy: 0, name: nil)
        XCTAssertNotEqual(left, right)
        
        right = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), coordinateAccuracy: nil, name: "")
        XCTAssertNotEqual(left, right)
    }
    
    func testTracepointEquality() {
        let left = Tracepoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), countOfAlternatives: 0, name: nil)
        XCTAssertEqual(left, left)
        
        let right = Tracepoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), countOfAlternatives: 0, name: nil)
        XCTAssertEqual(left, right)
        
        // FIXME: Only Waypoint.==(_:_:) ever gets called: <https://stackoverflow.com/a/28794214/4585461>. This will be moot once Tracepoint becomes a struct that doesn’t inherit from Waypoint: <https://github.com/mapbox/mapbox-directions-swift/pull/388>.
//        right = Tracepoint(coordinate: LocationCoordinate2D(latitude: 1, longitude: 1), countOfAlternatives: 0, name: nil)
//        XCTAssertNotEqual(left, right)
//
//        right = Tracepoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), countOfAlternatives: 1, name: nil)
//        XCTAssertNotEqual(left, right)
//
//        right = Tracepoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0), countOfAlternatives: 0, name: "")
//        XCTAssertNotEqual(left, right)
    }
    
    func testAccuracies() {
        let from = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))
        let to = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))
        let options = RouteOptions(waypoints: [from, to])
        XCTAssertNil(options.bearings)
        XCTAssertNil(options.radiuses)
        
        from.heading = 90
        from.headingAccuracy = 45
        XCTAssertEqual(options.bearings, "90.0,45.0;")
        
        from.coordinateAccuracy = 5
        XCTAssertEqual(options.radiuses, "5.0;unlimited")
    }
    
    func testClosedRoadSnapping() {
        let from = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))
        let to = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))
        let through = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))

        let routeOptions = RouteOptions(waypoints: [from, through, to])
        let matchOptions = MatchOptions(waypoints: [from, through, to], profileIdentifier: nil)

        through.allowsSnappingToClosedRoad = true
        through.allowsSnappingToStaticallyClosedRoad = true

        XCTAssertEqual(routeOptions.urlQueryItems.first { $0.name == "snapping_include_closures" }?.value, ";true;")
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "snapping_include_closures" }?.value, ";true;")
        XCTAssertEqual(routeOptions.urlQueryItems.first { $0.name == "snapping_include_static_closures" }?.value, ";true;")
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "snapping_include_static_closures" }?.value, ";true;")
    }

    func testClosedRoadSnappingNotSet() {
        let from = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))
        let to = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))
        let through = Waypoint(coordinate: LocationCoordinate2D(latitude: 0, longitude: 0))

        let routeOptions = RouteOptions(waypoints: [from, through, to])
        let matchOptions = MatchOptions(waypoints: [from, through, to], profileIdentifier: nil)

        XCTAssertEqual(routeOptions.urlQueryItems.first { $0.name == "snapping_include_closures" }?.value, nil)
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "snapping_include_closures" }?.value, nil)
        XCTAssertEqual(routeOptions.urlQueryItems.first { $0.name == "snapping_include_static_closures" }?.value, nil)
        XCTAssertEqual(matchOptions.urlQueryItems.first { $0.name == "snapping_include_static_closures" }?.value, nil)
    }
}
