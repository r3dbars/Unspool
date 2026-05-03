// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DailyPages",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DailyPages", targets: ["DailyPages"])
    ],
    targets: [
        .executableTarget(
            name: "DailyPages",
            dependencies: ["DailyPagesCore"],
            path: "Sources/DailyPages"
        ),
        .target(
            name: "DailyPagesCore",
            path: "Sources/DailyPagesCore"
        ),
        .testTarget(
            name: "DailyPagesTests",
            dependencies: ["DailyPagesCore"],
            path: "Tests/DailyPagesTests"
        )
    ]
)
