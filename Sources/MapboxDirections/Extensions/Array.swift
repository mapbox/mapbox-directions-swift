import Foundation

extension Collection {
    /**
     Returns an index set containing the indices that satisfy the given predicate.
     */
    func indices(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        return IndexSet(try enumerated().filter { try predicate($0.element) }.map { $0.offset })
    }
}
