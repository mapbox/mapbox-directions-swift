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
 Contains necessary features to build a more rich visual experience for a `RouteStep`.
 */
@objc(MBVisualInstructionDetailComponent)
public class VisualInstructionDetailComponent: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Single part of a visual instruction.
     */
    public let text: String?
    
    /**
     :nodoc:
     Dictionary containing `UITraitCollection` for scales 1.0, 2.0 and 3.0. Each key's value is a `URL`.
     */
    public var imageURLS: [UITraitCollection: URL] = [:]
    
    internal init(json: JSONDictionary) {
        text = json["text"] as? String
        
        if let baseURL = json["imageBaseURL"] as? String {
            imageURLS[UITraitCollection(displayScale: 1.0)] = URL(string: "\(baseURL)@1x.png")
            imageURLS[UITraitCollection(displayScale: 2.0)] = URL(string: "\(baseURL)@2x.png")
            imageURLS[UITraitCollection(displayScale: 3.0)] = URL(string: "\(baseURL)@3x.png")
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        guard let imageURLS = decoder.decodeObject(of: [NSDictionary.self, UITraitCollection.self, NSURL.self], forKey: "imageURLS") as? [UITraitCollection: URL] else {
                return nil
        }
        self.imageURLS = imageURLS
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(imageURLS, forKey: "imageURLS")
    }
}
