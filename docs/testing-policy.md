---
title: Testing policy
kind: specification
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Testing policy

Two audiences, and the rules differ.

**Part A** is what the course's own test suites may and may not assert. It is
binding on anyone authoring a chapter or a project, because these tests are
the grading mechanism and a bad one either lets a wrong answer through or
fails a right one.

**Part B** is what you should test in your own code, starting with the
capstone. It is advice with reasons, and its main job is to stop you spending
a week discovering which tests are worth writing.

---

# Part A: rules for the course's tests

## A1. Two assertions, distinct expected values

Every exercise's test suite contains at least two assertions with **different
expected values**.

This is what makes sentinel stubs safe. A stub returns a compiling wrong value
rather than calling `fatalError`, because a `fatalError` aborts the whole
parallel run with `error: Exited with unexpected signal code 5` and prints no
summary line, and the scoreboard is the point. The cost of a sentinel is that
a constant return could accidentally satisfy a single assertion. Two
assertions with distinct expected values close that mechanically, at zero
cost.

A suite that asserts `#expect(f(1) == 0)` and `#expect(f(2) == 0)` has two
assertions and one expected value. That is one assertion wearing a disguise
and it will be sent back.

## A2. One test per exercise fails a plausible first implementation

Not only an empty one. Design the stumble in.

The stumbles that pay: negative zero, the empty collection, a multi scalar
grapheme, integer overflow, a tie in a sort, an off-by-one at both bounds, a
key that is present with a `nil` value versus a key that is absent.

Chapter 01's warmest-station test with a negative-only input and chapter 10's
`#expect(survivors.first === kept)` are the reference examples. Each one
passes for the naive implementation right up to the input that reveals the
missing case.

## A3. Never assert exact diagnostic text

Wording drifts between toolchain releases, and a test that pins it fails on
an upgrade for a reason that is not a regression.

Diagnostics belong in the chapter's `Where it goes wrong` table, pasted
verbatim from that chapter's `probes/errors.swift`, next to a `verified:`
line naming the toolchain. That is the place where staleness is a visible
documentation bug rather than a red suite.

What a test *may* assert about failure: that a specific case of **your own**
error type was thrown, and its payload.

```swift
#expect(throws: FeedError.missingField(name: "author")) { try parse(bad) }
```

## A4. Never assert a value that varies per run

Pointer addresses, process ids, wall clock durations, and dictionary iteration
order are all different on the next run. Verified: two consecutive runs of
chapter 10's dangling-reference probe printed `0xc32d208e0` and `0xb9ccc0ec0`.

A test that needs an order sorts first, or asserts on a `Set`. A test that
needs a duration injects a clock.

## A5. The public surface is the contract

A test imports the exercise target and calls the declared name. It does not
reach into private state, and it does not reimplement the algorithm it is
grading. If the test computes the expected value the same way the answer does,
it grades nothing.

`@testable import ChapterNN` is used so that `internal` declarations are
visible without every exercise being `public`. It is not permission to assert
on implementation details.

## A6. Tests may not contain the answer

This is the tutor rule applied to the grading mechanism. A test that builds
the expected value by doing the work is an answer key in a file the learner is
told to read.

Concretely: write expected values as **literals** wherever a literal is
possible. `#expect(summarize(readings).warmest == "pier")` and not
`#expect(summarize(readings).warmest == readings.max(by: ...)?.station)`.

## A7. Test names describe the behavior, not the function

`@Test("calls zero zero, not rated 0")` and not `@Test("testLabelForZero")`.
The suite output is the scoreboard, and a scoreboard reads as a list of
promises the code has not kept yet.

## A8. The suite name carries the chapter

`@Suite("10 weak registry")` inside a test target named `Chapter10Tests`. The
chapter gate is `swift test --filter Chapter10Tests`, never `--filter 10`,
because the filter regex matches the source line embedded in each test ID.
Measured: `--filter 10` runs 17 tests, `--filter Chapter10Tests` runs 15.

## A9. Project tests pin the API by name

A project's tests import the public API the spec describes, so the shape is
pinned and a wrong-language solution does not compile. Project 01's tests
mention `Grid`, `subscript`, and `step()`, so a class-based solution fails the
copy test rather than failing to be noticed.

