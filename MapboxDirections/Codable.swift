import Foundation
import Polyline

extension Decodable {
    static internal func from<T: Decodable>(json: String, using encoding: String.Encoding = .utf8) -> T? {
        guard let data = json.data(using: encoding) else { return nil }
        return from(data: data) as T?
    }
    
    static internal func from<T: Decodable>(data: Data) -> T? {
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: data) as T?
    }
}

struct UncertainCodable<T: Codable, U: Codable>: Codable {
    var t: T?
    var u: U?
    
    var value: Codable? {
        return t ?? u
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        if let geo = value as? String {
            return decodePolyline(geo, precision: 1e5)!
        } else if let geo = value as? Geometry {
            return geo.coordinates
        } else {
            return []
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        t = try? container.decode(T.self)
        if t == nil {
            u = try? container.decode(U.self)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let t = t {
            try? container.encode(t)
        }
        if let u = u {
            try? container.encode(u)
        }
    }
}
