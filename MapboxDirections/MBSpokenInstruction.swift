import Foundation

/**
 An instruction about an upcoming `RouteStep`’s maneuver, optimized for speech synthesis.
 
 The instruction is provided in two formats: plain text and text marked up according to the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML). Use a speech synthesizer such as `AVSpeechSynthesizer` or Amazon Polly to read aloud the instruction.
 
 The `distanceAlongStep` property is measured from the beginning of the step associated with this object. By contrast, the `text` and `ssmlText` properties refer to the details in the following step. It is also possible for the instruction to refer to two following steps simultaneously when needed for safe navigation.
 */
@objc(MBSpokenInstruction)
open class SpokenInstruction: NSObject, NSSecureCoding {
    
    /**
     A distance along the associated `RouteStep` at which to read the instruction aloud.
     
     The distance is measured in meters from the beginning of the associated step.
     */
    @objc public let distanceAlongStep: CLLocationDistance

    
    /**
     A plain-text representation of the speech-optimized instruction.
     
     This representation is appropriate for speech synthesizers that lack support for the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML), such as `AVSpeechSynthesizer`. For speech synthesizers that support SSML, use the `ssmlText` property instead.
     */
    @objc public let text: String
    
    
    /**
     A formatted representation of the speech-optimized instruction.
     
     This representation is appropriate for speech synthesizers that support the [Speech Synthesis Markup Language](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language) (SSML), such as [Amazon Polly](https://aws.amazon.com/polly/). Numbers and names are marked up to ensure correct pronunciation. For speech synthesizers that lack SSML support, use the `text` property instead.
     */
    @objc public let ssmlText: String
    
    /**
     Initialize a `SpokenInstruction` from a dictionary.
     */
    @objc public convenience init(json: [String: Any]) {
        let distanceAlongStep = json["distanceAlongGeometry"] as! CLLocationDistance
        let text = json["announcement"] as! String
        let ssmlText = json["ssmlAnnouncement"] as! String

        self.init(distanceAlongStep: distanceAlongStep, text: text, ssmlText: ssmlText)
    }

    /**
     Initialize a `SpokenInstruction`.
     
     - parameter distanceAlongStep: A distance along the associated `RouteStep` at which to read the instruction aloud.
     - parameter text: A plain-text representation of the speech-optimized instruction.
     - parameter ssmlText: A formatted representation of the speech-optimized instruction.
     */
    @objc public init(distanceAlongStep: CLLocationDistance, text: String, ssmlText: String) {
        self.distanceAlongStep = distanceAlongStep
        self.text = text
        self.ssmlText = ssmlText
    }
    
    public required init?(coder decoder: NSCoder) {
        distanceAlongStep = decoder.decodeDouble(forKey: "distanceAlongStep")
        text = decoder.decodeObject(of: NSString.self, forKey: "text") as String!
        ssmlText = decoder.decodeObject(of: NSString.self, forKey: "ssmlText") as String!
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(distanceAlongStep, forKey: "distanceAlongStep")
        coder.encode(text, forKey: "text")
        coder.encode(ssmlText, forKey: "ssmlText")
    }
}

