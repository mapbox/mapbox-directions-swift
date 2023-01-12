import Foundation

struct Query: Codable, Identifiable {
    let id: String
    var name: String
    var waypoints: [Waypoint]

    static func make() -> Query {
        let uuid = UUID().uuidString
        return .init(id: uuid, name: "New Query", waypoints: .defaultWaypoints)
    }

    static var `default`: Query {
        .init(id: UUID().uuidString, name: "Mapbox Office", waypoints: .defaultWaypoints)
    }
}
