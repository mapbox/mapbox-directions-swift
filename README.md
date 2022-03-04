# Mapbox Directions for Swift

[![CircleCI](https://circleci.com/gh/mapbox/mapbox-directions-swift.svg?style=svg)](https://circleci.com/gh/mapbox/mapbox-directions-swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/MapboxDirections.svg)](https://cocoapods.org/pods/MapboxDirections/)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

Mapbox Directions for Swift (formerly MapboxDirections.swift) makes it easy to connect your iOS, macOS, tvOS, watchOS, or Linux application to the [Mapbox Directions](https://docs.mapbox.com/api/navigation/) and [Map Matching](https://docs.mapbox.com/api/navigation/#map-matching) APIs. Quickly get driving, cycling, or walking directions, whether the trip is nonstop or it has multiple stopping points, all using a simple interface reminiscent of MapKit’s `MKDirections` API. Fit a GPX trace to the [OpenStreetMap](https://www.openstreetmap.org/) road network. The Mapbox Directions and Map Matching APIs are powered by the [OSRM](http://project-osrm.org/) and [Valhalla](https://github.com/valhalla/valhalla/) routing engines. For more information, see the [Mapbox Navigation](https://www.mapbox.com/navigation/) homepage.

Mapbox Directions pairs well with [MapboxGeocoder.swift](https://github.com/mapbox/MapboxGeocoder.swift), [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift), the [Mapbox Navigation SDK for iOS](https://github.com/mapbox/mapbox-navigation-ios/), and the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/).

## Getting started

Specify the following dependency in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
# Latest stable release
github "mapbox/mapbox-directions-swift" ~> 2.3
# Latest prerelease
github "mapbox/mapbox-directions-swift" "v2.3.0-rc.2"
```

Or in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
# Latest stable release
pod 'MapboxDirections', '~> 2.3'
# Latest prerelease
pod 'MapboxDirections', :git => 'https://github.com/mapbox/mapbox-directions-swift.git', :tag => 'v2.3.0-rc.2'
```

Or in your [Swift Package Manager](https://swift.org/package-manager/) Package.swift:

```swift
// Latest stable release
.package(name: "MapboxDirections", url: "https://github.com/mapbox/mapbox-directions-swift.git", from: "2.3.0")
// Latest prerelease
.package(name: "MapboxDirections", url: "https://github.com/mapbox/mapbox-directions-swift.git", .exact("2.3.0-rc.2"))
```

Then `import MapboxDirections`.

This repository contains an example application that demonstrates how to use the framework. To run it, you need to use [Carthage](https://github.com/Carthage/Carthage) 0.19 or above to install the dependencies. Detailed documentation is available in the [Mapbox API Documentation](https://docs.mapbox.com/api/navigation/#directions).

## System requirements

* One of the following package managers:
   * CocoaPods (CocoaPods 1.10 or above if using Xcode 12)
   * Carthage 0.38 or above
   * Swift Package Manager 5.3 or above
* Xcode 12 or above
* One of the following operating systems:
   * iOS 10.0 or above
   * macOS 10.12.0 or above
   * tvOS 10.0 or above
   * watchOS 3.0 or above
   * Any Linux distribution supported by Swift

v0.30.0 is the last release of MapboxDirections.swift that supports a minimum deployment target of iOS 9._x_, macOS 10.11._x_, tvOS 9._x_, or watchOS 2._x_. v0.30.0 is also the last release that is compatible with Objective-C or AppleScript code.

## Usage

**[API reference](https://docs.mapbox.com/ios/api/directions/)**

You’ll need a [Mapbox access token](https://docs.mapbox.com/api/#access-tokens-and-token-scopes) in order to use the API. If you’re already using the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/), Mapbox Directions automatically recognizes your access token, as long as you’ve placed it in the `MBXAccessToken` key of your application’s Info.plist file.

The examples below are each provided in Swift (denoted with `main.swift`). For further details, see the documentation available by the link in the [releases](https://github.com/mapbox/mapbox-directions-swift/releases).

### Calculating directions between locations

The main directions class is `Directions`. Create a directions object using your access token:

```swift
// main.swift
import MapboxDirections

let directions = Directions(credentials: Credentials(accessToken: "<#your access token#>"))
```

Alternatively, you can place your access token in the `MBXAccessToken` key of your application’s Info.plist file, then use the shared directions object:

```swift
// main.swift
let directions = Directions.shared
```

With the directions object in hand, construct a RouteOptions object and pass it into the `Directions.calculate(_:completionHandler:)` method.

```swift
// main.swift

let waypoints = [
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox"),
    Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House"),
]
let options = RouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
options.includesSteps = true

let task = directions.calculate(options) { (session, result) in
    switch result {
    case .failure(let error):
        print("Error calculating directions: \(error)")
    case .success(let response):
        guard let route = response.routes?.first, let leg = route.legs.first else {
            return
        }

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

This library uses version 5 of the Mapbox Directions API by default.

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

let task = directions.calculate(options) { (session, result) in
    switch result {
    case .failure(let error):
        print("Error matching coordinates: \(error)")
    case .success(let response):
        guard let match = response.matches?.first, let leg = match.legs.first else {
            return
        }

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

You can also use the `Directions.calculateRoutes(matching:completionHandler:)` method to get Route objects suitable for use anywhere a standard Directions API response would be used.

### Build an isochrone map

Tell the user how far they can travel within certain distances or times of a given location using the Isochrone API. `Isochrones` uses the same access token initialization as `Directions`. Once that is configured, you need to fill `IsochronesOptions` parameters to calculate the desired GeoJSON:

```swift
let isochrones = Isochrones(credentials: Credentials(accessToken: "<#your access token#>"))

let isochroneOptions = IsochroneOptions(centerCoordinate: CLLocationCoordinate2D(latitude: 45.52, longitude: -122.681944),
                                        contours: .byDistances([
                                            .init(value: 500, unit: .meters,     color: .orange),
                                            .init(value: 1,   unit: .kilometers, color: .red)
                                        ]))

isochrones.calculate(isochroneOptions) { session, result in
    if case .success(let response) = result {
         print(response)
    }
}
```
...

## Usage with other Mapbox libraries

### Drawing the route on a map

With the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/), you can easily draw the route on a map:

```swift
// main.swift

if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
    // Convert the route’s coordinates into a polyline.
    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))

    // Add the polyline to the map.
    mapView.addAnnotation(routeLine)

    // Fit the viewport to the polyline.
    let camera = mapView.cameraThatFitsShape(routeLine, direction: 0, edgePadding: .zero)
    mapView.setCamera(camera, animated: true)
}
```

### Displaying a turn-by-turn navigation interface

The [Mapbox Navigation SDK for iOS](https://github.com/mapbox/mapbox-navigation-ios/) provides a full-fledged user interface for turn-by-turn navigation along routes supplied by MapboxDirections.

### Drawing Isochrones contours on a map snapshot

[MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift) provides an easy way to draw a isochrone contours on a map.

```swift
// main.swift
import MapboxStatic
import MapboxDirections

let centerCoordinate = CLLocationCoordinate2D(latitude: 45.52, longitude: -122.681944)
let accessToken = "<#your access token#>"

// Setup snapshot parameters
let camera = SnapshotCamera(
    lookingAtCenter: centerCoordinate,
    zoomLevel: 12)
let options = SnapshotOptions(
    styleURL: URL(string: "<#your mapbox: style URL#>")!,
    camera: camera,
    size: CGSize(width: 200, height: 200))

// Request Isochrone contour to draw on a map
let isochrones = Isochrones(credentials: Credentials(accessToken: accessToken))
isochrones.calculate(IsochroneOptions(centerCoordinate: centerCoordinate,
                                      contours: .byDistances([.init(value: 500, unit: .meters)]))) { session, result in
    if case .success(let response) = result {
        // Serialize the geoJSON
        let encoder = JSONEncoder()
        let data = try! encoder.encode(response)
        let geoJSONString = String(data: data, encoding: .utf8)!
        let geoJSONOverlay = GeoJSON(objectString: geoJSONString)

        // Feed resulting geoJSON to snapshot options
        options.overlays.append(geoJSONOverlay)

        let snapshot = Snapshot(
            options: options,
            accessToken: accessToken)

        // Display the result!
        drawImage(snapshot.image)
    }
}
```

## Directions CLI

`MapboxDirectionsCLI` is a command line tool, designed to round-trip an arbitrary, JSON-formatted Directions or Map Matching API response through model objects and back to JSON. This is useful for various scenarios including testing purposes and designing more sophisticated API response processing pipelines. It is supplied as a Swift package.

To build `MapboxDirectionsCLI` using SPM:

1. `swift build`

To run (and build if it wasn't yet) `MapboxDirectionsCLI` and see usage:

1. `swift run mapbox-directions-swift -h`

For further details, see the [MapboxDirectionsCLI documentation](CommandLineTool.md).

## Pricing

API calls made to the Directions API are individually billed by request. Review the [pricing information](https://docs.mapbox.com/api/navigation/directions/#directions-api-pricing) and the [pricing page](https://www.mapbox.com/pricing/#directions) for current rates.
