# [Mapbox Directions for Swift](https://docs.mapbox.com/ios/directions/)

Mapbox Directions for Swift makes it easy to connect your iOS, macOS, tvOS, or watchOS application to the [Mapbox Directions](https://docs.mapbox.com/api/navigation/) and [Map Matching](https://docs.mapbox.com/api/navigation/#map-matching) APIs. Quickly get driving, cycling, or walking directions, whether the trip is nonstop or it has multiple stopping points, all using a simple interface reminiscent of MapKit’s `MKDirections` API. Fit a GPX trace to the [OpenStreetMap](https://www.openstreetmap.org/) road network. The Mapbox Directions and Map Matching APIs are powered by the [OSRM](http://project-osrm.org/) and [Valhalla](https://github.com/valhalla/valhalla/) routing engines. For more information, see the [Mapbox Navigation](https://www.mapbox.com/navigation/) homepage.

Mapbox Directions pairs well with [MapboxGeocoder.swift](https://github.com/mapbox/MapboxGeocoder.swift), [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift), the [Mapbox Navigation SDK for iOS](https://github.com/mapbox/mapbox-navigation-ios/), and the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/).

## Installation

Specify the following dependency in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
github "mapbox/mapbox-directions-swift" ~> ${MINOR_VERSION}
```

Or in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'MapboxDirections', '~> ${MINOR_VERSION}'
```

Or in your [Swift Package Manager](https://swift.org/package-manager/) Package.swift:

```swift
.package(url: "https://github.com/mapbox/mapbox-directions-swift.git", from: "0.30.0")
```

Then `import MapboxDirections`.

## Configuration

You’ll need a [Mapbox access token](https://docs.mapbox.com/api/#access-tokens-and-token-scopes) in order to use the API. If you’re already using the [Mapbox Maps SDK for iOS](https://docs.mapbox.com/ios/maps/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/), Mapbox Directions automatically recognizes your access token, as long as you’ve placed it in the `MBXAccessToken` key of your application’s Info.plist file.

## Starting points

`Directions` is the main class that represents the Mapbox Directions and Map Matching APIs. To calculate directions between coordinates, configure a `RouteOptions` object and pass it into `Directions.calculate(_:completionHandler:)`. Similarly, to match a trace to the road network, configure a `MatchOptions` object and pass it into either `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)`. These methods asynchronously send requests to the API, then form `Route` or `Match` objects that correspond to the API’s response.

A `Route` object is composed of one or more `RouteLeg`s between waypoints, which in turn are composed of one or more `RouteStep`s between maneuvers. Depending on the request, a `RouteStep` may additionally contain objects representing intersection- and segment-level data. A `Match` object is structured similarly, except that it provides additional details about how the trace matches the road network.

For further details, consult the guides and examples included with this API reference. To integrate real-time turn-by-turn navigation into your iOS application, see “[Navigation SDK](navigation-sdk.html)”. If you have any questions, please see [our help page](https://docs.mapbox.com/help/). We welcome your [bug reports, feature requests, and contributions](https://github.com/mapbox/mapbox-directions-swift/).
