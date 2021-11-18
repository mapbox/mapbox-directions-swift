
import Foundation

/**
 Description of `RoadClasses` that were meant to be avoided during routing but still got used in a `Route`.
 
 If something in `RouteOptions.roadClassesToAvoid` prevents the origin or destination from connecting to the main road network, the Directions API will temporarily ignore the road class constraints in order to reach the main road network.
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
     Filters `violations` to search for specific leg and step.
     
     - parameter legIndex: Index of a leg inside related `Route`to search in.
     - parameter stepIndex: Index of a step inside given `Route`'s leg.
     - returns: Array of `RoadClassExclusionViolation` under given indicies.
     
     Passing `nil` as `stepIndex` will result in searching for all steps.
     */
    public func violations(at legIndex: Int, stepIndex: Int? = nil) -> [RoadClassExclusionViolation] {
        return fetchViolations(at: legIndex, stepIndex: stepIndex, intersectionIndex: nil)
    }
    
    /**
     Filters `violations` to search for specific leg, step and intersection.
     
     - parameter legIndex: Index of a leg inside related `Route`to search in.
     - parameter stepIndex: Index of a step inside given `Route`'s leg.
     - parameter intersectionIndex: Index of an intersection inside given `Route`'s leg and step.
     - returns: Array of `RoadClassExclusionViolation` under given indicies.
     
     Passing `nil` as `intersectionIndex` will result in searching for all intersections of given step.
     */
    public func violations(at legIndex: Int, stepIndex: Int, intersectionIndex: Int?) -> [RoadClassExclusionViolation] {
        return fetchViolations(at: legIndex, stepIndex: stepIndex, intersectionIndex: intersectionIndex)
    }
    
    private func fetchViolations(at legIndex: Int, stepIndex: Int? = nil, intersectionIndex: Int? = nil) -> [RoadClassExclusionViolation] {
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
     Index of a `Route` inside `RouteResponse` where violation occured.
     */
    public var routeIndex: Int
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
