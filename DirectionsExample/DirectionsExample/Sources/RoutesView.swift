import Foundation
import SwiftUI
import MapboxDirections

struct RoutesView: View {
    private static let distanceFormatter: LengthFormatter = .init()
    private static let travelTimeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .short
        return f
    }()

    let routes: [Route]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10, content: {
                ForEach(routes, id: \.distance) { route in
                    VStack(alignment: .leading, spacing: 3) {
                        headerView(for: route)
                        ForEach(0..<route.legs.count, id: \.self) { legIdx in
                            if let source = route.legs[legIdx].source?.name,
                               let destination = route.legs[legIdx].destination?.name {
                                Text("From '\(source)' to '\(destination)'").font(.title2)
                            }
                            else {
                                Text("Steps:").font(.title2)
                            }
                            stepsView(for: route.legs[legIdx])
                        }
                    }
                }
            })
        }
        .navigationTitle("Routes")
        .padding(5)
    }

    @ViewBuilder
    private func headerView(for route: Route) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Route: ").fontWeight(.bold)
                Text(route.description)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Text("Distance: ").fontWeight(.bold)
                Text(formattedDistance(for:route))
            }
            HStack {
                Text("ETA: ").fontWeight(.bold)
                Text(formattedTravelTime(for: route))
            }
            HStack {
                Text("Typical travel time: ").fontWeight(.bold)
                Text(formattedTypicalTravelTime(for: route))
            }
            Divider()
        }
    }

    @ViewBuilder
    private func stepsView(for leg: RouteLeg) -> some View {
        LazyVStack(alignment: .leading, spacing: 5, content: {
            ForEach(0..<leg.steps.count, id: \.self) { stepIdx in
                HStack {
                    Text("\(stepIdx + 1). ").fontWeight(.bold)
                    Text(stepDescriptions(for: leg.steps[stepIdx]))
                }
                .padding([.top, .bottom], 3)

                Divider()
            }
        })
    }

    func formattedDistance(for route: Route) -> String {
        return Self.distanceFormatter.string(fromMeters: route.distance)
    }

    func formattedTravelTime(for route: Route) -> String {
        return Self.travelTimeFormatter.string(from: route.expectedTravelTime)!
    }

    func formattedTypicalTravelTime(for route: Route) -> String {
        if let typicalTravelTime = route.typicalTravelTime,
           let formattedTypicalTravelTime = Self.travelTimeFormatter.string(from: typicalTravelTime) {
            return formattedTypicalTravelTime
        }
        else {
            return "Not available"
        }
    }

    func stepDescriptions(for step: RouteStep) -> String {
        var description: String = ""
        let direction = step.maneuverDirection?.rawValue ?? "none"
        description.append("\(step.instructions) [\(step.maneuverType) \(direction)]")
        if step.distance > 0 {
            let formattedDistance = Self.distanceFormatter.string(fromMeters: step.distance)
            description.append(" (\(step.transportType) for \(formattedDistance))")
        }
        return description
    }
}
