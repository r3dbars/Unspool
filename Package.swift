// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Unspool",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Unspool", targets: ["Unspool"])
    ],
    targets: [
        .executableTarget(
            name: "Unspool",
            dependencies: ["MentalCompostCore"],
            path: "Sources/MentalCompost"
        ),
        .target(
            name: "MentalCompostCore",
            path: "Sources/MentalCompostCore"
        ),
        .testTarget(
            name: "MentalCompostTests",
            dependencies: ["MentalCompostCore"],
            path: "Tests/MentalCompostTests"
        )
    ]
)
