MapboxDirections.swift
======================

[![Build Status](https://www.bitrise.io/app/2f82077d3f083479.svg?token=mC783nGMKA3XrvcMCJAOLg&branch=master)](https://www.bitrise.io/app/2f82077d3f083479)

MapboxDirections.swift makes it easy to connect your iOS or OS X application to the [Mapbox Directions API](https://www.mapbox.com/api-documentation/#directions). MapboxDirections.swift combines the power of the OSRM routing engine with the simplicity of MapKit’s directions API (but without depending on MapKit).

### Example

```swift
let mapBox = CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047)
let whiteHouse = CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365)
let request = MBDirectionsRequest(sourceCoordinate: mapBox, destinationCoordinate: whiteHouse)

// Use the older v4 endpoint for now, while v5 is in development.
request.version = .Four

let directions = MBDirections(request: request, accessToken: MapboxAccessToken)
directions.calculateDirectionsWithCompletionHandler { (response, error) in
    if let route = response?.routes.first {
        print("Enjoy a trip down \(route.legs.first!.name)!")
    }
}
```

Note: This library currently supports both versions 4 and 5 of the Mapbox Directions API. However, only v4 is currently available to Mapbox accounts while v5 is in development.

### Tests

To run the included unit tests, you need to use [CocoaPods](http://cocoapods.org) to install the dependencies. 

1. `pod install`
1. `open Directions Example.xcworkspace`
1. `Command+U` or `xcodebuild test`
