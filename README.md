# MapboxDirections

[📱&nbsp;![iOS Build Status](https://www.bitrise.io/app/2f82077d3f083479.svg?token=mC783nGMKA3XrvcMCJAOLg&branch=master)](https://www.bitrise.io/app/2f82077d3f083479) &nbsp;&nbsp;&nbsp;
[🖥💻&nbsp;![OS X Build Status](https://www.bitrise.io/app/3e18d5c284ee7fe4.svg?token=YCPg5FTvNCSoRBvECdFWtg&branch=master)](https://www.bitrise.io/app/3e18d5c284ee7fe4) &nbsp;&nbsp;&nbsp;
[📺&nbsp;![tvOS Build Status](https://www.bitrise.io/app/0dd69f13a42252d6.svg?token=jin7-oeLn35GfZqWaqumtA&branch=master)](https://www.bitrise.io/app/0dd69f13a42252d6) &nbsp;&nbsp;&nbsp;
[⌚️&nbsp;![watchOS Build Status](https://www.bitrise.io/app/6db52b89a8fbfb40.svg?token=v645xdLSJWX0uYxLU7CA3g&branch=master)](https://www.bitrise.io/app/6db52b89a8fbfb40)

MapboxDirections.swift makes it easy to connect your iOS, OS X, tvOS, or watchOS application to the [Mapbox Directions API](https://www.mapbox.com/directions/). Quickly get driving, cycling, or walking directions, whether the trip is nonstop or it has multiple stopping points, all using a simple interface reminiscent of MapKit’s `MKDirections` API. The Mapbox Directions API is powered by the [OSRM](http://project-osrm.org/) routing engine and open data from the [OpenStreetMap](https://www.openstreetmap.org/) project.

MapboxDirections.swift pairs well with [MapboxGeocoder.swift](https://github.com/mapbox/MapboxGeocoder.swift), [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift), and the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx).

## Getting started

Specify the following dependency in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'MapboxDirections.swift', :git => 'https://github.com/mapbox/MapboxDirections.swift.git', :tag => 'v0.6.0'
```

Or in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
github "Mapbox/MapboxDirections.swift" ~> 0.6.0
```

Then `import MapboxDirections` or `@import MapboxDirections;`.

This repository includes a example application written in Swift demonstrating how to use the framework. More examples and detailed documentation are available in the [Mapbox API Documentation](https://www.mapbox.com/api-documentation/?language=Swift#directions).

## Usage

You’ll need a [Mapbox access token](https://www.mapbox.com/developers/api/#access-tokens) in order to use the API. If you’re already using the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx), MapboxDirections.swift automatically recognizes your access token, as long as you’ve placed it in the `MGLMapboxAccessToken` key of your application’s Info.plist file.

### Basics

The main directions class is Directions in Swift or MBDirections in Objective-C. Create a directions object using your access token:

```swift
// main.swift
import MapboxDirections

let directions = Directions(accessToken: "<#your access token#>")
```

```objc
// main.m
@import MapboxDirections;

MBDirections *directions = [[MBDirections alloc] initWithAccessToken:@"<#your access token#>"];
```

Alternatively, you can place your access token in the `MGLMapboxAccessToken` key of your application’s Info.plist file, then use the shared directions object:

```swift
// main.swift
let directions = Directions.sharedDirections
```

```objc
// main.m
MBDirections *directions = [MBDirections sharedDirections];
```

With the directions object in hand, construct a RouteOptions or MBRouteOptions object and pass it into the `Directions.calculateDirections(options:completionHandler:)` method.

```swift
// main.swift

let waypoints = [
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox"),
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House"),
]
let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifierAutomobile)
options.includesSteps = true

let task = directions.calculateDirections(options: options) { (waypoints, routes, error) in
    guard error == nil else {
        print("Error calculating directions: \(error!)")
        return
    }
    
    if let route = routes?.first, leg = route.legs.first {
        print("Route via \(leg):")
        
        let distanceFormatter = NSLengthFormatter()
        let formattedDistance = distanceFormatter.stringFromMeters(route.distance)
        
        let travelTimeFormatter = NSDateComponentsFormatter()
        travelTimeFormatter.unitsStyle = .Short
        let formattedTravelTime = travelTimeFormatter.stringFromTimeInterval(route.expectedTravelTime)
        
        print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
        
        for step in leg.steps {
            print("\(step.instructions)")
            let formattedDistance = distanceFormatter.stringFromMeters(step.distance)
            print("— \(formattedDistance) —")
        }
    }
}
```

```objc
// main.m

NSArray<MBWaypoint *> *waypoints = @[
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.9131752, -77.0324047), @"Mapbox"],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.8977, -77.0365), @"White House"],
];
MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:waypoints
                                                  profileIdentifier:MBDirectionsProfileIdentifierAutomobile];
options.includesSteps = YES;

NSURLSessionDataTask *task = [directions calculateDirectionsWithOptions:options
                                                      completionHandler:^(NSArray<MBWaypoint *> * _Nullable waypoints,
                                                                          NSArray<MBRoute *> * _Nullable routes,
                                                                          NSError * _Nullable error) {
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
            NSLog(@"%@", step.instructions);
            NSString *formattedDistance = [distanceFormatter stringFromMeters:step.distance];
            NSLog(@"— %@ —", formattedDistance);
        }
    }
}];
```

This library uses version 5 of the Mapbox Directions API by default. To use version 4 instead, replace RouteOptions with RouteOptionsV4 (or MBRouteOptions with MBRouteOptionsV4).

### Drawing the route on a map

With the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx), you can easily draw the route on a map:

```swift
// main.swift

if route.coordinateCount > 0 {
    // Convert the route’s coordinates into a polyline.
    var routeCoordinates = route.coordinates!
    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
    
    // Add the polyline to the map and fit the viewport to the polyline.
    mapView.addAnnotation(routeLine)
    mapView.setVisibleCoordinates(routeCoordinates, count: route.coordinateCount, edgePadding: UIEdgeInsetsZero, animated: true)
}
```

```objc
// main.m

if (route.coordinateCount) {
    // Convert the route’s coordinates into a polyline.
    CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
    [route getCoordinates:routeCoordinates];
    MGLPolyline *routeLine = [MGLPolyline polylineWithCoordinates:routeCoordinates count:route.coordinateCount];
    
    // Add the polyline to the map and fit the viewport to the polyline.
    [mapView addAnnotation:routeLine];
    [mapView setVisibleCoordinates:routeCoordinates count:route.coordinateCount edgePadding:UIEdgeInsetsZero animated:YES];
    
    // Make sure to free this array to avoid leaking memory.
    free(routeCoordinates);
}
```

## Tests

To run the included unit tests, you need to use [CocoaPods](http://cocoapods.org) to install the dependencies. 

1. `pod install`
1. `open MapboxDirections.xcworkspace`
1. Switch to the MapboxDirections scheme and go to Product ‣ Test.
