#import <XCTest/XCTest.h>
#import <MapKit/MKGeometry.h>
@import MapboxDirections;

@interface BridgingTests : XCTestCase
@end

@implementation BridgingTests

- (void)testDirections {
    
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

@end
