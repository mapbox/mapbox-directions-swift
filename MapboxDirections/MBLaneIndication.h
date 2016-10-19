
typedef NS_OPTIONS(NSUInteger, MBLaneIndication) {
    // Indicates a sharp turn to the right.
    SharpRight = (1 << 4),
    
    // Indicates a turn to the right.
    Right = (1 << 2),
    
    // Indicates a turn to the right.
    SlightRight = (1 << 2),
    
    // Indicates no turn.
    StraightAhead = (1 << 7),
    
    // Indicates a slight turn to the left.
    SlightLeft = (1 << 5),
    
    // Indicates a turn to the left.
    Left = (1 << 1),
    
    // Indicates a sharp turn to the left.
    SharpLeft = (1 << 3),
    
    // Indicates a U-turn.
    UTurn = (1 << 8),
    
    // No explicit turn indication.
    None = (1 << 9),
};
