import Foundation

struct DirectionsResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case uuid
        case routes
        case waypoints
    }
    
    let code: String?
    let message: String?
    let uuid: String?
    let routes: [Route]?
    let waypoints: [Waypoint]?
}
