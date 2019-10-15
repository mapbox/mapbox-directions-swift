import Foundation
import UIKit
import CoreGraphics

/**
The component representable protocol that comprises what the instruction banner should display.
 */

public protocol ComponentRepresentable: class { }

internal struct Component: Codable {
    let component: ComponentRepresentable
    
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case abbreviatedText = "abbr"
        case abbreviatedTextPriority = "abbr_priority"
        case imageBaseURL
        case imageURL
        case directions
        case isActive = "active"
    }
    init(component: ComponentRepresentable) {
        self.component = component
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let lane = component as? LaneIndicationComponent {
            try container.encode(lane.indications, forKey: .directions)
            try container.encode(lane.isUsable, forKey: .isActive)
        } else if let instruction = component as? VisualInstructionComponent {
            try container.encodeIfPresent(instruction.text, forKey: .text)
            try container.encodeIfPresent(instruction.abbreviation, forKey: .abbreviatedText)
            try container.encodeIfPresent(instruction.abbreviationPriority, forKey: .abbreviatedTextPriority)
            try container.encodeIfPresent(instruction.imageURL, forKey: .imageURL)
            
        }
        
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(VisualInstructionComponentType.self, forKey: .type)
        
        switch type {
        case .lane:
            let indications = try container.decode(LaneIndication.self, forKey: .directions)
            let isUsable = try container.decode(Bool.self, forKey: .isActive)
            component = LaneIndicationComponent(indications: indications, isUsable: isUsable)
        default:
            let text = try container.decode(String.self, forKey: .text)
            let abbreviatedText = try container.decodeIfPresent(String.self, forKey: .abbreviatedText)
            var imageURL: URL?
            if let generatedURL = try container.decodeIfPresent(String.self, forKey: .imageURL) {
                imageURL = URL(string: generatedURL)
                
            } else if let imageBaseURL = try container.decodeIfPresent(String.self, forKey: .imageBaseURL), !imageBaseURL.isEmpty {
                let scale: CGFloat
                    #if os(OSX)
                        scale = NSScreen.main?.backingScaleFactor ?? 1
                    #elseif os(watchOS)
                        scale = WKInterfaceDevice.current().screenScale
                    #else
                        scale = UIScreen.main.scale
                    #endif
                    imageURL = URL(string: "\(imageBaseURL)@\(Int(scale))x.png")
            }
            let abbreviationPriority = try container.decodeIfPresent(Int.self, forKey: .abbreviatedTextPriority)
            component = VisualInstructionComponent(type: type, text: text, imageURL: imageURL, abbreviation: abbreviatedText, abbreviationPriority: abbreviationPriority)
        }

    }
}
