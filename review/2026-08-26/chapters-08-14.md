# swift-academy technical review, chapters 08 to 14

Toolchain used for every check: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, xcode-select at /Applications/Xcode.app.

## 08-errors

Checks run: all 12 commented blocks in probes/errors.swift extracted and compiled with `swiftc -swift-version 6 -typecheck`, every diagnostic line matches verbatim (including block 6, `Result { }` really does infer `any Error` under an annotation). README samples (windSpeed, retryDelay with exhaustive switch and no default, sampleSpeed, held.get(), throws(Never) call without try) typecheck. `make probe CH=08 P=predict|paths|errors` all run. Tests read: every suite has two distinct expected values; every stub fails for the stated reason (constant returns). No implementation touched.

Edits:
- modules/08-errors/probes/predict.swift line 1: "Three snippets. Write your prediction" -> "Four snippets. Write your prediction". Reason: the file carries four numbered snippets and the README says "Three of the four are below".

Open questions:
- README "Coming from C#": "a bare `catch { }` is the only catch all". `catch let error { }` also catches everything; the sentence is true about type based catching only. Left as is.

## 09-codable

Checks run: all 8 blocks in probes/errors.swift compiled, diagnostics match verbatim (with Foundation imported, as the probe does). `make probe CH=09 P=predict|failures|threeway|errors` all run; the threeway output matches the README's five row table cell for cell. README samples (Show, Segment, Episode with nestedUnkeyedContainer) typecheck and decode. Test fixtures checked by hand: both epoch constants in 09.5 are right for the ISO strings given (1785748500 and 1798156800); `.convertFromSnakeCase` maps `stop_id` to `stopId`, so `stopID` is the one property that still fails, as the README says; keyNotFound's codingPath stops at the container, as the stub comment says. Every stub fails its tests by construction (synthesized keys do not match, raw value enum throws, `.missing` for all three states, default decoder, empty string).

Edits:
- modules/09-codable/probes/predict.swift, snippet 1 comment: "A Date, encoded by a decoder you did not configure." -> "A Date, encoded by an encoder you did not configure." Reason: the snippet calls `encoder.encode`.

Open questions: none.

## 10-classes-and-arc

Checks run: all 7 blocks in probes/errors.swift compiled, diagnostics match verbatim. `make probe CH=10 P=predict|cycle|errors` run; `P=dangling ARGS=unowned` prints exactly the fatal error the README row quotes (address varies, as the row says) and `ARGS=weak` prints "Unexpectedly found nil while unwrapping an Optional value". The Socket sample compiled at -Onone and -O prints "close db" at the closing brace both times. Tests read: every suite has distinct expected values; stubs fail for the stated reasons (0, no closure installed, [], unchanged document). docs/diagrams/arc-and-cycles.md exists.

Edits:
- modules/10-classes-and-arc/exercises/Exercises.swift line 5: "// Run: swift test --filter 10" -> "// Run: swift test --filter Chapter10Tests". Reason: the Makefile and CONTRIBUTING measure that `--filter 10` also selects tests from other chapters (17 tests instead of 15); the README already says `Chapter10Tests`.

Open questions:
- README "Swift's answer", Socket sample comment: "close db prints here, at this brace, every run". The language only promises release after the last use, not at the closing brace (that is why `withExtendedLifetime` exists); measured at -O on this toolchain it did print at the brace, so left as is.
- Test `screenDeallocatesAfterScopeExit` and `dropsDeallocatedListener` rely on scope end releasing a local; true in the debug builds `swift test` makes. Not changed.

## 11-isolation

Checks run: all 9 blocks in probes/errors.swift and both blocks in probes/regions.swift uncommented one at a time inside a copy of the whole file and compiled fully (`swiftc -c`, since region diagnostics come from a SIL pass); every diagnostic and note matches verbatim. `make probe CH=11 P=predict|reentrancy|regions|errors` all run; reentrancy prints `loads: 2` as the Done when item says. Compiler check: a `@MainActor` class, final or not, is accepted where `some Sendable` is required. Tests read: the ledger suite really re-enters from the audit hook; the tag suite is off the main actor and the stub's `""` fails it; every stub fails for the stated reason.

Edits:
- modules/11-isolation/README.md, Swift's answer: "A class qualifies only by being `final` with every stored property immutable and `Sendable`, or by taking the `@unchecked Sendable` escape hatch, which is you promising a lock the compiler cannot see." -> "A class qualifies only by being `final` with every stored property immutable and `Sendable`, by being isolated to a global actor such as `@MainActor`, or by taking the `@unchecked Sendable` escape hatch, which is you promising a lock the compiler cannot see." Reason: with "only" the sentence excluded the chapter's own `Console` and the stub's `Dashboard`, both `@MainActor` classes, which the compiler treats as `Sendable` (verified).
- modules/11-isolation/tests/ExercisesTests.swift line 166 (doc comment): "If `tag()` reads anything the main actor owns, this file stops compiling." -> "... the exercise file stops compiling." Reason: the diagnostic lands in exercises/Exercises.swift, not in the test file.

Open questions:
- Retrieval checkpoint 4 (`@MainActor a()` calls `nonisolated b()` calls `@MainActor c()`): the answer changes once `NonisolatedNonsendingByDefault` (SE-0461) is on; it is an upcoming feature, off by default on this toolchain, so the question is still well posed. No edit.
- probes/errors.swift blocks 1 and 2 redeclare `Tripmeter` next to the live one, so uncommenting them also prints "invalid redeclaration of 'Tripmeter'" above the quoted error. The quoted error still appears. No edit.

## 12-async-await

