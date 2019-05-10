import Foundation


extension NSCoder {
    
    func encodeIfPresent(_ any: Any?, forKey key: String) {
        if let any = any {
            encode(any, forKey: key)
        }
    }
    
    func decodeIfPresent<T>(_ type: T.Type, forKey key: String) -> T? {
        if let obj = decodeObject(forKey: key) as? T {
            return obj
        }
        return nil
    }
}
