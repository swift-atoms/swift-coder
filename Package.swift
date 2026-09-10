// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-coder",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Coder", targets: ["Coder"]),
        .library(name: "Coder Foundation Integration", targets: ["Coder Foundation Integration"]),
        .library(name: "Coder Test Support", targets: ["Coder Test Support"]),
        .executable(name: "CoderUserRecords", targets: ["User Records Example"]),
    ],
    traits: [
        .trait(name: "Always", description: "The infallible Void unit grammar"),
        .trait(name: "Either", description: "Conditional coder construction"),
        .trait(name: "Pair", description: "Safe structural product composition", enabledTraits: ["Either"]),
        .trait(name: "Skip", description: "Canonical Void grammar composition", enabledTraits: ["Either"]),
        .trait(name: "Map", description: "Bidirectional conversion and failure mapping"),
        .trait(name: "Optic", description: "Optic conversion and explicit case branches", enabledTraits: ["Map"]),
        .trait(name: "Repetition", description: "Bounded, rejection-aware element and separator composition", enabledTraits: ["Checkpoint"]),
        .trait(name: "Predicate", description: "Borrowed value validation in both directions"),
        .trait(name: "Checkpoint", description: "Rejection-aware alternatives and repetition"),
        .default(enabledTraits: ["Either", "Pair", "Skip", "Map", "Optic", "Checkpoint", "Repetition", "Predicate", "Always"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-always.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-repetition.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cardinal.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-predicate.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main", traits: [
            .trait(name: "Always", condition: .when(traits: ["Always"])),
            .trait(name: "Predicate", condition: .when(traits: ["Predicate"])),
            .trait(name: "Repetition", condition: .when(traits: ["Repetition"])),

            .trait(name: "Either", condition: .when(traits: ["Either"])),
            .trait(name: "Pair", condition: .when(traits: ["Pair"])),
            .trait(name: "Skip", condition: .when(traits: ["Skip"])),
            .trait(name: "Map", condition: .when(traits: ["Map"])),
            .trait(name: "Optic", condition: .when(traits: ["Optic"])),
        ]),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main", traits: [
            .trait(name: "Always", condition: .when(traits: ["Always"])),
            .trait(name: "Repetition", condition: .when(traits: ["Repetition"])),

            .trait(name: "Either", condition: .when(traits: ["Either"])),
            .trait(name: "Pair", condition: .when(traits: ["Pair"])),
            .trait(name: "Map", condition: .when(traits: ["Map"])),
            .trait(name: "Optic", condition: .when(traits: ["Optic"])),
        ]),
        .package(url: "https://github.com/swift-atoms/swift-either.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-pair.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-skip.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-map.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-checkpoint.git", branch: "main"),
    ],
    targets: [
        .target(name: "Coder", dependencies: [
            .product(name: "Always", package: "swift-always", condition: .when(traits: ["Always"])),
            .product(name: "Repetition", package: "swift-repetition", condition: .when(traits: ["Repetition"])),
            .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["Repetition"])),
            .product(name: "Predicate", package: "swift-predicate", condition: .when(traits: ["Predicate"])),
            .product(name: "Parser", package: "swift-parser"),
            .product(name: "Serializer", package: "swift-serializer"),
            .product(name: "Either", package: "swift-either", condition: .when(traits: ["Either"])),
            .product(name: "Pair", package: "swift-pair", condition: .when(traits: ["Pair"])),
            .product(name: "Skip", package: "swift-skip", condition: .when(traits: ["Skip"])),
            .product(name: "Map", package: "swift-map", condition: .when(traits: ["Map"])),
            .product(name: "Optic", package: "swift-optic", condition: .when(traits: ["Optic"])),
            .product(name: "Checkpoint", package: "swift-checkpoint", condition: .when(traits: ["Checkpoint"])),
        ]),
        .target(name: "Coder Foundation Integration", dependencies: ["Coder"]),
        .target(name: "Coder Test Support", dependencies: ["Coder"], path: "Tests/Support"),
        .testTarget(name: "Coder Tests", dependencies: ["Coder", "Coder Test Support", "User Records Model"]),
        .target(name: "User Records Model", dependencies: ["Coder"], path: "Examples/User Records/Model"),
        .executableTarget(name: "User Records Example", dependencies: ["User Records Model"], path: "Examples/User Records/Executable"),
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
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("MoveOnlyTuples"),
    ]
}
