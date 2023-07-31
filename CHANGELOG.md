# Changes to Mapbox Directions for Swift

## v2.11.0

* Added `Incident.trafficCodes` and corresponding `TrafficCodes` struct to hold jartic codes. ([#808](https://github.com/mapbox/mapbox-directions-swift/pull/808))

## v2.10.0

* Added `Matrix` API wrapper. The [Mapbox Matrix API](https://docs.mapbox.com/api/navigation/matrix/) computes travel times between many points, and returns a matrix of all travel times between the locations. [#626](https://github.com/mapbox/mapbox-directions-swift/pull/626)
* Fixed a crash that could occur if only one `Waypoint` with a nonnull `name` was used in the Directions request. [#797](https://github.com/mapbox/mapbox-directions-swift/pull/797)
* Added `Interchange` and `Junction` structs describing IC and JCT. [#799](https://github.com/mapbox/mapbox-directions-swift/pull/799)
* Fixed an issue where using `cashTollOnly` for road class exclusions failed the directions request. ([#801](https://github.com/mapbox/mapbox-directions-swift/pull/801))

## v2.9.0

* Added the `RestStop.amenities` property that describes useful and important facilities such as gas stations, restaurants, and ATMs. ([#780](https://github.com/mapbox/mapbox-directions-swift/pull/780))

## v2.8.0

### Packaging

* This library now requires a minimum deployment target of iOS 12.0 or above, macOS 10.14.0 or above, tvOS 12.0 or above, or watchOS 5.0 or above. Older operating system versions are no longer supported. ([#736](https://github.com/mapbox/mapbox-directions-swift/pull/736))

### Other changes

* Added the `Waypoint.layer` property, which can ensure that the route begins on the correct road if it is above or below another road. ([#745](https://github.com/mapbox/mapbox-directions-swift/pull/745))
* Added the `AttributeOptions.update(customOption:comparisonPolicy:)` method and `AttributeOptions.customOptionsByRawValue` property for specifying attribute options that are still marked as beta in the Mapbox Directions API. ([#748](https://github.com/mapbox/mapbox-directions-swift/pull/748))
* Fixed stale `Incident.shapeIndexRange` values even after calling the `RouteRefreshResponse.refreshLegIncidents(from:legIndex:legShapeIndex:)` method. ([#752](https://github.com/mapbox/mapbox-directions-swift/pull/752))
* Added the `RouteLeg.closures` property containing information about road closures based on live traffic conditions. This information requires adding `AttributeOptions.closures` to the `RouteOptions.attributeOptions` property and setting the `DirectionsOptions.profileIdentifier` property to `ProfileIdentifier.automobileAvoidingTraffic`. ([#755](https://github.com/mapbox/mapbox-directions-swift/pull/755))
* Added the `Route.refresh(from:refreshParameters:)` method as a single entry point for refreshing various parameters of the `Route` object. ([#755](https://github.com/mapbox/mapbox-directions-swift/pull/755))

## v2.7.1

### Packaging

* This release of MapboxDirections requires Turf v2.5._x_ to work around a dependency resolution failure. If you use Carthage, it requires Turf v2.5.0 exactly. ([#766](https://github.com/mapbox/mapbox-directions-swift/pull/766))

## v2.7.0

### Packaging

* Xcode 13.0 or above and Swift 5.5 or above are now required to build MapboxDirections from source. ([#725](https://github.com/mapbox/mapbox-directions-swift/pull/725), [#727](https://github.com/mapbox/mapbox-directions-swift/pull/727))

### Command line tool

* Removed the `--config` option. Instead, pass in either the path to a JSON configuration file or the full URL to a Mapbox Directions API or Mapbox Map Matching API request. ([#726](https://github.com/mapbox/mapbox-directions-swift/pull/726))
* When the `MAPBOX_ACCESS_TOKEN` environment variable is unset, the tool exits with an error code instead of crashing. ([#728](https://github.com/mapbox/mapbox-directions-swift/pull/728))
* The tool now connects to the API endpoint in the `MAPBOX_HOST` environment variable, if specified. ([#728](https://github.com/mapbox/mapbox-directions-swift/pull/728))

### Other changes

* Added `Waypoint.allowsSnappingToStaticallyClosedRoad` property to allow snapping the waypoint’s location to a statically (long-term) closed part of a road. ([#721](https://github.com/mapbox/mapbox-directions-swift/pull/721))
* `RouteOptions(url:)` now returns `nil` if given a Mapbox Map Matching API request URL, and `MatchOptions(url:)` returns `nil` if given a Mapbox Directions API request URL. ([#728](https://github.com/mapbox/mapbox-directions-swift/pull/728))
* Added the `Directions.refreshRoute(responseIdentifier:routeIndex:fromLegAtIndex:currentRouteShapeIndex:completionHandler:)` method, which takes the index into the route geometry at which to begin refreshing, as well as corresponding `Directions.urlRequest(forRefreshing responseIdentifier:routeIndex:fromLegAtIndex:currentRouteShapeIndex:)`, `RouteRefreshResponse.refreshLegAttributes(from:legIndex:legShapeIndex:)`, and `RouteRefreshResponse.refreshLegIncidents(from:legIndex:legShapeIndex:)` methods. ([#733](https://github.com/mapbox/mapbox-directions-swift/pull/733/files))

## v2.6.1

### Packaging

* This release of MapboxDirections requires Turf v2.5._x_ to work around a dependency resolution failure. If you use Carthage, it requires Turf v2.5.0 exactly. ([#771](https://github.com/mapbox/mapbox-directions-swift/pull/771))

## v2.6.0

* MapboxDirections now requires [Turf v2.4](https://github.com/mapbox/turf-swift/releases/tag/v2.4.0). ([#703](https://github.com/mapbox/mapbox-directions-swift/pull/703))
* Added the `RouteOptions.maximumWeight` property to compute routes that excludes roads with a lower weight limit. ([#694](https://github.com/mapbox/mapbox-directions-swift/pull/694))
* Added `Route.refreshLegIncidents(from:)` method to allow refreshing `RouteLeg.incidents` during a route refresh. ([#704](https://github.com/mapbox/mapbox-directions-swift/pull/704))
* Added the `Intersection.railroadCrossing`, `Intersection.trafficSignal`, `Intersection.stopSign` and `Intersection.yieldSign` properties to indicate the kind of traffic control devices at an intersection along the route. ([#706](https://github.com/mapbox/mapbox-directions-swift/pull/706))

## v2.5.0

* Added the `RestStop.name` property. ([#689](https://github.com/mapbox/mapbox-directions-swift/pull/689))
* Added the `TollCollection.name` property. ([#691](https://github.com/mapbox/mapbox-directions-swift/pull/691))
* Types that correspond to objects in the Mapbox Directions API response, such as `RouteResponse`, `RouteRefreshResponse`, `MatchResponse`, and `RouteStep`, now conform to the `ForeignMemberContainer` and `ForeignMemberClassContainer` protocols. Types that conform to these protocols can persist unrecognized properties in the response, such as properties that are in beta, even after coding and decoding. You can access these properties using the `ForeignMemberContainer.foreignMembers` and `ForeignMemberClassContainer.foreignMembers` properties. ([#669](https://github.com/mapbox/mapbox-directions-swift/pull/669))
* Fixed an issue where `RouteStep.distance`, `RouteStep.expectedTravelTime` and `RouteStep.typicalTravelTime` were rounded to one decimal place when being encoded. ([#697](https://github.com/mapbox/mapbox-directions-swift/pull/697))
* Fixed an issue where decoding a `RouteResponse` incorrectly set the `Waypoint.snappedDistance` property to `nil`. ([#669](https://github.com/mapbox/mapbox-directions-swift/pull/669))
* The `mapbox-directions-swift` command line tool now requests routes from the Mapbox Directions API if no input file is specified. ([#576](https://github.com/mapbox/mapbox-directions-swift/pull/576))

## v2.4.0

* Fixed a crash that occurred when `RouteOptions.roadClassesToAvoid` or `RouteOptions.roadClassesToAllow` properties contained multiple road classes.
* `RoadClasses.tunnel` and `RoadClasses.restricted` are no longer supported in `RouteOptions.roadClassesToAvoid` or `RouteOptions.roadClassesToAllow` properties
* Added `DirectionsOptions(url:)`, `RouteOptions(url:)` and extended existing `DirectionsOptions(waypoints:profileIdentifier:queryItems:)`, `RouteOptions(waypoints:profileIdentifier:queryItems:)`, `MatchOptions(waypoints:profileIdentifier:queryItems:)` and related convenience init methods for deserializing corresponding options object using appropriate request URL or it's query items. ([#655](https://github.com/mapbox/mapbox-directions-swift/pull/655))
* Added `Incident` properties: `countryCode`, `countryCodeAlpha3`, `roadIsClosed`, `longDescription`, `numberOfBlockedLanes`, `congestionLevel`, `affectedRoadNames`. ([#672](https://github.com/mapbox/mapbox-directions-swift/pull/672))
* Added `departAt` and `arriveBy` properties to `RouteOptions` to allow configuring Directions routes calculation. ([#673](https://github.com/mapbox/mapbox-directions-swift/pull/673))
* Removed url request's `.json` suffix for Directions and Isochrones to follow V5 scheme. ([#678](https://github.com/mapbox/mapbox-directions-swift/pull/678))

## v2.3.0

* Added `VisualInstruction.Component.ShieldRepresentation` struct and the `VisualInstruction.Component.ImageRepresentation.shield` property containing metadata for displaying a highway shield consistent with map styles used by the Mapbox Maps SDK. ([#644](https://github.com/mapbox/mapbox-directions-swift/pull/644), [#647](https://github.com/mapbox/mapbox-directions-swift/pull/647))
* Added a `RouteLeg.viaWaypoints` property that lists the non-leg-separating waypoints (also known as “silent waypoints”) along a `RouteLeg`. Previously, you had to filter `DirectionsOptions.waypoints` to include only the items whose `Waypoints.separatesLegs` property was set to `true`, then zip them with `RouteResponse.routes`. This approach still works in some cases but is not guaranteed to be reliable for all Mapbox Directions API responses in the future. ([#656](https://github.com/mapbox/mapbox-directions-swift/pull/656))

## v2.2.0
* Added the `RouteResponse.roadClassViolations` property, which indicates any requested `RouteOptions.roadClassesToAvoid` values that could not be satisfied when calculating the routes. You can use convenience `RouteResponse.exclusionViolations(routeIndex:legIndex:stepIndex:intersectionIndex:)` method to search for a specific item. ([#627](https://github.com/mapbox/mapbox-directions-swift/pull/627))
* Fixed an issue where `PolyLineString` encoded an invalid GeoJSON LineString. ([#638](https://github.com/mapbox/mapbox-directions-swift/pull/638))
* Added `RouteRefreshSource` protocol to allow refreshing `Route` objects with `RefreshedRoute` or another `Route` instance. ([#634](https://github.com/mapbox/mapbox-directions-swift/pull/634))

## v2.1.0

* Added the `Waypoint.snappedDistance` property to get the straight-line distance from the waypoint to the location it was snapped to in the `RouteResponse`. ([#616](https://github.com/mapbox/mapbox-directions-swift/pull/616))
* Added the `RouteOptions.initialManeuverAvoidanceRadius` property to avoid a sudden maneuver when calculating a route while the user is in motion. ([#609](https://github.com/mapbox/mapbox-directions-swift/pull/609))
* Added the `RoadClasses.unpaved` option for avoiding unpaved roads. ([#620](https://github.com/mapbox/mapbox-directions-swift/pull/620))
* Added the `RoadClasses.cashOnlyToll` property for avoiding toll roads that only accept cash payment. ([#620](https://github.com/mapbox/mapbox-directions-swift/pull/620))
* Added `Isochrones`, which connects to the [Mapbox Isochrone API](https://docs.mapbox.com/api/navigation/isochrone/) to compute areas that are reachable within a specified amount of time from a location and return the reachable regions as contours of polygons or lines that you can display on a map. ([#621](https://github.com/mapbox/mapbox-directions-swift/pull/621))
* Renamed `DirectionsCredentials` and `DirectionsProfileIdentifier` to `Credentials` and `ProfileIdentifier`, respectively. ([#621](https://github.com/mapbox/mapbox-directions-swift/pull/621))
* Added the `RouteOptions.maximumHeight` and `RouteOptions.maximumWidth` properties for ensuring that the resulting routes can accommodate a vehicle of a certain size. ([#623](https://github.com/mapbox/mapbox-directions-swift/pull/623))
* The `DirectionsPriority` struct now conforms to the `Codable` protocol. ([#623](https://github.com/mapbox/mapbox-directions-swift/pull/623))
* Fixed an issue where the `RouteOptions.alleyPriority`, `RouteOptions.walkwayPriority`, and `RouteOptions.speed` properties were excluded from the encoded representation of a `RouteOptions` object. ([#623](https://github.com/mapbox/mapbox-directions-swift/pull/623))

## v2.0.0

### Packaging

* To gain access to the Mapbox Directions and Map Matching APIs, set `MBXAccessToken` in your Info.plist. `MGLMapboxAccessToken` is still supported but is now deprecated. ([#522](https://github.com/mapbox/mapbox-directions-swift/pull/522))
* MapboxDirections now requires [Turf v2._x_](https://github.com/mapbox/turf-swift/releases/tag/v2.0.0). ([#571](https://github.com/mapbox/mapbox-directions-swift/pull/571), [#608](https://github.com/mapbox/mapbox-directions-swift/pull/608))
* Carthage v0.38 or above is now required for installing this SDK if you use Carthage. ([#548](https://github.com/mapbox/mapbox-directions-swift/pull/548))
* Xcode 12.0 or above is now required to build MapboxDirections from source. ([#548](https://github.com/mapbox/mapbox-directions-swift/pull/548))
* You can fully build this SDK on Macs with Apple Silicon. ([#548](https://github.com/mapbox/mapbox-directions-swift/pull/548))
* The `mapbox-directions-swift` command line tool can no longer be built using Carthage. It now requires [swift-argument-parser](https://github.com/apple/swift-argument-parser) v1.0.0 or above. ([#606](https://github.com/mapbox/mapbox-directions-swift/pull/606))

### Other changes

* The `Incident.impact` property is now an `Incident.Impact` value instead of a string. ([#519](https://github.com/mapbox/mapbox-directions-swift/pull/519))
* `RouteOptions.alleyPriority`, `RouteOptions.walkwayPriority`, and `RouteOptions.speed` are now optional. Set them explicitly if you want to include them in the HTTP request. Renamed `DirectionsOptions.default` to `DirectionsOptions.medium`. ([#557](https://github.com/mapbox/mapbox-directions-swift/pull/557))
* Removed the `DirectionsResult.routeIdentifier` property. Use the `RouteResponse.identifier` property in conjunction with an index into the `RouteResponse.routes` array instead. ([#562](https://github.com/mapbox/mapbox-directions-swift/pull/562))
* Added the `Intersection.preferredApproachLanes` and `Intersection.usableLaneIndication` properties that indicate preferred lane usage. `VisualInstruction.Component.lane(indications:isUsable:)` has been renamed to `VisualInstruction.Component.lane(indications:isUsable:preferredDirection:)`. ([#529](https://github.com/mapbox/mapbox-directions-swift/pull/529))
* Comparing two `Intersection`s with `==` now considers whether the `Intersection.restStop`, `Intersection.regionCode`, and `Intersection.outletMapboxStreetsRoadClass` properties are equal. ([#529](https://github.com/mapbox/mapbox-directions-swift/pull/529))
* Added the `Waypoint.allowsSnappingToClosedRoad` property to allow snapping the waypoint’s location to a closed part of a road. ([#583](https://github.com/mapbox/mapbox-directions-swift/pull/583))
* Added `AttributeOptions.numericCongestionLevel`, `RouteLeg.segmentNumericCongestionLevels`, `RouteLeg.Attributes.segmentNumericCongestionLevels` and `NumericCongestionLevel` to support receiving the numeric value for congestion level along each segment of a `RouteLeg`. ([#575](https://github.com/mapbox/mapbox-directions-swift/pull/575))
* Added a `RouteOptions.roadClassesToAllow` property that enables the resulting routes to use HOV-only roads or high-occupancy toll roads. ([#598](https://github.com/mapbox/mapbox-directions-swift/pull/598))
* Added new optional parameters to the `Directions(credentials:urlSession:processingQueue:)` initializer that allow you to provide a custom `URLSession` and GCD processing queue. ([#613](https://github.com/mapbox/mapbox-directions-swift/pull/613))
* Fixed an issue where `RouteStep.exitIndex` was always unset. ([#567](https://github.com/mapbox/mapbox-directions-swift/pull/567))
* Fixed an issue where `RouteLeg.segmentRangesByStep` contained a range that was off by one for the arrival step of a leg. ([#587](https://github.com/mapbox/mapbox-directions-swift/pull/587))

## v1.2.0

### Packaging

* Added support for building and running on any Linux distribution supported by Swift. ([#488](https://github.com/mapbox/mapbox-directions-swift/pull/488))
* Added the `MapboxDirectionsCLI` command line tool that round-trips Mapbox Directions API responses between JSON format and Swift model objects. ([#469](https://github.com/mapbox/mapbox-directions-swift/pull/469))

### Other changes

* Added the `RouteStep.segmentIndicesByIntersection` property for associating `Intersection`s with portions of the step’s shape. ([#490](https://github.com/mapbox/mapbox-directions-swift/pull/490))
* Added the `Intersection.outletMapboxStreetsRoadClass` property that indicates a more detailed road classification than the existing `Intersection.outletRoadClasses` property. ([#507](https://github.com/mapbox/mapbox-directions-swift/pull/507]))
* Added the `RouteLeg.incidents` property that indicates known traffic incidents, toll collection points, rest areas, and border crossings along the route leg. ([#466](https://github.com/mapbox/mapbox-directions-swift/pull/466), [#506](https://github.com/mapbox/mapbox-directions-swift/pull/506))
* Added the `RouteLeg.regionCode(atStepIndex:intersectionIndex:)` method and `Intersection.regionCode` property to get the administrative region where an intersection is located, as well as a `RouteLeg.administrativeRegions` property that indicates the administrative regions traversed by the route leg. ([#466](https://github.com/mapbox/mapbox-directions-swift/pull/466), [#485](https://github.com/mapbox/mapbox-directions-swift/pull/485), [#506](https://github.com/mapbox/mapbox-directions-swift/pull/506))
* Added the `Intersection.tunnelName`, `Intersection.tollCollection`, `Intersection.restStop`, and `Intersection.isUrban` properties. ([#466](https://github.com/mapbox/mapbox-directions-swift/pull/466), [#506](https://github.com/mapbox/mapbox-directions-swift/pull/506))
* The `CongestionLevel` enumeration now conforms to the `CaseIterable` protocol. ([#500](https://github.com/mapbox/mapbox-directions-swift/pull/500))

## v1.1.0

* Added the `DirectionsResult.typicalTravelTime`, `RouteLeg.typicalTravelTime` and `RouteStep.typicalTravelTime` properties that indicate the typical travel time, as opposed to the current expected travel time. ([#462](https://github.com/mapbox/mapbox-directions-swift/pull/462))
* Fixed an error that occurred when setting the `Waypoint.separatesLegs` property to `true` and setting the `Waypoint.targetCoordinate` property. ([#480](https://github.com/mapbox/mapbox-directions-swift/pull/480))
* `Directions.fetchAvailableOfflineVersions(completionHandler:)` now calls its completion handler on the main queue consistently. ([#475](https://github.com/mapbox/mapbox-directions-swift/pull/475))
* Upgraded to Polyline v5.0.0. ([#487](https://github.com/mapbox/mapbox-directions-swift/pull/487))

## v1.0.0

* Added the `Directions.refreshRoute(responseIdentifier:routeIndex:fromLegAtIndex:completionHandler:)` method for refreshing attributes along the legs of a route and the `Route.refreshLegAttributes(from:)` method for merging the refreshed attributes into an existing route. To enable route refreshing for the routes in a particular route response, set `RouteOptions.refreshingEnabled` to `true` before passing the `RouteOptions` object into `Directions.calculate(_:completionHandler:)`. ([#420](https://github.com/mapbox/mapbox-directions-swift/pull/420))
* Fixed a crash that could occur if the Mapbox Directions API includes unrecognized `RoadClasses` values in its response. ([#450](https://github.com/mapbox/mapbox-directions-swift/pull/450))
* Fixed malformed `RouteStep.shape` values that could occur when `RouteStep.maneuverType` is `ManeuverType.arrive`, `DirectionsOptions.shapeFormat` is `RouteShapeFormat.polyline6`, and the Mapbox Directions API returns certain encoded Polyline strings. ([#456](https://github.com/mapbox/mapbox-directions-swift/pull/456))
* Restored the `DirectionsOptions.urlQueryItems` property so that subclasses of `RouteOptions` and `MatchOptions` can add any additional URL query parameters that are supported by the Mapbox Directions and Map Matching APIs. ([#461](https://github.com/mapbox/mapbox-directions-swift/pull/461))

## v0.33.2

* Fixed an issue where waypoints in a `RouteResponse` did not persist the `Waypoint.targetCoordinate`, `Waypoint.heading`, `Waypoint.headingAccuracy`, and `Waypoint.allowsArrivingOnOppositeSide` properties from the initial `RouteOptions` object.

## v0.33.1

* Fixed an issue where `RouteResponse(matching:options:credentials:)` and `Directions.calculateRoutes(matching:completionHandler:)` resulted in misshappen `Route.shape`s and `RouteStep.shape`s in the Atlantic Ocean if `MatchOptions.shapeFormat` was set to `RouteShapeFormat.polyline6`. ([#437](https://github.com/mapbox/mapbox-directions-swift/pull/437))

## v0.33.0

* Fixed an issue where decoding and reencoding a JSON-formatted response from the Mapbox Directions API would cause the `voiceLocale` property to be omitted from route objects. ([#424](https://github.com/mapbox/mapbox-directions-swift/pull/424))
* Added the `Route(legs:shape:distance:expectedTravelTime:)` and `Route(from:)` initializers. ([#430](https://github.com/mapbox/mapbox-directions-swift/pull/430))
* Fixed an issue where `VisualInstruction.Component.guidanceView` lacked an image URL. ([#432](https://github.com/mapbox/mapbox-directions-swift/pull/432))

## v0.32.0

* Removed the `CoordinateBounds` struct in favor of `BoundingBox` from Turf. ([#427](https://github.com/mapbox/mapbox-directions-swift/pull/427))
* Added the `VisualInstructionBanner.quaternaryInstruction` property and `VisualInstruction.Component.guidanceView(image:alternativeText:)` enumeration case to represent a detailed image of an upcoming junction. ([#425](https://github.com/mapbox/mapbox-directions-swift/pull/425))

## v0.31.1

* Fixed an issue where `RouteResponse(matching:options:credentials:)` and `Directions.calculateRoutes(matching:completionHandler:)` resulted in misshappen `Route.shape`s and `RouteStep.shape`s in the Atlantic Ocean if `MatchOptions.shapeFormat` was set to `RouteShapeFormat.polyline6`. ([#437](https://github.com/mapbox/mapbox-directions-swift/pull/437))

## v0.31.0

### Packaging

* Renamed MapboxDirections.swift to Mapbox Directions for Swift. The CocoaPods pod is now named MapboxDirections, matching the module name. ([#400](https://github.com/mapbox/MapboxDirections.swift/pull/400))
* This library now requires a minimum deployment target of iOS 10.0 or above, macOS 10.12.0 or above, tvOS 10.0 or above, or watchOS 3.0 or above. Older operating system versions are no longer supported. ([#379](https://github.com/mapbox/mapbox-directions-swift/pull/379))
* Swift is now required to directly use public types and methods defined by this library. If your application is written in Objective-C or Cocoa-AppleScript, you need to implement your own wrapper in Swift that bridges to Objective-C. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* This library now depends on [Turf](https://github.com/mapbox/turf-swift/). ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))

### Error handling

* The `RouteCompletionHandler` and `MatchCompletionHandler` closures’ `error` argument is now a `DirectionsError` instead of an `NSError`. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* Classes such as `Route`, `Match`, and `RouteStep` conform to the `Codable` protocol, so you can create instances of them from JSON-formatted `Data` using `JSONDecoder` and round-trip them back to JSON using `JSONEncoder`. Malformed input now throws decoding errors instead of crashing by unwrapping `nil`s. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))

### Visual instructions

* Removed the `Lane` class in favor of storing an array of `LaneIndication`s directly in the `Intersection.approachLanes` property. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* Removed the `ComponentRepresentable` protocol, `VisualInstructionComponent` class, and `LaneIndicationComponent` class in favor of a `VisualInstruction.Component` enumeration that contains a `VisualInstruction.Component.TextRepresentation` and/or `VisualInstruction.Component.ImageRepresentation`, depending on the type of component. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* Added the `VisualInstruction.Component.ImageRepresentation.imageURL(scale:format:)` method for fetching images with scales other than the current screen’s native scale or formats other than PNG. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))

### Other changes

* Removed support for [Mapbox Directions API v4](https://docs.mapbox.com/api/legacy/directions-v4/). ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* Replaced the `MBDefaultWalkingSpeed`, `MBMinimumWalkingSpeed`, and `MBMaximumWalkingSpeed` constants with `CLLocationSpeed.normalWalking`, `CLLocationSpeed.minimumWalking`, and `CLLocationSpeed.maximumWalking`, respectively.
* Replaced the `Route.coordinates` property with `Route.shape` and the `RouteStep.coordinates` property with `RouteStep.shape`. The `Route.coordinateCount` and `RouteStep.coordinateCount` properties have been removed, but you can use the `LineString.coordinates` property to get the array of `CLLocationCoordinate2D`s. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* `RouteLeg.source` and `RouteLeg.destination` are now optional. They can be `nil` when the `RouteLeg` object is decoded individually from JSON. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* Removed `TransportType.none`, `ManeuverType.none`, and `ManeuverDirection.none`. Unrecognized `TransportType` and `ManeuverDirection` values now raise decoding errors. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* `RouteStep.maneuverType` is now optional. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* Renamed the `Tracepoint.alternateCount` property to `Tracepoint.countOfAlternatives`. ([#382](https://github.com/mapbox/mapbox-directions-swift/pull/382))
* The `Intersection.approachIndex` and `Intersection.outletIndex` properties are now optional, not −1, in the case of a departure or arrival maneuver. ([#393](https://github.com/mapbox/mapbox-directions-swift/pull/393))
* Added initializers for `Route`, `Match`, `RouteLeg`, and `RouteStep`. ([#393](https://github.com/mapbox/mapbox-directions-swift/pull/393))
* Various properties of `Route`, `RouteLeg`, and `RouteStep` are now writable. ([#393](https://github.com/mapbox/mapbox-directions-swift/pull/393))
* Added `AttributeOptions.maximumSpeedLimit` for getting maximum posted speed limits in the `RouteLeg.segmentMaximumSpeedLimits` property. ([#367](https://github.com/mapbox/mapbox-directions-swift/pull/367))
* Added the `RouteLeg.segmentRangesByStep` property for more easily associating `RouteStep`s with the values in segment-based arrays such as `RouteLeg.segmentCongestionLevels`. ([#367](https://github.com/mapbox/mapbox-directions-swift/pull/367))
* The `RouteOptions.alleyPriority` property now works with `DirectionsProfileIdentifier.automobile`, allowing you to request routes that prefer or avoid alleys while driving. ([#416](https://github.com/mapbox/mapbox-directions-swift/pull/416))

## v0.30.0

* `Directions.fetchAvailableOfflineVersions(completionHandler:)` and `Directions.downloadTiles(in:version:completionHandler:)` now resumes the data task before returning it to conform to its naming conventions and avoid confusion. ([#353](https://github.com/mapbox/mapbox-directions-swift/pull/353))

## v0.29.0

* Added support for Swift Package Manager. ([#362](https://github.com/mapbox/mapbox-directions-swift/pull/362))

## v0.28.0

* Added the `RouteOptions.alleyPriority`, `RouteOptions.walkwayPriority`, and `RouteOptions.speed` properties for fine-tuning walking directions. ([#370](https://github.com/mapbox/mapbox-directions-swift/pull/370))
* Added the `MBStringFromManeuverType()`, `MBStringFromManeuverDirection()`, `MBStringFromDrivingSide()`, and `MBStringFromTransportType()` functions, which are intended for use in Objective-C. ([#369](https://github.com/mapbox/mapbox-directions-swift/pull/369))

## v0.27.3

* Fixed compatibility issues with Xcode 10.2 when the SDK is installed using Carthage. ([#363](https://github.com/mapbox/mapbox-directions-swift/pull/363))

## v0.27.2

* Fixed an issue where `Waypoint.separatesLegs` caused the resulting `RouteLeg.source` and `RouteLeg.destination` to have mismatched coordinates and names. ([#358](https://github.com/mapbox/mapbox-directions-swift/pull/358))
* Fixed an issue where a Directions API or Map Matching API request would fail if a `Waypoint` has `Waypoint.name` set and `Waypoint.separatesLegs` set to `false`. ([#358](https://github.com/mapbox/mapbox-directions-swift/pull/358))

## v0.27.1

### Offline routing

* Fixed an issue where `Directions.downloadTiles(in:version:session:completionHandler:)` always failed with an error after passing in a `CoordinateBounds` created using the `CoordinateBounds(northWest:southEast:)` initializer. ([#349](https://github.com/mapbox/mapbox-directions-swift/pull/349))
* Added a `CoordinateBounds(southWest:northEast:)` initializer. ([#349](https://github.com/mapbox/mapbox-directions-swift/pull/349))
* The versions passed into the completion handler of `Directions.fetchAvailableOfflineVersions(completionHandler:)` are now sorted in reverse chronological order. ([#350](https://github.com/mapbox/mapbox-directions-swift/pull/350))

### Other changes

* Fixed issues where `VisualInstruction`, `VisualInstructionBanner`, `VisualInstructionComponent`, `LaneIndicationComponent`, and `RouteOptionsV4` objects failed to roundtrip through `NSCoder`. ([#351](https://github.com/mapbox/mapbox-directions-swift/pull/351))

## v0.27.0

* If a `RouteOptions` object has exceptionally many waypoints or if many of the waypoint have very long names, `Directions.calculate(_:completionHandler:)` sends a POST request to the Mapbox Directions API instead of sending a GET request that returns an error. ([#341](https://github.com/mapbox/mapbox-directions-swift/pull/341))
* When possible, `Directions.calculateRoutes(matching:completionHandler:)` now sends a GET request to the Mapbox Map Matching API instead of a POST request. ([#341](https://github.com/mapbox/mapbox-directions-swift/pull/341))
* Fixed an issue where certain waypoint names would cause `Directions.calculateRoutes(matching:completionHandler:)` to return an error. ([#341](https://github.com/mapbox/mapbox-directions-swift/pull/341))
* Added the `Directions.url(forCalculating:httpMethod:)` and `Directions.urlRequest(forCalculating:)` methods for implementing custom GET- and POST-compatible request code. ([#341](https://github.com/mapbox/mapbox-directions-swift/pull/341))
* Added the `Waypoint.separatesLegs` property, which you can set to `false` to create a route that travels “via” the waypoint but doesn’t stop there. Deprecated the `MatchOptions.waypointIndices` property in favor of `Waypoint.separatesLegs`, which also works with `RouteOptions`. ([#340](https://github.com/mapbox/mapbox-directions-swift/pull/340))
* Fixed unset properties in  `Waypoint` objects that are included in a calculated `Route`s or `Match`es. ([#340](https://github.com/mapbox/mapbox-directions-swift/pull/340))
* Added `DirectionsResult.fetchStartDate` and `DirectionsResult.requestEndDate` properties. ([#335](https://github.com/mapbox/mapbox-directions-swift/pull/335))
* Added a `DirectionsOptions.urlQueryItems` property so that subclasses of `RouteOptions` and `MatchOptions` can add any additional URL query parameters that are supported by the Mapbox Directions and Map Matching APIs. ([#343](https://github.com/mapbox/mapbox-directions-swift/pull/343))

## v0.26.1

* `Waypoint`s and `Tracepoint`s can now be compared for object equality. ([#331](https://github.com/mapbox/mapbox-directions-swift/pull/331))
* Fixed an issue where the `DirectionsResult.accessToken` and `DirectionsResult.apiEndpoint` properties failed to roundtrip through `NSCoder`. ([#331](https://github.com/mapbox/mapbox-directions-swift/pull/331))
* `Route` now supports secure coding via the `NSSecureCoding` protocol. ([#331](https://github.com/mapbox/mapbox-directions-swift/pull/331))
* Fixed an issue where `Intersection` failed to decode when an outlet road has no road classes (i.e., a normal road that isn’t a bridge, tunnel, toll road, or motorway). ([#331](https://github.com/mapbox/mapbox-directions-swift/pull/331))

## v0.26.0

* Renamed `CoordinateBounds(_:)` to `CoordinateBounds(coordinates:)`. ([#325](https://github.com/mapbox/mapbox-directions-swift/pull/325))
* Added a `Waypoint.targetCoordinate` property for specifying a more specific destination for arrival instructions. ([#326](https://github.com/mapbox/mapbox-directions-swift/pull/326))
* Fixed an issue where the `Waypoint.allowsArrivingOnOppositeSide` property was not copied when copying a `Waypoint` object. ([#326](https://github.com/mapbox/mapbox-directions-swift/pull/326))

## v0.25.2

* Fixed an issue where `VisualInstructionComponent(json:)` would set `VisualInstructionComponent.imageURL` to an invalid URL when the JSON representation includes an empty image URL. ([#322](https://github.com/mapbox/mapbox-directions-swift/pull/322))

## v0.25.1

* Added the `Directions.apiEndpoint` and `Directions.accessToken` properties that reflect the values passed into the `Directions` class’s initializers. ([#313](https://github.com/mapbox/mapbox-directions-swift/pull/313))
* Fixed an issue causing some requests with many waypoints or long waypoint names to fail. ([#311](https://github.com/mapbox/mapbox-directions-swift/pull/311))
* Fixed an issue where some requests with very many waypoints would fail silently. ([#314](https://github.com/mapbox/mapbox-directions-swift/pull/314))

## v0.25.0

* Added `Directions.fetchAvailableOfflineVersions(completionHandler:)` for listing available offline versions. ([#303](https://github.com/mapbox/mapbox-directions-swift/pull/303))
* Added `Directions.downloadTiles(in:version:session:completionHandler:)` for downloading a tile pack. ([#303](https://github.com/mapbox/mapbox-directions-swift/pull/303))

## v0.24.1

* Added `RouteOptions.response(from:)` which can be used for deserializing a response from an external source. ([#300](https://github.com/mapbox/mapbox-directions-swift/pull/300))

## v0.24.0

* `DirectionsResult` now includes the API response as JSON

## v0.23.0

* Added `Waypoint.allowsArrivingOnOppositeSide` property for restricting the side of arrival. ([#288](https://github.com/mapbox/mapbox-directions-swift/pull/288))

## v0.22.0

* Added the `VisualInstructionBanner.tertiaryInstruction` property for additional information to display, such as a lane configuration or subsequent turn. Renamed the `VisualInstruction.textComponents` property to `VisualInstruction.components`. Some of the components may be `LaneIndicationComponent` objects, representing a lane at an intersection. ([#258](https://github.com/mapbox/mapbox-directions-swift/pull/258))
* Fixed a bug which caused coordinates to be off by a factor of 10 when requesting `.polyline6` shape format. ([#281](https://github.com/mapbox/mapbox-directions-swift/pull/281))
* Removed `MBAttributeOpenStreetMapNodeIdentifier`, as it is no longer being tracked by the API. This is a breaking change. ([#275](https://github.com/mapbox/mapbox-directions-swift/pull/275))

## v0.21.0

* Renamed `VisualInstruction.degrees` to `VisualInstruction.finalHeading`. ([#266](https://github.com/mapbox/mapbox-directions-swift/pull/266))
* Removed support for `MBAttributeOpenStreetMapNodeIdentifier`. ([#272](https://github.com/mapbox/mapbox-directions-swift/pull/272]))
* A named `Waypoint` will now be exposed in `VisualInstructionComponent`. ([#273](https://github.com/mapbox/mapbox-directions-swift/pull/273))

## v0.20.0

* Banner instructions object now includes a `degrees` field, corresponding to the location at which the user should exit a roundabout. (#259)
* Also introduces a `VisualInstructionBanner` object which now contains the primary and secondary `VisualInstruction` objects. (#259)

## v0.19.1

* Fixed an issue that caused a warning when using Swift 4.1. (#254, #255)
* Added types `.exit` and `.exitCodes` to `MBVisualInstructionType`. (#252)
* Made an initializer on `MBLane` public. (#253)

This release includes the ability to make a [Mapbox Map Matching request](https://docs.mapbox.com/api/navigation/#map-matching).

## v0.19.0

* `CompletionHandler` has been renamed to `RouteCompletionHandler` to give room for `MatchCompletionHandler`.

### Map matching
* Added new class `Match`. A `Match` object defines a single route that was created from a series of points that were matched against a road network.
* Added new class `MatchOptions`. A `MatchOptions` object is a structure that specifies the criteria for results returned by the Mapbox Map Matching API.
* Added `Directions.calculate(matchOptions:completionHandler:)` which returns a `Match`.
* Added `Directions.calculateRoutes(matching:completionHandler:)`. This is useful for creating a `Route` from a map matching request.

## v0.18.0

* Added support for abbreviations to `VisualInstructionComponents`. (#244)
* Added new types to `VisualInstructionComponentType`. (#243)

## v0.17.0

* Added `ManeuverType` and `ManeuverDirection` to `VisualInstructionComponents` ([#239](https://github.com/mapbox/mapbox-directions-swift/pull/239]))

## v0.16.1

* `RouteStep.drivingSide` is now safely unwrapped for cases where the value is missing from the response. (#233)
* Added `.tunnel` as a valid `RoadClass`. (#237)
* Added `.speechLocale` to `Route` for deciphering which `Locale` to use for speaking voice instructions. (#235)

## v0.16.0

* The `maneuverType`, `maneuverDirection`, and `transportType` properties of  `RouteStep` are now available in Objective-C code. The properties are no longer optional in Swift; check for `ManeuverType.none` ,`ManeuverDirection.none`, and `TransportType.none` instead of `nil`. (#227)

## v0.15.1

* API Response parser now handles API JSON response containing empty waypoint names correctly. (#222)

## v0.15.0

* Added property `drivingSide` to `RouteStep` that indicates which side of the road cars and traffic flow. (#219)
* Fixed a bug where named `Waypoints` were having their names stripped from the response. (#218)
* Moved the class `SpokenInstruction` from private to open for easier testability. (#216)

## v0.14.0

* Added a `RouteOption.roadClassesToAvoid` property that avoids toll roads, motorways, or ferries. (#180)
* The return value of `Directions.calculate(_:completionHandler:)` can be implicitly discarded. (#209)

## v0.13.0

* Upgraded the project to Swift 4. A final Swift 3.2 version is v0.12.1 and is also available on the branch [`swift3.2`](https://github.com/mapbox/mapbox-directions-swift/tree/swift3.2). (#196)

## v0.12.1

* Fixed an issue preventing `Route` objects archived prior to v0.12.0 from unarchiving. (#204)

## v0.12.0

* The `RouteOptions.locale` property now defaults to the current system locale and is no longer optional in Swift or nullable in Objective-C. (#202)
* The `RouteOptions` class now conforms to the `NSCopying` protocol. (#200)
* Fixed an issue preventing the `RouteOptions.distanceMeasurementSystem` property from round-tripping after the `RouteOptions` object is encoded and decoded. (#200)
* Clarified the factors that may affect the `RouteStep.expectedTravelTime` property’s accuracy. (#193)

## v0.11.2

* Changed `RouteOptions.includesVoiceInstructions` to `RouteOptions. includesSpokenInstructions`.

## v0.11.1

* Fixed a bug when decoding a `Route`, if the route did not include a `locale` option, it would fail. (#187)

## v0.11.0

* Added `instructionsSpokenAlongStep` to `RouteOptions`. This can be used for getting voice instructions for a `RouteStep` (#175)
* Added `locale` to `RouteOptions`. This can be used for setting the language settings for instructions on a `RouteStep`. (#176)

## v0.10.6

* Fixed build errors in Xcode 9. (#183)

## v0.10.5

* Added `RouteStep.phoneticNames` and `RouteStep.phoneticExitNames` for providing speech synthesizers with accurate road name pronunciation data. (#174)

## v0.10.4

* Added a `RouteShapeFormat.polyline6` option for enhanced route line precision. (#167)
* Added a `RouteOptions.includeExitRoundaboutManeuver` option to get separate steps for entering and exiting each roundabout. (#168, #169)

## v0.10.3

* Added a `RouteShapeFormat.polyline6` option for enhanced route line precision. (#167)
* Added a `RouteOptions.includeExitRoundaboutManeuver` option to get separate steps for entering and exiting each roundabout. (#168, #169)

## v0.10.2

* Added a `Route.routeIdentifer` property that contains the unique identifier associated with the network request that created the route. (#165)

## v0.10.1

* While the debugger is paused, you can visually inspect `Route`, `RouteLeg`, `RouteStep`, and `Waypoint` objects using Xcode’s built-in Quick Look feature. (#152)
* Fixed an issue causing an exit with multiple exit numbers to correspond to only a single item in the `RouteStep.exitCodes` property. (#149)
* Added an `Intersection.outletRoadClasses` property that provides details about the road leading away from the intersection. (#154, #157)
* Added properties to `Route` that indicate the access token and API endpoint of the `Directions` object that created the route. (#155)

## v0.10.0

* Added an `AttributeOptions` option, `congestion`, for obtaining the level of traffic congestion along each segment of a `RouteLeg`. (#123)
* Added a `RouteStep.exitCodes` property that contains the exit number of a `takeOffRamp` maneuver. (#147)
* Renamed `Directions.urlForCalculating(_:)` to `url(forCalculating:)` to adhere to Swift 3 naming conventions. (#138)
* If any of the waypoints of`RouteOptions` is named, those names persist in the `RouteLeg`s’ waypoints.
* Fixed an issue causing `RouteStep`s to fail to decode if the `maneuverDirection` was omitted or unrecognized. (#137)
* Changed the raw values of the `AttributeOptions` options. (#123)

## v0.9.1

* `RouteOptions` now conforms to `NSSecureCoding`. (#129)
* Multiple `AttributeOptions` values can be specified simultaneously in one `RouteOptions` object. (#129)

## v0.9.0

* Added an option to RouteOptions for obtaining attributes about each node or segment between nodes in the returned route legs. Available attributes include expected speed and travel time. ([#118](https://github.com/mapbox/mapbox-directions-swift/pull/118))
* Replaced Route’s `profileIdentifier` property with a `routeOptions` property set to the RouteOptions object that was used to obtain the route. ([#122](https://github.com/mapbox/mapbox-directions-swift/pull/122))

## v0.8.1

* Improved Swift 3.1 compatibility. ([#119](https://github.com/mapbox/mapbox-directions-swift/pull/119), [raphaelmor/Polyline#43](https://github.com/raphaelmor/Polyline/pull/43))

## v0.8.0

* Migrated to Swift 3.0. If your application is written in Swift 2.3, you should stick to v0.7.x or use the swift2.3 branch. ([#57](https://github.com/mapbox/mapbox-directions-swift/pull/64))
* Fixed an issue causing the error “The sandbox is not in sync with the Podfile.lock” when updating a Carthage-based project that requires this framework. ([#102](https://github.com/mapbox/mapbox-directions-swift/pull/102))
* Replaced the profile identifier constants with the `MBDirectionsProfileIdentifier` extensible string enumeration, which is available to both Objective-C and Swift. ([#106](https://github.com/mapbox/mapbox-directions-swift/pull/106))

## v0.7.0

* Migrated to Swift 2.3.
* Fixed an error that occurred when archiving an application that links to this library. ([#108](https://github.com/mapbox/mapbox-directions-swift/pull/108))
* Added the profile identifier constant `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` for driving routes that avoid traffic congestion. ([#86](https://github.com/mapbox/mapbox-directions-swift/pull/86))
* Replaced RouteStep’s `name` property with a `names` property; each string in the array is a road name that was previously delimited by a semicolon. ([#91](https://github.com/mapbox/mapbox-directions-swift/pull/91))
* Added a `codes` property to RouteStep that contains any highway route numbers associated with the road. These are the same route numbers that were formerly parenthesized in the `name` property. ([#91](https://github.com/mapbox/mapbox-directions-swift/pull/91))
* Added a `destinations` property to RouteStep that indicates a highway ramp’s signposted destination. ([#63](https://github.com/mapbox/mapbox-directions-swift/pull/63))
* Added an `intersections` property to RouteStep that indicates the locations and configurations of each intersection along the step, including turn lane markings. ([#80](https://github.com/mapbox/mapbox-directions-swift/pull/80))
* Added `UseLane` and `TakeRotary` maneuver types, which indicate an instruction to change lanes or enter a large, named roundabout, respectively. ([#93](https://github.com/mapbox/mapbox-directions-swift/pull/93))
* Fixed a crash that could occur when the user is connected to a captive network. ([#71](https://github.com/mapbox/mapbox-directions-swift/pull/72))
* Fixed a crash that occurred when a request failed due to rate limiting. ([#103](https://github.com/mapbox/mapbox-directions-swift/pull/103))
* The Route, RouteLeg, and RouteStep classes now conform to the NSSecureCoding protocol. ([#68](https://github.com/mapbox/mapbox-directions-swift/pull/68))
* Added convenience initializers to RouteLeg and RouteStep that accept a JSON dictionary formatted as the relevant part of a Mapbox Directions API response. ([#92](https://github.com/mapbox/mapbox-directions-swift/pull/92))
* The user agent string sent by the Mac version of this library now says “macOS” instead of “OS X”. ([#55](https://github.com/mapbox/mapbox-directions-swift/pull/55))

## v0.6.0

This is a complete rewrite of mapbox-directions-swift that focuses on making the API more Swift-like in Swift but also adds Objective-C support ([#47](https://github.com/mapbox/mapbox-directions-swift/pull/47)). The goal is no longer to be a drop-in replacement for MapKit’s MKDirections API, but the library continues to use terminology familiar to Cocoa and Cocoa Touch developers. This version includes a number of breaking changes:

* Most types and methods can now be used in Objective-C.
* Removed the `MB` class prefix from Swift but kept it for Objective-C. If any type conflicts with a type in your application’s module, prefix it with `MapboxDirections.`.
* Added a shared (singleton) `Directions` object. Use the shared object if you’ve set your Mapbox access token in the `MGLMapboxAccessToken` key of your application’s Info.plist file. (You may have already done so if you’ve installed the [Mapbox iOS SDK](https://docs.mapbox.com/ios/maps/) or [Mapbox OS X SDK](https://mapbox.github.io/mapbox-gl-native/macos/).) Otherwise, create a `Directions` object with the access token explicitly.
* Simplified the networking part of the library:
  * Removed the dependency on RequestKit. If you’re upgrading to this version using CocoaPods, you can remove the `NBNRequestKit` dependency override.
  * `Directions` no longer needs to be strongly held in order for the request to finish. Instead, the request is made against the shared URL session; to use a custom URL session, make the request yourself using the URL returned by the `URLForCalculatingDirections(options:)` property.
  * A single directions object uses the shared URL session for all requests, so it can handle multiple requests concurrently without raising an exception.
  * Removed the `cancel()` method; instead, directly cancel the NSURLSessionDataTask returned by `calculateDirections(options:completionHandler:)`.
* Replaced `calculateDirectionsWithCompletionHandler(_:completionHandler:)` and `calculateETAWithCompletionHandler(_:completionHandler:)` with a single `calculateDirections(options:completionHandler:)` method, which takes a `RouteOptions` object that supports all the options exposed by the Geocoding API. If you need to use Mapbox Directions API v4, use a `RouteOptionsV4` instead of `RouteOptions`.
* Steps are no longer returned by default, and the overview geometry is simplified by default. If you want full, turn-by-turn directions, configure the `RouteOptions` object to include the route steps and full-resolution route shapes. If you only want the estimated travel time or distance to a destination, use the default values in `RouteOptions`.
* Replaced the `MBDirectionsRequest.TransportType` type with a freeform `profileIdentifier` option. Use one of the three profile identifier constants with this option.
* Removed the `MBDirectionsResponse` class in favor of passing the waypoints and routes from the response directly into the completion handler.
* Renamed `Route.geometry` to `Route.coordinates`. For Objective-C compatibility, there are additional methods that work with C arrays of coordinates.
* Each enumeration’s raw values are integer types instead of strings, but the enumerations also conform to `CustomStringConvertible` in Swift, allowing the enumeration values to be converted to and from strings easily.

Other changes since v0.5.0:

* Added official support for OS X, tvOS, and watchOS. ([#49](https://github.com/mapbox/mapbox-directions-swift/pull/49))
* Added documentation for the entire library. You can access the documentation for any symbol using Quick Help (option-click) or Jump to Definition (command-click). ([#47](https://github.com/mapbox/mapbox-directions-swift/pull/47))
* Replaced the `TakeRamp` maneuver type with `TakeOnRamp`, `TakeOffRamp`, and `TurnAtRoundabout` to reflect changes in OSRM v5.1.0 and Mapbox Directions API v5. ([#45](https://github.com/mapbox/mapbox-directions-swift/pull/45))
* Added options to configure what’s included in the output, how close the route needs to come to the specified waypoints, and whether to include routes that U-turn at intermediate waypoints. ([#47](https://github.com/mapbox/mapbox-directions-swift/pull/47))
* Added a way to specify the heading accuracy of any waypoint. ([#47](https://github.com/mapbox/mapbox-directions-swift/pull/47))
* By default, returned routes may U-turn at intermediate waypoints. ([#47](https://github.com/mapbox/mapbox-directions-swift/pull/47))
* Various error conditions returned by the API, such as the rate limiting error, cause the localized failure reason and recovery suggestion to be set in the NSError object that is passed into the completion handler. ([#47](https://github.com/mapbox/mapbox-directions-swift/pull/47))
* Requests sent through this library now use a more specific user agent string, so you can more easily identify this library on [your Statistics page in Mapbox Studio](https://account.mapbox.com/statistics/). ([#50](https://github.com/mapbox/mapbox-directions-swift/pull/50))

## v0.5.0

* Updated Directions API v5 support to reflect late-breaking changes to the API. ([#40](https://github.com/mapbox/mapbox-directions-swift/pull/40))
* Distinguished between requested transport types and transport types in the response. Each route step in a returned route may have a different transport type. ([#40](https://github.com/mapbox/mapbox-directions-swift/pull/40))
* Route lines returned by the Directions API are now polyline-encoded instead of GeoJSON-encoded, so your application receives directions faster with less data usage ([#27](https://github.com/mapbox/mapbox-directions-swift/pull/27))
* Fixed a crash that occurred when encountering an unrecognized maneuver type from the Directions API. The API reserves the right to add new maneuver types at any time. Now unrecognized maneuver types resolve to `nil`. ([#38](https://github.com/mapbox/mapbox-directions-swift/pull/38))
* Route summaries are synthesized on the client side when absent from routes returned from the server. ([#40](https://github.com/mapbox/mapbox-directions-swift/pull/40))
* A single MBDirections object can manage multiple concurrent requests. `cancel()` cancels all outstanding tasks. ([#42](https://github.com/mapbox/mapbox-directions-swift/pull/42))

## v0.4.0

* Added support for Mapbox Directions API v5. ([#23](https://github.com/mapbox/mapbox-directions-swift/pull/23), [#25](https://github.com/mapbox/mapbox-directions-swift/pull/25)) Some highlights:
  * An MBRoute now contains one or more MBRouteLegs, each of which contains one or more MBRouteSteps. A route leg connects two waypoints.
  * The arrival step now announces the side of the street that contains the destination, if available.
  * Specify an initial heading to avoid getting directions that begin opposite the current course.
  * Start and end headings are provided for most steps.
* The library is now packaged as a dynamic framework, MapboxDirections.framework, rather than a collection of standalone Swift files. ([#24](https://github.com/mapbox/mapbox-directions-swift/pull/24))
* Added support for getting the estimated travel time to a destination. ([#17](https://github.com/mapbox/mapbox-directions-swift/pull/17))
* Added support for intermediate waypoints. ([#16](https://github.com/mapbox/mapbox-directions-swift/pull/16))
* Added support for specifying a custom profile identifier beyond the standard driving, biking, and walking profiles. ([#15](https://github.com/mapbox/mapbox-directions-swift/pull/15))
* An alternative route is no longer requested by default but can be requested by setting `MBDirectionsRequest.requestsAlternateRoutes`. ([#19](https://github.com/mapbox/mapbox-directions-swift/pull/19))
* Fixed a crash that occurred when the departure step required a turn. ([#24](https://github.com/mapbox/mapbox-directions-swift/pull/24))

## v0.3.1

No notable changes.

## v0.3.0

No notable changes.

## v0.2.0

* Removed the use of SwiftyJSON.
* Updated the API endpoint URL. ([#5](https://github.com/mapbox/mapbox-directions-swift/pull/5]))

## v0.1.0

Initial release.
