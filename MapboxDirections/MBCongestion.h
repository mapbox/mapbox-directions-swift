typedef NS_OPTIONS(NSUInteger, MBCongestionLevel) {
    
    MBCongestionLevelUnknown = (1 << 1),
    
    MBCongestionLevelLow = (1 << 2),
    
    MBCongestionLevelModerate = (1 << 3),
    
    MBCongestionLevelHeavy = (1 << 4),
    
    MBCongestionLevelSevere = (1 << 5)
};
