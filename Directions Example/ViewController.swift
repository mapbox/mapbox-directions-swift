import UIKit
import CoreLocation
import MapboxDirections
import Mapbox

// A Mapbox access token is required to use the Directions API.
// https://www.mapbox.com/help/create-api-access-token/
let MapboxAccessToken = "<# your Mapbox access token #>"

class ViewController: UIViewController, MBDrawingViewDelegate {
    @IBOutlet var mapView: MGLMapView!
    var drawingView: MBDrawingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(MapboxAccessToken != "<# your Mapbox access token #>", "You must set `MapboxAccessToken` to your Mapbox access token.")
        MGLAccountManager.setAccessToken(MapboxAccessToken)
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), animated: false)
        mapView.setZoomLevel(15, animated: false)
        view.addSubview(mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupDrawingView()
        
        // setupDirections()
    }
    
    func setupDirections() {
        let options = RouteOptions(waypoints: [
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox"),
            Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House"),
            ])
        options.includesSteps = true
        
        Directions(accessToken: MapboxAccessToken).calculate(options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            if let route = routes?.first, let leg = route.legs.first {
                print("Route via \(leg):")
                
                let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                
                let travelTimeFormatter = DateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .short
                let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                
                for step in leg.steps {
                    print("\(step.instructions)")
                    if step.distance > 0 {
                        let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                        print("— \(formattedDistance) —")
                    }
                }
                
                if route.coordinateCount > 0 {
                    // Convert the route’s coordinates into a polyline.
                    var routeCoordinates = route.coordinates!
                    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    // Add the polyline to the map and fit the viewport to the polyline.
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .zero, animated: true)
                }
            }
        }
    }
    
    func setupDrawingView() {
        drawingView = MBDrawingView(frame: view.bounds, strokeColor: .red, lineWidth: 1)
        drawingView!.autoresizingMask = mapView.autoresizingMask
        drawingView!.delegate = self
        view.addSubview(drawingView!)
        
        mapView.isUserInteractionEnabled = false
        
        let unpitchedCamera = mapView.camera
        unpitchedCamera.pitch = 0
        mapView.setCamera(unpitchedCamera, animated: true)
    }
    
    func drawingView(drawingView: MBDrawingView, didDrawWithPoints points: [CGPoint]) {
        self.drawingView = drawingView
        drawingView.reset()
        
        var coordinates = [CLLocationCoordinate2D]()
        for point in points {
            coordinates.append(mapView.convert(point, toCoordinateFrom: mapView))
        }
        makeMatchRequest(locations: coordinates)
    }
    
    func makeMatchRequest(locations: [CLLocationCoordinate2D]) {
        let matchOptions = MatchingOptions(coordinates: locations)
        
        Directions(accessToken: MapboxAccessToken).match(matchOptions) { (tracepoints, matches, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let annotations = self.mapView.annotations {
                self.mapView.removeAnnotations(annotations)
            }
            
            guard let matches = matches, let match = matches.first else { return }
            
            var routeCoordinates = match.coordinates!
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: match.coordinateCount)
            
            // Add the polyline to the map and fit the viewport to the polyline.
            self.mapView.addAnnotation(routeLine)
            self.drawingView?.reset()
        }
    }
}
