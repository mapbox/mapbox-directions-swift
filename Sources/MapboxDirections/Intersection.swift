import Foundation
import CoreLocation

/**
 A single cross street along a step.
 */
public struct Intersection {
    // MARK: Creating an Intersection
    
    public init(location: CLLocationCoordinate2D,
                headings: [CLLocationDirection],
                approachIndex: Int,
                outletIndex: Int,
                outletIndexes: IndexSet,
                approachLanes: [LaneIndication]?,
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
    
    // MARK: Getting the Location of the Intersection
    
    /**
     The geographic coordinates at the center of the intersection.
     */
    public let location: CLLocationCoordinate2D
    
    // MARK: Getting the Roads that Meet at the Intersection
    
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
    
    // MARK: Getting the Roads That Take the Route Through the Intersection
    
    /**
     The index of the item in the `headings` array that corresponds to the road that the containing route step uses to approach the intersection.
     
     This property is set to `nil` for a departure maneuver.
     */
    public let approachIndex: Int?
    
    /**
     The index of the item in the `headings` array that corresponds to the road that the containing route step uses to leave the intersection.
     
     This property is set to `nil` for an arrival maneuver.
     */
    public let outletIndex: Int?
    
    /**
     The road classes of the road that the containing step uses to leave the intersection.
     
     If road class information is unavailable, this property is set to `nil`.
     */
    public let outletRoadClasses: RoadClasses?
    
    // MARK: Telling the User Which Lanes to Use
    
    /**
     All the lanes of the road that the containing route step uses to approach the intersection. Each item in the array represents a lane, which is represented by one or more `LaneIndication`s.
     
     If no lane information is available for the intersection, this property’s value is `nil`. The first item corresponds to the leftmost lane, the second item corresponds to the second lane from the left, and so on, regardless of whether the surrounding country drives on the left or on the right.
     */
    public let approachLanes: [LaneIndication]?
    
    /**
     The indices of the items in the `approachLanes` array that correspond to the lanes that may be used to execute the maneuver.
     
     If no lane information is available for an intersection, this property’s value is `nil`.
     */
    public let usableApproachLanes: IndexSet?
}

extension Intersection: Codable {
    private enum CodingKeys: String, CodingKey {
        case outletIndexes = "entry"
        case headings = "bearings"
        case location
        case approachIndex = "in"
        case outletIndex = "out"
        case lanes
        case outletRoadClasses = "classes"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(headings, forKey: .headings)
        
        try container.encodeIfPresent(approachIndex, forKey: .approachIndex)
        try container.encodeIfPresent(outletIndex, forKey: .outletIndex)
        
        var outletArray = headings.map { _ in false }
        for index in outletIndexes {
            outletArray[index] = true
        }
        
        try container.encode(outletArray, forKey: .outletIndexes)
        
        var lanes: [Lane]?
        if let approachLanes = approachLanes,
            let usableApproachLanes = usableApproachLanes {
            lanes = approachLanes.map { Lane(indications: $0) }
            for i in usableApproachLanes {
                lanes![i].isValid = true
            }
        }
        try container.encodeIfPresent(lanes, forKey: .lanes)
        
        if let classes = outletRoadClasses?.description.components(separatedBy: ",").filter({ !$0.isEmpty }) {
            try container.encode(classes, forKey: .outletRoadClasses)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(CLLocationCoordinate2D.self, forKey: .location)
        headings = try container.decode([CLLocationDirection].self, forKey: .headings)
        
        if let lanes = try container.decodeIfPresent([Lane].self, forKey: .lanes) {
            approachLanes = lanes.map { $0.indications }
            usableApproachLanes = lanes.indices { $0.isValid }
        } else {
            approachLanes = nil
            usableApproachLanes = nil
        }
        outletRoadClasses = try container.decodeIfPresent(RoadClasses.self, forKey: .outletRoadClasses)
        
        let outletsArray = try container.decode([Bool].self, forKey: .outletIndexes)
        outletIndexes = outletsArray.indices { $0 }
        
        outletIndex = try container.decodeIfPresent(Int.self, forKey: .outletIndex)
        approachIndex = try container.decodeIfPresent(Int.self, forKey: .approachIndex)
    }
}

extension Intersection: Equatable {
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
