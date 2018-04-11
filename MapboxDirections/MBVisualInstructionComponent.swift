import Foundation

#if os(OSX)
    import Cocoa
#elseif os(watchOS)
    import WatchKit
#else
    import UIKit
#endif

/**
 :nodoc:
 A component of a `VisualInstruction` that represents a single run of similarly formatted text or an image with a textual fallback representation.
 */
@objc(MBVisualInstructionComponent)
open class VisualInstructionComponent: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     The plain text representation of this component.
     
     Use this property if `imageURLs` is an empty dictionary or if the URLs contained in that property are not yet available.
     */
    @objc public let text: String?
    
    /**
     :nodoc:
     The type of visual instruction component. You can display the component differently depending on its type.
     */
    @objc public var type: VisualInstructionComponentType
    
    /**
     :nodoc:
    The URL to an image representation of this component.
 
    The URL refers to an image that uses the device’s native screen scale.
    */
    @objc public var imageURL: URL?
    
    /**
     An abbreviated version of the text for a given component.
     */
    @objc public var abbreviation: String?
    
    /**
     The priority in which the component should be abbreviated. Lower numbers should be abbreviated first.
     */
    @objc public var abbreviationPriority: Int = NSNotFound
    
    /**
     :nodoc:
     Initialize A `VisualInstructionComponent`.
     */
    @objc public convenience init(json: [String: Any]) {
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
        
        self.init(type: type, text: text, imageURL: imageURL, abbreviation: abbreviation, abbreviationPriority: abbreviationPriority)
    }
    
    /**
     :nodoc:
     Initialize A `VisualInstructionComponent`.
     */
    @objc public init(type: VisualInstructionComponentType, text: String?, imageURL: URL?, abbreviation: String?, abbreviationPriority: Int) {
        self.text = text
        self.imageURL = imageURL
        self.type = type
        self.abbreviation = abbreviation
        self.abbreviationPriority = abbreviationPriority
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
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(imageURL, forKey: "imageURL")
        coder.encode(type, forKey: "type")
        coder.encode(abbreviation, forKey: "abbreviation")
        coder.encode(abbreviationPriority, forKey: "abbreviationPriority")
    }
}

