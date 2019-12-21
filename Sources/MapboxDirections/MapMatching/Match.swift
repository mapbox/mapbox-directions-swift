import Foundation
import CoreLocation
import Polyline

extension CodingUserInfoKey {
    static let tracepoints = CodingUserInfoKey(rawValue: "com.mapbox.directions.coding.tracepoints")!
}
/**
 A `Match` object defines a single route that was created from a series of points that were matched against a road network.
 
 Typically, you do not create instances of this class directly. Instead, you receive match objects when you pass a `MatchOptions` object into the `Directions.calculate(_:completionHandler:)` or `Directions.calculateRoutes(matching:completionHandler:)` method.
 */
open class Match: DirectionsResult {
    private enum CodingKeys: String, CodingKey {
        case confidence
        case tracepoints
        case matchOptions
    }
    
    /**
     Creates a match from a decoder.
     
     - precondition: If the decoder is decoding JSON data from an API response, the `Decoder.userInfo` dictionary must contain a `MatchOptions` object in the `CodingUserInfoKey.options` key. If it does not, a `DirectionsCodingError.missingOptions` error is thrown.
     - parameter decoder: The decoder of JSON-formatted API response data or a previously encoded `Match` object.
     */
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        confidence = try container.decode(Float.self, forKey: .confidence)
        tracepoints = try container.decodeIfPresent([Tracepoint?].self, forKey: .tracepoints) ?? []
        if let matchOptions = try container.decodeIfPresent(MatchOptions.self, forKey: .matchOptions)
            ?? decoder.userInfo[.options] as? MatchOptions {
            self.matchOptions = matchOptions
        } else {
            throw DirectionsCodingError.missingOptions
        }
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(tracepoints, forKey: .tracepoints)
        try container.encode(matchOptions, forKey: .matchOptions)
        try super.encode(to: encoder)
    }
    
    /**
     A number between 0 and 1 that indicates the Map Matching API’s confidence that the match is accurate. A higher confidence means the match is more likely to be accurate.
     */
    open var confidence: Float
    
    /**
     Tracepoints on the road network that match the tracepoints in the match options.
     
     Any outlier tracepoint is omitted from the match. This array represents an outlier tracepoint if the element is `nil`.
     */
    open var tracepoints: [Tracepoint?]
    
    public override var directionsOptions: DirectionsOptions {
        return matchOptions
    }
    
    /**
     `MatchOptions` used to create the match request.
     */
    public let matchOptions: MatchOptions
}

extension Match: Equatable {
    public static func ==(lhs: Match, rhs: Match) -> Bool {
        return lhs.routeIdentifier == rhs.routeIdentifier &&
            lhs.distance == rhs.distance &&
            lhs.expectedTravelTime == rhs.expectedTravelTime &&
            lhs.speechLocale == rhs.speechLocale &&
            lhs.confidence == rhs.confidence &&
            lhs.tracepoints == rhs.tracepoints &&
            lhs.legs == rhs.legs &&
            lhs.shape == rhs.shape
    }
}
