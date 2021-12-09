import Foundation

/**
 A skeletal route containing infromation to refresh `Route` object annotations.
 */
public protocol RouteRefreshing {
    var refreshedLegs: [RouteLegRefreshing] { get }
}

/**
 A skeletal route leg containing infromation to refresh `RouteLeg` object annotations.
 */
public protocol RouteLegRefreshing {
    var refreshedAttributes: RouteLeg.Attributes { get }
}

extension Route: RouteRefreshing {
    public var refreshedLegs: [RouteLegRefreshing] {
        legs
    }
}
extension RouteLeg: RouteLegRefreshing {
    public var refreshedAttributes: Attributes {
        attributes
    }
}

extension RefreshedRoute: RouteRefreshing {
    public var refreshedLegs: [RouteLegRefreshing] {
        legs
    }
}
extension RefreshedRouteLeg: RouteLegRefreshing {
    public var refreshedAttributes: RouteLeg.Attributes {
        attributes
    }
}
