import Foundation

/**
 A single cross street along a step.
 */
@objc(MBIntersection)
public class Intersection: NSObject, NSSecureCoding {
    
    /**
     Index into bearings/entry array.
     
     The index of the item in the headings array that corresponds to the road that the containing route step uses to approach the intersection.
    */
    public var approachIndex: Int
    
    /**
     Index into the bearings/entry array.
     
     The index of the item in the headings array that corresponds to the road that the containing route step uses to leave the intersection.
    */
    public var outletIndex: Int
    
    /**
     An array of booleans, corresponding in a 1:1 relationship to the headings.
     
     A value of true indicates that the respective road could be entered on a valid route. false indicates that the turn onto the respective road would violate a restriction.
     */
    public let entry: [Bool]
    
    /**
     CLLocationCoordinate2D representing the location of the intersection
    */
    public let location: CLLocationCoordinate2D
    
    /**
     The geographic coordinates at the center of the intersection.
    */
    public var headings: [CLLocationDirection]
    
    /**
     Array of Lane objects.
     
     If no lane information is available for an intersection, the lanes property will not be present. The first lane represents the left most lane, while the last represents the right most lane.
    */
    public var lanes: [Lane]?
    
    /**
     Set of Lane objects that have a valid turn. This is a subset of the lanes object.
    */
    public var usableLanes: Set<Lane>?
    
    internal init(approachIndex: Int?, outletIndex: Int?, entry: [Bool], location: CLLocationCoordinate2D, headings: [CLLocationDirection], lanes: [Lane]?, usableLanes: Set<Lane>) {
        self.approachIndex = approachIndex ?? -1
        self.outletIndex = outletIndex ?? -1
        self.entry = entry
        self.location = location
        self.headings = headings
        self.lanes = lanes
        self.usableLanes = usableLanes
    }
    
    internal convenience init(json: JSONDictionary) {
        let approachIndex = json["in"] as? Int
        let outletIndex = json["out"] as? Int
        let entry = json["entry"] as! [Bool]
        let coords = json["location"] as! [Double]
        let location = CLLocationCoordinate2D(geoJSON: coords)
        let headings = json["bearings"] as! [CLLocationDirection]
        let lanesJSON = json["lanes"] as? [JSONDictionary]
        var lanes = [Lane]()
        var usableLanes = Set<Lane>()
        
        for laneJSON in lanesJSON ?? [] {
            let lane = Lane(json: laneJSON)
            lanes.append(lane)
            if laneJSON["valid"] as! Bool {
                usableLanes.insert(lane)
            }
        }
        
        self.init(approachIndex: approachIndex, outletIndex: outletIndex, entry: entry, location: location, headings: headings, lanes: lanes, usableLanes: usableLanes)
    }
    
    public required init?(coder decoder: NSCoder) {
        approachIndex = decoder.decodeObjectForKey("approachIndex") as! Int
        outletIndex = decoder.decodeObjectForKey("outletIndex") as! Int
        entry = decoder.decodeObjectForKey("entry") as! [Bool]
        let coordinateDictionaries = decoder.decodeObjectForKey("location") as? [String: CLLocationDegrees]
        location = CLLocationCoordinate2D(latitude: coordinateDictionaries!["latitude"]!, longitude: coordinateDictionaries!["longitude"]!)
        headings = decoder.decodeObjectForKey("headings") as! [CLLocationDirection]
        usableLanes = decoder.decodeObjectForKey("usableLanes") as? Set<Lane>
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(approachIndex, forKey: "approachIndex")
        coder.encodeObject(outletIndex, forKey: "outletIndex")
        coder.encodeObject(entry, forKey: "entry")
        coder.encodeObject(headings, forKey: "headings")
        coder.encodeObject(usableLanes, forKey: "usableLanes")
        coder.encodeObject([
            "latitude": location.latitude,
            "longitude": location.longitude
        ], forKey: "location")
    }
}
