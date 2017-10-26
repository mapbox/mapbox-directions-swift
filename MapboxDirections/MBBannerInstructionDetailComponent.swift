import Foundation


@objc(MBBannerInstructionDetailComponent)
public class BannerInstructionDetailComponent: NSObject, NSSecureCoding {
    
    public let text: String
    
    internal init(json: JSONDictionary) {
        text = json["text"] as! String
    }
    
    public required init?(coder decoder: NSCoder) {
        guard let text = decoder.decodeObject(of: NSString.self, forKey: "text") as String? else {
            return nil
        }
        self.text = text
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
    }
}
