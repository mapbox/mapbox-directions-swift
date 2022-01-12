import Foundation

/**
 A skeletal route containing infromation to refresh `Route` object attributes.
 */
public protocol RouteRefreshSource {
    var refreshedLegs: [RouteLegRefreshSource] { get }
}

/**
 A skeletal route leg containing infromation to refresh `RouteLeg` object attributes.
 */
public protocol RouteLegRefreshSource {
    var refreshedAttributes: RouteLeg.Attributes { get }
}

extension Route: RouteRefreshSource {
    public var refreshedLegs: [RouteLegRefreshSource] {
        legs
    }
}
extension RouteLeg: RouteLegRefreshSource {
    public var refreshedAttributes: Attributes {
        attributes
    }
}

extension RefreshedRoute: RouteRefreshSource {
    public var refreshedLegs: [RouteLegRefreshSource] {
        legs
    }
}
extension RefreshedRouteLeg: RouteLegRefreshSource {
    public var refreshedAttributes: RouteLeg.Attributes {
        attributes
    }
}
