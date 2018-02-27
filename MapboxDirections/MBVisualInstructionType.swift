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
     The component bears an exit number or the name of a place or street.
     */
    case text
    
    /**
     Component contains an icon that should be rendered.
     */
    case icon
    
    public init?(description: String) {
        let type: VisualInstructionComponentType
        switch description {
        case "delimiter":
            type = .delimiter
        case "icon":
            type = .icon
        case "text":
            type = .text
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .delimiter:
            return "delimiter"
        case .icon:
            return "icon"
        case .text:
            return "text"
        }
    }
}
