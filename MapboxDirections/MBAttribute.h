#import <Foundation/Foundation.h>

/**
 Attributes are metadata information for a route leg.
 
 When most of the attributes are specified, the resulting route leg contains one attribute value for each segment in leg, where a segment is the straight line between two coordinates in the route leg’s full geometry. When the `MBAttributeOpenStreetMapNodeIdentifier` attribute is specified, the corresponding `RouteLeg` property contains one more value than each of the other attributes.
 */
typedef NS_OPTIONS(NSUInteger, MBAttributeOptions) {
    /**
     [OpenStreetMap node identifier](https://wiki.openstreetmap.org/wiki/Node).
     
     When this attribute is specified, the `RouteLeg.openStreetMapNodeIdentifiers` property contains one value for each coordinate in the leg’s full geometry.
     */
    MBAttributeOpenStreetMapNodeIdentifier = (1 << 1),
    
    /**
     Distance (in meters) along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentDistances` property contains one value for each segment in the leg’s full geometry.
     */
    MBAttributeDistance = (1 << 2),
    
    /**
     Expected travel time (in seconds) along the segment.
     
     When this attribute is specified, the `RouteLeg.expectedSegmentTravelTimes` property contains one value for each segment in the leg’s full geometry.
     */
    MBAttributeExpectedTravelTime = (1 << 3),
    
    /**
     Current average speed (in meters per second) along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentSpeeds` property contains one value for each segment in the leg’s full geometry.
     */
    MBAttributeSpeed = (1 << 4),
    
    /**
     Traffic congestion level along the segment.
     
     When this attribute is specified, the `RouteLeg.congestionLevels` property contains one value for each segment in the leg’s full geometry.
     
     This attribute requires `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`. Any other profile identifier produces `CongestionLevel.unknown` for each segment along the route.
     */
    MBAttributeCongestionLevel = (1 << 5),
};
