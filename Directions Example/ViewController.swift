import UIKit
import CoreLocation
import MapboxDirections
import Mapbox

class ViewController: UIViewController, MBDrawingViewDelegate {
    @IBOutlet var mapView: MGLMapView!
    var drawingView: MBDrawingView?
    var segmentedControl: UISegmentedControl!
    static let initialMapCenter = CLLocationCoordinate2D(latitude: 37.3300, longitude: -122.0312)
    static let initialZoom: Double = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let options = RouteOptions(waypoints: [wp1, wp2])
        options.includesSteps = true
        
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            if let error = error {
                print("Error calculating directions: \(error)")
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
                    print("\(step.instructions) [\(step.maneuverType) \(step.maneuverDirection)]")
                    if step.distance > 0 {
                        let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                        print("— \(step.transportType) for \(formattedDistance) —")
                    }
                }
                
                if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
                    // Convert the route’s coordinates into a polyline.
                    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))

                    // Add the polyline to the map.
                    self.mapView.addAnnotation(routeLine)
                    
                    // Fit the viewport to the polyline.
                    let camera = self.mapView.cameraThatFitsShape(routeLine, direction: 0, edgePadding: .zero)
                    self.mapView.setCamera(camera, animated: true)
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
        guard points.count > 0 else { return }
        
        let ratio: Double = Double(points.count) / 100.0
        let keepEvery = Int(ratio.rounded(.up))
        
        let abridgedPoints = points.enumerated().compactMap { index, element -> CGPoint? in
            guard index % keepEvery == 0 else { return nil }
            return element
        }
        let coordinates = abridgedPoints.map {
            mapView.convert($0, toCoordinateFrom: mapView)
        }
        makeMatchRequest(locations: coordinates)
    }
    
    func makeMatchRequest(locations: [CLLocationCoordinate2D]) {
        let matchOptions = MatchOptions(coordinates: locations)

        Directions.shared.calculate(matchOptions) { (matches, error) in
            if let error = error {
                let errorString = """
                ⚠️ Error Enountered. ⚠️
                Failure Reason: \(error.failureReason ?? "")
                Recovery Suggestion: \(error.recoverySuggestion ?? "")
                
                Technical Details: \(error)
                """
                print(errorString)
                return
            }
            
            guard let matches = matches, let match = matches.first else { return }
            
            if let annotations = self.mapView.annotations {
                self.mapView.removeAnnotations(annotations)
            }
            
            var routeCoordinates = match.shape!.coordinates
            let coordCount = UInt(routeCoordinates.count)
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: coordCount)
            self.mapView.addAnnotation(routeLine)
            self.drawingView?.reset()
        }
    }
}
