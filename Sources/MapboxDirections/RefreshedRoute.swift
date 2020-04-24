
import Foundation

struct RefreshedRoute {
    var legAnnotations: [RouteLegAnnotation]
}

extension RefreshedRoute: Codable {
    enum CodingKeys: String, CodingKey {
        case legAnnotations = "legs"
    }
}
