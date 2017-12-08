import Foundation

extension String {
    var isNotEmpty: Bool { return !isEmpty }
    var nonEmptyString: String? {
        return isNotEmpty ? self : nil
    }
}
