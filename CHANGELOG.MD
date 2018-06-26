# Changes to the Mapbox Directions SDK for iOS

## master

* Removed `MBAttributeOpenStreetMapNodeIdentifier, as it is no longer being tracked by the API. This is a breaking change.
* Fixed a bug which caused coordinates to be off by a factor of 10 when requesting `.polyline6` shape format.