Because projects are separate packages, a project whose types do not exist yet
fails to build in isolation without reddening any chapter. That is the
expected state of an unstarted project and the CI workflow says so.

If a scaffold must pre declare something for the package to parse, that
declaration is part of the answer and the project's `SPEC.md` says so out
loud, rather than pretending the tests pinned it.

## A10. Nothing in a test is a `fatalError`, a `try!`, or a force unwrap

`try #require(x)` unwraps and reports. A force unwrap in a test turns a
readable failure into a crash that takes the run down.

---

# Part B: what to test in your own code

The short version: **test the things that are cheap to test and expensive to
get wrong, and stop.** On a solo project, a test suite that costs more to
maintain than the bugs it catches is a net loss, and there is nobody to
overrule you when it happens.

## B1. Test exhaustively

| Thing | Why |
|---|---|
| Model types and their invariants | Pure, fast, and where the real logic is. |
| State transitions | "Can this reach that state" is where the bugs are, and it is free to assert. |
| Decoding, and every failure branch | The data boundary is hostile by definition and the failure modes are enumerable. |
| Business rules | Anything with a "should" in the spec. |
| Anything a bug already appeared in | Once, always. |

## B2. Test with judgment

**Async code.** Worth testing, and the way to make it fast is to inject the
clock rather than to sleep. A timeout test that sleeps for the timeout takes
the timeout; a timeout test over an injected clock takes microseconds. Test
cancellation explicitly: cancel the task and assert the effect, because
cooperative cancellation is a thing your code has to actually check.

**Dependency failure branches.** Every injected dependency needs a double that
fails, and a test that the failure is handled. The success path gets tested by
you using the app. The failure path does not.

**Concurrency and isolation.** Mostly the compiler's job on this toolchain,
which is the point of chapter 11. Do not write tests to prove `Sendable`
conformance; the compiler already refused to build the alternative.

## B3. Do not test

**View bodies.** Unit testing a SwiftUI `body` is mostly wasted effort. The
body is a description, its assembly is SwiftUI's business, and the test you
can write asserts the shape of a tree that is an implementation detail of your
layout. Use previews and the simulator for visual iteration. Move the logic
out of the body and test that instead, which is most of the value the test was
supposedly going to provide.

**Snapshot tests, on a solo project.** They are a real technique on a team
with a review process, where a diff in an image is a conversation. Alone, they
are a suite that goes red every time you deliberately change a color, and the
fix is always to re-record, so within a month re-recording is reflexive and
the suite asserts nothing.

**More than one XCUITest, before shipping.** Write exactly one: launch, do the
core thing, assert it happened. It catches the class of failure where the app
does not start, which no unit test can see. A second one costs the same as the
first and catches almost nothing more, and the maintenance cost of a UI suite
is superlinear in its size.

**Getters, setters, and the compiler.** A test that `struct.name` returns what
you assigned is a test of Swift.

## B4. Designing a seam

The capstone requires a test double for every dependency, so the seam has to
exist before the test does. Three shapes, in the order to reach for them:

1. **A closure, or a small struct of closures.** The default. Zero ceremony, no
   protocol, and the double is a literal written inline in the test.
   `init(load: @escaping @Sendable () async throws -> [Row])`.
2. **A protocol.** Once there are two or more real implementations, not
   before. The C# reflex of one protocol per dependency plus a container is
   named and rejected in chapter 14.
3. **`@Environment`.** For values scoped to a subtree of the view tree, where
   passing them through every initializer would be the worse cost.

The test asks a question of shape 1 that is worth internalizing: can I
construct the thing under test with fake behavior, in one line, without
importing anything? If not, the seam is in the wrong place.

## B5. When you believe a test is wrong

Tests written by a tutor contain bugs. The rule:

Write the case you believe is correct as a **new assertion** next to the one
you dispute. Run both. If both cannot pass, the test is wrong and you change
it, and the diff is the record of why. If both pass, your reading was wrong
and you have just added a test.

Do not file an issue against yourself. That is not a workflow.

---

Related: [how-this-repo-works.md](how-this-repo-works.md),
[legacy-swift.md](legacy-swift.md) section 8 for the XCTest mapping, and
[../CONTRIBUTING.md](../CONTRIBUTING.md).
