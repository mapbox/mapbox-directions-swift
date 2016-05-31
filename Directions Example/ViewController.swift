import UIKit
import CoreLocation
import MapboxDirections

// A Mapbox access token is required to use the Directions API.
// https://www.mapbox.com/help/create-api-access-token/
let MapboxAccessToken = "<# your Mapbox access token #>"

class ViewController: UIViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        assert(MapboxAccessToken != "<# your Mapbox access token #>", "You must set `MapboxAccessToken` to your Mapbox access token.")

        view.addSubview({ [unowned self] in
            let label = UILabel(frame: CGRect(x: (self.view.bounds.size.width - 200) / 2,
                y: (self.view.bounds.size.height - 40) / 2,
                width: 200,
                height: 40))
            label.autoresizingMask = [ .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin ]
            label.textColor = UIColor.whiteColor()
            label.textAlignment = .Center
            label.text = "Check the console"
            return label
            }())

        let options = RouteOptions(waypoints: [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House"),
        ])
        options.includesSteps = true
        
        Directions(accessToken: MapboxAccessToken).calculateDirections(options: options) { (waypoints, routes, error) in
            if let route = routes?.first, leg = route.legs.first {
                print("Route via \(leg.name):")
                let formattedDistance = NSLengthFormatter().stringFromMeters(route.distance)
                let formattedTravelTime = NSDateComponentsFormatter().stringFromTimeInterval(route.expectedTravelTime)
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                for step in leg.steps {
                    let formattedDistance = NSLengthFormatter().stringFromMeters(step.distance)
                    print("\(step.instructions) \(formattedDistance)")
                }
            } else {
                print("Error calculating directions: \(error)")
            }
        }
    }
}
