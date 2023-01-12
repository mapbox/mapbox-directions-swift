import SwiftUI

struct InfoButton: View {
    enum DocUrl {
        case waypointAllowsSnappingToClosedRoad
        case waypointAllowsArrivingOnOppositeSide
        case separatesLegs
    }

    let docUrl: DocUrl
    @Environment(\.openURL) var openURL

    var body: some View {
        Button {
            openURL(docUrl.url)
        } label: {
            Image(systemName: "info.circle")
        }
        .buttonStyle(.bordered)
    }
}

extension InfoButton.DocUrl {
    var urlString: String {
        switch self {
        case .waypointAllowsArrivingOnOppositeSide:
            return "https://docs.mapbox.com/ios/directions/api/2.3.0/Classes/Waypoint.html#/s:16MapboxDirections8WaypointC28allowsArrivingOnOppositeSideSbvp"
        case .waypointAllowsSnappingToClosedRoad:
            return "https://docs.mapbox.com/ios/directions/api/2.3.0/Classes/Waypoint.html#/s:16MapboxDirections8WaypointC26allowsSnappingToClosedRoadSbvp"
        case .separatesLegs:
            return "https://docs.mapbox.com/ios/directions/api/2.3.0/Classes/Waypoint.html#/s:16MapboxDirections8WaypointC13separatesLegsSbvp"
        }
    }

    var url: URL {
        URL(string: urlString)!
    }
}
