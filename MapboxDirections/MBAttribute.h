/**
 Attributes are metadata information for a given route. The number of attributes returned will be a direct 1-1 relationship with the route's full geometry. Each type will return an ordered list of requested attributes. For `.distance`, `.expectedTrabelTime`, and `.speed` there will be one less value when compared to the route geometry. This is because these values represent the data on segment between geometry points.
*/
typedef NS_OPTIONS(NSUInteger, MBAttributeOptions) {

    /// Segment distance.
    MBAttributeDistance = (1 << 1),
    
    // Segment expected travel time in seconds.
    MBAttributeExpectedTravelTime = (1 << 2),
    
    // Segment current speed.
    MBAttributeSpeed = (1 << 3),
    
    // Unique OpenStreetMap node.
    MBAttributeOpenStreetMapNodeIdentifier = (1 << 4)
};