Checks run: all 7 diagnostic blocks in probes/errors.swift uncommented one at a time and fully compiled, verbatim match (blocks 6 and 7 are the SIL pass ones, as the probe header says). Both continuation misuse messages reproduced on this toolchain, including the `CheckedContinuation.swift:172` line number the table quotes. README samples (fetchHeadline, bulletin with await inside interpolation, crawl, poll) compile. `make probe CH=12 P=predict|continuation|tree|errors` run; tree output shows the three claims (children start at declaration, group brace joins, cancel reaches owned child and not the detached one). Tests read: time limits present; the throwing group suite really needs the siblings to be started and then abandoned; each stub fails for its stated reason (empty string, 0, [], 0, nil, [:]).

Edits: none.

Open questions: none.

## 13-swiftui-state

Checks run: all 8 blocks in probes/errors.swift compiled (6 through the whole file script, blocks 2 and 4 by hand because they hold two declarations), every diagnostic matches verbatim. README samples (PressView, `@Observable @MainActor final class Cart`, `@State private var cart = Cart()`, `@Bindable` child) typecheck against the macOS 26 SDK. `make probe CH=13 P=predict|errors` run. The Stretch `-dump-macro-expansions` command runs and its output contains `access(keyPath:)` and `withMutation(keyPath:)`. Tests read: four suites, distinct expected values, every stub fails (false/no-op, `.constant(0)`, `[]`, `nil`). preview-app/README.md read, not built.

Edits:
- modules/13-swiftui-state/README.md, Where it goes wrong: "make probe CH=13 P=diagnostics" -> "make probe CH=13 P=errors". Reason: the probe file is probes/errors.swift; there is no diagnostics.swift, so the documented command fails with "No such probe".
- modules/13-swiftui-state/README.md, Swift's answer: "`Cart()` runs on every rebuild, and every `Cart` after the first is built and immediately discarded." -> "`Cart()` runs every time the struct is constructed, and every `Cart` after the first is built and immediately discarded." Reason: the view's init (and so the `@State` initial value expression) runs when the parent constructs the view, not when the view's own state change re-reads `body`; the previous paragraph already states the precise rule, this sentence contradicted it.

Open questions:
- Same section, opening paragraph: "When state changes it builds a new one" (a new view struct). A change to the view's own `@State` re-evaluates `body` on the stored value without calling the struct's init again; a parent re-evaluating its body is what constructs a new child. Left as is because retrieval checkpoint 2 depends on the author's intended reading.
- README Predict excerpt shows `onChange: { tally.fired += 1 }`; the probe needs `MainActor.assumeIsolated` around that under strict concurrency. It is an excerpt of the probe, not a standalone sample, so left as is.

## 14-swiftui-app

Checks run: blocks 2, 6, 8 of probes/errors.swift verified through the whole file script and blocks 3, 4, 5, 7 by hand; every diagnostic and note matches verbatim. Block 1 (the SwiftDataMacros plugin message) needs xcode-select at CommandLineTools, which needs sudo, so it was not reproduced. README samples typechecked with stand-ins for the undefined names: App with `@State` model, `Scene.onChange(of: phase) { _, incoming in }`, `.environment(shell)`, `NavigationStack(path:)`, `.navigationDestination(for:)`, `.sheet(item:)`, `@Model`, and the accessibility pair all typecheck; `@Query(sort:order:)` and `@Environment(\.modelContext)` typecheck with Xcode's toolchain (/usr/bin/swiftc, Swift 6.3.3) but not with the swiftly 6.2 toolchain, see open questions. `make probe CH=14 P=predict|errors` run. Tests read: five suites, distinct expected values, every stub fails for its stated reason (`Data()`/`[]`, depth `-1`, no state change, `[]`, `""`). preview-app/README.md read, not built.

Edits:
- modules/14-swiftui-app/preview-app/README.md: deleted the opening paragraph "Chapter 14 has not been written yet. This page is the shape its preview app will take, written now so that the canonical tree is real on a fresh clone and so the chapter's author has the constraint in front of them." Reason: the chapter is written and its Done when list points here; the paragraph was stale.
- modules/14-swiftui-app/exercises/EntryList.swift line 14 (doc comment): "Four states, not a `Bool` and an optional array. Two of the four are the" -> "Five states, not a `Bool` and an optional array. Two of the five are the". Reason: `LoadState` has five cases (idle, loading, empty, loaded, failed).
- modules/14-swiftui-app/README.md, Exercises item 3: "An injected closure, four states, no network." -> "An injected closure, five states, no network." Same reason.

Open questions:
- On this machine `swift`/`swiftc` resolve to the swiftly swift-6.2-RELEASE toolchain, and under it `import SwiftData` loads `@Model` but not the SwiftUI overlay: `@Query` is "unknown attribute" and `\.modelContext` does not resolve. Xcode 26's own toolchain (Swift 6.3.3) accepts the README sample. Nothing in the chapter asks the learner to compile `@Query` outside Xcode, so no edit, but the verified: line's "swift-6.2-RELEASE" cannot have covered that sample on the command line.
- preview-app/README.md says "a router is a pure function from a value to a screen name", while the exercise's `AppRouter` is an `@Observable` class that owns the path. Left as is.
- README row 1 of Where it goes wrong (the plugin message) was not reproduced, see above.

## Build

The repo's own .build is stale (its module cache was made when the checkout lived at ~/swift-academy, so `swift build` there fails with "PCH was compiled with module cache path ... missing required module 'SwiftShims'"; `make clean` fixes it, not run here because another agent shares the checkout). A clean `swift build --build-tests --scratch-path <scratchpad>/build` at the root: Build complete! (67.32s), zero errors, all 28 targets. No test was run against a solution; no implementation was added; no test expectation was changed.
