import Foundation

/**
 A single cross street along a step.
 */
@objc(MBIntersection)
public class Intersection: NSObject, NSSecureCoding {
    /**
     The geographic coordinates at the center of the intersection.
     */
    @objc public let location: CLLocationCoordinate2D
    
    /**
     An array of `CLLocationDirection`s indicating the absolute headings of the roads that meet at the intersection.
     
     A road is represented in this array by a heading indicating the direction from which the road meets the intersection. To get the direction of travel when leaving the intersection along the road, rotate the heading 180 degrees.
     
     A single road that passes through this intersection is represented by two items in this array: one for the segment that enters the intersection and one for the segment that exits it.
     */
    @objc public let headings: [CLLocationDirection]
    
    /**
     The indices of the items in the `headings` array that correspond to the roads that may be used to leave the intersection.
     
     This index set effectively excludes any one-way road that leads toward the intersection.
     */
    @objc public let outletIndexes: IndexSet
    
    /**
     The index of the item in the `headings` array that corresponds to the road that the containing route step uses to approach the intersection.
     */
    @objc public let approachIndex: Int
    
    /**
     The index of the item in the `headings` array that corresponds to the road that the containing route step uses to leave the intersection.
     */
    @objc public let outletIndex: Int
    
    /**
     An array of `Lane` objects representing all the lanes of the road that the containing route step uses to approach the intersection.
     
     If no lane information is available for an intersection, this property’s value is `nil`. The first item corresponds to the leftmost lane, the second item corresponds to the second lane from the left, and so on, regardless of whether the surrounding country drives on the left or on the right.
     */
    @objc public let approachLanes: [Lane]?
    
    /**
     The indices of the items in the `approachLanes` array that correspond to the roads that may be used to execute the maneuver.
     
     If no lane information is available for an intersection, this property’s value is `nil`.
     */
    @objc public let usableApproachLanes: IndexSet?
    
    /**
     The road classes of the road that the containing step uses to leave the intersection.
     
     If road class information is unavailable, this property is set to `nil`.
     */
    public let outletRoadClasses: RoadClasses?
    
    internal init(json: JSONDictionary) {
        location = CLLocationCoordinate2D(geoJSON: json["location"] as! [Double])
        headings = json["bearings"] as! [CLLocationDirection]
        
        let outletsArray = json["entry"] as! [Bool]
        let outletIndexes = outletsArray.enumerated().filter{ $1 }.map { $0.offset }
        self.outletIndexes = IndexSet(outletIndexes)
        
        approachIndex = json["in"] as? Int ?? -1
        outletIndex = json["out"] as? Int ?? -1
        
        if let lanesJSON = json["lanes"] as? [JSONDictionary] {
            var lanes: [Lane] = []
            var usableApproachLanes = IndexSet()
            
            for (i, laneJSON) in lanesJSON.enumerated() {
                lanes.append(Lane(json: laneJSON))
                if laneJSON["valid"] as! Bool {
                    usableApproachLanes.update(with: i)
                }
            }
            self.approachLanes = lanes
            self.usableApproachLanes = usableApproachLanes
        } else {
            approachLanes = nil
            usableApproachLanes = nil
        }
        
        if let classStrings = json["classes"] as? [String] {
            outletRoadClasses = RoadClasses(descriptions: classStrings)
        } else {
            outletRoadClasses = nil
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let locationDictionary = decoder.decodeObject(of: [NSDictionary.self, NSString.self, NSNumber.self], forKey: "location") as? [String: CLLocationDegrees],
            let latitude = locationDictionary["latitude"],
            let longitude = locationDictionary["longitude"] else {
            return nil
        }
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        guard let headings = decoder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "headings") as? [CLLocationDirection] else {
            return nil
        }
        self.headings = headings
        
        guard let outletIndexes = decoder.decodeObject(of: NSIndexSet.self, forKey: "outletIndexes") else {
            return nil
        }
        self.outletIndexes = outletIndexes as IndexSet
        
        approachIndex = decoder.decodeInteger(forKey: "approachIndex")
        outletIndex = decoder.decodeInteger(forKey: "outletIndex")
        
        approachLanes = decoder.decodeObject(of: [NSArray.self, Lane.self], forKey: "approachLanes") as? [Lane]
        usableApproachLanes = decoder.decodeObject(of: NSIndexSet.self, forKey: "usableApproachLanes") as IndexSet?
        
        guard let descriptions = decoder.decodeObject(of: NSString.self, forKey: "outletRoadClasses") as String?,
            let outletRoadClasses = RoadClasses(descriptions: descriptions.components(separatedBy: ",")) else {
                return nil
        }
        self.outletRoadClasses = outletRoadClasses
    }
    
    open static var supportsSecureCoding = true
    
    @objc public func encode(with coder: NSCoder) {
        coder.encode([
            "latitude": location.latitude,
            "longitude": location.longitude,
        ], forKey: "location")
        
        coder.encode(headings, forKey: "headings")
        coder.encode(outletIndexes, forKey: "outletIndexes")
        
        coder.encode(approachIndex, forKey: "approachIndex")
        coder.encode(outletIndex, forKey: "outletIndex")
        
        coder.encode(approachLanes, forKey: "approachLanes")
        coder.encode(usableApproachLanes, forKey: "usableApproachLanes")
        
        coder.encode(outletRoadClasses?.description, forKey: "outletRoadClasses")
    }
}
