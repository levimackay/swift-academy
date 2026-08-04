---
title: "Swift Academy: architecture and decisions"
kind: decision record
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Swift Academy: architecture and decisions

This is the canonical design. Every chapter author builds against this
document. Where it conflicts with any earlier proposal or critique, this
document wins.

Verified on Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, on
2026-08-03. Claims marked VERIFIED were reproduced on this machine, not
recalled.

The operational form of these decisions, meaning the template, the budgets,
the manifest, and the commands, is
[how-this-repo-works.md](how-this-repo-works.md). This file is the reasoning
behind them. Read that one to author a chapter; read this one to argue about
one.

---

## 1. Shape of the course

Fourteen chapters, six projects, about 157 hours, roughly four months at ten
hours a week. That number goes in the README, because courses die when the
finish line is invisible.

Chapters live in `modules/NN-slug/` and are one root SwiftPM package. Projects
live in `projects/NN-slug/` and are separate packages. Drills are a third
separate package.

The three arcs:

- Chapters 01 through 10 are the language, run entirely from the terminal.
- Chapters 11 and 12 are isolation and then structured concurrency.
- Chapters 13 and 14 are SwiftUI.

Project 02, a five hour SwiftUI spike, sits after chapter 05 so that Levi sees
a screen in week four rather than week fifteen.

## 2. The Xcode gate does not exist

VERIFIED: `/Applications/Xcode.app` is Xcode 26.6, fully installed at 3.7 GB,
with iOS 26.0 and iOS 26.5 simulator runtimes already downloaded and a full
device set including iPhone 17 Pro and iPad Pro M5. `xcode-select` merely
points at CommandLineTools, which is one command to change.

Three proposals scheduled homework, built a chapter, and listed a top project
risk around a multi hour download that has already happened. Beyond the
factual error, this let the long terminal only spine be presented as toolchain
forced when it was a pedagogical choice, so it was never argued on merit.

