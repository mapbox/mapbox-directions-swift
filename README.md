# MaplibreDirections

The MaplibreDirections SDK for iOS is built on a for of the MapboxDirections SDK v.023.

MapboxDirections.swift makes it easy to connect your iOS, macOS, tvOS, or watchOS application to the [Mapbox Directions API](https://www.mapbox.com/directions/) and [Mapbox Map Matching API](https://www.mapbox.com/directions/). Quickly get driving, cycling, or walking directions, whether the trip is nonstop or it has multiple stopping points, all using a simple interface reminiscent of MapKit’s `MKDirections` API. Fit a GPX trace to the [OpenStreetMap](https://www.openstreetmap.org/) road network. The Mapbox Directions and Map Matching APIs are powered by the [OSRM](http://project-osrm.org/) routing engine.

Despite its name, MapboxDirections.swift works in Objective-C and Cocoa-AppleScript code in addition to Swift 4.

MapboxDirections.swift pairs well with [MapboxGeocoder.swift](https://github.com/mapbox/MapboxGeocoder.swift), [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift), the [Mapbox Navigation SDK for iOS](https://github.com/mapbox/mapbox-navigation-ios/), and the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/).

# Why have we forked

1. We wanted to upgrade the SDK from iOS 9.0 to 12.0.

# What have we changed

- Upgrade iOS version from 9.0 to 12.0.
- Upgraded Polyline SDK from v4.2.0 to v5.1.0. 
- Removed private cartfile.

## Getting started

If you are looking to include this inside your project, you have to follow the the following steps:

Specify the following dependency in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
github "mapbox/MapboxDirections.swift" ~> 0.23
```

Or in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'MapboxDirections.swift', '~> 0.23'
```

Then `import MapboxDirections` or `@import MapboxDirections;`.

v0.12.1 is the last release of MapboxDirections.swift written in Swift 3. All subsequent releases will be based on the `master` branch, which is written in Swift 4. The Swift examples below are written in Swift 4.

This repository contains example applications written in Swift and Objective-C that demonstrate how to use the framework. To run them, you need to use [Carthage](https://github.com/Carthage/Carthage) 0.19 or above to install the dependencies. More examples and detailed documentation are available in the [Mapbox API Documentation](https://www.mapbox.com/api-documentation/?language=Swift#directions).

## Usage

**[API reference](https://www.mapbox.com/mapbox-navigation-ios/directions/)**

You’ll need a [Mapbox access token](https://www.mapbox.com/developers/api/#access-tokens) in order to use the API. If you’re already using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/), MapboxDirections.swift automatically recognizes your access token, as long as you’ve placed it in the `MGLMapboxAccessToken` key of your application’s Info.plist file.

The examples below are each provided in Swift (denoted with `main.swift`), Objective-C (`main.m`), and AppleScript (`AppDelegate.applescript`). For further details, see the [MapboxDirections.swift API reference](https://www.mapbox.com/mapbox-navigation-ios/directions/).

### Calculating directions between locations

The main directions class is Directions (in Swift) or MBDirections (in Objective-C or AppleScript). Create a directions object using your access token:

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

```applescript
-- AppDelegate.applescript
set theDirections to alloc of MBDirections of the current application
tell theDirections to initWithAccessToken:"<#your access token#>"
```

Alternatively, you can place your access token in the `MGLMapboxAccessToken` key of your application’s Info.plist file, then use the shared directions object:

```swift
// main.swift
let directions = Directions.shared
```

```objc
// main.m
MBDirections *directions = [MBDirections sharedDirections];
```

```applescript
-- AppDelegate.applescript
set theDirections to sharedDirections of MBDirections of the current application
```

With the directions object in hand, construct a RouteOptions or MBRouteOptions object and pass it into the `Directions.calculate(_:completionHandler:)` method.

```swift
// main.swift

let waypoints = [
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox"),
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House"),
]
let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
options.includesSteps = true

let task = directions.calculate(options) { (waypoints, routes, error) in
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
            let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
            print("— \(formattedDistance) —")
        }
    }
}
```

```objc
// main.m

NSArray<MBWaypoint *> *waypoints = @[
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.9131752, -77.0324047) coordinateAccuracy:-1 name:@"Mapbox"],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.8977, -77.0365) coordinateAccuracy:-1 name:@"White House"],
];
MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:waypoints
                                                  profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
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

```applescript
-- AppDelegate.applescript

set mapbox to alloc of MBWaypoint of the current application
tell mapbox to initWithCoordinate:{38.9131752, -77.0324047} coordinateAccuracy:-1 |name|:"Mapbox"
set theWhiteHouse to alloc of MBWaypoint of the current application
tell theWhiteHouse to initWithCoordinate:{38.8977, -77.0365} coordinateAccuracy:-1 |name|:"White House"
set theWaypoints to {mapbox, theWhiteHouse}

set theOptions to alloc of MBRouteOptions of the current application
tell theOptions to initWithWaypoints:theWaypoints profileIdentifier:"mapbox/driving-traffic"
set theOptions's includesSteps to true

set theURL to theDirections's URLForCalculatingDirectionsWithOptions:theOptions
set theData to the current application's NSData's dataWithContentsOfURL:theURL
set theJSON to the current application's NSJSONSerialization's JSONObjectWithData:theData options:0 |error|:(missing value)

set theRoute to alloc of MBRoute of the current application
tell theRoute to initWithJson:(the first item of theJSON's routes) waypoints:theWaypoints profileIdentifier:"mapbox/driving"
set theLeg to the first item of theRoute's legs

log "Route via " & theLeg's |name| & ":"

set theDistanceFormatter to alloc of NSLengthFormatter of the current application
tell theDistanceFormatter to init()
set theDistance to theDistanceFormatter's stringFromMeters:(theLeg's distance)

log "Distance: " & theDistance

repeat with theStep in theLeg's steps
    log theStep's instructions
    set theDistance to theDistanceFormatter's stringFromMeters:(theStep's distance)
    log "— " & theDistance & " —"
end repeat
```

This library uses version 5 of the Mapbox Directions API by default. To use version 4 instead, replace RouteOptions with RouteOptionsV4 (or MBRouteOptions with MBRouteOptionsV4).

### Matching a trace to the road network

If you have a GPX trace or other GPS-derived location data, you can clean up the data and fit it to the road network using the Map Matching API:

```swift
// main.swift

let coordinates = [
    CLLocationCoordinate2D(latitude: 32.712041, longitude: -117.172836),
    CLLocationCoordinate2D(latitude: 32.712256, longitude: -117.17291),
    CLLocationCoordinate2D(latitude: 32.712444, longitude: -117.17292),
    CLLocationCoordinate2D(latitude: 32.71257,  longitude: -117.172922),
    CLLocationCoordinate2D(latitude: 32.7126,   longitude: -117.172985),
    CLLocationCoordinate2D(latitude: 32.712597, longitude: -117.173143),
    CLLocationCoordinate2D(latitude: 32.712546, longitude: -117.173345)
]

let options = MatchOptions(coordinates: coordinates)
options.includesSteps = true

let task = directions.calculate(options) { (matches, error) in
    guard error == nil else {
        print("Error matching coordinates: \(error!)")
        return
    }

    if let match = matches?.first, let leg = match.legs.first {
        print("Match via \(leg):")

        let distanceFormatter = LengthFormatter()
        let formattedDistance = distanceFormatter.string(fromMeters: match.distance)

        let travelTimeFormatter = DateComponentsFormatter()
        travelTimeFormatter.unitsStyle = .short
        let formattedTravelTime = travelTimeFormatter.string(from: match.expectedTravelTime)

        print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")

        for step in leg.steps {
            print("\(step.instructions)")
            let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
            print("— \(formattedDistance) —")
        }
    }
}
```

```objc
// main.m
NSArray<MBWaypoint *> *waypoints = @[
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.712041, -117.172836) coordinateAccuracy:-1 name:nil],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.712256, -117.17291) coordinateAccuracy:-1 name:nil],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.712444, -117.17292) coordinateAccuracy:-1 name:nil],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.71257, -117.172922) coordinateAccuracy:-1 name:nil],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.7126, -117.172985) coordinateAccuracy:-1 name:nil],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.712597, -117.173143) coordinateAccuracy:-1 name:nil],
    [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.712546, -117.173345) coordinateAccuracy:-1 name:nil],
];

