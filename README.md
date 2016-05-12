MapboxDirections.swift
======================

[![Build Status](https://www.bitrise.io/app/2f82077d3f083479.svg?token=mC783nGMKA3XrvcMCJAOLg&branch=master)](https://www.bitrise.io/app/2f82077d3f083479)

MapboxDirections.swift makes it easy to connect your iOS or OS X application to the [Mapbox Directions API](https://www.mapbox.com/api-documentation/#directions). MapboxDirections.swift combines the power of the [OSRM](http://project-osrm.org/) routing engine with the simplicity of MapKit’s directions API (but without depending on MapKit).

MapboxDirections.swift pairs well with [MapboxGeocoder.swift](https://github.com/mapbox/MapboxGeocoder.swift), [MapboxStatic.swift](https://github.com/mapbox/MapboxStatic.swift), and the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx).

### Installation

Import `MapboxDirections.framework` into your project, then use `MBDirections` as a drop-in replacement for Apple’s `MKDirections`. Alternatively, for the bleeding-edge version of this framework, specify the following dependencies in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'NBNRequestKit', :git => 'https://github.com/1ec5/RequestKit.git', :branch => 'mapbox-podspec' # temporarily until nerdishbynature/RequestKit#14 is merged
pod 'MapboxDirections.swift', :git => 'https://github.com/mapbox/MapboxDirections.swift.git', :tag => 'v0.5.0'
```

### Usage

```swift
let mapBox = CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047)
let whiteHouse = CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365)
let request = MBDirectionsRequest(sourceCoordinate: mapBox, destinationCoordinate: whiteHouse)

// The surrounding class should hold a strong reference to this MBDirections object.
directions = MBDirections(request: request, accessToken: MapboxAccessToken)
directions.calculateDirectionsWithCompletionHandler { (response, error) in
    if let route = response?.routes.first {
        print("Enjoy a trip down \(route.legs.first!.name)!")
    }
}
```

This library currently supports both versions 4 and 5 of the Mapbox Directions API. Version 5 is used by default.

This repository includes an example application written in Swift. More examples are available in the [Mapbox API Documentation](https://www.mapbox.com/api-documentation/?language=Swift#geocoding).

### Tests

To run the included unit tests, you need to use [CocoaPods](http://cocoapods.org) to install the dependencies. 

1. `pod install`
1. `open MapboxDirections.xcworkspace`
1. `Command+U` or `xcodebuild test`