`SETUP.md` carries one line:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p
```

and a note that `DEVELOPER_DIR` scopes it per command if the terminal chapters
should stay on CommandLineTools.

VERIFIED, and narrower than the first draft of this ruling: SwiftUI and
Observation ship in the macOS SDK, so the chapter 13 and 14 exercise and test
targets compile and run under plain `swift test` with `xcode-select` pointing
at CommandLineTools. Xcode is needed only for the simulator work: the
preview-app in 13, the preview-app in 14, project 02, and the capstone's App
target. Any file claiming that a chapter needs Xcode to build is wrong and is
the bug.

## 3. Ordering, and why it deviates

**Value semantics at 03, before protocols, collections, and generics.** Array
is a copy on write struct, Dictionary subscript returns an Optional, and
`mutating` is why append works on a `var` and not a `let`. None of that is
learnable as a list of rules without the model underneath. Teaching value
semantics first converts fifteen memorized collection rules into one
principle.

**Collections (06) before generics (07).** Generics taught before he has used
`[Element]` and `map` a few hundred times is abstraction without referents.
Taught after, chapter 07 opens with code he has already written, and
`Collection`'s associated types read as obvious rather than exotic. It also
lets project 03 require conforming to standard library protocols, which is the
only exercise that actually teaches associated types.

**Classes and inheritance at 10.** He already knows inheritance. What he does
not know is that in Swift it is a niche tool. Placing classes at position
three, where every C# shaped course puts them, licenses him to keep writing C#
for the rest of the course. By chapter 10 he has nine chapters of working
Swift with zero classes, so the chapter can honestly price what a class buys:
identity, `deinit`, shared mutable state, and a `Sendable` problem.

**Isolation (11) before async/await (12).** Chapter 11 is isolation as a type
system topic with no timing behavior at all: `Sendable`, `actor`,
`@MainActor`, `nonisolated`, and regions. Every failure there has exactly one
cause, a type error. Chapter 12 adds `async let`, `TaskGroup`, cancellation,
and reentrancy. Merging them means every failure has two candidate causes,
which is where solo learners stall indefinitely.

**Sendable is previewed at 03 and taught at 11.** Strict concurrency is
ambient on this toolchain, so isolation diagnostics arrive whether or not the
syllabus is ready. Chapter 03 ends with a short section stating the honest
core, that a struct of value types is `Sendable` for exactly the same reason
it is safe to copy, with no actor vocabulary. That is one of chapter 03's
three concepts only if it fits; if the chapter runs long, it moves wholesale
to 11.

## 4. Scope: what was cut

From the roughly 45 topic list, about eighteen topics are gone. Three buckets.

**Bucket A, [reference.md](reference.md), lookups rather than skills.**
String.Index and the unicode views, the numeric protocol hierarchy, overflow
operators, the conformance zoo (CustomDebugStringConvertible and friends),
`defer` ordering rules, overloaded subscripts, access control minutiae,
`@autoclosure`, `@inlinable` and library evolution, `Mirror`, `MemoryLayout`
and unsafe pointers, noncopyable types and the ownership modifiers.

**Bucket B, [legacy-swift.md](legacy-swift.md), one paragraph each with a
pointer.** GCD and DispatchQueue and semaphores, completion handlers and
`withCheckedContinuation`, class inheritance and `override` and `final`,
`@objc` and KVO, `UIViewRepresentable`, XCTest, and `ObservableObject` with
`@Published` and `@StateObject`. These must actually be written, not merely
planned, or the cuts become blind spots the first time he hits a 2021 Stack
Overflow answer.

**Bucket C, cut entirely.** Combine, macro authoring, result builder
authoring, operator overloading and custom operators, property wrapper
authoring, Core Data as an architecture target, UIKit and storyboards and
xibs, CocoaPods and Carthage, `@dynamicMemberLookup`, writable key paths,
widgets and App Intents and watchOS and Core ML.

Combine deserves its own sentence, since it is the largest cut. It is frozen,
its `Sendable` story under Swift 6 is poor, and Observation plus AsyncSequence
covers its ground with better isolation guarantees. One page mapping
`ObservableObject` and `@Published` to Observation is enough to read legacy
code.

Also cut from the proposals themselves: `academyctl` and the whole generated
progress pipeline, `CLASS-BUDGET.md`, `make peek` and `peeked.log`, the Linux
CI job, the cross branch bot, the pixel graded layout replica project, the
timing based job runner project, and six of the eight learner journals.

## 5. Persistence, state, and architecture

**SwiftData is the only persistence layer taught.** It composes with the rest
of the course: `@Model` is a macro, `#Predicate` is the natural contrast to
LINQ expression trees, and `ModelActor` makes the actor model concrete. Core
Data is [core-data-literacy.md](core-data-literacy.md), roughly two pages, no
exercises, no test target, positioned after SwiftData as the system SwiftData's
design responds to. Two caveats the proposals missed go in chapter 14: keep
`@Query` out of deeply nested views because it couples persistence to the view
tree and is hard to test, and design for schema migration before shipping
rather than after.

**State is an `@Observable @MainActor final class` owned by `@State`,** with
`@Bindable` where bindings are needed.

VERIFIED, and this is load bearing for the whole SwiftUI plan: an
`@Observable @MainActor` model taking an injected
`@Sendable () async throws -> [Row]` closure, exercised by two `@Test`
functions covering the success and failure paths, passes under plain
`swift test` on CommandLineTools with no simulator. So roughly seventy percent
of chapters 13 and 14 keeps the red and green rhythm across the SwiftUI
transition.

**MVVM gets named.** Chapter 14 carries a required section, "MVVM, and what is
actually true in 2026". It states plainly that a model type separate from the
view survives and is correct, that a ViewModel per view is not required and
usually adds a layer for nothing, and that `ObservableObject`, `@Published`,
`@StateObject`, and `@ObservedObject` are the Combine era mechanism. It gives
him the interview answer in one paragraph he can say out loud. The phrase
"view model" is banned from target names and exercise descriptions.

**Dependency injection is taught, in chapter 14.** Three tools with a rule for
each: initializer injection with a closure or a small struct of closures as
the default seam, a protocol only when two or more real implementations exist,
`@Environment` for values scoped to a subtree of the view tree. The C# reflex
of a protocol per dependency plus a container is named and rejected
explicitly.

