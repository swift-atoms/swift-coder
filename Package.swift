// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-coder-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Coder Primitive",
            targets: ["Coder Primitive"]
        ),
        .library(
            name: "Coder Witness Primitives",
            targets: ["Coder Witness Primitives"]
        ),
        .library(
            name: "Coder Primitives",
            targets: ["Coder Primitives"]
        ),
        .library(
            name: "Coder Parser Primitives",
            targets: ["Coder Parser Primitives"]
        ),
        .library(
            name: "Coder Primitives Test Support",
            targets: ["Coder Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-parser-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-serializer-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-product-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-pair-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-input-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Coder Primitive",
            dependencies: [
                .product(name: "Parser Primitives Core", package: "swift-parser-primitives"),
                .product(
                    name: "Serializer Primitives Core",
                    package: "swift-serializer-primitives"
                ),
            ]
        ),

        .target(
            name: "Coder Witness Primitives",
            dependencies: [
                .target(name: "Coder Primitive")
            ]
        ),

        .target(
            name: "Coder Primitives",
            dependencies: [
                .target(name: "Coder Primitive"),
                .target(name: "Coder Witness Primitives"),
            ]
        ),

        .target(
            name: "Coder Parser Primitives",
            dependencies: [
                .product(name: "Input Primitives", package: "swift-input-primitives"),
                "Coder Primitives",
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser Pair Primitives", package: "swift-parser-primitives"),
                .product(
                    name: "Serializer Primitives Core",
                    package: "swift-serializer-primitives"
                ),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Product Primitives", package: "swift-product-primitives"),
                .product(name: "Pair Primitives", package: "swift-pair-primitives"),
            ]
        ),

        .target(
            name: "Coder Primitives Test Support",
            dependencies: ["Coder Primitives"],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Coder Parser Primitives Tests",
            dependencies: ["Coder Parser Primitives"],
            path: "Tests/Coder Parser Primitives Tests"
        ),
        .target(
            name: "Coder Module Boundary Control",
            dependencies: [.target(name: "Coder Primitives")],
            path: "Tests/Coder Module Boundary Control",
            swiftSettings: [

                .unsafeFlags([
                    "-Xfrontend", "-sil-verify-all",
                    "-Xfrontend", "-whole-module-optimization",
                ])
            ]
        ),
        .testTarget(
            name: "Coder Module Boundary Tests",
            dependencies: [
                .target(name: "Coder Module Boundary Control"),
                .target(name: "Coder Primitives"),
            ],
            path: "Tests/Coder Module Boundary Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
