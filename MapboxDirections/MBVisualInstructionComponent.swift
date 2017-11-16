import Foundation

#if os(iOS) || os(tvOS)
    import UIKit
#endif


/**
 :nodoc:
 A component of a `VisualInstruction` that represents a single run of similarly formatted text or an image with a textual fallback representation.
 */
@objc(MBVisualInstructionComponent)
public class VisualInstructionComponent: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     The plain text representation of this component.
     
     Use this property if `imageURLs` is an empty dictionary or if the URLs contained in that property are not yet available.
     */
    public let text: String?
    
    /**
     :nodoc:
     Dictionary containing `UITraitCollection` for scales 1.0, 2.0 and 3.0. Each key's value is a `URL`.
     */
    #if os(iOS) || os(tvOS)
        /**
        A dictionary containing the URLs to image representations of this component.
     
        The keys of this dictionary are trait collections specifying different display scales. The values of this dictionary are URLs to remote images that you should prefer over the `text` property once they are available. Use the URL that is best suited to the system’s current traits.
        */
        public var imageURLs: [UITraitCollection: URL] = [:]
    #else
        /**
        A dictionary containing the URLs to image representations of this component.
     
        The keys of this dictionary are screen scale factors. The values of this dictionary are URLs to remote images that you should prefer over the `text` property once they are available. Use the URL that is best suited to the current screen’s scale factor.
        */
        public var imageURLs: [NSNumber: URL] = [:]
    #endif
    
    internal init(json: JSONDictionary) {
        text = json["text"] as? String
        
        if let baseURL = json["imageBaseURL"] as? String {
            let oneXURL = URL(string: "\(baseURL)@1x.png")
            let twoXURL = URL(string: "\(baseURL)@2x.png")
            let threeXURL = URL(string: "\(baseURL)@3x.png")
            
            #if os(iOS) || os(tvOS)
                imageURLs[UITraitCollection(displayScale: 1.0)] = oneXURL
                imageURLs[UITraitCollection(displayScale: 2.0)] = twoXURL
                imageURLs[UITraitCollection(displayScale: 3.0)] = threeXURL
            #else
                imageURLs[1] = oneXURL
                imageURLs[2] = twoXURL
                imageURLs[3] = threeXURL
            #endif
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        #if os(iOS) || os(tvOS)
            guard let imageURLs = decoder.decodeObject(of: [NSDictionary.self, UITraitCollection.self, NSURL.self], forKey: "imageURLs") as? [UITraitCollection: URL] else {
                return nil
            }
        #else
            guard let imageURLs = decoder.decodeObject(of: [NSDictionary.self, NSNumber.self, NSURL.self], forKey: "imageURLs") as? [NSNumber: URL] else {
                return nil
            }
        #endif
        
        self.imageURLs = imageURLs
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(imageURLs, forKey: "imageURLs")
    }
}
