import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

private let accessTokenKey = "access_token"
private let skuKey = "sku"

func checkDuplicateParametersAreRemoved(requestQueryItems: ([URLQueryItem]) -> [URLQueryItem]) {
    let duplicateKey = "duplicate_param"
    let firstValue = "first_value"
    let secondValue = "second_value"

    let queryItems = requestQueryItems([
        URLQueryItem(name: duplicateKey, value: firstValue),
        URLQueryItem(name: duplicateKey, value: secondValue),
        URLQueryItem(name: accessTokenKey, value: "custom_access_token"),
        URLQueryItem(name: skuKey, value: "custom_sku"),
    ])

    // Verify custom duplicate parameters are deduplicated
    let duplicateItems = queryItems.filter { $0.name == duplicateKey }
    XCTAssertEqual(duplicateItems.count, 1, "Duplicate query items should be removed")
    XCTAssertEqual(duplicateItems.first?.value, firstValue, "First occurrence should be kept")

    // Verify standard parameters (access_token, sku) are also deduplicated
    let accessTokenItems = queryItems.filter { $0.name == accessTokenKey }
    XCTAssertEqual(accessTokenItems.count, 1, "Duplicate access_token items should be removed")

    let skuItems = queryItems.filter { $0.name == skuKey }
    XCTAssertEqual(skuItems.count, 1, "Duplicate sku items should be removed")

    // Verify no duplicate names exist across all query items
    let allNames = queryItems.map(\.name)
    let uniqueNames = Set(allNames)
    XCTAssertEqual(allNames.count, uniqueNames.count, "All query item names should be unique")
}
