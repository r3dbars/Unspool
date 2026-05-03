// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MentalCompost",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MentalCompost", targets: ["MentalCompost"])
    ],
    targets: [
        .executableTarget(
            name: "MentalCompost",
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
