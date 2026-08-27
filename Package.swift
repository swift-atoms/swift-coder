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
            url: "https://github.com/swift-molecules/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-product.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-input.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Coder Primitive",
            dependencies: [
                .product(name: "Parser Core", package: "swift-parser"),
                .product(
                    name: "Serializer Core",
                    package: "swift-serializer"
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
                .product(name: "Input", package: "swift-input"),
                "Coder",
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Pair", package: "swift-parser"),
                .product(
                    name: "Serializer Core",
                    package: "swift-serializer"
                ),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Product", package: "swift-product"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),

        .target(
            name: "Coder Test Support",
            dependencies: ["Coder"],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Coder Parser Tests",
            dependencies: ["Coder Parser"],
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
