
typedef NS_OPTIONS(NSUInteger, MBLaneIndication) {
    // Indicates a turn to the left.
    Left = (1 << 1),
    // Indicates a turn to the right.
    Right = (1 << 2),
    // An indication indicating a sharp turn to the left.
    SharpLeft = (1 << 3),
    // An indication indicating a sharp turn to the right.
    SharpRight = (1 << 4),
    // An indication indicating a slight turn to the left.
    SlightLeft = (1 << 5),
    // An indication indicating a slight turn to the right.
    SlightRight = (1 << 6),
    // An indication indicating no turn.
    StraightAhead = (1 << 7),
    // An indication indicating a turn
    Uturn = (1 << 8),
    // An indication indicating no turn.
    None = (1 << 9),
};
