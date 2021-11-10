
import Foundation

/**
 Description of `RoadClasses` that were meant to be avoided during routing but still got used in a `Route`.
 
 Such ignoring may be done by the engine if it cannot provide a route otherwise.
 */
public struct RouteRoadClassesViolations {
    /**
     Related `Route` object
     */
    public let route: Route
    
    /**
     List of all existing violations, down to `RouteStep` granularity.
     */
    public let violations: [RoadClassExclusionViolation]
    
    /**
     Filters `violations` to search for specific leg, step and intersection.
     
     - parameter legIndex: Index of a leg inside related `Route`to search in.
     - parameter stepIndex: Index of a step inside given `Route`'s leg.
     - parameter intersectionIndex: Index of an intersection inside given `Route`'s leg and step.
     - returns: Array of `RoadClassExclusionViolation` under given indicies.
     
     Passing `nil` as one of the indicies will result in searching for all violations at given `legIndex`/`stepIndex`.
     - note: Searching by `intersectionIndex` requires non-nil `stepIndex`.
     */
    public func violations(at legIndex: Int, stepIndex: Int? = nil, intersectionIndex: Int? = nil) -> [RoadClassExclusionViolation] {
        assert(!(stepIndex == nil && intersectionIndex != nil), "It is forbidden to select `intersectionIndex` without specifying `stepIndex`.")
        
        return violations.filter { violation in
            let validStep = (stepIndex ?? violation.stepIndex) == violation.stepIndex
            let validIntersection = (intersectionIndex ?? violation.intersectionIndex) == violation.intersectionIndex
            
            return violation.legIndex == legIndex &&
                validStep &&
                validIntersection
        }
    }
}

/**
 Exact `RoadClass` exclusion violation case.
 */
public struct RoadClassExclusionViolation {
    /**
     `RoadClasses` that were violated at this point.
     */
    public var roadClasses: RoadClasses
    /**
     Related `Route` object.
     */
    public var route: Route
    /**
     Index of a `RouteLeg` inside `Route` where violation occured.
     */
    public var legIndex: Int
    /**
     Index of a `RouteStep` inside `RouteLeg` where violation occured.
     */
    public var stepIndex: Int
    /**
     Index of an `Intersection` inside `RouteStep` where violation occured.
     */
    public var intersectionIndex: Int
}
