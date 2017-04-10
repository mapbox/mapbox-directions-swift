/**
 Attributes are metadata information for a given route. The number of attributes returned will be a direct 1-1 relationship with the route's full geometry. The `.distance`, `.expectedTravelTime`, and `.speed` attributes have one fewer value than the `.openStreetMapNodeIdentifier` attribute.
*/
typedef NS_OPTIONS(NSUInteger, MBAttributeOptions) {

    /// Segment distance. Distances are measured in meters.
    MBAttributeDistance = (1 << 1),
    
    // Segment expected travel time in seconds.
    MBAttributeExpectedTravelTime = (1 << 2),
    
    // Segment current speed. Speeds are measured in meters per second.
    MBAttributeSpeed = (1 << 3),
    
    // [OpenStreetMap node identifier](https://wiki.openstreetmap.org/wiki/Node).
    MBAttributeOpenStreetMapNodeIdentifier = (1 << 4)
};
