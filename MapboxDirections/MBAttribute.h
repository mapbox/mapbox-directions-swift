typedef NS_OPTIONS(NSUInteger, MBAttribute) {

    MBAttributeDistance = (1 << 1),
    
    MBAttributeExpectedTravelTime = (1 << 2),
    
    MBAttributeOpenStreetMapNodeIdentifier = (1 << 3),
    
    MBAttributeSpeed = (1 << 4),
    
    MBAttributeAll = 0x0ffffUL
};
