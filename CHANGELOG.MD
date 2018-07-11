# Changes to the Mapbox Directions SDK for iOS

## v0.22.0
* Added the `VisualInstructionBanner.tertiaryInstruction` property for additional information to display, such as a lane configuration or subsequent turn. Renamed the `VisualInstruction.textComponents` property to `VisualInstruction.components`. Some of the components may be `LaneIndicationComponent` objects, representing a lane at an intersection. [#258](https://github.com/mapbox/MapboxDirections.swift/pull/258)
* Fixed a bug which caused coordinates to be off by a factor of 10 when requesting `.polyline6` shape format. [#281](https://github.com/mapbox/MapboxDirections.swift/pull/281)
* Removed `MBAttributeOpenStreetMapNodeIdentifier`, as it is no longer being tracked by the API. This is a breaking change. [#275](https://github.com/mapbox/MapboxDirections.swift/pull/275)

