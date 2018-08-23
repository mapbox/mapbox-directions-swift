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
    var segmentedControl: UISegmentedControl!
    static let initialMapCenter = CLLocationCoordinate2D(latitude: 37.3300, longitude: -122.0312)
    static let initialZoom: Double = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(MapboxAccessToken != "<# your Mapbox access token #>", "You must set `MapboxAccessToken` to your Mapbox access token.")
        MGLAccountManager.setAccessToken(MapboxAccessToken)
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(ViewController.initialMapCenter, animated: false)
        mapView.setZoomLevel(ViewController.initialZoom, animated: false)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
        
        setUpSegmentedControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUpSegmentedControls() {
        let items = ["Move", "Draw", "Directions"]
        segmentedControl = UISegmentedControl(items: items)
        let frame = UIScreen.main.bounds
        segmentedControl.frame = CGRect(x: frame.minX + 10, y: frame.minY + 50, width: frame.width - 20, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(segmentedControl)
    }
    
    @objc func segmentedValueChanged(_ sender: UISegmentedControl) {
        resetDrawingView()
        
        switch sender.selectedSegmentIndex {
        case 1:
            setupDrawingView()
        case 2:
            setupDirections()
        default:
            return
        }
    }
    
    func resetDrawingView() {
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        drawingView?.reset()
        drawingView?.removeFromSuperview()
        drawingView = nil
        mapView.isUserInteractionEnabled = true
    }
    
    func setupDirections() {
        let wp1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox")
        let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House")
        wp1.allowsArrivingOnOppositeSide = false
        wp2.allowsArrivingOnOppositeSide = false
        let options = RouteOptions(waypoints: [wp1, wp2])
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
        view.insertSubview(drawingView!, belowSubview: segmentedControl)
        
        mapView.isUserInteractionEnabled = false
        
        let unpitchedCamera = mapView.camera
        unpitchedCamera.pitch = 0
        mapView.setCamera(unpitchedCamera, animated: true)
    }
    
    func drawingView(drawingView: MBDrawingView, didDrawWithPoints points: [CGPoint]) {
        
        let coordinates = points.map {
            mapView.convert($0, toCoordinateFrom: mapView)
        }
        makeMatchRequest(locations: coordinates)
    }
    
    func makeMatchRequest(locations: [CLLocationCoordinate2D]) {
        let matchOptions = MatchOptions(coordinates: locations)

        Directions(accessToken: MapboxAccessToken).calculate(matchOptions) { (matches, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let matches = matches, let match = matches.first else { return }
            
            if let annotations = self.mapView.annotations {
                self.mapView.removeAnnotations(annotations)
            }
            
            var routeCoordinates = match.coordinates!
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: match.coordinateCount)
            self.mapView.addAnnotation(routeLine)
            self.drawingView?.reset()
        }
    }
}
