import Foundation

@objc(MBIntersection)
public class Intersection: NSObject, NSSecureCoding {
    
    /**
     Index into bearings/entry array.
     
     Used to calculate the bearing just before the turn. Namely, the clockwise angle from true north to the direction of travel immediately before the maneuver/passing the intersection. Bearings are given relative to the intersection. To get the bearing in the direction of driving, the bearing has to be rotated by a value of 180. The value is not supplied for depart maneuvers.
    */
    public let approachIndex: Int?
    
    /**
     Index into the bearings/entry array.
     
     Used to extract the bearing just after the turn. Namely, The clockwise angle from true north to the direction of travel immediately after the maneuver/passing the intersection. The value is not supplied for arrive maneuvers.
    */
    public let outletIndex: Int?
    
    /**
     An array of booleans, corresponding in a 1:1 relationship to the bearings.
     
     A value of true indicates that the respective road could be entered on a valid route. false indicates that the turn onto the respective road would violate a restriction.
     */
    public var entry: [Bool]
    
    /**
     CLLocationCoordinate2D representing the location of the intersection
    */
    public var location: CLLocationCoordinate2D
    
    
    public var headings: [CLLocationDirection]
    public var lanes: [Lane]?
    
    internal init(approachIndex: Int?, outletIndex: Int?, entry: [Bool], location: CLLocationCoordinate2D, headings: [CLLocationDirection], lanes: [Lane]?) {
        self.approachIndex = approachIndex
        self.outletIndex = outletIndex
        self.entry = entry
        self.location = location
        self.headings = headings
        self.lanes = lanes
    }
    
    internal convenience init(json: JSONDictionary) {
        let approachIndex = json["in"] as? Int
        let outletIndex = json["out"] as? Int
        let entry = json["entry"] as! [Bool]
        let locationArray = json["location"] as! [Double]
        let location = CLLocationCoordinate2D(latitude: locationArray[0], longitude: locationArray[1])
        let headings = json["bearings"] as! [CLLocationDirection]
        let lanesJSON = json["lanes"] as? [JSONDictionary]
        let lanes = lanesJSON?.map { Lane(json: $0) }
        
        self.init(approachIndex: approachIndex, outletIndex: outletIndex, entry: entry, location: location, headings: headings, lanes: lanes)
    }
    
    public required init?(coder decoder: NSCoder) {
        approachIndex = decoder.decodeObjectForKey("approachIndex") as? Int
        outletIndex = decoder.decodeObjectForKey("outletIndex") as? Int
        entry = decoder.decodeObjectForKey("entry") as! [Bool]
        let coordinateDictionaries = decoder.decodeObjectForKey("location") as? [String: CLLocationDegrees]
        location = CLLocationCoordinate2D(latitude: coordinateDictionaries!["latitude"]!, longitude: coordinateDictionaries!["longitude"]!)
        headings = decoder.decodeObjectForKey("headings") as! [CLLocationDirection]
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(approachIndex, forKey: "approachIndex")
        coder.encodeObject(outletIndex, forKey: "outletIndex")
        coder.encodeObject(entry, forKey: "entry")
        coder.encodeObject(headings, forKey: "headings")
        coder.encodeObject([
            "latitude": location.latitude,
            "longitude": location.longitude
        ], forKey: "location")
    }
}
