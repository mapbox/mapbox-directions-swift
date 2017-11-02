import Foundation


/**
 Contains necessary features to build a more rich visual experience for a `RouteStep`.
 */
@objc(MBVisualInstructionDetailComponent)
public class VisualInstructionDetailComponent: NSObject, NSSecureCoding {
    
    /**
     Single part of a visual instruction.
     */
    public let text: String?
    
    
    /**
     @1x PNG to inline in visual instruction.
     */
    public var imageURL1x: URL? = nil
    
    
    /**
     @2x PNG to inline in visual instruction.
     */
    public var imageURL2x: URL? = nil
    
    
    /**
     @3x PNG to inline in visual instruction.
     */
    public var imageURL3x: URL? = nil
    
    
    /**
     SVG to inline in visual instruction.
     */
    public var imageURLSVG: URL? = nil
    
    
    internal init(json: JSONDictionary) {
        text = json["text"] as? String
        
        if let baseURL = json["imageBaseURL"] as? String {
            imageURL1x = URL(string: "\(baseURL)@1x.png")
            imageURL2x = URL(string: "\(baseURL)@2x.png")
            imageURL3x = URL(string: "\(baseURL)@3x.png")
            imageURLSVG = URL(string: "\(baseURL).svg")
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        guard let imageURL1x = decoder.decodeObject(of: NSURL.self, forKey: "imageURL1x") as URL? else {
            return nil
        }
        self.imageURL1x = imageURL1x
        
        guard let imageURL2x = decoder.decodeObject(of: NSURL.self, forKey: "imageURL2x") as URL? else {
            return nil
        }
        self.imageURL2x = imageURL2x
        
        guard let imageURL3x = decoder.decodeObject(of: NSURL.self, forKey: "imageURL3x") as URL? else {
            return nil
        }
        self.imageURL3x = imageURL3x
        
        guard let imageURLSVG = decoder.decodeObject(of: NSURL.self, forKey: "imageURLSVG") as URL? else {
            return nil
        }
        self.imageURLSVG = imageURLSVG
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(imageURL1x, forKey: "imageURL1x")
        coder.encode(imageURL2x, forKey: "imageURL2x")
        coder.encode(imageURL3x, forKey: "imageURL3x")
        coder.encode(imageURLSVG, forKey: "imageURLSVG")
    }
}
