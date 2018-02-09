import Foundation

@objc(MBTracepoint)
public class Tracepoint: Waypoint {
    
    /**
     Number of probable alternative matchings for this trace point. A value of zero indicates that this point was matched unambiguously.
     */
    @objc open var alternateCount: Int
    
    /**
     Index of the waypoint inside the matched route.
     */
    open var waypointIndex: Int?
    
    /**
      Index to the match object in matchings the sub-trace was matched to.
     */
    @objc open var matchingIndex: Int
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int, waypointIndex: Int?, matchingIndex: Int, name: String?) {
        self.alternateCount = alternateCount
        self.waypointIndex = waypointIndex
        self.matchingIndex = matchingIndex
        super.init(coordinate: coordinate)
        self.name = name
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        alternateCount = decoder.decodeInteger(forKey: "alternateCount")
        waypointIndex = decoder.decodeInteger(forKey: "waypointIndex")
        matchingIndex = decoder.decodeInteger(forKey: "matchingIndex")
        super.init(coder: decoder)
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(alternateCount, forKey: "alternateCount")
        coder.encode(waypointIndex, forKey: "waypointIndex")
        coder.encode(matchingIndex, forKey: "matchingIndex")
    }
}
