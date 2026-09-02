// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-coder",
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
            name: "Coder Witness",
            targets: ["Coder Witness"]
        ),
        .library(
            name: "Coder",
            targets: ["Coder"]
        ),
        .library(
            name: "Coder Parser",
            targets: ["Coder Parser"]
        ),
        .library(
            name: "Coder Test Support",
            targets: ["Coder Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-product.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-checkpoint.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cursor.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-always.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-always-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-pair-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cursor-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-collection-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-collection-serializer.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Coder Primitive",
            dependencies: [
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(
                    name: "Collection Serializer Buffer",
                    package: "swift-collection-serializer"
                ),
            ]
        ),

        .target(
            name: "Coder Witness",
            dependencies: [
                .target(name: "Coder Primitive")
            ]
        ),

        .target(
            name: "Coder",
            dependencies: [
                .target(name: "Coder Primitive"),
                .target(name: "Coder Witness"),
            ]
        ),

        .target(
            name: "Coder Parser",
            dependencies: [
                "Coder",
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Error", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(name: "Parser Take", package: "swift-parser"),
                .product(
                    name: "Parser Standard Library Integration",
                    package: "swift-parser"
                ),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Product", package: "swift-product"),
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Always", package: "swift-always"),
                .product(name: "Always Parser", package: "swift-always-parser"),
                .product(name: "Pair Parser", package: "swift-pair-parser"),
                .product(name: "Cursor Parser First", package: "swift-cursor-parser"),
                .product(name: "Cursor Parser Many", package: "swift-cursor-parser"),
                .product(name: "Cursor Parser OneOf", package: "swift-cursor-parser"),
                .product(name: "Cursor Parser Optionally", package: "swift-cursor-parser"),
                .product(name: "Collection Parser End", package: "swift-collection-parser"),
                .product(name: "Collection Parser Prefix", package: "swift-collection-parser"),
                .product(name: "Collection Parser Rest", package: "swift-collection-parser"),
            ]
        ),

        .target(
            name: "Coder Test Support",
            dependencies: ["Coder"],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Coder Parser Tests",
            dependencies: [
                "Coder Parser",
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "Pair Parser", package: "swift-pair-parser"),
                .product(name: "Parser Match", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
            ],
            path: "Tests/Coder Parser Tests"
        ),
        .target(
            name: "Coder Module Boundary Control",
            dependencies: [.target(name: "Coder")],
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
                .target(name: "Coder"),
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
