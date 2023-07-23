// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapboxDirections",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MapboxDirections",
            targets: ["MapboxDirections", "MapboxDirectionsObjc"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/raphaelmor/Polyline", from: "5.1.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MapboxDirections",
            dependencies: ["Polyline", "MapboxDirectionsObjc"],
            path: "MapboxDirections"
        ),
        .target(
            name: "MapboxDirectionsObjc",
            path: "MapboxDirectionsObjc"
        ),
        .testTarget(
            name: "MapboxDirectionsTests",
            dependencies: [
                "MapboxDirections",
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
            ],
            path: "MapboxDirectionsTests"
        ),
    ]
)
