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
    @objc open var waypointIndex: Int = NSNotFound
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int, waypointIndex: Int?, matchingIndex: Int, name: String?) {
        self.alternateCount = alternateCount
        self.waypointIndex = waypointIndex ?? NSNotFound
        super.init(coordinate: coordinate)
        self.name = name
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        alternateCount = decoder.decodeInteger(forKey: "alternateCount")
        waypointIndex = decoder.decodeInteger(forKey: "waypointIndex")
        super.init(coder: decoder)
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(alternateCount, forKey: "alternateCount")
        coder.encode(waypointIndex, forKey: "waypointIndex")
    }
}
