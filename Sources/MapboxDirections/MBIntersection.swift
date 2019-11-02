import Foundation
import CoreLocation

/**
 A single cross street along a step.
 */
public struct Intersection: Codable, Equatable {
    /**
     The geographic coordinates at the center of the intersection.
     */
    public let location: CLLocationCoordinate2D
    
    /**
     An array of `CLLocationDirection`s indicating the absolute headings of the roads that meet at the intersection.
     
     A road is represented in this array by a heading indicating the direction from which the road meets the intersection. To get the direction of travel when leaving the intersection along the road, rotate the heading 180 degrees.
     
     A single road that passes through this intersection is represented by two items in this array: one for the segment that enters the intersection and one for the segment that exits it.
     */
    public let headings: [CLLocationDirection]
    
    /**
     The indices of the items in the `headings` array that correspond to the roads that may be used to leave the intersection.
     
     This index set effectively excludes any one-way road that leads toward the intersection.
     */
    public let outletIndexes: IndexSet
    
    /**
     The index of the item in the `headings` array that corresponds to the road that the containing route step uses to approach the intersection.
     */
    public let approachIndex: Int
    
    /**
     The index of the item in the `headings` array that corresponds to the road that the containing route step uses to leave the intersection.
     */
    public let outletIndex: Int
    
    /**
     An array of `Lane` objects representing all the lanes of the road that the containing route step uses to approach the intersection.
     
     If no lane information is available for an intersection, this property’s value is `nil`. The first item corresponds to the leftmost lane, the second item corresponds to the second lane from the left, and so on, regardless of whether the surrounding country drives on the left or on the right.
     */
    public let approachLanes: [Lane]?
    
    /**
     The indices of the items in the `approachLanes` array that correspond to the roads that may be used to execute the maneuver.
     
     If no lane information is available for an intersection, this property’s value is `nil`.
     */
    public let usableApproachLanes: IndexSet?
    
    /**
     The road classes of the road that the containing step uses to leave the intersection.
     
     If road class information is unavailable, this property is set to `nil`.
     */
    public let outletRoadClasses: RoadClasses?
    
    private enum CodingKeys: String, CodingKey {
        case outletIndexes = "entry"
        case headings = "bearings"
        case location
        case approachIndex = "in"
        case outletIndex = "out"
        case lanes
        case outletRoadClasses = "classes"
    }
    
    public init(location: CLLocationCoordinate2D,
                headings: [CLLocationDirection],
                approachIndex: Int,
                outletIndex: Int,
                outletIndexes: IndexSet,
                approachLanes: [Lane]?,
                usableApproachLanes: IndexSet?,
                outletRoadClasses: RoadClasses?) {
        self.location = location
        self.headings = headings
        self.approachIndex = approachIndex
        self.approachLanes = approachLanes
        self.outletIndex = outletIndex
        self.outletIndexes = outletIndexes
        self.usableApproachLanes = usableApproachLanes
        self.outletRoadClasses = outletRoadClasses
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(headings, forKey: .headings)
        
        try container.encode(approachIndex, forKey: .approachIndex)
        try container.encode(outletIndex, forKey: .outletIndex)
        
        var outletArray: [Bool] = Array<Bool>.init(repeating: false, count: (outletIndexes.max()! + 1))
    
        for index in outletIndexes {
            outletArray[index] = true
        }
        
        try container.encode(outletArray, forKey: .outletIndexes)
        
        try container.encode(approachLanes, forKey: .lanes)
        
        if let classes = outletRoadClasses?.description.components(separatedBy: ",") {
            try container.encode(classes, forKey: .outletRoadClasses)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(CLLocationCoordinate2D.self, forKey: .location)
        headings = try container.decode([CLLocationDirection].self, forKey: .headings)
        
        approachLanes = try container.decodeIfPresent([Lane].self, forKey: .lanes)
        usableApproachLanes = approachLanes?.indices { $0.isValid }
        outletRoadClasses = try container.decodeIfPresent(RoadClasses.self, forKey: .outletRoadClasses)
        
        let outletsArray = try container.decode([Bool].self, forKey: .outletIndexes)
        outletIndexes = outletsArray.indices { $0 }
        
        outletIndex = try container.decodeIfPresent(Int.self, forKey: .outletIndex) ?? -1
        approachIndex = try container.decodeIfPresent(Int.self, forKey: .approachIndex) ?? -1
    }
    
    //MARK: - Equatable
    
    public static func == (lhs: Intersection, rhs: Intersection) -> Bool {
        return lhs.location == rhs.location &&
            lhs.headings == rhs.headings &&
            lhs.outletIndexes == rhs.outletIndexes &&
            lhs.approachIndex == rhs.approachIndex &&
            lhs.outletIndex == rhs.outletIndex &&
            lhs.approachLanes == rhs.approachLanes &&
            lhs.usableApproachLanes == rhs.usableApproachLanes &&
            lhs.outletRoadClasses == rhs.outletRoadClasses
    }
}
