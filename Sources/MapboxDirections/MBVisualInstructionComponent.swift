#if os(OSX)
    import Cocoa
#elseif os(watchOS)
    import WatchKit
#else
    import UIKit
#endif

/**
 A component of a `VisualInstruction` that represents a single run of similarly formatted text or an image with a textual fallback representation.
 Note: This class does not conform to Codable because it's serialization is directly handled by `Component`
 */

open class VisualInstructionComponent: ComponentRepresentable {

    /**
    The URL to an image representation of this component.

    The URL refers to an image that uses the device’s native screen scale.
    */
    public var imageURL: URL?

    /**
     An abbreviated representation of the `text` property.
     */
    public var abbreviation: String?

    /**
     The priority for which the component should be abbreviated.

     A component with a lower abbreviation priority value should be abbreviated before a component with a higher abbreviation priority value.
     */
    public var abbreviationPriority: Int?

    /**
     The plain text representation of this component.

     Use this property if `imageURL` is `nil` or if the URL contained in that property is not yet available.
     */
    public var text: String?

    /**
     The type of visual instruction component. You can display the component differently depending on its type.
     */
    public var type: VisualInstructionComponentType
    
    public init(type: VisualInstructionComponentType, text: String?, imageURL: URL?, abbreviation: String?, abbreviationPriority: Int?) {
        self.text = text
        self.type = type
        self.imageURL = imageURL
        self.abbreviation = abbreviation
        self.abbreviationPriority = abbreviationPriority
    }
}
