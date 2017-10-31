import Foundation


@objc(MBVisualInstructionDetailComponent)
public class VisualInstructionDetailComponent: NSObject, NSSecureCoding {
    
    public let text: String?
    
    public let imageBaseURL: URL?
    
    internal init(json: JSONDictionary) {
        text = json["text"] as? String
        
        imageBaseURL = json["imageBaseURL"] as? URL
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        guard let imageBaseURL = decoder.decodeObject(of: NSURL.self, forKey: "imageBaseURL") as URL? else {
            return nil
        }
        self.imageBaseURL = imageBaseURL
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(imageBaseURL, forKey: "imageBaseURL")
    }
}
