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
    The URL to an image representation of this component.
 
    The URL refers to an image that uses the device’s native screen scale.
    */
    @objc public var imageURL: URL?
    
    
    /**
     :nodoc:
     `Bool` whether the `VisualInstructionComponent` should be visualized as a delimiter between two text components.
     */
    @objc public var isDelimiter: Bool
    
    /**
     :nodoc:
     Initialize A `VisualInstructionComponent`.
     */
    @objc public convenience init(json: [String: Any]) {
        let text = json["text"] as? String
        let isDelimiter = json["delimiter"] as? Bool ?? false
        
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
        
        self.init(text: text, imageURL: imageURL, isDelimiter: isDelimiter)
    }
    
    /**
     :nodoc:
     Initialize A `VisualInstructionComponent`.
     */
    @objc public init(text: String?, imageURL: URL?, isDelimiter: Bool) {
        self.text = text
        self.imageURL = imageURL
        self.isDelimiter = isDelimiter
    }

    @objc public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        guard let imageURL = decoder.decodeObject(of: NSURL.self, forKey: "imageURL") as URL? else {
            return nil
        }
        self.imageURL = imageURL
        
        self.isDelimiter = decoder.decodeBool(forKey: "isDelimiter")
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(imageURL, forKey: "imageURL")
        coder.encode(isDelimiter, forKey: "isDelimiter")
    }
}
