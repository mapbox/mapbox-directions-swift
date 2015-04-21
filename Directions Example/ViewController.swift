import UIKit
import CoreLocation

class ViewController: UIViewController {

    var directions: MBDirections?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let mb = CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047)
        let wh = CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365)

        let request = MBDirectionsRequest(sourceCoordinate: mb, destinationCoordinate: wh)

        directions = MBDirections(request: request, accessToken: "pk.eyJ1IjoianVzdGluIiwiYSI6IlpDbUJLSUEifQ.4mG8vhelFMju6HpIY-Hi5A")

        directions!.calculateDirectionsWithCompletionHandler { (response, error) in
            if let route = response?.routes.first {
                println("Route summary:")
                println("Distance: \(route.distance) meters (\(route.steps.count) route steps) in \(route.expectedTravelTime / 60) minutes")
                for step in route.steps {
                    println("\(step.instructions) \(step.distance) meters")
                }
            } else {
                println("Error calculating directions: \(error)")
            }
        }
    }

}
