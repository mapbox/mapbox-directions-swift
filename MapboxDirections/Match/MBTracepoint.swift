import Foundation

@objc(MBTracepoint)
public class Tracepoint: Waypoint {
    
    /**
     Number of probable alternative matchings for this trace point. A value of zero indicates that this point was matched unambiguously.
     */
    @objc open var alternateCount: Int
    
    /**
     Index representing 
     */
    @objc open var waypointIndex: Int
    
    /**
      Index to the match object in matchings the sub-trace was matched to.
     */
    @objc open var matchingIndex: Int
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int, waypointIndex: Int, matchingIndex: Int, name: String?) {
        self.alternateCount = alternateCount
        self.waypointIndex = waypointIndex
        self.matchingIndex = matchingIndex
        super.init(coordinate: coordinate)
    }
    
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