MBMatchOptions *matchOptions = [[MBMatchOptions alloc] initWithWaypoints:waypoints profileIdentifier:MBDirectionsProfileIdentifierAutomobile];
NSURLSessionDataTask *task = [[[MBDirections alloc] initWithAccessToken:MapboxAccessToken] calculateMatchesWithOptions:matchOptions completionHandler:^(NSArray<MBMatch *> * _Nullable matches, NSError * _Nullable error) {
    if (error) {
        NSLog(@"Error matching waypoints: %@", error);
        return;
    }
    
    MBMatch *match = matches.firstObject;
    MBRouteLeg *leg = match.legs.firstObject;
    if (leg) {
        NSLog(@"Match via %@:", leg);
        
        NSLengthFormatter *distanceFormatter = [[NSLengthFormatter alloc] init];
        NSString *formattedDistance = [distanceFormatter stringFromMeters:leg.distance];
        
        NSDateComponentsFormatter *travelTimeFormatter = [[NSDateComponentsFormatter alloc] init];
        travelTimeFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        NSString *formattedTravelTime = [travelTimeFormatter stringFromTimeInterval:match.expectedTravelTime];
        
        NSLog(@"Distance: %@; ETA: %@", formattedDistance, formattedTravelTime);
        
        for (MBRouteStep *step in leg.steps) {
            NSLog(@"%@", step.instructions);
            NSString *formattedDistance = [distanceFormatter stringFromMeters:step.distance];
            NSLog(@"— %@ —", formattedDistance);
        }
    }
}];
```

You can also use the `Directions.calculateRoutes(matching:completionHandler:)` method in Swift or the `-[MBDirections calculateRoutesMatchingOptions:completionHandler:]` method in Objective-C to get Route objects suitable for use anywhere a standard Directions API response would be used.

## Usage with other Mapbox libraries

### Drawing the route on a map

With the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/), you can easily draw the route on a map in Swift or Objective-C:

```swift
// main.swift

if route.coordinateCount > 0 {
    // Convert the route’s coordinates into a polyline.
    var routeCoordinates = route.coordinates!
    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)

    // Add the polyline to the map and fit the viewport to the polyline.
    mapView.addAnnotation(routeLine)
    mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .zero, animated: true)
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

### Displaying a turn-by-turn navigation interface

See the [Mapbox Navigation SDK for iOS](https://github.com/mapbox/mapbox-navigation-ios/#usage) documentation for usage examples.

## Tests

To run the included unit tests, you need to use [Carthage](https://github.com/Carthage/Carthage) 0.19 or above to install the dependencies.

1. `carthage build --platform iOS`
1. `open MapboxDirections.xcodeproj`
1. Go to Product ‣ Test.

Copyright (c) 2023 MapLibre contributors
