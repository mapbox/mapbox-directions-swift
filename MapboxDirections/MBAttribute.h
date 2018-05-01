#import <Foundation/Foundation.h>

/**
 Attributes are metadata information for a route leg.
 
 When any of the attributes are specified, the resulting route leg contains one attribute value for each segment in leg, where a segment is the straight line between two coordinates in the route leg’s full geometry.
 */
typedef NS_OPTIONS(NSUInteger, MBAttributeOptions) {
    /**
     Distance (in meters) along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentDistances` property contains one value for each segment in the leg’s full geometry.
     */
    MBAttributeDistance = (1 << 1),
    
    /**
     Expected travel time (in seconds) along the segment.
     
     When this attribute is specified, the `RouteLeg.expectedSegmentTravelTimes` property contains one value for each segment in the leg’s full geometry.
     */
    MBAttributeExpectedTravelTime = (1 << 2),
    
    /**
     Current average speed (in meters per second) along the segment.
     
     When this attribute is specified, the `RouteLeg.segmentSpeeds` property contains one value for each segment in the leg’s full geometry.
     */
    MBAttributeSpeed = (1 << 3),
    
    /**
     Traffic congestion level along the segment.
     
     When this attribute is specified, the `RouteLeg.congestionLevels` property contains one value for each segment in the leg’s full geometry.
     
     This attribute requires `MBDirectionsProfileIdentifierAutomobileAvoidingTraffic`. Any other profile identifier produces `CongestionLevel.unknown` for each segment along the route.
     */
    MBAttributeCongestionLevel = (1 << 4),
};
