import Foundation

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

struct GenericDecodable<T: Decodable, U: Decodable>: Decodable {
    var t: T?
    var u: U?
    
    var value: Decodable? {
        return t ?? u
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        t = try? container.decode(T.self)
        u = try? container.decode(U.self)
    }
}
