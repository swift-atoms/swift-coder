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
            name: "Coder",
            targets: ["Coder"]
        ),
        .library(
            name: "Coder Standard Library Integration",
            targets: ["Coder Standard Library Integration"]
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
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Coder",
            dependencies: [
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Error", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(name: "Parser Product", package: "swift-parser"),
                .product(name: "Parser Sequence", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),
        .target(
            name: "Coder Standard Library Integration",
            dependencies: [
                .target(name: "Coder"),
                .product(name: "Parser", package: "swift-parser"),
                .product(
                    name: "Parser Standard Library Integration",
                    package: "swift-parser"
                ),
                .product(name: "Serializer", package: "swift-serializer"),
            ]
        ),
        .testTarget(
            name: "Coder Tests",
            dependencies: [
                .target(name: "Coder"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Error", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(name: "Parser Product", package: "swift-parser"),
                .product(name: "Parser Sequence", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
            ],
            path: "Tests/Coder Tests"
        ),
        .testTarget(
            name: "Coder Standard Library Integration Tests",
            dependencies: [
                .target(name: "Coder"),
                .target(name: "Coder Standard Library Integration"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(
                    name: "Parser Standard Library Integration",
                    package: "swift-parser"
                ),
                .product(name: "Serializer", package: "swift-serializer"),
            ],
            path: "Tests/Coder Standard Library Integration Tests"
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
