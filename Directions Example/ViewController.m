@import UIKit;
@import CoreLocation;
@import MapboxDirections;

#import "ViewController.h"

// A Mapbox access token is required to use the Directions API.
// https://www.mapbox.com/help/create-api-access-token/
NSString *const MapboxAccessToken = @"<# your Mapbox access token #>";

@interface ViewController ()

@property (nonatomic) MBDirections *directions;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(![MapboxAccessToken isEqualToString:@"<# your Mapbox access token #>"], @"You must enter your Mapbox access token at the top of this view controller.");

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 200) / 2, (self.view.bounds.size.height - 40) / 2, 200, 40)];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Check the console.";
    [self.view addSubview:label];

    CLLocationCoordinate2D origin = CLLocationCoordinate2DMake(38.9131752, -77.0324047);
    CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(38.8977, -77.0365);

    MBDirectionsRequest *request = [[MBDirectionsRequest alloc] initWithOriginCoordinate:origin destinationCoordinate:destination];

    self.directions = [[MBDirections alloc] initWithRequest:request accessToken:MapboxAccessToken];

    [self.directions calculateDirectionsWithCompletionHandler:^(MBDirectionsResponse *response, NSError *error) {
        MBRoute *route = response.routes.firstObject;
        if (route) {
            NSLog(@"Route summary:");
            NSLog(@"Distance: %.2f meters (%lu route steps) after %.2f minutes", route.distance, (unsigned long)route.steps.count, route.expectedTravelTime / 60);
            for (MBRouteStep *step in route.steps) {
                NSLog(@"  %@ in %.f meters", step.instructions, step.distance);
            }
        } else {
            NSLog(@"Error calculating directions: %@", error);
        }
    }];
}

@end
