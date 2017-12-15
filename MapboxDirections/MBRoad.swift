import Foundation

/**
 Encapsulates all the information about a road.
 */
struct Road {
    let names: [String]?
    let codes: [String]?
    let exitCodes: [String]?
    let destinations: [String]?
    let destinationCodes: [String]?
    let rotaryNames: [String]?
    
    init(name: String, ref: String?, exits: String?, destination: String?, rotaryName: String?) {
        var codes: [String]?
        if !name.isEmpty, let ref = ref {
            // Mapbox Directions API v5 encodes the ref separately from the name but redundantly includes the ref in the name for backwards compatibility. Remove the ref from the name.
            let parenthetical = "(\(ref))"
            if name == ref {
                self.names = nil
            } else {
                self.names = name.replacingOccurrences(of: parenthetical, with: "").tagValues(separatedBy: ";")
            }
            codes = ref.tagValues(separatedBy: ";")
        } else if !name.isEmpty, let codesRange = name.range(of: "\\(.+?\\)$", options: .regularExpression, range: name.startIndex..<name.endIndex) {
            // Mapbox Directions API v4 encodes the ref inside a parenthetical. Remove the ref from the name.
            let parenthetical = name[codesRange]
            if name == ref {
                self.names = nil
            } else {
                self.names = name.replacingOccurrences(of: parenthetical, with: "").tagValues(separatedBy: ";")
            }
            codes = parenthetical.trimmingCharacters(in: CharacterSet(charactersIn: "()")).tagValues(separatedBy: ";")
        } else {
            self.names = name.isEmpty ? nil : name.tagValues(separatedBy: ";")
            codes = ref?.tagValues(separatedBy: ";")
        }
        
        // Mapbox Directions API v5 combines the destination’s ref and name.
        if let destination = destination, destination.contains(": ") {
            let destinationComponents = destination.components(separatedBy: ": ")
            self.destinationCodes = destinationComponents.first?.tagValues(separatedBy: ",")
            self.destinations = destinationComponents.dropFirst().joined(separator: ": ").tagValues(separatedBy: ",")
        } else {
            self.destinationCodes = nil
            self.destinations = destination?.tagValues(separatedBy: ",")
        }
        
        self.exitCodes = exits?.tagValues(separatedBy: ";")
        self.codes = codes
        self.rotaryNames = rotaryName?.tagValues(separatedBy: ";")
    }
}

extension String {
    internal func tagValues(separatedBy separator: String) -> [String] {
        return components(separatedBy: separator).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
