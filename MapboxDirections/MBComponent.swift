import Foundation
/**
The component protocol that comprises what the instruction banner should display.
 */
@objc(MBComponent)
public protocol Component: class, NSSecureCoding {
    /**
     The plain text representation of this component.
     */
    @objc var text: String? { get }
    
    /**
     The type of visual instruction component. You can display the component differently depending on its type.
     */
    @objc var type: VisualInstructionComponentType { get }
}
