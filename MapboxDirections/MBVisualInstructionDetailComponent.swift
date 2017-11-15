import Foundation

#if os(iOS) || os(tvOS)
    import UIKit
#endif


/**
 :nodoc:
 Contains necessary features to build a more rich visual experience for a `RouteStep`.
 */
@objc(MBVisualInstructionComponent)
public class VisualInstructionComponent: NSObject, NSSecureCoding {
    
    /**
     :nodoc:
     Single part of a visual instruction.
     */
    public let text: String?
    
    /**
     :nodoc:
     Dictionary containing `UITraitCollection` for scales 1.0, 2.0 and 3.0. Each key's value is a `URL`.
     */
    #if os(iOS) || os(tvOS)
        public var imageURLS: [UITraitCollection: URL] = [:]
    #else
        public var imageURLS: [NSNumber: URL] = [:]
    #endif
    
    internal init(json: JSONDictionary) {
        text = json["text"] as? String
        
        if let baseURL = json["imageBaseURL"] as? String {
            let oneXURL = URL(string: "\(baseURL)@1x.png")
            let twoXURL = URL(string: "\(baseURL)@2x.png")
            let threeXURL = URL(string: "\(baseURL)@3x.png")
            
            #if os(iOS) || os(tvOS)
                imageURLS[UITraitCollection(displayScale: 1.0)] = oneXURL
                imageURLS[UITraitCollection(displayScale: 2.0)] = twoXURL
                imageURLS[UITraitCollection(displayScale: 3.0)] = threeXURL
            #else
                imageURLS[1] = oneXURL
                imageURLS[2] = twoXURL
                imageURLS[3] = threeXURL
            #endif
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        #if os(iOS) || os(tvOS)
            guard let imageURLS = decoder.decodeObject(of: [NSDictionary.self, UITraitCollection.self, NSURL.self], forKey: "imageURLS") as? [UITraitCollection: URL] else {
                return nil
            }
        #else
            guard let imageURLS = decoder.decodeObject(of: [NSDictionary.self, NSNumber.self, NSURL.self], forKey: "imageURLS") as? [NSNumber: URL] else {
                return nil
            }
        #endif
        
        self.imageURLS = imageURLS
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(imageURLS, forKey: "imageURLS")
    }
}
