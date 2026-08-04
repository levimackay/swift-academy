// swift-tools-version: 6.2
//
// One package for all fourteen chapters. Every chapter contributes two
// targets: an exercise target holding the stubs you fill in, and a test
// target holding the suite that grades them.
//
// Why one package and not fourteen: the point of `swift test` at the repo
// root is the question "did chapter 03 still pass after I refactored".
// Fourteen packages means fourteen .build directories, no cross chapter
// regression run, and manifest drift.
//
// Projects and drills are deliberately outside this package. A project test
// cannot compile until you write the conformance it exercises, so an in
// progress project would red the whole chapter build. Each project is its own
// standalone package for that reason.
//
// The rules this manifest follows, and why, are written down once in
// docs/how-this-repo-works.md. Settle disagreements by reference to that file.
//
//   platforms:  mandatory. Omit it and Swift Testing macro expansion fails
//               with "'isolation()' is only available in macOS 10.15 or
//               newer", which points at nothing you wrote.
//   ExistentialAny: on for every target, so every existential must be spelled
//               `any Shape`. That turns the `some` versus `any` distinction
//               into a compiler enforced habit instead of a paragraph.
//
// There is no swiftLanguageMode line: Swift 6 mode is the default at this
// tools version, and stating a default teaches that it is optional.
// There is no -strict-concurrency flag: that is a Swift 5 migration flag.

import PackageDescription

/// Every chapter directory under `modules/`, in order. Adding a chapter is
/// one row here plus the directories it names.
let chapters: [(number: String, slug: String)] = [
    ("01", "01-optionals"),
    ("02", "02-functions"),
    ("03", "03-value-semantics"),
    ("04", "04-protocols"),
    ("05", "05-enums"),
    ("06", "06-collections"),
    ("07", "07-generics"),
    ("08", "08-errors"),
    ("09", "09-codable"),
    ("10", "10-classes-and-arc"),
    ("11", "11-isolation"),
    ("12", "12-async-await"),
    ("13", "13-swiftui-state"),
    ("14", "14-swiftui-app"),
]

let academySettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny")
]

/// Target names carry the chapter number so that `swift test --filter 03`
/// selects exactly one chapter.
let chapterTargets: [Target] = chapters.flatMap { chapter -> [Target] in
    let exercises = "Chapter\(chapter.number)"
    let tests = "Chapter\(chapter.number)Tests"
    return [
        .target(
            name: exercises,
            path: "modules/\(chapter.slug)/exercises",
            swiftSettings: academySettings
        ),
        .testTarget(
            name: tests,
            dependencies: [.target(name: exercises)],
            path: "modules/\(chapter.slug)/tests",
            swiftSettings: academySettings
        ),
    ]
}

let package = Package(
    name: "SwiftAcademy",
    platforms: [.macOS(.v14)],
    targets: chapterTargets
)
