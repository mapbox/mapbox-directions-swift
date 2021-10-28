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
    
    public init(centerCoordinate: LocationCoordinate2D, contours: Contours, profileIdentifier: IsochroneProfileIdentifier = .automobile) {
        self.centerCoordinate = centerCoordinate
        self.contours = contours
        self.profileIdentifier = profileIdentifier
    }
    
    // MARK: Configuring the Contour
    
    /**
     Contours GeoJSON format.
     */
    public enum ContourFormat {
        /**
         Requested contour will be presented as GeoJSON LineString.
         */
        case lineString
        /**
         Requested contour will be presented as GeoJSON Polygon.
         */
        case polygon
    }
    
    /**
     A string specifying the primary mode of transportation for the contours.

     The default value of this property is `IsochroneProfileIdentifier.automobile`, which specifies driving directions.
     */
    public var profileIdentifier: IsochroneProfileIdentifier
    /**
     A coordinate around which to center the isochrone lines.
     */
    public var centerCoordinate: LocationCoordinate2D
    /**
     Contours bounds and color sheme definition.
     */
    public var contours: Contours
    
    /**
     Specifies the format of output contours.
     
     Defaults to `.lineString` which represents contours as linestrings.
     */
    public var contoursFormat: ContourFormat = .lineString
    
    /**
     Removes contours which are `denoisingFactor` times smaller than the biggest one.
     
     The default is 1.0. A value of 1.0 will only return the largest contour for a given value. A value of 0.5 drops any contours that are less than half the area of the largest contour in the set of contours for that same value.
     */
    public var denoisingFactor: Float?
    
    /**
     Douglas-Peucker simplification tolerance.
     
     Higher means simpler geometries and faster performance. There is no upper bound. If no value is specified in the request, the Isochrone API will choose the most optimized value to use for the request.
     
     - note: Simplification of contours can lead to self-intersections, as well as intersections of adjacent contours.
     */
    public var simplificationTolerance: LocationDistance?
    
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
        return "\(abridgedPath)/\(centerCoordinate.requestDescription).json"
    }
    
    /**
     An array of URL query items (parameters) to include in an HTTP request.
     */
    public var urlQueryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        switch contours {
        case .byDistances(let definition):
            let (values, colors) = definition.serialize(roundingTo: .meters)
            
            queryItems.append(URLQueryItem(name: "contours_meters", value: values))
            if let colors = colors {
                queryItems.append(URLQueryItem(name: "contours_colors", value: colors))
            }
        case .byExpectedTravelTimes(let definition):
            let (values, colors) = definition.serialize(roundingTo: .minutes)
            
            queryItems.append(URLQueryItem(name: "contours_minutes", value: values))
            if let colors = colors {
                queryItems.append(URLQueryItem(name: "contours_colors", value: colors))
            }
        }
        
        if contoursFormat == .polygon {
            queryItems.append(URLQueryItem(name: "polygons", value: "true"))
        }
        
        if let denoise = denoisingFactor {
            queryItems.append(URLQueryItem(name: "denoise", value: String(denoise)))
        }
        
        if let tolerance = simplificationTolerance {
            queryItems.append(URLQueryItem(name: "generalize", value: String(tolerance)))
        }
        
        return queryItems
    }
}

extension IsochroneOptions {
    
    /**
     Definition of contours limits.
     */
    public enum Contours {
        
        /**
         Describes Individual contour bound and color.
         */
        public enum ContourDefinition<Unt: Dimension> {
            /**
             Contour bound definition value.
             */
            public typealias Value = Measurement<Unt>
            /**
             Contour bound definition value and contour color.
             */
            public typealias ValueAndColor = (value: Value, color: Color)
            
            /**
             Allows configuring just the bound, leaving coloring to a default rainbow scheme.
             */
            case `default`([Value])
            /**
             Allows configuring both the bound and contour color.
             */
            case colored([ValueAndColor])
            
            func serialize(roundingTo unit: Unt) -> (String, String?) {
                switch (self) {
                case .default(let intervals):
                    
                    return (intervals.map { String(Int($0.converted(to: unit).value.rounded())) }.joined(separator: ";"), nil)
                case .colored(let intervals):
                    let sorted = intervals.sorted { lhs, rhs in
                        lhs.value < rhs.value
                    }
                    
                    let values = sorted.map { String(Int($0.value.converted(to: unit).value.rounded())) }.joined(separator: ";")
                    let colors = sorted.map(\.color.queryDescription).joined(separator: ";")
                    return (values, colors)
                }
            }
        }
        
        /**
         The desired travel times to use for each isochrone contour.
         
         This value will be rounded to minutes.
         */
        case byExpectedTravelTimes(ContourDefinition<UnitDuration>)
        
        /**
         The distances to use for each isochrone contour.
         
         Will be rounded to meters.
         */
        case byDistances(ContourDefinition<UnitLength>)
    }
}

extension IsochroneOptions {
    #if canImport(UIKit)
    /**
     RGB-based color representation for Isochrone contour.
     */
    public typealias Color = UIColor
    #elseif canImport(AppKit)
    /**
     RGB-based color representation for Isochrone contour.
     */
    public typealias Color = NSColor
    #else
    /**
     sRGB color space representation for Isochrone contour.
     
     This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack `UIKit` or `AppKit`. On Apple platforms, you can use `UIColor` or `NSColor` respectively anywhere you see this type.
     */
    public struct Color {
        /**
         Red color component.
         
         Value ranged from `0` up to `255`.
         */
        public var red: Int
        /**
         Green color component.
         
         Value ranged from `0` up to `255`.
         */
        public var green: Int
        /**
         Blue color component.
         
         Value ranged from `0` up to `255`.
         */
        public var blue: Int
        
        /**
         Creates new `Color` instance.
         */
        public init(red: Int, green: Int, blue: Int) {
            self.red = red
            self.green = green
            self.blue = blue
        }
    }
    #endif
}

extension IsochroneOptions.Color {
    var queryDescription: String {
        let hexFormat = "%02X%02X%02X"
        
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        getRed(&red,
               green: &green,
               blue: &blue,
               alpha: nil)
        
        return String(format: hexFormat,
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
        #elseif canImport(AppKit)
        var convertedColor = self
        if colorSpace != .sRGB {
            guard let converted = usingColorSpace(.sRGB) else {
                assertionFailure("Failed to convert Isochrone contour color to RGB space.")
                return "000000"
            }
            
            convertedColor = converted
        }
        
        return String(format: hexFormat,
                      Int(convertedColor.redComponent * 255),
                      Int(convertedColor.greenComponent * 255),
                      Int(convertedColor.blueComponent * 255))
        #else
        return String(format: hexFormat,
                      red,
                      green,
                      blue)
        #endif
    }
}
