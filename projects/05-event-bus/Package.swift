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
    name: "EventBus",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "EventBus", targets: ["EventBus"])
    ],
    targets: [
        .target(
            name: "EventBus",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "EventBusTests",
            dependencies: ["EventBus"],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
    ]
)
