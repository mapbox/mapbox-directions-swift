import XCTest
import Turf
@testable import MapboxDirections

class RouteLegTests: XCTestCase {
    func testSegmentRanges() {
        let departureStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 0, longitude: 0), maneuverType: .depart, instructions: "Depart", drivingSide: .right, distance: 10, expectedTravelTime: 10)
        departureStep.shape = LineString([
            LocationCoordinate2D(latitude: 0, longitude: 0),
            LocationCoordinate2D(latitude: 1, longitude: 1),
        ])
        let noShapeStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 1, longitude: 1), maneuverType: .continue, instructions: "Continue", drivingSide: .right, distance: 0, expectedTravelTime: 0)
        let turnStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 1, longitude: 1), maneuverType: .turn, maneuverDirection: .left, instructions: "Turn left at Albuquerque", drivingSide: .right, distance: 10, expectedTravelTime: 10)
        turnStep.shape = LineString([
            LocationCoordinate2D(latitude: 1, longitude: 1),
            LocationCoordinate2D(latitude: 2, longitude: 2),
            LocationCoordinate2D(latitude: 3, longitude: 3),
            LocationCoordinate2D(latitude: 4, longitude: 4),
        ])
        let typicalTravelTime = 10.0
        let arrivalStep = RouteStep(transportType: .automobile, maneuverLocation: LocationCoordinate2D(latitude: 4, longitude: 4), maneuverType: .arrive, instructions: "Arrive at Elmer’s House", drivingSide: .right, distance: 0, expectedTravelTime: 0)
        arrivalStep.shape = LineString([
            LocationCoordinate2D(latitude: 4, longitude: 4),
            LocationCoordinate2D(latitude: 4, longitude: 4),
        ])
        let leg = RouteLeg(steps: [departureStep, noShapeStep, turnStep, arrivalStep], name: "", distance: 10, expectedTravelTime: 10, typicalTravelTime: typicalTravelTime, profileIdentifier: .automobile)
        leg.segmentDistances = [
            10,
            10, 20, 30,
        ]
        XCTAssertEqual(leg.segmentRangesByStep.count, leg.steps.count)
        XCTAssertEqual(leg.segmentRangesByStep, [0..<1, 1..<1, 1..<4, 4..<4])
        XCTAssertEqual(leg.segmentRangesByStep.last?.upperBound, leg.segmentDistances?.count)
        XCTAssertEqual(leg.typicalTravelTime, typicalTravelTime)
    }

    func testDecodingSucceedsWhenClosureGeometryIndexRangeIsEmpty() throws {
        let data = try makeRouteLegData(overriding: [
            "closures": [
                [
                    "geometry_index_start": 5,
                    "geometry_index_end": 5,
                ],
            ],
        ])

        let leg = try makeRouteLegDecoder().decode(RouteLeg.self, from: data)
        XCTAssertEqual(leg.closures?.first?.shapeIndexRange, 5..<5)
    }

    func testDecodingFailsWhenClosureGeometryIndexRangeIsInverted() throws {
        let data = try makeRouteLegData(overriding: [
            "closures": [
                [
                    "geometry_index_start": 5,
                    "geometry_index_end": 0,
                ],
            ],
        ])

        XCTAssertThrowsError(try makeRouteLegDecoder().decode(RouteLeg.self, from: data))
    }

    func testDecodingFailsWhenClosureGeometryIndexRangeIsNegative() throws {
        let data = try makeRouteLegData(overriding: [
            "closures": [
                [
                    "geometry_index_start": -1,
                    "geometry_index_end": 0,
                ],
            ],
        ])

        XCTAssertThrowsError(try makeRouteLegDecoder().decode(RouteLeg.self, from: data))
    }

    func testRefreshClosuresUsesEmptyRangeWhenAdjustedShapeIndexOverflows() throws {
        let leg = try makeRouteLegDecoder().decode(RouteLeg.self, from: makeRouteLegData())
        let closure = try makeClosureData(startIndex: 1, endIndex: 2)

        leg.refreshClosures(
            newClosures: [try JSONDecoder().decode(RouteLeg.Closure.self, from: closure)],
            startLegShapeIndex: Int.max
        )

        XCTAssertEqual(leg.closures?.first?.shapeIndexRange, 0..<0)
    }

    func testRefreshIncidentsUsesEmptyRangeWhenAdjustedShapeIndexOverflows() throws {
        let leg = try makeRouteLegDecoder().decode(RouteLeg.self, from: makeRouteLegData())
        let incident = Incident(
            identifier: "test_id",
            type: .accident,
            description: "Test description",
            creationDate: Date(),
            startDate: Date(),
            endDate: Date(),
            impact: nil,
            subtype: nil,
            subtypeDescription: nil,
            alertCodes: [],
            lanesBlocked: nil,
            shapeIndexRange: 1..<2
        )

        leg.refreshIncidents(newIncidents: [incident], startLegShapeIndex: Int.max)

        XCTAssertEqual(leg.incidents?.first?.shapeIndexRange, 0..<0)
    }

    func testRefreshAttributesDoesNotReplaceWhenStartIndexIsNegative() throws {
        let leg = try makeRouteLegDecoder().decode(RouteLeg.self, from: makeRouteLegData())
        leg.segmentDistances = [1, 2, 3]
        var attributes = RouteLeg.Attributes()
        attributes.segmentDistances = [9]

        leg.refreshAttributes(newAttributes: attributes, startLegShapeIndex: -1)

        XCTAssertEqual(leg.segmentDistances, [1, 2, 3])
    }

    private func makeRouteLegDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.userInfo[.options] = RouteOptions(coordinates: [
            LocationCoordinate2D(latitude: 0, longitude: 0),
            LocationCoordinate2D(latitude: 1, longitude: 1),
        ])
        return decoder
    }

    private func makeRouteLegData(overriding overrides: [String: Any?] = [:]) throws -> Data {
        var dict: [String: Any] = [
            "summary": "Test Leg",
            "distance": 100.0,
            "duration": 60.0,
            "steps": [Any](),
        ]
        for (key, value) in overrides {
            if let value = value {
                dict[key] = value
            } else {
                dict.removeValue(forKey: key)
            }
        }
        return try JSONSerialization.data(withJSONObject: dict)
    }

    private func makeClosureData(startIndex: Int, endIndex: Int) throws -> Data {
        return try JSONSerialization.data(withJSONObject: [
            "geometry_index_start": startIndex,
            "geometry_index_end": endIndex,
        ])
    }
}
