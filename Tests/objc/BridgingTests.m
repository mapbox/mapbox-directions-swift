#import <XCTest/XCTest.h>
#import <MapKit/MKGeometry.h>
@import MapboxDirections;

@interface BridgingTests : XCTestCase
@end

@implementation BridgingTests

- (void)testDirections {
    NSArray<CLLocation *> *locations = @[[[CLLocation alloc] initWithLatitude:0 longitude:1],
                                         [[CLLocation alloc] initWithLatitude:2 longitude:3]];
    
    MBRouteOptions *options = [[MBRouteOptions alloc] initWithLocations:locations
                                                      profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    
    MBDirections *directions = [[MBDirections alloc] initWithAccessToken:nil];
    [directions calculateDirectionsWithOptions:options
                             completionHandler:^(NSArray<MBWaypoint *> * _Nullable waypoints, NSArray<MBRoute *> * _Nullable routes, NSError * _Nullable error) {
        
    }];
}

- (void)testRouteOptions {
    NSArray<CLLocation *> *locations = @[[[CLLocation alloc] initWithLatitude:0 longitude:1],
                                         [[CLLocation alloc] initWithLatitude:2 longitude:3]];
    
    NSArray<NSValue *> *coordinates = @[[NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(0, 1)],
                                        [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(2, 3)]];
    
    NSArray<MBWaypoint *> *waypoints = @[[[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 1) coordinateAccuracy:-1 name:nil],
                                         [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(2, 3) coordinateAccuracy:-1 name:nil]];
    
    MBRouteOptions *options = nil;
    
    options = [[MBRouteOptions alloc] initWithLocations:locations profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    options = [[MBRouteOptions alloc] initWithCoordinates:coordinates profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    options = [[MBRouteOptions alloc] initWithWaypoints:waypoints profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
}

- (void)testRoute {
    NSString *filePath = [[NSBundle bundleForClass:[BridgingTests class]] pathForResource:@"subLaneInstructions" ofType:@"json"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *routes = [response objectForKey:@"routes"];
    NSDictionary *routeDict = routes[0];
    
    NSArray<MBWaypoint *> *waypoints = @[[[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 1) coordinateAccuracy:-1 name:nil],
                                         [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(2, 3) coordinateAccuracy:-1 name:nil]];
    
    MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:waypoints profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    
    MBRoute *route = [[MBRoute alloc] initWithJSON:routeDict waypoints:waypoints routeOptions:options];
    
    MBRouteLeg *leg = route.legs[0];
    MBRouteStep *step = leg.steps[0];
    
    MBVisualInstructionBanner *banner = step.instructionsDisplayedAlongStep[0];
    MBVisualInstruction *visualInstruction = banner.primaryInstruction;
    
    MBManeuverType type = visualInstruction.maneuverType;
    MBManeuverDirection direction = visualInstruction.maneuverDirection;
    
    MBVisualInstruction *teriaryInstruction = banner.tertiaryInstruction;
    NSArray<id<MBComponentRepresentable>> *components = teriaryInstruction.components;
    
    MBLaneIndicationComponent *component = (MBLaneIndicationComponent *)components[0];
    MBLaneIndication indications = component.indications;

    XCTAssertNotNil(leg);
    XCTAssertNotNil(step);
    XCTAssertNotNil(banner);
    XCTAssertEqual(type, MBManeuverTypeTurn);
    XCTAssertEqual(direction, MBManeuverDirectionRight);
    XCTAssertEqual(indications, MBLaneIndicationStraightAhead);
}

@end
