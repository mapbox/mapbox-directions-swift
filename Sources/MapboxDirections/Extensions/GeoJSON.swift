import Foundation
import CoreLocation
import Polyline
import Turf

extension BoundingBox: CustomStringConvertible {
    public var description: String {
        return "\(southWest.longitude),\(southWest.latitude);\(northEast.longitude),\(northEast.latitude)"
    }
}

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
        guard var coordinates = decodePolyline(encodedPolyline, precision: precision) as [CLLocationCoordinate2D]? else {
            throw GeometryError.cannotDecodePolyline(precision: precision)
        }
        // If the polyline has zero length with both endpoints at the same coordinate, Polyline drops one of the coordinates.
        // https://github.com/raphaelmor/Polyline/issues/59
        // Duplicate the coordinate to ensure a valid GeoJSON geometry.
        if coordinates.count == 1 {
            coordinates.append(coordinates[0])
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
