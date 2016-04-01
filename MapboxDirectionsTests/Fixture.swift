import XCTest
import Foundation

internal class Fixture {
    internal class func stringFromFileNamed(name: String) -> String {
        guard let path = NSBundle(forClass: self).pathForResource(name, ofType: "json") else {
            XCTAssert(false, "Fixture \(name) not found.")
            return ""
        }
        do {
            return try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        } catch {
            XCTAssert(false, "Unable to decode fixture at \(path): \(error).")
            return ""
        }
    }
    
    internal class func JSONFromFileNamed(name: String) -> [String: AnyObject] {
        guard let path = NSBundle(forClass: self).pathForResource(name, ofType: "json") else {
            XCTAssert(false, "Fixture \(name) not found.")
            return [:]
        }
        guard let data = NSData(contentsOfFile: path) else {
            XCTAssert(false, "No data found at \(path).")
            return [:]
        }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
        } catch {
            XCTAssert(false, "Unable to decode JSON fixture at \(path): \(error).")
            return [:]
        }
    }
}
