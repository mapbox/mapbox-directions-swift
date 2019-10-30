import Foundation
import CoreGraphics

#if os(OSX)
import Cocoa
#elseif os(watchOS)
import WatchKit
#else
import UIKit
#endif

/**
The component representable protocol that comprises what the instruction banner should display.
 */
public enum Component: Equatable {
    case lane(_ component: LaneIndicationComponent)
    case visual(_ component: VisualInstructionComponent)
    
    public static func == (lhs: Component, rhs: Component) -> Bool {
        switch lhs {
        case let .lane(left):
            switch rhs {
            case let .lane(right):
                return left == right
            default:
                return false
            }
        case let .visual(left):
            switch rhs {
            case let .visual(right):
                return left == right
            default:
                return false
            }
        }
    }
}

internal struct ComponentSerializer: Codable {
    let component: Component
    
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
    init(component: Component) {
        self.component = component
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch component {
        case let .lane(lane):
            try container.encode(lane.indications, forKey: .directions)
            try container.encode(lane.isUsable, forKey: .isActive)
            try container.encode(VisualInstructionComponentType.lane, forKey: .type)
        case let .visual(instruction):
             try container.encodeIfPresent(instruction.text, forKey: .text)
             try container.encodeIfPresent(instruction.abbreviation, forKey: .abbreviatedText)
             try container.encodeIfPresent(instruction.abbreviationPriority, forKey: .abbreviatedTextPriority)
             try container.encodeIfPresent(instruction.imageURL, forKey: .imageURL)
             try container.encode(instruction.type, forKey: .type)
        }
        
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(VisualInstructionComponentType.self, forKey: .type)
        
        switch type {
        case .lane:
            let indications = try container.decode(LaneIndication.self, forKey: .directions)
            let isUsable = try container.decode(Bool.self, forKey: .isActive)
            let comp = LaneIndicationComponent(indications: indications, isUsable: isUsable)
            component = .lane(comp)
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
            let comp = VisualInstructionComponent(type: type, text: text, imageURL: imageURL, abbreviation: abbreviatedText, abbreviationPriority: abbreviationPriority)
            component = .visual(comp)
        }

    }
}
