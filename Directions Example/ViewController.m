@import Mapbox;
@import MapboxDirections;

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) MGLMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray<MBWaypoint *> *waypoints = @[
        [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.9131752, -77.0324047) coordinateAccuracy:-1 name:@"Mapbox"],
        [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.8977, -77.0365) coordinateAccuracy:-1 name:@"White House"],
    ];
    MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:waypoints profileIdentifier:nil];
    options.includesSteps = YES;
    
    [[MBDirections sharedDirections] calculateDirectionsWithOptions:options completionHandler:^(NSArray<MBWaypoint *> * _Nullable waypoints, NSArray<MBRoute *> * _Nullable routes, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error calculating directions: %@", error);
            return;
        }
        
        MBRoute *route = routes.firstObject;
        MBRouteLeg *leg = route.legs.firstObject;
        if (leg) {
            NSLog(@"Route via %@:", leg);
            
            NSLengthFormatter *distanceFormatter = [[NSLengthFormatter alloc] init];
            NSString *formattedDistance = [distanceFormatter stringFromMeters:leg.distance];
            
            NSDateComponentsFormatter *travelTimeFormatter = [[NSDateComponentsFormatter alloc] init];
            travelTimeFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
            NSString *formattedTravelTime = [travelTimeFormatter stringFromTimeInterval:route.expectedTravelTime];
            
            NSLog(@"Distance: %@; ETA: %@", formattedDistance, formattedTravelTime);
            
            for (MBRouteStep *step in leg.steps) {
                NSLog(@"%@ [%@ %@]", step.instructions, MBStringFromManeuverType(step.maneuverType), MBStringFromManeuverDirection(step.maneuverDirection));
                NSString *formattedDistance = [distanceFormatter stringFromMeters:step.distance];
                NSLog(@"— %@ for %@ —", MBStringFromTransportType(step.transportType), formattedDistance);
            }
            
            if (route.coordinateCount) {
                // Convert the route’s coordinates into a polyline.
                CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
                [route getCoordinates:routeCoordinates];
                MGLPolyline *routeLine = [MGLPolyline polylineWithCoordinates:routeCoordinates count:route.coordinateCount];
                
                // Add the polyline to the map and fit the viewport to the polyline.
                [self.mapView addAnnotation:routeLine];
                [self.mapView setVisibleCoordinates:routeCoordinates count:route.coordinateCount edgePadding:UIEdgeInsetsZero animated:YES];
                
                // Make sure to free this array to avoid leaking memory.
                free(routeCoordinates);
            }
        }
    }];
}

@end
