import Foundation
/**
 A `Tracepoint` represents a location matched to the road network.
 */
@objc(MBTracepoint)
public class Tracepoint: Waypoint {
    
    /**
     Number of probable alternative matchings for this tracepoint. A value of zero indicates that this point was matched unambiguously.
     */
    @objc open var alternateCount: Int = NSNotFound
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int?, name: String?) {
        self.alternateCount = alternateCount ?? NSNotFound
        super.init(coordinate: coordinate, name: name)
    }
    
    @objc public required init?(coder decoder: NSCoder) {
        alternateCount = decoder.decodeInteger(forKey: "alternateCount")
        super.init(coder: decoder)
    }
    
    @objc public override func encode(with coder: NSCoder) {
        coder.encode(alternateCount, forKey: "alternateCount")
    }
    
    override public class var supportsSecureCoding: Bool {
        return true
    }
}
