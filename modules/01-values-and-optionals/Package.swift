// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ValuesAndOptionals",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "ValuesAndOptionals"),
        .testTarget(
            name: "ValuesAndOptionalsTests",
            dependencies: ["ValuesAndOptionals"]
        ),
    ]
)
