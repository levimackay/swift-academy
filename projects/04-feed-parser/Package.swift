// swift-tools-version: 6.2
//
// Standalone package. It is deliberately not part of the root chapter
// package: its tests exercise API you have not written yet, so it is allowed
// to fail to build in isolation while the chapters stay green.
//
// platforms: is mandatory. Omitting it fails Swift Testing macro expansion
// with "'isolation()' is only available in macOS 10.15 or newer".
//
// Fixtures live at the package root in Fixtures/, not as a bundled resource.
// Load them from disk with a path derived from #filePath. See SPEC.md.

import PackageDescription

let package = Package(
    name: "FeedParser",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "FeedParser", targets: ["FeedParser"])
    ],
    targets: [
        .target(
            name: "FeedParser",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "FeedParserTests",
            dependencies: ["FeedParser"],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
    ]
)
