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
        .library(name: "Coder", targets: ["Coder"]),

        .library(name: "Coder Foundation Integration", targets: ["Coder Foundation Integration"]),
        .library(name: "Coder Test Support", targets: ["Coder Test Support"]),
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
    ],
    targets: [
        .target(
            name: "Coder",
            dependencies: [
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Either", package: "swift-either"),
            ],
            path: "Sources/Coder"
        ),
        
        .target(
            name: "Coder Foundation Integration",
            dependencies: [
                .target(name: "Coder"),
            ],
            path: "Sources/Coder Foundation Integration"
        ),
        .target(
            name: "Coder Test Support",
            dependencies: [
                .target(name: "Coder"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Coder Tests",
            dependencies: [
                .target(name: "Coder"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "Coder Test Support"),
                .target(name: "Coder Foundation Integration"),
            ],
            path: "Tests/Coder Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
