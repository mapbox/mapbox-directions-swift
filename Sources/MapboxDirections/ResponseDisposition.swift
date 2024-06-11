import Foundation


struct ResponseDisposition: Decodable {
    var code: String?
    var message: String?
    var error: String?
    var refreshTTL: Int?
    
    private enum CodingKeys: String, CodingKey {
        case code, message, error, refreshTTL = "refresh_ttl"
    }
}
