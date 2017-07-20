#import <Foundation/Foundation.h>

/**
 Option set that contains attributes of a road segment.
 */
typedef NS_OPTIONS(NSUInteger, MBRoadClasses) {
    
    /**
     Indidcates a road has a segments which has [paid tolls](https://wiki.openstreetmap.org/wiki/Key:toll).
     */
    MBRoadClassesToll = (1 << 1),
    
    /**
     Indicates a road has a segments which is [restricted](https://wiki.openstreetmap.org/wiki/Key:access).
     */
    MBRoadClassesRestricted = (1 << 2),
    
    /**
     Indicates a road segment is a [freeway](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway) or [freeway ramp](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway_link).
     */
    MBRoadClassesMotorway = (1 << 3),
    
    /**
     Indicates a road segment requires the use of a ferry.
     
     @see TransportType.ferry
     */
    MBRoadClassesFerry = (1 << 4),
};
