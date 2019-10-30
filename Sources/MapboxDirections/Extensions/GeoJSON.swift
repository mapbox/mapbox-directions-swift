import Foundation
import CoreLocation
import Polyline
import struct Turf.LineString

extension LineString {
    init(polyLineString: PolyLineString) throws {
        switch polyLineString {
        case let .lineString(lineString):
            self = lineString
        case let .polyline(encodedPolyline, precision: precision):
            self = try LineString(encodedPolyline: encodedPolyline, precision: precision)
        }
    }
    
    init(encodedPolyline: String, precision: Double) throws {
        guard let coordinates = decodePolyline(encodedPolyline, precision: precision) as [CLLocationCoordinate2D]? else {
            throw GeometryError.cannotDecodePolyline(precision: precision)
        }
        self.init(coordinates)
    }
}

public enum GeometryError: LocalizedError {
    case cannotDecodePolyline(precision: Double)
    
    public var failureReason: String? {
        switch self {
        case let .cannotDecodePolyline(precision):
            return "Unable to decode the string as a polyline with precision \(precision)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .cannotDecodePolyline:
            return "Choose the precision that the string was encoded with."
        }
    }
}
