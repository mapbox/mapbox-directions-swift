import Foundation
import SwiftUI
import CoreLocation
import MapboxDirections

struct Waypoint: Identifiable, Hashable, Codable {
    let id: UUID
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var name: String = ""
    var allowsSnappingToClosedRoad: Bool = false
    var allowsArrivingOnOppositeSide: Bool = false
    var separatesLegs: Bool = true

    var native: MapboxDirections.Waypoint {
        let waypoint = MapboxDirections.Waypoint(coordinate: .init(latitude: latitude, longitude: longitude), name: name)
        waypoint.allowsSnappingToClosedRoad = allowsSnappingToClosedRoad
        waypoint.allowsArrivingOnOppositeSide = allowsArrivingOnOppositeSide
        waypoint.separatesLegs = separatesLegs
        return waypoint
    }

    static func make() -> Waypoint {
        .init(id: .init())
    }
}

struct WaypointsEditor: View {
    @Binding
    var waypoints: [Waypoint]

    var body: some View {
        List {
            ForEach($waypoints) { $waypoint in
                HStack(alignment: .top) {
                    WaypointView(waypoint: $waypoint)

                    Menu {
                        Button("Insert Above") {
                            addNewWaypoint(before: waypoint)
                        }
                        Button("Insert Below") {
                            addNewWaypoint(after: waypoint)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30, alignment: .center)
                    }.menuStyle(.borderlessButton)
                }
            }
            .onMove { indices, newOffset in
                waypoints.move(fromOffsets: indices, toOffset: newOffset)
            }
            .onDelete { indexSet in
                waypoints.remove(atOffsets: indexSet)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.automatic) {
                EditButton()
            }
        }
    }

    private func addNewWaypoint(after waypoint: Waypoint) {
        guard let waypointIndex = waypoints.firstIndex(of: waypoint) else {
            preconditionFailure("Waypoint is in the array of waypoints")
        }
        let insertionIndex = waypoints.index(after: waypointIndex)
        waypoints.insert(Waypoint.make(), at: insertionIndex)
    }
    private func addNewWaypoint(before waypoint: Waypoint) {
        guard let insertionIndex = waypoints.firstIndex(of: waypoint) else {
            preconditionFailure("Waypoint is in the array of waypoints")
        }
        waypoints.insert(Waypoint.make(), at: insertionIndex)
    }
}

struct WaypointView: View {
    @Binding var waypoint: Waypoint
    @State private var latitudeString: String
    @State private var longitudeString: String    

    init(waypoint: Binding<Waypoint>) {
        _waypoint = waypoint
        _latitudeString = State<String>(initialValue: waypoint.wrappedValue.latitude.description)
        _longitudeString = .init(initialValue: waypoint.wrappedValue.longitude.description)
    }

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Name", text: $waypoint.name)
            HStack {
                TextField("Lat", text: $latitudeString, onEditingChanged: { _ in
                    waypoint.latitude = .init(latitudeString) ?? 0
                })
                .fixedSize()
                TextField("Lon", text: $longitudeString, onEditingChanged: { _ in
                    waypoint.longitude = .init(longitudeString) ?? 0
                })
                .fixedSize()
            }
            HStack {
                InfoButton(docUrl: .separatesLegs)
                Toggle("Separates Legs", isOn: $waypoint.separatesLegs)
            }
            HStack {
                InfoButton(docUrl: .waypointAllowsSnappingToClosedRoad)
                Toggle("Snap To Closed Road", isOn: $waypoint.allowsArrivingOnOppositeSide)
            }
            HStack {
                InfoButton(docUrl: .waypointAllowsArrivingOnOppositeSide)
                Toggle("Allows Arriving On Opposite Side", isOn: $waypoint.allowsSnappingToClosedRoad)
            }
        }
    }
}
