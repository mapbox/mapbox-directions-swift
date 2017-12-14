import Foundation

/**
 `VisualInstructionComponentType` describes the type of `VisualInstructionComponent`.
 */
@objc(MBVisualInstructionComponentType)
public enum VisualInstructionComponentType: Int, CustomStringConvertible {
    
    /**
     Text is a delimiter.
     */
    case delimiter
    
    /**
     Text is a way name.
     */
    case destination
    
    public init?(description: String) {
        let level: VisualInstructionComponentType
        switch description {
        case "delimiter":
            level = .delimiter
        case "destination":
            level = .destination
        default:
            return nil
        }
        self.init(rawValue: level.rawValue)
    }
    
    public var description: String {
        switch self {
        case .delimiter:
            return "delimiter"
        case .destination:
            return "destination"
        }
    }
}
