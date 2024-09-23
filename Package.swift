// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "PredicateHelper",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10), .macCatalyst(.v17)],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PredicateHelper",
            targets: ["PredicateHelper"]
        ),
        .executable(
            name: "PredicateHelperClient",
            targets: ["PredicateHelperClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "PredicateHelperMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "PredicateHelper", dependencies: ["PredicateHelperMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "PredicateHelperClient", dependencies: ["PredicateHelper"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "PredicateHelperTests",
            dependencies: [
                "PredicateHelperMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
