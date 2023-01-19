import SwiftUI
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections
import CoreLocation
import MapboxMaps

public struct NavigationMapUI: UIViewRepresentable {
    private let onTap: (@MainActor (CLLocationCoordinate2D, CLLocation?) -> Void)?
    private let response: Binding<RouteResponse?>
    private let cameraState: Binding<CameraState?>

    public init(
        route: Binding<RouteResponse?>,
        cameraState: Binding<CameraState?>,
        onTap: (@MainActor (CLLocationCoordinate2D, CLLocation?) -> Void)? = nil
    ) {
        self.response = route
        self.cameraState = cameraState
        self.onTap = onTap
    }

    public func makeUIView(context: Context) -> NavigationMapView {
        let navigationMapView = NavigationMapView()
        
        let passiveLocationManager = PassiveLocationManager()
        let passiveLocationProvider = PassiveLocationProvider(locationManager: passiveLocationManager)
        navigationMapView.mapView.location.overrideLocationProvider(with: passiveLocationProvider)
        context.coordinator.navigationMapView = navigationMapView
        navigationMapView.mapView.gestures.singleTapGestureRecognizer
            .addTarget(context.coordinator, action: #selector(Coordinator.onTap(_:)))
        context.coordinator.cameraState = cameraState

        if let initialCameraState = cameraState.wrappedValue {
            navigationMapView.mapView.mapboxMap.onNext(.renderFrameFinished) { _ in
                navigationMapView.mapView.camera.fly(to: .init(cameraState: initialCameraState), duration: 0)
            }
        }

        return navigationMapView
    }

    public func updateUIView(_ navigationMapView: NavigationMapView, context: Context) {
        context.coordinator.updateRoutePreview(with: response.wrappedValue,
                                               animated: !context.transaction.disablesAnimations)

        if let cameraState = cameraState.wrappedValue, cameraState != navigationMapView.mapView.cameraState {
            navigationMapView.mapView.camera.ease(to: .init(cameraState: cameraState), duration: 1)
        }

        context.coordinator.onTap = self.onTap
        context.coordinator.cameraState = cameraState
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    public final class Coordinator {
        private var showcasingRouteResponse: RouteResponse?

        var navigationMapView: NavigationMapView?
        var onTap: (@MainActor (CLLocationCoordinate2D, CLLocation?) -> Void)?
        var cameraState: Binding<CameraState?>? {
            didSet {
                if cameraState != nil {
                    cameraStateCancellable = navigationMapView?.mapView.mapboxMap.onEvery(.cameraChanged, handler: { [weak self] event in
                        guard let self = self,
                              let navigationMapView = self.navigationMapView else { return }
                        let currentState = navigationMapView.mapView.mapboxMap.cameraState
                        self.cameraState?.wrappedValue = currentState
                    })
                }
                else {
                    cameraStateCancellable = nil
                }
            }
        }
        private var cameraStateCancellable: Cancelable?

        @objc func onTap(_ tapGesture: UITapGestureRecognizer) {
            guard let mapView = tapGesture.view as? MapView else {
                fatalError()
            }
            let gestureLocation = tapGesture.location(in: mapView)
            let destinationCoordinate = mapView.mapboxMap.coordinate(for: gestureLocation)
            onTap?(destinationCoordinate, mapView.location.latestLocation?.location)
        }

        func updateRoutePreview(with response: RouteResponse?, animated: Bool) {
            guard showcasingRouteResponse?.routes != response?.routes,
                  let navigationMapView = navigationMapView
            else { return }

            self.showcasingRouteResponse = response

            if let routes = response?.routes {
                navigationMapView.showcase(routes, animated: animated)
            }
            else {
                navigationMapView.removeRoutes()
                navigationMapView.removeWaypoints()
                navigationMapView.removeArrow()
            }
        }
    }
}

