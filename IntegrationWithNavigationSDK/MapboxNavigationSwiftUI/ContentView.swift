import SwiftUI
import MapboxDirections
import CoreLocation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxMaps

struct ContentView: View {
    @State private var routingProvider: MapboxRoutingProvider = .init()
    @State private var response: RouteResponse?
    @State private var cameraState: CameraState?
    @StateObject private var locationVM: LocationVM = .init()
    @State private var showNavigation: Bool = false {
        didSet {
            if !showNavigation {
                response = nil
            }
        }
    }
    @State private var simulateRouteDrive: Bool = true

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if showNavigation {
                Text("Active Navigation")
            }
            else {
                switch locationVM.state {
                case .initializing:
                    ProgressView()
                case .initialized:
                    mapView()
                case .error(let error):
                    Text("Error: \(error.localizedDescription)")
                }
            }
        }
        .task {
            locationVM.start()
        }
        .fullScreenCover(isPresented: $showNavigation) {
            if let response = response,
               case .route(let options) = response.options {
                NavigationView(
                    routeResponse: response,
                    routeIndex: 0,
                    routeOptions: options,
                    navigationOptions: navigationOptions()
                )
                .ignoresSafeArea()
            }
            else {
                Text("Invalid route")
            }
        }
    }

    @ViewBuilder
    private func mapView() -> some View {
        NavigationMapUI(
            route: $response,
            cameraState: $cameraState,
            onTap: { tapCoordinate, currentLocation in
                Task {
                    guard let currentCoordinate = currentLocation?.coordinate else {
                        print("[ERROR] No location available")
                        return
                    }
                    let options = NavigationRouteOptions(coordinates: [currentCoordinate, tapCoordinate])
                    self.response = try await routingProvider.calculate(options: options)
                }
            }
        )
        .ignoresSafeArea()

        HStack {
            if response != nil {
                Button {
                    showNavigation = true
                } label: {
                    Image(systemName: "paperplane")
                }
                Toggle(isOn: $simulateRouteDrive) {
                    Text("Simulate")
                }
                .fixedSize()
                Spacer()
                Button {
                    response = nil
                } label: {
                    Image(systemName: "x.circle.fill")
                }
            }
            else {
                Text("Tap to build route")
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    private func navigationOptions() -> NavigationOptions {
        NavigationOptions(
            simulationMode: simulateRouteDrive ? .always : .never
        )
    }
}

final class LocationVM: NSObject, ObservableObject, CLLocationManagerDelegate {
    enum State {
        case initializing
        case initialized
        case error(Error)
    }

    @Published
    var state: State = .initializing
    private var locationManager: CLLocationManager? = .init()

    func start() {
        let locationManager = CLLocationManager()
        self.locationManager = locationManager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            locationManager = nil
        }

        if !locations.isEmpty {
            state = .initialized
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if manager.authorizationStatus != .notDetermined {
            locationManager = nil
            state = .error(error)
        }
    }
}
