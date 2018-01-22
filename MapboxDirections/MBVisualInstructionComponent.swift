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
open class VisualInstructionComponent: NSObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case text
        case imageBaseURL
    }
    
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
    @objc public var imageURL: URL? {
        guard let baseURL = imageBaseURL else {
            return nil
        }
        let scale: CGFloat
        #if os(OSX)
            scale = NSScreen.main?.backingScaleFactor ?? 1
        #elseif os(watchOS)
            scale = WKInterfaceDevice.current().screenScale
        #else
            scale = UIScreen.main.scale
        #endif
        return URL(string: "\(baseURL)@\(Int(scale))x.png")
    }
    
    var imageBaseURL: String?
    
    /**
     Initializes a `VisualInstructionComponent`.
     */
    public init(text: String? = nil, imageBaseURL: String? = nil) {
        self.text = text
        self.imageBaseURL = imageBaseURL
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(imageBaseURL, forKey: .imageBaseURL)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        imageBaseURL = try container.decodeIfPresent(String.self, forKey: .imageBaseURL)
    }
}
