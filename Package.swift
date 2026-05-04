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
            dependencies: ["UnspoolCore"],
            path: "Sources/Unspool"
        ),
        .target(
            name: "UnspoolCore",
            path: "Sources/UnspoolCore"
        ),
        .testTarget(
            name: "UnspoolTests",
            dependencies: ["UnspoolCore"],
            path: "Tests/UnspoolTests"
        )
    ]
)
