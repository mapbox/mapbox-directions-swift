// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Tests that use OHHTTPStubs don't support Linux
#if !os(Linux)
let optionalPackageDependencies = [Package.Dependency.package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0")]
let optionalTestTargetDependecies = [Target.Dependency.product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")]
#else
let optionalPackageDependencies = [Package.Dependency]()
let optionalTestTargetDependecies = [Target.Dependency]()
#endif

let package = Package(
    name: "MapboxDirections",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .watchOS(.v3), .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MapboxDirections",
            targets: ["MapboxDirections"]
        ),
        .executable(
            name: "mapbox-directions-swift",
            targets: ["MapboxDirectionsCLI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/raphaelmor/Polyline.git", from: "5.0.2"),
        .package(name: "Turf", url: "https://github.com/mapbox/turf-swift.git", from: "1.1.0"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
    ] + optionalPackageDependencies,
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MapboxDirections",
            dependencies: ["Polyline", "Turf"],
            exclude: ["Info.plist"]),
        .testTarget(
            name: "MapboxDirectionsTests",
            dependencies: ["MapboxDirections"] + optionalTestTargetDependecies,
            exclude: ["Info.plist"],
            resources: [
                .process("Fixtures"),
            ]),
        .target(
            name: "MapboxDirectionsCLI",
            dependencies: ["MapboxDirections", "SwiftCLI"]),
    ]
)
