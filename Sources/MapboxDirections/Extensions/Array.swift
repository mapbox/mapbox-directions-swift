import Foundation

extension Array {
    #if !swift(>=4.1)
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
    #endif
}

extension Collection {
    /**
     Returns an index set containing the indices that satisfy the given predicate.
     */
    func indices(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        return IndexSet(try enumerated().filter { try predicate($0.element) }.map { $0.offset })
    }
}
