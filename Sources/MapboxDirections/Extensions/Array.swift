import Foundation

extension Array {
    #if !swift(>=4.1)
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
    #endif
}
