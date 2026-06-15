import XCTest
@testable import MapboxDirections

final class IncidentTests: XCTestCase {
    func testDecodingFailsWhenGeometryIndexRangeIsInverted() throws {
        let data = try makeIncidentData(overriding: [
            "geometry_index_start": 5,
            "geometry_index_end": 0,
        ])

        XCTAssertThrowsError(try JSONDecoder().decode(Incident.self, from: data))
    }

    func testDecodingFailsWhenGeometryIndexRangeIsNegative() throws {
        let data = try makeIncidentData(overriding: [
            "geometry_index_start": -1,
            "geometry_index_end": 0,
        ])

        XCTAssertThrowsError(try JSONDecoder().decode(Incident.self, from: data))
    }

    private func makeIncidentData(overriding overrides: [String: Any?] = [:]) throws -> Data {
        var dictionary: [String: Any] = [
            "id": "test_id",
            "type": "accident",
            "description": "Test description",
            "creation_time": "2021-01-01T10:00:00Z",
            "start_time": "2021-01-01T09:00:00Z",
            "end_time": "2021-01-01T12:00:00Z",
            "alertc_codes": [Int](),
            "geometry_index_start": 0,
            "geometry_index_end": 5,
        ]
        for (key, value) in overrides {
            if let value = value {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
        }
        return try JSONSerialization.data(withJSONObject: dictionary)
    }
}
