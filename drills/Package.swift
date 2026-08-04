// swift-tools-version: 6.2
//
// The drills package. A drill is a small, repeatable exercise you contribute
// yourself at the end of a chapter, four per chapter. It is a separate
// package so that a half written drill never reds the chapter build, and so
// `swift test` here is a fast spaced repetition run you can do in five
// minutes without building fourteen chapters.
//
// platforms: is mandatory. Omitting it fails Swift Testing macro expansion
// with "'isolation()' is only available in macOS 10.15 or newer".

import PackageDescription

let package = Package(
    name: "Drills",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Drills", targets: ["Drills"])
    ],
    targets: [
        .target(
            name: "Drills",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "DrillsTests",
            dependencies: ["Drills"],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
    ]
)
