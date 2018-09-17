# Changes to the Mapbox Directions SDK for iOS

## v0.23.0

* Added `Waypoint.allowsArrivingOnOppositeSide` property for restricting the side of arrival. ([#288](https://github.com/mapbox/MapboxDirections.swift/pull/288))

## v0.22.0

* Added the `VisualInstructionBanner.tertiaryInstruction` property for additional information to display, such as a lane configuration or subsequent turn. Renamed the `VisualInstruction.textComponents` property to `VisualInstruction.components`. Some of the components may be `LaneIndicationComponent` objects, representing a lane at an intersection. ([#258](https://github.com/mapbox/MapboxDirections.swift/pull/258))
* Fixed a bug which caused coordinates to be off by a factor of 10 when requesting `.polyline6` shape format. ([#281](https://github.com/mapbox/MapboxDirections.swift/pull/281))
* Removed `MBAttributeOpenStreetMapNodeIdentifier`, as it is no longer being tracked by the API. This is a breaking change. ([#275](https://github.com/mapbox/MapboxDirections.swift/pull/275))

## v0.21.0

* Renamed `VisualInstruction.degrees` to `VisualInstruction.finalHeading`. ([#266](https://github.com/mapbox/MapboxDirections.swift/pull/266))
* Removed support for `MBAttributeOpenStreetMapNodeIdentifier`. ([#272](https://github.com/mapbox/MapboxDirections.swift/pull/272]))
* A named `Waypoint` will now be exposed in `VisualInstructionComponent`. ([#273](https://github.com/mapbox/MapboxDirections.swift/pull/273))

## v0.20.0

* Banner instructions object now includes a `degrees` field, corresponding to the location at which the user should exit a roundabout. (#259)
* Also introduces a `VisualInstructionBanner` object which now contains the primary and secondary `VisualInstruction` objects. (#259)

## v0.19.1

* Fixed an issue that caused a warning when using Swift 4.1. (#254, #255)
* Added types `.exit` and `.exitCodes` to `MBVisualInstructionType`. (#252)
* Made an initializer on `MBLane` public. (#253)

This release includes the ability to make a [Mapbox Map Matching request](https://www.mapbox.com/api-documentation/#map-matching). 

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

* Added `ManeuverType` and `ManeuverDirection` to `VisualInstructionComponents` ([#239](https://github.com/mapbox/MapboxDirections.swift/pull/239]))

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

* Upgraded the project to Swift 4. A final Swift 3.2 version is v0.12.1 and is also available on the branch [`swift3.2`](https://github.com/mapbox/MapboxDirections.swift/tree/swift3.2). (#196)

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

* Added an option to RouteOptions for obtaining attributes about each node or segment between nodes in the returned route legs. Available attributes include expected speed and travel time. ([#118](https://github.com/mapbox/MapboxDirections.swift/pull/118))
* Replaced Route’s `profileIdentifier` property with a `routeOptions` property set to the RouteOptions object that was used to obtain the route. ([#122](https://github.com/mapbox/MapboxDirections.swift/pull/122))

## v0.8.1

* Improved Swift 3.1 compatibility. ([#119](https://github.com/mapbox/MapboxDirections.swift/pull/119), [raphaelmor/Polyline#43](https://github.com/raphaelmor/Polyline/pull/43))

## v0.8.0

* Migrated to Swift 3.0. If your application is written in Swift 2.3, you should stick to v0.7.x or use the swift2.3 branch. ([#57](https://github.com/mapbox/MapboxDirections.swift/pull/64))
* Fixed an issue causing the error “The sandbox is not in sync with the Podfile.lock” when updating a Carthage-based project that requires this framework. ([#102](https://github.com/mapbox/MapboxDirections.swift/pull/102))
* Replaced the profile identifier constants with the `MBDirectionsProfileIdentifier` extensible string enumeration, which is available to both Objective-C and Swift. ([#106](https://github.com/mapbox/MapboxDirections.swift/pull/106))

## v0.7.0

* Migrated to Swift 2.3.
* Fixed an error that occurred when archiving an application that links to this library. ([#108](https://github.com/mapbox/MapboxDirections.swift/pull/108))
* Added the profile identifier constant `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic` for driving routes that avoid traffic congestion. ([#86](https://github.com/mapbox/MapboxDirections.swift/pull/86))
* Replaced RouteStep’s `name` property with a `names` property; each string in the array is a road name that was previously delimited by a semicolon. ([#91](https://github.com/mapbox/MapboxDirections.swift/pull/91))
* Added a `codes` property to RouteStep that contains any highway route numbers associated with the road. These are the same route numbers that were formerly parenthesized in the `name` property. ([#91](https://github.com/mapbox/MapboxDirections.swift/pull/91))
* Added a `destinations` property to RouteStep that indicates a highway ramp’s signposted destination. ([#63](https://github.com/mapbox/MapboxDirections.swift/pull/63))
* Added an `intersections` property to RouteStep that indicates the locations and configurations of each intersection along the step, including turn lane markings. ([#80](https://github.com/mapbox/MapboxDirections.swift/pull/80))
* Added `UseLane` and `TakeRotary` maneuver types, which indicate an instruction to change lanes or enter a large, named roundabout, respectively. ([#93](https://github.com/mapbox/MapboxDirections.swift/pull/93))
* Fixed a crash that could occur when the user is connected to a captive network. ([#71](https://github.com/mapbox/MapboxDirections.swift/pull/72))
* Fixed a crash that occurred when a request failed due to rate limiting. ([#103](https://github.com/mapbox/MapboxDirections.swift/pull/103))
* The Route, RouteLeg, and RouteStep classes now conform to the NSSecureCoding protocol. ([#68](https://github.com/mapbox/MapboxDirections.swift/pull/68))
* Added convenience initializers to RouteLeg and RouteStep that accept a JSON dictionary formatted as the relevant part of a Mapbox Directions API response. ([#92](https://github.com/mapbox/MapboxDirections.swift/pull/92))
* The user agent string sent by the Mac version of this library now says “macOS” instead of “OS X”. ([#55](https://github.com/mapbox/MapboxDirections.swift/pull/55))

## v0.6.0

This is a complete rewrite of MapboxDirections.swift that focuses on making the API more Swift-like in Swift but also adds Objective-C support ([#47](https://github.com/mapbox/MapboxDirections.swift/pull/47)). The goal is no longer to be a drop-in replacement for MapKit’s MKDirections API, but the library continues to use terminology familiar to Cocoa and Cocoa Touch developers. This version includes a number of breaking changes:

* Most types and methods can now be used in Objective-C.
* Removed the `MB` class prefix from Swift but kept it for Objective-C. If any type conflicts with a type in your application’s module, prefix it with `MapboxDirections.`.
* Added a shared (singleton) `Directions` object. Use the shared object if you’ve set your Mapbox access token in the `MGLMapboxAccessToken` key of your application’s Info.plist file. (You may have already done so if you’ve installed the [Mapbox iOS SDK](https://www.mapbox.com/ios-sdk/) or [Mapbox OS X SDK](https://github.com/mapbox/mapbox-gl-native/tree/master/platform/osx).) Otherwise, create a `Directions` object with the access token explicitly.
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

* Added official support for OS X, tvOS, and watchOS. ([#49](https://github.com/mapbox/MapboxDirections.swift/pull/49))
* Added documentation for the entire library. You can access the documentation for any symbol using Quick Help (option-click) or Jump to Definition (command-click). ([#47](https://github.com/mapbox/MapboxDirections.swift/pull/47))
* Replaced the `TakeRamp` maneuver type with `TakeOnRamp`, `TakeOffRamp`, and `TurnAtRoundabout` to reflect changes in OSRM v5.1.0 and Mapbox Directions API v5. ([#45](https://github.com/mapbox/MapboxDirections.swift/pull/45))
* Added options to configure what’s included in the output, how close the route needs to come to the specified waypoints, and whether to include routes that U-turn at intermediate waypoints. ([#47](https://github.com/mapbox/MapboxDirections.swift/pull/47))
* Added a way to specify the heading accuracy of any waypoint. ([#47](https://github.com/mapbox/MapboxDirections.swift/pull/47))
* By default, returned routes may U-turn at intermediate waypoints. ([#47](https://github.com/mapbox/MapboxDirections.swift/pull/47))
* Various error conditions returned by the API, such as the rate limiting error, cause the localized failure reason and recovery suggestion to be set in the NSError object that is passed into the completion handler. ([#47](https://github.com/mapbox/MapboxDirections.swift/pull/47))
* Requests sent through this library now use a more specific user agent string, so you can more easily identify this library on [your Statistics page in Mapbox Studio](https://www.mapbox.com/studio/stats/). ([#50](https://github.com/mapbox/MapboxDirections.swift/pull/50))

## v0.5.0

* Updated Directions API v5 support to reflect late-breaking changes to the API. ([#40](https://github.com/mapbox/MapboxDirections.swift/pull/40))
* Distinguished between requested transport types and transport types in the response. Each route step in a returned route may have a different transport type. ([#40](https://github.com/mapbox/MapboxDirections.swift/pull/40))
* Route lines returned by the Directions API are now polyline-encoded instead of GeoJSON-encoded, so your application receives directions faster with less data usage ([#27](https://github.com/mapbox/MapboxDirections.swift/pull/27))
* Fixed a crash that occurred when encountering an unrecognized maneuver type from the Directions API. The API reserves the right to add new maneuver types at any time. Now unrecognized maneuver types resolve to `nil`. ([#38](https://github.com/mapbox/MapboxDirections.swift/pull/38))
* Route summaries are synthesized on the client side when absent from routes returned from the server. ([#40](https://github.com/mapbox/MapboxDirections.swift/pull/40))
* A single MBDirections object can manage multiple concurrent requests. `cancel()` cancels all outstanding tasks. ([#42](https://github.com/mapbox/MapboxDirections.swift/pull/42))

## v0.4.0

* Added support for Mapbox Directions API v5. ([#23](https://github.com/mapbox/MapboxDirections.swift/pull/23), [#25](https://github.com/mapbox/MapboxDirections.swift/pull/25)) Some highlights:
  * An MBRoute now contains one or more MBRouteLegs, each of which contains one or more MBRouteSteps. A route leg connects two waypoints.
  * The arrival step now announces the side of the street that contains the destination, if available.
  * Specify an initial heading to avoid getting directions that begin opposite the current course.
  * Start and end headings are provided for most steps.
* The library is now packaged as a dynamic framework, MapboxDirections.framework, rather than a collection of standalone Swift files. ([#24](https://github.com/mapbox/MapboxDirections.swift/pull/24))
* Added support for getting the estimated travel time to a destination. ([#17](https://github.com/mapbox/MapboxDirections.swift/pull/17))
* Added support for intermediate waypoints. ([#16](https://github.com/mapbox/MapboxDirections.swift/pull/16))
* Added support for specifying a custom profile identifier beyond the standard driving, biking, and walking profiles. ([#15](https://github.com/mapbox/MapboxDirections.swift/pull/15))
* An alternative route is no longer requested by default but can be requested by setting `MBDirectionsRequest.requestsAlternateRoutes`. ([#19](https://github.com/mapbox/MapboxDirections.swift/pull/19))
* Fixed a crash that occurred when the departure step required a turn. ([#24](https://github.com/mapbox/MapboxDirections.swift/pull/24))

## v0.3.1

No notable changes.

## v0.3.0

No notable changes.

## v0.2.0

* Removed the use of SwiftyJSON.
* Updated the API endpoint URL. ([#5](https://github.com/mapbox/MapboxDirections.swift/pull/5]))

## v0.1.0

Initial release.
