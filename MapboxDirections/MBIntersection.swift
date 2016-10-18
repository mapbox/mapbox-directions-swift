import Foundation

public class Intersection: NSObject, NSSecureCoding {
    public var inIndex: Int?
    public var outIndex: Int?
    public var entry: [Bool]
    public var location: CLLocationCoordinate2D
    public var headings: [CLLocationDirection]
    public var lanes: [Lane]?
    
    internal init(inIndex: Int?, outIndex: Int?, entry: [Bool], location: CLLocationCoordinate2D, headings: [CLLocationDirection], lanes: [Lane]?) {
        self.inIndex = inIndex
        self.outIndex = outIndex
        self.entry = entry
        self.location = location
        self.headings = headings
        self.lanes = lanes
    }
    
    internal convenience init(json: JSONDictionary) {
        let inIndex = json["in"] as? Int
        let outIndex = json["out"] as? Int
        let entry = json["entry"] as! [Bool]
        let locationArray = json["location"] as! [Double]
        let location = CLLocationCoordinate2D(latitude: locationArray[0], longitude: locationArray[1])
        let headings = json["bearings"] as! [CLLocationDirection]
        let lanesJSON = json["lanes"] as? [JSONDictionary]
        let lanes = lanesJSON?.map { Lane(json: $0) }
        
        self.init(inIndex: inIndex, outIndex: outIndex, entry: entry, location: location, headings: headings, lanes: lanes)
    }
    
    public required init?(coder decoder: NSCoder) {
        inIndex = decoder.decodeObjectForKey("inIndex") as? Int
        outIndex = decoder.decodeObjectForKey("outIndex") as? Int
        entry = decoder.decodeObjectForKey("entry") as! [Bool]
        let coordinateDictionaries = decoder.decodeObjectForKey("location") as? [String: CLLocationDegrees]
        location = CLLocationCoordinate2D(latitude: coordinateDictionaries!["latitude"]!, longitude: coordinateDictionaries!["longitude"]!)
        headings = decoder.decodeObjectForKey("headings") as! [CLLocationDirection]
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(inIndex, forKey: "inIndex")
        coder.encodeObject(outIndex, forKey: "outIndex")
        coder.encodeObject(entry, forKey: "entry")
        coder.encodeObject(headings, forKey: "headings")
        coder.encodeObject([
            "latitude": location.latitude,
            "longitude": location.longitude
        ], forKey: "location")
    }
}
