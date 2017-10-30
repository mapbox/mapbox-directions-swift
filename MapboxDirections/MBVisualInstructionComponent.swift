import Foundation


@objc(MBVisualInstructionComponent)
public class VisualInstructionComponent: NSObject, NSSecureCoding {
    
    public let text: String
    
    public let components: [VisualInstructionDetailComponent]
    
    internal init(json: JSONDictionary) {
        text = json["text"] as! String
        
        components = (json["components"] as! [JSONDictionary]).map {
            VisualInstructionDetailComponent(json: $0)
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
        
        components = decoder.decodeObject(of: [NSArray.self, VisualInstructionDetailComponent.self], forKey: "components") as? [VisualInstructionDetailComponent] ?? []
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(components, forKey: "components")
    }
}
