# MapboxDirections

[![Build Status](https://www.bitrise.io/app/2f82077d3f083479.svg?token=mC783nGMKA3XrvcMCJAOLg&branch=master)](https://www.bitrise.io/app/2f82077d3f083479)

MapboxDirections.swift makes it easy to connect your iOS application to the [Mapbox Directions API](https://www.mapbox.com/directions/). Quickly get driving, cycling, or walking directions, whether the trip is nonstop or it has multiple stopping points, all using a simple interface reminiscent of MapKit’s `MKDirections` API. The Mapbox Directions API is powered by the [OSRM](http://project-osrm.org/) routing engine and open data from the [OpenStreetMap](https://www.openstreetmap.org/) project.

MapboxDirections.swift pairs well with [MapboxGeocoder.swift](https://github.com/mapbox/MapboxGeocoder.swift), [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift), and the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx).

## Getting started

Specify the following dependency in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'MapboxDirections.swift', :git => 'https://github.com/mapbox/MapboxDirections.swift.git', :branch => 'master'
```

Or in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
github "Mapbox/MapboxDirections.swift" ~> 0.5.0
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

let options = RouteOptions(waypoints: [
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox"),
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House"),
])
options.includesSteps = true

let task = directions.calculateDirections(options: options) { (waypoints, routes, error) in
    if let route = routes?.first {
        print("Route summary:")
        let steps = route.legs.first!.steps
        print("Distance: \(route.distance) meters (\(steps.count) route steps) in \(route.expectedTravelTime / 60) minutes")
        for step in steps {
            print("\(step.instructions) \(step.distance) meters")
        }
    } else {
        print("Error calculating directions: \(error)")
    }
}
```

```
// main.m

MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:@[
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.9131752, -77.0324047), @"Mapbox"],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.8977, -77.0365), @"White House"],
]];
options.includesSteps = YES;

NSURLSessionDataTask *task = [directions calculateDirectionsWithOptions:options
                                                      completionHandler:^(NSArray<MBWaypoint *> * _Nullable waypoints,
                                                                          NSArray<MBRoute *> * _Nullable routes,
                                                                          NSError * _Nullable error) {
    if (routes.firstObject) {
        NSLog(@"Route summary:");
        NSArray<MBRouteStep *> *steps = route.legs.firstObject.steps;
        NSLog(@"Distance: %f meters (%ld route steps) in %f minutes", route.distance, steps.count, route.expectedTravelTime / 60);
        for (MBRouteStep *step in steps) {
            NSLog(@"%@ %f meters", step.instructions, step.distance);
        }
    } else {
        NSLog(@"Error calculating directions: %@", error);
    }
}];
```

This library uses version 5 of the Mapbox Directions API by default. To use version 4 instead, replace RouteOptions with RouteOptionsV4 (or MBRouteOptions with MBRouteOptionsV4).

## Tests

To run the included unit tests, you need to use [CocoaPods](http://cocoapods.org) to install the dependencies. 

1. `pod install`
1. `open MapboxDirections.xcworkspace`
1. Switch to the MapboxDirections scheme and go to Product ‣ Test.
