import Foundation

extension [URLQueryItem] {
    /**
     Removes duplicated parameters
     
     - returns Names of duplicated parameters or nil if none were found.
     */
    mutating func removeDuplicates() -> [String]? {
        var seen = Set<String>()
        var duplicates = Set<String>()
        var result = [URLQueryItem]()
        
        for param in self {
            if seen.contains(param.name) {
                duplicates.insert(param.name)
            } else {
                seen.insert(param.name)
                result.append(param)
            }
        }
        self = result
        return duplicates.isEmpty ? nil : duplicates.sorted()
    }
}
