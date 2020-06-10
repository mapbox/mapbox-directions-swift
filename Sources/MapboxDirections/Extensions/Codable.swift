import Foundation
import Polyline
import Turf

extension LineString {
    /**
     Returns a string representation of the line string in [Polyline Algorithm Format](https://developers.google.com/maps/documentation/utilities/polylinealgorithm).
     */
    func polylineEncodedString(precision: Double = 1e5) -> String {
        return encodeCoordinates(coordinates, precision: precision)
    }
}

enum PolyLineString {
    case lineString(_ lineString: LineString)
    case polyline(_ encodedPolyline: String, precision: Double)
    
    init(lineString: LineString, shapeFormat: RouteShapeFormat) {
        switch shapeFormat {
        case .geoJSON:
            self = .lineString(lineString)
        case .polyline, .polyline6:
            let precision = shapeFormat == .polyline6 ? 1e6 : 1e5
            let encodedPolyline = lineString.polylineEncodedString(precision: precision)
            self = .polyline(encodedPolyline, precision: precision)
        }
    }
}

extension PolyLineString: Codable {
    private enum LineStringCodingKeys: String, CodingKey {
        case coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let options = decoder.userInfo[.options] as? DirectionsOptions
        switch options?.shapeFormat ?? .default {
        case .geoJSON:
            let lineStringContainer = try decoder.container(keyedBy: LineStringCodingKeys.self)
            let coordinates = try lineStringContainer.decode([CLLocationCoordinate2DCodable].self, forKey: .coordinates).map { $0.decodedCoordinates }
            self = .lineString(LineString(coordinates))
        case .polyline, .polyline6:
            let precision = options?.shapeFormat == .polyline6 ? 1e6 : 1e5
            let encodedPolyline = try container.decode(String.self)
            self = .polyline(encodedPolyline, precision: precision)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .lineString(lineString):
            var lineStringContainer = encoder.container(keyedBy: LineStringCodingKeys.self)
            try lineStringContainer.encode(lineString.coordinates.map { CLLocationCoordinate2DCodable($0) }, forKey: .coordinates)
        case let .polyline(encodedPolyline, precision: _):
            try container.encode(encodedPolyline)
        }
    }
}
