import Foundation


class MapMatchingResponse: Decodable {
    var code: String
    var routes : [Route]?
    var waypoints: [Waypoint]
    
    private enum CodingKeys: String, CodingKey {
        case code
        case matches = "matchings"
        case tracepoints
    }
    
    public required init(from decoder: Decoder) throws {
        let options = decoder.userInfo[.options] as? MatchOptions
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(String.self, forKey: .code)
        let waypoints = try container.decode([Waypoint].self, forKey: .tracepoints)
        
        if let optionsPoints = options?.waypoints {
            let updatedPoints = zip(waypoints, optionsPoints).map { (arg) -> Waypoint in
                let (local, api) = arg
                
                return Waypoint(coordinate: api.coordinate, coordinateAccuracy: local.coordinateAccuracy, name: local.name ?? api.name)
            }
            self.waypoints = updatedPoints
        } else {
            self.waypoints = waypoints
        }
        
        routes = try container.decodeIfPresent([Route].self, forKey: .matches)
    }

}
