import Foundation
import SwiftUI
import Combine
import MapboxDirections

struct QueryEditor: View {
    @State var routes: [Route] = [] {
        didSet {
            showRoutes = !routes.isEmpty
        }
    }
    @State var error: DirectionsError?
    @State var showRoutes: Bool = false
    @Binding var query: Query

    var body: some View {
        VStack {
            WaypointsEditor(waypoints: $query.waypoints)
                .toolbar(content: {
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        NavigationLink(
                            destination: RoutesView(routes: routes),
                            isActive: $showRoutes,
                            label: {
                                Button("Directions") {
                                    loadRoutes(for: query)
                                }.buttonStyle(.borderless)
                            })
                    }
                })
                .navigationTitle(query.name)

        }
        .alert(isPresented: .constant(error != nil), error: error) {
            Button("Ok") {
                error = nil
            }
        }
    }

    func loadRoutes(for query: Query) {
        let options = RouteOptions(waypoints: query.waypoints.map(\.native))
        print("Calculating route for \(options.waypoints)")
        options.includesSteps = true
        options.routeShapeResolution = .full
        options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]

        Directions.shared.calculate(options) { (session, result) in
            switch result {
            case let .failure(error):
                self.error = error
            case let .success(response):
                self.routes = response.routes ?? []
            }
        }
    }
}

extension Array where Element == Waypoint {
    static var defaultWaypoints: Self {
        [
            .init(id: .init(), latitude: 38.9131752, longitude: -77.0324047, name: "Mapbox"),
            .init(id: .init(), latitude: 38.8906572, longitude: -77.0090701, name: "Capitol"),
            .init(id: .init(), latitude: 38.8977000, longitude: -77.0365000, name: "White House"),
        ]
    }
}