**View identity gets a named section in chapter 13.** Structural versus
explicit identity, `.id()`, how `ForEach` identity works, and why `@State` on
the wrong side of an identity change silently resets. This is the number one
source of real SwiftUI bugs and it appeared in the proposals as four words in
a list.

**Task cancellation across the seam.** `.task` cancels when the view
disappears and `.onAppear` plus `Task { }` does not. It sits between chapters
12 and 13, so every proposal missed it. It goes in chapter 13.

**Testing policy, [testing-policy.md](testing-policy.md).** Test models, state
transitions, decoding, and business logic exhaustively. Use previews and the
simulator for visual iteration. Write at most one XCUITest happy path before
shipping. Do not write snapshot tests on a solo project. Unit testing view
bodies is mostly wasted effort, and saying so up front stops him burning a
week discovering it.

## 6. Mechanisms

**Stubs.** VERIFIED: a `fatalError` stub aborts the whole run with
`error: Exited with unexpected signal code 5`, prints no summary line, and
because Swift Testing runs tests in parallel in one process, which other tests
reported first is nondeterministic. Sentinel stubs produce the complete
scoreboard, ending in `Test run with 4 tests in 1 suite failed`.

So stubs return a compiling wrong value with a `// TODO:` comment. The
legitimate objection, that a sentinel can accidentally satisfy a real
assertion, is closed mechanically: every exercise's test suite must contain at
least two assertions with distinct expected values, so no constant return can
pass. That one rule deletes the per exercise process runner, the progress
gated `ConditionTrait`, and `progress.json` as a SwiftPM resource.

**API pinning.** Each project's tests import the public API by name, so the
shape is pinned and the wrong language solution does not compile. Because
projects are separate packages, an in progress project failing to build cannot
red the chapters. Where a scaffold must pre declare something to compile, that
declaration is part of the answer and the spec says so rather than pretending
otherwise.

**Spaced repetition.** Three mechanisms, and one honest admission.

1. `drills/`, a separate package. Each chapter contributes four micro problems
   at authoring time, tagged by origin chapter. Run
   `swift test --package-path drills --filter Ch03`. A chapter that ships
   without its drills is not done. Retrofitting fifty six drills after chapter
   14 will not happen.
2. The Cold open. Chapters 03 and later open by re-solving one drill from two
   chapters back, blank file, no reference. Spaced retrieval, and unforgeable
   evidence of authorship.
3. Projects interleave by design, reusing material two to four chapters old,
   and each `SPEC.md` says so out loud.

The honest admission: the seven day recall gate is self reported, self graded,
and self dated. It is a documented ritual with a date column in `PROGRESS.md`,
not a machine check, and the design must stop describing it as compiler
verified. Everything else here has a compiler behind it. This does not.

**Journals: exactly two.** `NOTES/errors.md` at the root (the verbatim
diagnostic, what he thought it meant, what it actually meant) and the Log at
the bottom of `PROGRESS.md`, whose last line is always the single next
concrete action. Eight journals is a second job, and the first to lapse makes
the others feel like failures.

**Tooling.** A `Makefile` with four targets (`test`, `next`, `done`, `probe`),
one macOS CI job running `swift build --build-tests` and `swift test`,
`.gitignore`, and `.gitattributes`. `PROGRESS.md` stays hand written.
Everything else waits for a single "make it public" pass after chapter 06.
Levi's first substantial Swift project must not be this course's build
tooling, authored by someone else.

**Solutions.** A long lived `solutions` branch containing only implementations
Levi wrote. `main` holds stubs forever. For anything unsolved, the answer does
not exist anywhere, which cannot be defeated by grep or a fuzzy finder because
there is nothing to find. The README says reference solutions appear as he
earns them, so the repo does not read as abandoned.

## 7. The canonical manifest

