import Foundation
import CoreLocation


/**
 A `Tracepoint` represents a location matched to the road network.
 */

public class Tracepoint: Waypoint {
    
    /**
     Number of probable alternative matchings for this tracepoint. A value of zero indicates that this point was matched unambiguously.
     */
    open var alternateCount: Int = NSNotFound
    
    init(coordinate: CLLocationCoordinate2D, alternateCount: Int?, name: String?) {
        self.alternateCount = alternateCount ?? NSNotFound
        super.init(coordinate: coordinate, name: name)
    }
    
    public required init?(coder decoder: NSCoder) {
        alternateCount = decoder.decodeInteger(forKey: "alternateCount")
        super.init(coder: decoder)
    }
    
    public override func encode(with coder: NSCoder) {
        coder.encode(alternateCount, forKey: "alternateCount")
    }
    
    override public class var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: Objective-C equality
    open override func isEqual(_ object: Any?) -> Bool {
        guard let opts = object as? Tracepoint else { return false }
        return isEqual(to: opts)
    }
    
    
    open func isEqual(to other: Tracepoint?) -> Bool {
        guard let other = other else { return false }
        return super.isEqual(to: other) && type(of: self) == type(of: other) &&
            alternateCount == other.alternateCount
    }
}
