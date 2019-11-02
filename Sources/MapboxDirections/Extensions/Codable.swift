import Foundation
import Polyline
import struct Turf.LineString

enum PolyLineString {
    case lineString(_ lineString: LineString)
    case polyline(_ encodedPolyline: String, precision: Double)
    
    init(lineString: LineString, shapeFormat: RouteShapeFormat) {
        switch shapeFormat {
        case .geoJSON:
            self = .lineString(lineString)
        case .polyline, .polyline6:
            let precision = shapeFormat == .polyline6 ? 1e6 : 1e5
            let encodedPolyline = encodeCoordinates(lineString.coordinates, precision: precision)
            self = .polyline(encodedPolyline, precision: precision)
        }
    }
}

extension PolyLineString: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let options = decoder.userInfo[.options] as? DirectionsOptions
        switch options?.shapeFormat ?? .polyline {
        case .geoJSON:
            self = .lineString(try container.decode(LineString.self))
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
            try container.encode(lineString)
        case let .polyline(encodedPolyline, precision: _):
            try container.encode(encodedPolyline)
        }
    }
}
