import Foundation

/**
 `VisualInstructionComponentType` describes the type of `VisualInstructionComponent`.
 */

public enum VisualInstructionComponentType: String, Codable {
    
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
    case image = "icon"
    
    /**
     The compoment contains the localized word for "exit".
     
     This component may appear before or after an `.exitNumber` component, depending on the language.
     */
    case exit
    
    /**
     A component contains an exit number.
     */
    case exitCode = "exit-number"
    
    /**
    A component contains a lane.
     */
    case lane
    
}
