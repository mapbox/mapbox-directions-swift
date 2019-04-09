#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//! Project version number for MapboxDirections.
FOUNDATION_EXPORT double MapboxDirectionsVersionNumber;

//! Project version string for MapboxDirections.
FOUNDATION_EXPORT const unsigned char MapboxDirectionsVersionString[];

#if !SWIFT_PACKAGE
#import "MBLaneIndication.h"
#import "MBAttribute.h"
#import "MBRouteOptions.h"
#import "MBRoadClasses.h"
#endif

#if SWIFT_PACKAGE
#define OBJC_NO_SPM
#define OBJC_NO_SPM(x)
#else
#define OBJC_NO_SPM @objc
#define OBJC_NO_SPM(x) @objc(x)
#endif
