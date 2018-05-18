import Foundation

#if os(OSX)
    import Cocoa
#elseif os(watchOS)
    import WatchKit
#else
    import UIKit
#endif

/**
 A component of a `VisualInstruction` that represents a single run of similarly formatted text or an image with a textual fallback representation.
 */
@objc(MBVisualInstructionComponent)
open class VisualInstructionComponent: NSObject, NSSecureCoding {
    
    /**
     The plain text representation of this component.
     
     Use this property if `imageURL` is `nil` or if the URL contained in that property is not yet available.
     */
    @objc public let text: String?
    
    /**
     The type of visual instruction component. You can display the component differently depending on its type.
     */
    @objc public var type: VisualInstructionComponentType
    
    /**
    The URL to an image representation of this component.
 
    The URL refers to an image that uses the device’s native screen scale.
    */
    @objc public var imageURL: URL?
    
    /**
     An abbreviated representation of the `text` property.
     */
    @objc public var abbreviation: String?
    
    /**
     The priority for which the component should be abbreviated.
     
     A component with a lower abbreviation priority value should be abbreviated before a component with a higher abbreviation priority value.
     */
    @objc public var abbreviationPriority: Int = NSNotFound
    
    /**
     An array indicating which directions you can go from a lane (left, right, or straight).
     
     If the value is `[.left", .straight]`, the driver can go straight or left from that lane. This is only set when the `component` is a lane.
     */
    @objc public var indications: LaneIndication
    
    /**
     The boolean that indicates whether the component is a lane and can be used to complete the upcoming maneuver.
     
     If multiple lanes are active, then they can all be used to complete the upcoming maneuver. This value is set to `false` by default.
     */
    @objc public var isLaneActive: Bool = false
    
    /**
     Initializes a new visual instruction component object based on the given JSON dictionary representation.
     
     - parameter json: A JSON object that conforms to the [banner component](https://www.mapbox.com/api-documentation/#banner-instruction-object) format described in the Directions API documentation.
     */
    @objc(initWithJSON:)
    public convenience init(json: [String: Any]) {
        let text = json["text"] as? String
        let type = VisualInstructionComponentType(description: json["type"] as? String ?? "") ?? .text
        
        let abbreviation = json["abbr"] as? String
        let abbreviationPriority = json["abbr_priority"] as? Int ?? NSNotFound
        
        var imageURL: URL?
        if let baseURL = json["imageBaseURL"] as? String {
            let scale: CGFloat
            #if os(OSX)
                scale = NSScreen.main?.backingScaleFactor ?? 1
            #elseif os(watchOS)
                scale = WKInterfaceDevice.current().screenScale
            #else
                scale = UIScreen.main.scale
            #endif
            imageURL = URL(string: "\(baseURL)@\(Int(scale))x.png")
        }
        
        var isLaneActive = false
        if let active = json["active"] as? Bool {
            isLaneActive = active
        }
        
        var indications = LaneIndication()
        if let directions = json["directions"] as? [String],
            let laneIndications = LaneIndication(descriptions: directions) {
            indications = laneIndications
        }
        
        self.init(type: type, text: text, imageURL: imageURL, abbreviation: abbreviation, abbreviationPriority: abbreviationPriority, indications: indications, isLaneActive: isLaneActive)
    }
    
    /**
     Initializes a new visual instruction component object that displays the given information.
     
     - parameter type: The type of visual instruction component.
     - parameter text: The plain text representation of this component.
     - parameter imageURL: The URL to an image representation of this component.
     - parameter abbreviation: An abbreviated representation of `text`.
     - parameter abbreviationPriority: The priority for which the component should be abbreviated.
     - parameter indications: The possibile directions to go from a lane component.
     - parameter isLaneActive: The flag to indicate that the upcoming maneuver can be completed with a lane component.
     */
    @objc public init(type: VisualInstructionComponentType, text: String?, imageURL: URL?, abbreviation: String?, abbreviationPriority: Int, indications: LaneIndication = LaneIndication(), isLaneActive: Bool = false) {
        self.text = text
        self.imageURL = imageURL
        self.type = type
        self.abbreviation = abbreviation
        self.abbreviationPriority = abbreviationPriority
        self.indications = indications
        self.isLaneActive = isLaneActive
    }

    @objc public required init?(coder decoder: NSCoder) {
        
        self.text = decoder.decodeObject(of: NSString.self, forKey: "text") as String?
        
        guard let imageURL = decoder.decodeObject(of: NSURL.self, forKey: "imageURL") as URL? else {
            return nil
        }
        self.imageURL = imageURL
        
        guard let typeString = decoder.decodeObject(of: NSString.self, forKey: "type") as String?, let type = VisualInstructionComponentType(description: typeString) else {
                return nil
        }
        self.type = type
        
        guard let abbreviation = decoder.decodeObject(of: NSString.self, forKey: "abbreviation") as String? else {
            return nil
        }
        self.abbreviation = abbreviation
        
        abbreviationPriority = decoder.decodeInteger(forKey: "abbreviationPriority")
        
        guard let directions = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "directions") as? [String] else {
            return nil
        }
        
        self.indications = LaneIndication(descriptions: directions) ?? LaneIndication()
        
        self.isLaneActive = decoder.decodeObject(forKey: "active") as? Bool ?? false
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(imageURL, forKey: "imageURL")
        coder.encode(type, forKey: "type")
        coder.encode(abbreviation, forKey: "abbreviation")
        coder.encode(abbreviationPriority, forKey: "abbreviationPriority")
        coder.encode(indications, forKey: "directions")
        coder.encode(isLaneActive, forKey: "active")
    }
}

