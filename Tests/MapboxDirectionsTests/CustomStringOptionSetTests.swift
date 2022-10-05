import Foundation
import XCTest
import MapboxDirections

struct BareCustomStringOptionSet : CustomValueOptionSet {
    init() {
        rawValue = 0
    }
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    var rawValue: Int
    var customOptions: [Int: String] = [:]
    var description: String = ""
}

///     Tests conformance to SetAlgebra [conditions](https://developer.apple.com/documentation/swift/setalgebra#Conforming-to-the-SetAlgebra-Protocol).
class CustomStringOptionSetTests: XCTestCase {
    func getEmptySet() -> BareCustomStringOptionSet {
        var set = BareCustomStringOptionSet()
        set.customOptions = [1: "value"]
        return set
    }
    
    func getSet1() -> BareCustomStringOptionSet {
        var set = BareCustomStringOptionSet(rawValue: 1+2+4+8)
        set.customOptions = [2: "value 2",
                             8: "value 8"]
        return set
    }
    
    func getSet2() -> BareCustomStringOptionSet {
        var set = BareCustomStringOptionSet(rawValue: 4+8+16+32)
        set.customOptions = [8: "value 8",
                             32: "value 32"]
        return set
    }
    
    func getSubset() -> BareCustomStringOptionSet {
        var set = BareCustomStringOptionSet(rawValue: 4+8)
        set.customOptions = [8: "value 8"]
        return set
    }
    
    //     S() == []
    func testEmptySet() {
        let set = getEmptySet()
        
        XCTAssertTrue(set.isEmpty)
    }
    
    //     x.intersection(x) == x
    //     x.intersection([]) == []
    func testIntersection() {
        let emptySet = getEmptySet()
        let set = getSet1()
        
        XCTAssertEqual(set, set.intersection(set,
                                             comparisonPolicy: .allowEqual))
        XCTAssertEqual(emptySet, set.intersection(emptySet,
                                                  comparisonPolicy: .allowEqual))
    }
    
    //     x.union(x) == x
    //     x.union([]) == x
    func testUnion() {
        let emptySet = getEmptySet()
        let set = getSet1()
        
        XCTAssertEqual(set, set.union(set,
                                      comparisonPolicy: .allowEqual))
        XCTAssertEqual(set, set.union(emptySet,
                                      comparisonPolicy: .allowEqual))
    }
    
    //     x.contains(e) implies x.union(y).contains(e)
    //     x.union(y).contains(e) implies x.contains(e) || y.contains(e)
    //     x.contains(e) && y.contains(e) if and only if x.intersection(y).contains(e)
    func testContains() {
        let set1 = getSet1()
        let set2 = getSet2()
        let setE = getSubset()
        
        XCTAssertTrue(set1.contains(setE, comparisonPolicy: .allowEqual))
        XCTAssertTrue(set1.union(set2, comparisonPolicy: .allowEqual).contains(setE, comparisonPolicy: .allowEqual))
        
        XCTAssertTrue(set1.intersection(set2, comparisonPolicy: .allowEqual).contains(setE, comparisonPolicy: .allowEqual))
    }
    
    //     x.isSubset(of: y) implies x.union(y) == y
    //     x.isSuperset(of: y) implies x.union(y) == x
    //     x.isSubset(of: y) if and only if y.isSuperset(of: x)
    func testSuperset() {
        let set1 = getSet1()
        let setE = getSubset()
        
        XCTAssertTrue(setE.isSubset(of: set1,
                                     comparisonPolicy: .allowEqual))
        XCTAssertEqual(setE.union(set1, comparisonPolicy: .allowEqual), set1)
        XCTAssertEqual(set1.union(setE, comparisonPolicy: .allowEqual), set1)
        XCTAssertTrue(set1.isSuperset(of: setE,
                                     comparisonPolicy: .allowEqual))
    }
    
    //     x.isStrictSuperset(of: y) if and only if x.isSuperset(of: y) && x != y
    //     x.isStrictSubset(of: y) if and only if x.isSubset(of: y) && x != y
    func testStrictSuperset() {
        let set1 = getSet1()
        let setE = getSubset()
        
        XCTAssertTrue(set1.isStrictSuperset(of: setE, comparisonPolicy: .allowEqual))
        XCTAssertTrue(setE.isStrictSubset(of: set1, comparisonPolicy: .allowEqual))
        XCTAssertNotEqual(set1, setE)
    }
}
