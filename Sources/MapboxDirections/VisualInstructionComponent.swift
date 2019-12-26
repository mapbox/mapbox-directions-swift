import Foundation
import CoreGraphics

#if os(macOS)
import Cocoa
#elseif os(watchOS)
import WatchKit
#else
import UIKit
#endif

public extension VisualInstruction {
    /**
     A unit of information displayed to the user as part of a `VisualInstruction`.
     */
    enum Component {
        /**
         The component separates two other destination components.
         
         If the two adjacent components are both displayed as images, you can hide this delimiter component.
         */
        case delimiter(text: TextRepresentation)
        
        /**
         The component bears the name of a place or street.
         */
        case text(text: TextRepresentation)
        
        /**
         The component is an image, such as a [route marker](https://en.wikipedia.org/wiki/Highway_shield), with a fallback text representation.
         
         - parameter image: The component’s preferred image representation.
         - parameter alternativeText: The component’s alternative text representation. Use this representation if the image representation is unavailable or unusable, but consider formatting the text in a special way to distinguish it from an ordinary `.text` component.
         */
        case image(image: ImageRepresentation, alternativeText: TextRepresentation)
        
        /**
         The compoment contains the localized word for “Exit”.
         
         This component may appear before or after an `.exitCode` component, depending on the language. You can hide this component if the adjacent `.exitCode` component has an obvious exit-number appearance, for example with an accompanying [motorway exit icon](https://commons.wikimedia.org/wiki/File:Sinnbild_Autobahnausfahrt.svg).
         */
        case exit(text: TextRepresentation)
        
        /**
         The component contains an exit number.
         
         You can hide the adjacent `.exit` component in favor of giving this component an obvious exit-number appearance, for example by pairing it with a [motorway exit icon](https://commons.wikimedia.org/wiki/File:Sinnbild_Autobahnausfahrt.svg).
         */
        case exitCode(text: TextRepresentation)
        
        /**
         A component that represents a turn lane or through lane at the approach to an intersection.
         
         - parameter indications: The direction or directions of travel that the lane is reserved for.
         - parameter isUsable: Whether the user can use this lane to continue along the current route.
         */
        case lane(indications: LaneIndication, isUsable: Bool)
    }
}

public extension VisualInstruction.Component {
    /**
     A textual representation of a visual instruction component.
     */
    struct TextRepresentation: Equatable {
        /**
         Initializes a text representation bearing the given abbreviatable text.
         */
        public init(text: String, abbreviation: String?, abbreviationPriority: Int?) {
            self.text = text
            self.abbreviation = abbreviation
            self.abbreviationPriority = abbreviationPriority
        }
        
        /**
         The plain text representation of this component.
         */
        public let text: String
        
        /**
         An abbreviated representation of the `text` property.
         */
        public let abbreviation: String?
        
        /**
         The priority for which the component should be abbreviated.
         
         A component with a lower abbreviation priority value should be abbreviated before a component with a higher abbreviation priority value.
         */
        public let abbreviationPriority: Int?
    }

    /**
     An image representation of a visual instruction component.
     */
    struct ImageRepresentation: Equatable {
        /**
         File formats of visual instruction component images.
         */
        public enum Format: String {
            /// Portable Network Graphics (PNG)
            case png
            /// Scalable Vector Graphics (SVG)
            case svg
        }
        
        /**
         Initializes an image representation bearing the image at the given base URL.
         */
        public init(imageBaseURL: URL?) {
            self.imageBaseURL = imageBaseURL
        }
        
        /**
         The URL whose path is the prefix of all the possible URLs returned by `imageURL(scale:format:)`.
         */
        public let imageBaseURL: URL?
        
        /**
         Returns a remote URL to the image file that represents the component.
         
         - parameter scale: The image’s scale factor. If this argument is unspecified, the current screen’s native scale factor is used. Only the values 1, 2, and 3 are currently supported.
         - parameter format: The file format of the image. If this argument is unspecified, PNG is used.
         - returns: A remote URL to the image.
         */
        public func imageURL(scale: CGFloat? = nil, format: Format = .png) -> URL? {
            guard let imageBaseURL = imageBaseURL,
                var imageURLComponents = URLComponents(url: imageBaseURL, resolvingAgainstBaseURL: false) else {
                return nil
            }
            imageURLComponents.path += "@\(Int(scale ?? ImageRepresentation.currentScale))x.\(format)"
            return imageURLComponents.url
        }
        
