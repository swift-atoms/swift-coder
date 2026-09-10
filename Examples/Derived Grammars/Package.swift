// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-coder-derived-grammars",
    platforms: [.macOS(.v27)],
    products: [
        .library(name: "Derived Grammars", targets: ["Derived Grammars"]),
        .executable(name: "DerivedGrammarsExample", targets: ["Derived Grammars Example"]),
    ],
    dependencies: [
        .package(
            path: "../..",
            traits: ["Pair", "Skip", "Map", "Optic", "Checkpoint"]
        ),
        .package(path: "../../../../swift-molecules/swift-isomorphism-derivation"),
        .package(path: "../../../../swift-molecules/swift-prism-derivation"),
    ],
    targets: [
        .target(
            name: "Derived Grammars",
            dependencies: [
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Isomorphism Derivation", package: "swift-isomorphism-derivation"),
                .product(name: "Prism Derivation", package: "swift-prism-derivation"),
            ]
        ),
        .executableTarget(
            name: "Derived Grammars Example",
            dependencies: ["Derived Grammars"]
        ),
        .testTarget(
            name: "Derived Grammars Tests",
            dependencies: [
                "Derived Grammars",
                .product(name: "Prism Derivation", package: "swift-prism-derivation"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
