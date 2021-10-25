import Foundation
import Turf

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


/**
 Options for calculating contours from the Mapbox Isochrone service.
*/
public class IsochroneOptions {
    
    public init(location: LocationCoordinate2D, contour: Contour, profileIdentifier: IsochroneProfileIdentifier = .automobile) {
        self.location = location
        self.contour = contour
        self.profileIdentifier = profileIdentifier
    }
    
    // MARK: Configuring the Contour
    
    /**
     A string specifying the primary mode of transportation for the contours.

     The default value of this property is `IsochroneProfileIdentifier.automobile`, which specifies driving directions.
     */
    public var profileIdentifier: IsochroneProfileIdentifier
    /**
     A coordinate around which to center the isochrone lines.
     */
    public var location: LocationCoordinate2D
    /**
     Contour distance or travel time definition.
     */
    public var contour: Contour
    
    /**
     The colors to use for each isochrone contour.
     
     Number of colors should match number of `contour`s.
     If no colors are specified, the Isochrone API will assign a default rainbow color scheme to the output.
     */
    public var colors: [Color]?
    
    /**
     Specify whether to return the contours as GeoJSON polygons.
     
     Defaults to `false` which represents contours as linestrings.
     */
    public var contoursPolygons: Bool?
    
    /**
     Removes contours which are `denoiseFactor` times smaller than the biggest one.
     
     The default is 1.0. A value of 1.0 will only return the largest contour for a given value. A value of 0.5 drops any contours that are less than half the area of the largest contour in the set of contours for that same value.
     */
    public var denoiseFactor: Float?
    
    /**
     Value in meters used as the tolerance for Douglas-Peucker generalization.
     
     There is no upper bound. If no value is specified in the request, the Isochrone API will choose the most optimized generalization to use for the request.
     
     - note: Generalization of contours can lead to self-intersections, as well as intersections of adjacent contours.
     */
    public var generalizeTolerance: LocationDistance?
    
    // MARK: Getting the Request URL
    
    /**
     An array of URL query items to include in an HTTP request.
     */
    var abridgedPath: String {
        return "isochrone/v1/\(profileIdentifier.rawValue)"
    }
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    var path: String {
        return "\(abridgedPath)/\(location.requestDescription).json"
    }
    
    /**
     An array of URL query items (parameters) to include in an HTTP request.
     */
    public var urlQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        var contoursCount = 0
        
        switch contour {
        case .meters(let meters):
            let value = meters.sorted().map { String(Int($0.rounded())) }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "contours_meters", value: value))
            contoursCount = meters.count
        case .minutes(let minutes):
            let value = minutes.sorted().map { String($0) }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "contours_minutes", value: value))
            contoursCount = minutes.count
        }
        
        if let colors = colors, !colors.isEmpty {
            assert(colors.count == contoursCount, "Contours `colors` count must match contours count!")
            let value = colors.map { String(format:"%02X%02X%02X", $0.red, $0.green, $0.blue)}.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "contours_colors", value: value))
        }
        
        if let isPolygon = contoursPolygons {
            queryItems.append(URLQueryItem(name: "polygons", value: String(isPolygon)))
        }
        
        if let denoise = denoiseFactor {
            queryItems.append(URLQueryItem(name: "denoise", value: String(denoise)))
        }
        
        if let tolerance = generalizeTolerance {
            queryItems.append(URLQueryItem(name: "generalize", value: String(tolerance)))
        }
        
        return queryItems
    }
}

extension IsochroneOptions {
    /**
     Definition of contour limit.
     */
    public enum Contour {
        /**
         The times in minutes to use for each isochrone contour.
         */
        case minutes([UInt])
        /**
         The distances to use for each isochrone contour.
         
         Will be rounded to the nearest integer.
         */
        case meters([LocationDistance])
    }
}

extension IsochroneOptions {
    public struct Color {
        public var red: Int
        public var green: Int
        public var blue: Int
        
        public init(red: Int, green: Int, blue: Int) {
            self.red = red
            self.green = green
            self.blue = blue
        }
        
        #if canImport(UIKit)
        init(_ color: UIColor) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            
            color.getRed(&red,
                         green: &green,
                         blue: &blue,
                         alpha: nil)
            
            self.red = Int(red * 255)
            self.green = Int(green * 255)
            self.blue = Int(blue * 255)
        }
        #elseif canImport(AppKit)
        init?(_ color: NSColor) {
            guard let convertedColor = color.usingColorSpace(.deviceRGB) else {
                return nil
            }
            red = Int(convertedColor.redComponent * 255)
            green = Int(convertedColor.greenComponent * 255)
            blue = Int(convertedColor.blueComponent * 255)
        }
        #endif
    }
}
