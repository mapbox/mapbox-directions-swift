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
    
    public init(location: LocationCoordinate2D, contours: Contours, profileIdentifier: IsochroneProfileIdentifier = .automobile) {
        self.location = location
        self.contours = contours
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
     Contours distance or travel time definition.
     */
    public var contours: Contours
    
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
        
        switch contours {
        case .distance(let meters):
            let value = meters.sorted().map { String(Int($0.rounded())) }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "contours_meters", value: value))
            contoursCount = meters.count
        case .expectedTravelTime(let intervals):
            let value = intervals.sorted().map { String(Int(($0 / 60.0).rounded())) }.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "contours_minutes", value: value))
            contoursCount = intervals.count
        }
        
        if let colors = colors, !colors.isEmpty {
            assert(colors.count == contoursCount, "Contours `colors` count must match contours count!")
            let value = colors.map { queryColorDescription(color: $0)}.joined(separator: ";")
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
    public enum Contours {
        /**
         The desired travel times to use for each isochrone contour.
         
         This value will be rounded to the nearest minute.
         */
        case expectedTravelTime([TimeInterval])
        /**
         The distances to use for each isochrone contour.
         
         Will be rounded to the nearest integer.
         */
        case distance([LocationDistance])
    }
}

extension IsochroneOptions {
    #if canImport(UIKit)
    public typealias Color = UIColor
    #elseif canImport(AppKit)
    public typealias Color = NSColor
    #else
    public struct Color {
        public var red: Int
        public var green: Int
        public var blue: Int
        
        public init(red: Int, green: Int, blue: Int) {
            self.red = red
            self.green = green
            self.blue = blue
        }
    }
    #endif
    
    func queryColorDescription(color: Color) -> String {
        let hexFormat = "%02X%02X%02X"
        
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        color.getRed(&red,
                     green: &green,
                     blue: &blue,
                     alpha: nil)
        
        return String(format: hexFormat,
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
        #elseif canImport(AppKit)
        guard let convertedColor = color.usingColorSpace(.deviceRGB) else {
            assertionFailure("Failed to convert Isochrone contour color to RGB space.")
            return "000000"
        }
        
        return String(format: hexFormat,
                      Int(convertedColor.redComponent * 255),
                      Int(convertedColor.greenComponent * 255),
                      Int(convertedColor.blueComponent * 255))
        #else
        return String(format: hexFormat,
                      color.red,
                      color.green,
                      color.blue)
        #endif
    }
}
