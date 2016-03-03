import UIKit
import CoreLocation
import MapboxDirections

// A Mapbox access token is required to use the Directions API.
// https://www.mapbox.com/help/create-api-access-token/
let MapboxAccessToken = "<# your Mapbox access token #>"

class ViewController: UIViewController {

    var directions: MBDirections?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        assert(MapboxAccessToken != "<# your Mapbox access token #>", "You must enter your Mapbox access token at the top of this view controller.")

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

        let origin = CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047)
        let destination = CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365)

        let request = MBDirectionsRequest(sourceCoordinate: origin, destinationCoordinate: destination)

        directions = MBDirections(request: request, accessToken: MapboxAccessToken)

        directions!.calculateDirectionsWithCompletionHandler { (response, error) in
            if let route = response?.routes.first {
                print("Route summary:")
                print("Distance: \(route.distance) meters (\(route.steps.count) route steps) after \(route.expectedTravelTime / 60) minutes")
                for step in route.steps {
                    print("  \(step.instructions) in \(step.distance) meters")
                }
            } else {
                print("Error calculating directions: \(error)")
            }
        }
    }

}
