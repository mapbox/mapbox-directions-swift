import SwiftUI
import MapboxNavigation
import MapboxDirections

public struct NavigationView: UIViewControllerRepresentable {
    public let routeResponse: RouteResponse
    public let routeIndex: Int
    public let routeOptions: RouteOptions
    public let navigationOptions: NavigationOptions?

    public func makeUIViewController(context: Context) -> NavigationViewController {
        NavigationViewController(
            for: routeResponse,
            routeIndex: routeIndex,
            routeOptions: routeOptions,
            navigationOptions: navigationOptions
        )
    }

    public func updateUIViewController(_ uiViewController: NavigationViewController, context: Context) {
        //
    }
}
