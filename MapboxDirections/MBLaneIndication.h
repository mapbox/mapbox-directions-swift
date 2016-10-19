
typedef NS_OPTIONS(NSUInteger, MBLaneIndication) {
    // Indicates a sharp turn to the right.
    MBLaneIndicationSharpRight = (1 << 4),
    
    // Indicates a turn to the right.
    MBLaneIndicationRight = (1 << 2),
    
    // Indicates a turn to the right.
    MBLaneIndicationSlightRight = (1 << 2),
    
    // Indicates no turn.
    MBLaneIndicationStraightAhead = (1 << 7),
    
    // Indicates a slight turn to the left.
    MBLaneIndicationSlightLeft = (1 << 5),
    
    // Indicates a turn to the left.
    MBLaneIndicationLeft = (1 << 1),
    
    // Indicates a sharp turn to the left.
    MBLaneIndicationSharpLeft = (1 << 3),
    
    // Indicates a U-turn.
    MBLaneIndicationUTurn = (1 << 8),
    
    // No explicit turn indication.
    MBLaneIndicationNone = (1 << 9),
};
