import Foundation

@objc(MBBannerInstruction)
public class BannerInstruction: NSObject, NSSecureCoding {
    
    public let distanceAlongStep: CLLocationDistance

    public let primaryContent: BannerInstructionComponent?
    
    public let secondaryContent: [BannerInstructionComponent]?
    
    internal init(json: JSONDictionary) {
        distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        
        if let primaryTextDict = json["primaryText"] as? JSONDictionary {
            self.primaryContent = BannerInstructionComponent(json: primaryTextDict)
        } else {
            self.primaryContent = nil
        }
        
        secondaryContent = (json["secondaryText"] as? [JSONDictionary])?.map {
            BannerInstructionComponent(json: $0)
        }
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        primaryContent = decoder.decodeObject(of: [NSArray.self, BannerInstructionComponent.self], forKey: "primaryContent") as? BannerInstructionComponent
        secondaryContent = decoder.decodeObject(of: [NSArray.self, BannerInstructionComponent.self], forKey: "secondaryContent") as? [BannerInstructionComponent]
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(primaryContent, forKey: "primaryContent")
        coder.encode(secondaryContent, forKey: "secondaryContent")
    }
}
