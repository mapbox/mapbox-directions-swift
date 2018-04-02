import Foundation

/**
 `VisualInstructionComponentType` describes the type of `VisualInstructionComponent`.
 */
@objc(MBVisualInstructionComponentType)
public enum VisualInstructionComponentType: Int, CustomStringConvertible {
    
    /**
     The component separates two other destination components.
     
     If the two adjacent components are both displayed as images, you can hide this delimiter component.
     */
    case delimiter
    
    /**
     The component bears the name of a place or street.
     */
    case text
    
    /**
     Component contains an image that should be rendered.
     */
    case image
    
    /**
     The compoment contains the localized word for "exit".
     */
    case exit
    
    /**
     A component contains an exit number.
     */
    case exitNumber
    
    public init?(description: String) {
        let type: VisualInstructionComponentType
        switch description {
        case "delimiter":
            type = .delimiter
        case "icon":
            type = .image
        case "text":
            type = .text
        case "exit":
            type = .exit
        case "exit-number":
            type = .exitNumber
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .delimiter:
            return "delimiter"
        case .image:
            return "icon"
        case .text:
            return "text"
        case .exit:
            return "exit"
        case .exitNumber:
            return "exit-number"
        }
    }
}
