# Changes to the Mapbox Directions SDK for iOS

## master

* Removed `MBAttributeOpenStreetMapNodeIdentifier, as it is no longer being tracked by the API. This is a breaking change.
* changed `MBVisualInstructionComponentType.image` to `MBVisualInstructionComponentType.icon`, as the API has changed to reflect the possibility of a "Generic Route Shield" icon component being passed back from the service.