        /**
         Returns the current screen’s native scale factor.
         */
        static var currentScale: CGFloat {
            let scale: CGFloat
            #if os(macOS)
            scale = NSScreen.main?.backingScaleFactor ?? 1
            #elseif os(watchOS)
            scale = WKInterfaceDevice.current().screenScale
            #else
            scale = UIScreen.main.scale
            #endif
            return scale
        }
    }
}

extension VisualInstruction.Component: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind = "type"
        case text
        case abbreviatedText = "abbr"
        case abbreviatedTextPriority = "abbr_priority"
        case imageBaseURL
        case directions
        case isActive = "active"
    }
    
    enum Kind: String, Codable {
        case delimiter
        case text
        case image = "icon"
        case exit
        case exitCode = "exit-number"
        case lane
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = (try? container.decode(Kind.self, forKey: .kind)) ?? .text
        
        if kind == .lane {
            let indications = try container.decode(LaneIndication.self, forKey: .directions)
            let isUsable = try container.decode(Bool.self, forKey: .isActive)
            self = .lane(indications: indications, isUsable: isUsable)
            return
        }
        
        let text = try container.decode(String.self, forKey: .text)
        let abbreviation = try container.decodeIfPresent(String.self, forKey: .abbreviatedText)
        let abbreviationPriority = try container.decodeIfPresent(Int.self, forKey: .abbreviatedTextPriority)
        let textRepresentation = TextRepresentation(text: text, abbreviation: abbreviation, abbreviationPriority: abbreviationPriority)
        
        switch kind {
        case .delimiter:
            self = .delimiter(text: textRepresentation)
        case .text:
            self = .text(text: textRepresentation)
        case .image:
            var imageBaseURL: URL?
            if let imageBaseURLString = try container.decodeIfPresent(String.self, forKey: .imageBaseURL) {
                imageBaseURL = URL(string: imageBaseURLString)
            }
            let imageRepresentation = ImageRepresentation(imageBaseURL: imageBaseURL)
            self = .image(image: imageRepresentation, alternativeText: textRepresentation)
        case .exit:
            self = .exit(text: textRepresentation)
        case .exitCode:
            self = .exitCode(text: textRepresentation)
        case .lane:
            preconditionFailure("Lane component should have been initialized before decoding text")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let textRepresentation: TextRepresentation?
        switch self {
        case .delimiter(let text):
            try container.encode(Kind.delimiter, forKey: .kind)
            textRepresentation = text
        case .text(let text):
            try container.encode(Kind.text, forKey: .kind)
            textRepresentation = text
        case .image(let image, let alternativeText):
            try container.encode(Kind.image, forKey: .kind)
            textRepresentation = alternativeText
            try container.encodeIfPresent(image.imageBaseURL?.absoluteString, forKey: .imageBaseURL)
        case .exit(let text):
            try container.encode(Kind.exit, forKey: .kind)
            textRepresentation = text
        case .exitCode(let text):
            try container.encode(Kind.exitCode, forKey: .kind)
            textRepresentation = text
        case .lane(let indications, let isUsable):
            try container.encode(Kind.lane, forKey: .kind)
            textRepresentation = .init(text: "", abbreviation: nil, abbreviationPriority: nil)
            try container.encode(indications, forKey: .directions)
            try container.encode(isUsable, forKey: .isActive)
        }
        
        if let textRepresentation = textRepresentation {
            try container.encodeIfPresent(textRepresentation.text, forKey: .text)
            try container.encodeIfPresent(textRepresentation.abbreviation, forKey: .abbreviatedText)
            try container.encodeIfPresent(textRepresentation.abbreviationPriority, forKey: .abbreviatedTextPriority)
        }
    }
}

extension VisualInstruction.Component: Equatable {
    public static func ==(lhs: VisualInstruction.Component, rhs: VisualInstruction.Component) -> Bool {
        switch (lhs, rhs) {
        case (let .delimiter(lhsText), let .delimiter(rhsText)),
             (let .text(lhsText), let .text(rhsText)),
             (let .exit(lhsText), let .exit(rhsText)),
             (let .exitCode(lhsText), let .exitCode(rhsText)):
            return lhsText == rhsText
        case (let .image(lhsURL, lhsAlternativeText),
              let .image(rhsURL, rhsAlternativeText)):
            return lhsURL == rhsURL
                && lhsAlternativeText == rhsAlternativeText
        case (let .lane(lhsIndications, lhsIsUsable),
              let .lane(rhsIndications, rhsIsUsable)):
            return lhsIndications == rhsIndications
                && lhsIsUsable == rhsIsUsable
        case (.delimiter, _),
             (.text, _),
             (.image, _),
             (.exit, _),
             (.exitCode, _),
             (.lane, _):
            return false
        }
    }
}
