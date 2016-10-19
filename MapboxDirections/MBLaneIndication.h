
typedef NS_OPTIONS(NSUInteger, MBLaneIndication) {
    // Indicates a turn to the left.
    Left = (1 << 1),
    // Indicates a turn to the right.
    Right = (1 << 2),
    // Indicates a sharp turn to the left.
    SharpLeft = (1 << 3),
    // Indicates a sharp turn to the right.
    SharpRight = (1 << 4),
    // Indicates a slight turn to the left.
    SlightLeft = (1 << 5),
    // Indicates a slight turn to the right.
    SlightRight = (1 << 6),
    // Indicates no turn.
    StraightAhead = (1 << 7),
    // Indicates no turn
    Uturn = (1 << 8),
    // Indicates a uturn.
    None = (1 << 9),
};
