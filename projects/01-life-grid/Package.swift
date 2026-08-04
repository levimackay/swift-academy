// swift-tools-version: 6.2
//
// Standalone package. It is deliberately not part of the root chapter
// package: its tests exercise API you have not written yet, so it is allowed
// to fail to build in isolation while the chapters stay green.
//
// platforms: is mandatory. Omitting it fails Swift Testing macro expansion
// with "'isolation()' is only available in macOS 10.15 or newer".

import PackageDescription

let package = Package(
    name: "LifeGrid",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LifeGrid", targets: ["LifeGrid"])
    ],
    targets: [
        .target(
            name: "LifeGrid",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "LifeGridTests",
            dependencies: ["LifeGrid"],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
    ]
)
