typedef NS_OPTIONS(NSUInteger, MBCongestion) {
    
    MBCongestionUnknown = (1 << 1),
    
    MBCongestionLow = (1 << 2),
    
    MBCongestionModerate = (1 << 3),
    
    MBCongestionHeavy = (1 << 4),
    
    MBCongestionSevere = (1 << 5)
};
