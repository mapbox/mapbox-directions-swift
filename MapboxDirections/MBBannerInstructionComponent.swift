import Foundation


@objc(MBBannerInstructionComponent)
public class BannerInstructionComponent: NSObject, NSSecureCoding {
    
    public let text: String
    
    public let components: [BannerInstructionDetailComponent]
    
    internal init(json: JSONDictionary) {
        text = json["text"] as! String
        
        components = (json["components"] as! [JSONDictionary]).map {
            BannerInstructionDetailComponent(json: $0)
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        components = decoder.decodeObject(of: [NSArray.self, BannerInstructionDetailComponent.self], forKey: "components") as? [BannerInstructionDetailComponent] ?? []
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(components, forKey: "components")
    }
}
