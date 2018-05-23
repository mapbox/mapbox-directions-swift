import Foundation

/**
The parent component that comprises what should be displayed in the instruction banner.
 */
@objc(MBComponent)
open class Component: NSObject, NSSecureCoding {
    
    open static var supportsSecureCoding: Bool = true
    
    /**
     The plain text representation of this component.
     */
    @objc public let text: String?
    
    /**
     The type of visual instruction component. You can display the component differently depending on its type.
     */
    @objc public var type: VisualInstructionComponentType
    
    /**
     Initializes a new component object that displays the given information.
     
     - parameter type: The type of visual instruction component.
     - parameter text: The plain text representation of this component.
     */
    @objc public init(text: String?, type: VisualInstructionComponentType) {
        self.text = text
        self.type = type
    }
    
    @objc public required init?(coder decoder: NSCoder) {
       self.text = decoder.decodeObject(of: NSString.self, forKey: "text") as String?
        
        guard let typeString = decoder.decodeObject(of: NSString.self, forKey: "type") as String?, let type = VisualInstructionComponentType(description: typeString) else {
            return nil
        }
        self.type = type
    }
    
    @objc public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(type, forKey: "type")
    }
}