VERIFIED to build and test clean.

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftAcademy",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "Chapter01",
            path: "modules/01-optionals/exercises",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "Chapter01Tests",
            dependencies: ["Chapter01"],
            path: "modules/01-optionals/tests",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        // Chapter02 through Chapter14, identical shape.
    ]
)
```

Twenty eight targets, zero external dependencies. The target name carries the
chapter number so that `swift test --filter Chapter01Tests` selects exactly
one chapter. A bare number does not: the filter regex also matches the source
line embedded in every test ID, so `--filter 10` pulls in tests from other
chapters that happen to be declared on a line containing 10.

Four decisions inside that file:

- `platforms:` is mandatory. VERIFIED: omitting it fails Swift Testing macro
  expansion with `'isolation()' is only available in macOS 10.15 or newer`.
  VERIFIED: `.macOS(.v13)` is sufficient, so the v15 floor some proposals
  demanded was unjustified. v14 is a safe arbitrary choice.
- No `swiftLanguageMode(.v6)` line. It is the default at tools version 6.2,
  and stating a default teaches that it is optional.
- No `-strict-concurrency=complete`. That is a Swift 5 migration flag.
- `ExistentialAny` on. VERIFIED: it produces
  `use of protocol 'Shape' as a type must be written 'any Shape'
  [#ExistentialAny]` and tests still run clean. `some` versus `any` is the
  highest value non obvious distinction for a C# developer and is invisible
  unless every existential site is spelled `any`.

`.defaultIsolation(MainActor.self)` is deliberately not set on any target. It
works and Apple recommends it for app targets, but it makes isolation
invisible, which is the exact thing chapter 11 exists to teach. Chapter 14
introduces it by toggling it on and reading the diff in errors.

`probes/` is excluded from the package, because probe files contain
deliberately failing code. They run via `make probe CH=NN P=name`.

## 8. Verified corrections that are now canon

Do not re-derive these, and do not ship a lesson contradicting them.

**Region based isolation.** VERIFIED: `Task { c.n += 1 }` on a local
non Sendable class compiles cleanly; adding `print(c.n)` on the next line
makes it `error: sending value of non-Sendable type '() async -> ()' risks
causing data races [#SendingRisksDataRace]`. Teach regions, never the rule
that a non Sendable value cannot cross a boundary. Also VERIFIED: `-typecheck`
reports nothing while full compilation reports the error, because these come
from a SIL pass. Chapter 11 carries a callout: trust `swift build`, not the
squiggles.

**Do not overclaim.** Swift 6 does not catch every shared mutable state
mistake. Anchor reliably diagnosing examples on global actor isolation.
Teaching the unqualified claim means the compiler contradicts the material
within a week, and trust loss is unrecoverable.

**Typed throws.** VERIFIED: pattern matched `catch` clauses are not
exhaustive. `catch .empty { } catch .bad(let t) { }` fails with `errors thrown
from here are not handled because the enclosing catch is not exhaustive`. The
working form is one `catch` containing a `switch` over `error`.

**Result.** `Result { try f() }` yields `Result<T, any Error>` and cannot
infer a typed failure. Building `Result<Int, ParseError>` needs an explicit
`do catch`.

**Existentials.** The published rule that a protocol with `Self` or associated
type requirements cannot be used as a type is out of date. Holding and passing
`any P` is fine; calling the `Self` requirement member is what fails. Teach
the precise boundary.

**Retain cycle demos.** A cycle needs both edges. A demo where the parent does
not also hold the child is a chain, it deinits normally, and it teaches that
`[weak self]` is superstition.

## 9. What is still open, and who owns it

**The app does not exist.** Chapters 13 and 14 and project 06 are all defined
against "his real app", and nothing says what it is. Ruling: Levi writes
`projects/06-capstone/CAPSTONE-SPEC.md` himself, from a process only template
the course supplies in `projects/06-capstone/SPEC.md` (screens list, one
sentence per screen, what data comes from where, what is explicitly out of
scope, three acceptance tests written before any code). Hard deadline: before
chapter 11 begins. Chapters 13 and 14 are authored against the template's
shape, not against a specific app, and that is a real constraint on how they
can be written.

**Prerequisites.** [../PREREQUISITES.md](../PREREQUISITES.md) exists and is
read before chapter 01. It names the Apple Developer Program annual cost, the
need for a physical device for the capstone's acceptance criterion, and the
fact that App Store submission has multi day external latency and is a post
course goal rather than a completion gate. Project 06 is done when a signed
build is installed on his own device.

**Getting stuck.** A documented protocol, because solo learners quit stuck far
more often than they quit bored. Progressive `<details>` hints in the chapter.
A sixty minute time box, after which the rule is to write the specific
question in `NOTES/errors.md` and move to the next exercise, returning cold
the next session. Permission to leave one exercise unfinished per chapter and
still mark the chapter done, stated explicitly, because unfinished work guilt
is a quit driver and it is free to eliminate.

**When a test is wrong.** Tests written by a tutor contain bugs. The rule: if
he believes a test is wrong, he writes the case he thinks is correct as a new
assertion, and if both cannot pass, the test is wrong and gets changed. Filing
an issue against himself is not a workflow.

**Recalibration.** The 157 hour estimate is a guess. After chapter 03, compare
actual hours to estimate and re-forecast. If the pace disagrees by more than
thirty percent, cut further, because completion is the product and the cut
list was justified entirely by that.

**Toolchain drift.** Every compiler claim here is true of Swift 6.2 on this
machine today. `NonisolatedNonsendingByDefault` is an upcoming feature that is
currently off and will become the default in a later language mode, which
would invert part of chapter 11. Rule: never assert exact diagnostic text
inside a test, and re-run every code sample in a chapter before marking that
chapter authored. Every chapter carries a `verified:` front matter line naming
the toolchain and date, so a stale claim is visible rather than assumed.

## 10. Authoring order

1. Fix the existing repo: shorten the slug to `01-optionals`, delete the
   committed `.build`, split `Problems.swift` into one file per exercise, drop
   the `enum Problems` namespace for free functions (the module is the
   namespace, and the static holder is exactly the C# idiom to correct in
   chapter 01), replace the `fatalError` stubs, and remove the six em dashes
   currently in that README.
2. Write [bridge.md](bridge.md), [keywords.md](keywords.md), and
   `CONTRIBUTING.md` first. They are the sources every chapter derives from.
3. Rewrite chapter 01 to the full template, end to end, and freeze it as the
   reference chapter. Seventeen chapters written against a spec instead of
   against a real example will diverge by chapter 05.
4. Then chapters in order, each one complete (README, exercises, tests,
   probes, four drills) before the next begins.

Do not gold plate the early chapters. Chapters 10 through 12 are the ones that
most need the diagnostic tables and the diagrams, and the usual failure is
that they arrive skeletal because the budget was spent on chapter 02.

---

## Addendum: hour arithmetic

Section 1 fixes the headline at 157 hours and section 9 says it is a guess to
be recalibrated after chapter 03. The published breakdown has to add up to it,
so the project estimates are the slack:

| Bucket | Hours |
|---|---|
| Fourteen chapters (4+5+6+6+6+6+7+5+5+6+7+7+8+8) | 86 |
| Six projects (6+5+8+10+7+35) | 71 |
| **Total** | **157** |

Project 03 was trimmed from 12 to 8 because it is the most academic of the
six, project 05 from 9 to 7, and the capstone from 40 to 35. Those numbers
live in each `SPEC.md` front matter as `estimated_hours` and nowhere else, so
there is exactly one place to change when chapter 03 forces a re-forecast.

## Addendum: work deferred, not dropped

A practitioner review of this design found real gaps between "excellent Swift
programmer" and "hireable iOS engineer": networking, the debugger and
Instruments, accessibility instruction rather than accessibility acceptance
criteria, shipping mechanics, and testing skills the learner is graded on but
never taught. Those are not folded into this document, because half applying a
structural change is worse than either applying or deferring it.

They are written up as a prioritized backlog with effort estimates in
[ROADMAP-NEXT.md](ROADMAP-NEXT.md). Nothing there is authored yet, and this
document remains the description of the course as it is specified today.
