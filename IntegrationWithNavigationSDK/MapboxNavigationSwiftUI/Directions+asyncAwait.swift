import MapboxCoreNavigation
import MapboxDirections

extension MapboxRoutingProvider {
    func calculate(options: RouteOptions) async throws -> IndexedRouteResponse {
        try await withCheckedThrowingContinuation { continuation in
            _ = calculateRoutes(options: options) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
