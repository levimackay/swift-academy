---
title: Legacy Swift, the code you will read and not write
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Legacy Swift

This course teaches one way to do each thing. The internet teaches six, and
five of them are older than the one you learned. Every mechanism below still
compiles, most of it still ships in production, and all of it will appear in
the first real codebase you open and in the first Stack Overflow answer you
find.

The purpose here is recognition and one paragraph of judgment each, not
fluency. You should be able to read it, say what it was for, say what replaced
it, and say whether it is a problem when you meet it. You should not write new
code with it.

One rule for all of it: **age is not wrongness.** A 2021 codebase using
`ObservableObject` is not badly written, it is correctly written for 2021.
What makes a choice wrong today is picking it today with the alternative
available.

---

## 1. `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`

The Combine era observation mechanism, and by volume the single most common
thing you will meet.

```swift
import Combine
import SwiftUI

final class CartStore: ObservableObject {
    @Published var items: [String] = []
    @Published var isCheckingOut = false
}

struct CartScreen: View {
    @StateObject private var store = CartStore()
    var body: some View { Text("\(store.items.count)") }
}
```

**What it was for.** Before the Observation macro there was no way to make a
reference type's mutations invalidate a view, so SwiftUI leaned on Combine.
`ObservableObject` gives the type an `objectWillChange` publisher, `@Published`
fires it in the property's `willSet`, and `@StateObject` owns the instance for
a view identity while `@ObservedObject` merely holds one somebody else owns.

**What replaced it.** `@Observable` plus `@State`.

| Combine era | Now |
|---|---|
| `class Store: ObservableObject` with `@Published` on each property | `@Observable final class Store` with plain stored properties |
| `@StateObject private var store = Store()` | `@State private var store = Store()` |
| `@ObservedObject var store: Store` | a plain `let store: Store`, or `@Bindable var store: Store` for bindings |
| `@EnvironmentObject var store: Store` | `@Environment(Store.self) private var store` |

**Why it matters, and it is not only tidiness.** `objectWillChange` is one
publisher for the whole object, so every view observing the object is
invalidated when any property changes. `@Observable` records which key paths
`body` actually read and invalidates only the readers of the key path that was
written. A list screen that reads a title and a detail screen that reads a
body are independent under `@Observable` and coupled under `ObservableObject`.
That is a performance difference that grows with the object.

**The Swift 6 problem.** `ObservableObject` conformance carries a
`Sendable`-hostile shape: the publisher, the subscribers, and the main-thread
delivery assumption are all conventions rather than isolation, so a codebase
migrating to strict concurrency hits its worst diagnostics in exactly these
types. That is the practical reason Combine was cut from this course rather
than merely deprioritized.

**When you meet it.** Leave it. Do not migrate a working screen to
`@Observable` as a side quest; migrate when you are already changing the type
for another reason. Mixing the two in one view is where the confusing bugs
live, and the compiler helps: `@StateObject` on an `@Observable` type fails
with `generic struct 'StateObject' requires that 'Cart' conform to
'ObservableObject'`.

**MVVM, and what is actually true in 2026.** What survives from MVVM is
correct: a model type separate from the view, holding the state and the rules,
testable without a screen. What does not follow is one view model per view.
Where the view is already a value recomputed from state, a per view class
forwarding six properties buys nothing and is a layer you keep in sync.

Here is the paragraph, for when you are asked out loud. I keep state in
`@Observable` `@MainActor` model types that own their own rules, and views own
only the state nobody else needs, in `@State`. I do not write a view model per
view, because the view is already a function of state and the extra layer
mostly forwards. What I keep from MVVM is the separation: the model is
testable with no screen. In a codebase already on `ObservableObject` I match
the local style, because a half converted codebase is worse than either one.

---

## 2. Combine itself

`Publisher`, `Subscriber`, `AnyCancellable`, `sink`, `assign`,
`CurrentValueSubject`, `PassthroughSubject`, `.debounce`, `.combineLatest`.

**What it was for.** Reactive streams, before `AsyncSequence` existed. Apple's
answer to RxSwift, introduced with SwiftUI in 2019.

**What replaced it.** `AsyncSequence` and `AsyncStream` for streams,
`@Observable` for object observation, and structured concurrency for the
composition operators.

**Status.** Frozen. It receives no new API, its `Sendable` story under Swift 6
is poor, and the framework's core types predate the concurrency model that
would make them safe.

**Where it is still genuinely the answer.** Two places. Some Apple APIs still
vend publishers and nothing else, and `.debounce` over user input has no
one-line async equivalent (the async version is a `Task` you cancel and
restart, which is more code and clearer code). Neither justifies learning the
operator catalogue.

**When you meet it.** Read the operator chain top to bottom as a pipeline. The
only thing you need to know that is not obvious from the names: an
`AnyCancellable` cancels on `deinit`, so a subscription stored in a local
variable is dead immediately, and a subscription stored in a `Set<AnyCancellable>`
on the object lives as long as the object. Chapter 10's model applies exactly.

---

## 3. GCD: `DispatchQueue`, `DispatchGroup`, semaphores

```swift
DispatchQueue.global(qos: .userInitiated).async {
    let result = expensive()
    DispatchQueue.main.async { label.text = result }
}
```

**What it was for.** All concurrency, from 2009 to 2021. A queue is a
serialization mechanism and threads are borrowed from a pool.

**What replaced it.** `actor` for serialized state, `@MainActor` for the main
thread, `Task` and `TaskGroup` for the work.

**The mapping that matters:**

| GCD | Swift concurrency |
|---|---|
| `DispatchQueue.main.async { }` | `@MainActor`, or `await MainActor.run { }` |
| a private serial queue guarding state | an `actor` |
| `DispatchGroup` plus `notify` | `withTaskGroup`, or `async let` and `await` |
| `DispatchSemaphore` to limit concurrency | `withTaskGroup` with a bounded in-flight count |
| `DispatchQueue.asyncAfter` | `try await Task.sleep(for:)` |

**The one thing you must never do.** `DispatchSemaphore.wait()` inside an
`async` function. It blocks a cooperative pool thread that the runtime assumes
is never blocked, and with a small pool that is a deadlock, not a slowdown.
This is the single most common way a half-migrated codebase hangs. If you see
a `semaphore.wait()` next to an `await`, that is the bug.

**When you meet it.** GCD code in a Swift 6 target compiles fine and its
closures become `@Sendable`, so the diagnostics you get are real captured-state
problems that were always there and were previously invisible.

---

## 4. Completion handlers, and `withCheckedContinuation`

```swift
func loadUser(id: Int, completion: @escaping (Result<User, any Error>) -> Void)
```

**What it was for.** Asynchrony before `async`. The callback pyramid, error
handling by convention, and cancellation by a token you passed everywhere.

**What replaced it.** `async throws`.

**The bridge you will actually write.** When you must call a completion
handler API from async code:

```swift
func loadUser(id: Int) async throws -> User {
    try await withCheckedThrowingContinuation { continuation in
        loadUser(id: id) { result in continuation.resume(with: result) }
    }
}
```

**The rule that makes it safe: resume exactly once, on every path.** Resuming
twice traps at runtime. Never resuming leaks the task forever, which presents
as a spinner that never stops. `withCheckedContinuation` is the checked
variant and it is the one to use: it detects both mistakes and tells you. Its
unchecked sibling exists for hot paths and costs you the diagnosis.

Also note what a continuation does not give you: cancellation. The completion
handler API has no idea the task was cancelled. Use
`withTaskCancellationHandler` if the underlying API has a cancel method, and
accept that it does not if it has none.

**When you meet it.** Apple's own frameworks mostly ship async overloads now,
generated automatically for Objective C APIs with the right shape. Check for
one before writing a continuation.

---

## 5. Class inheritance, `override`, `final`, `super`

**What it was for.** The same thing it is for in C#. Swift has it, fully:
single inheritance, `override`, `super`, designated and convenience
initializers, and required initializers.

**Why this course does not teach it.** Not because it is broken, but because
reaching for it is the specific C# reflex that keeps a Swift codebase from
becoming Swift. Chapter 04 teaches protocols and extensions as the composition
mechanism, and chapter 10 prices what a class buys. Between them, the case for
a class hierarchy in new Swift is narrow: you need it for UIKit and AppKit
interop, and for the rare case of genuinely shared stored state plus shared
behavior.

**The one detail worth knowing before you read it.** A method declared only in
a protocol extension, and not in the protocol itself, dispatches statically.
So the "override" you think you see may not be one, and the behavior depends
on the static type of the variable rather than the dynamic type of the value.
That is chapter 04's material and it is the single most surprising dispatch
rule in the language.

`final` on a class enables devirtualization and is worth writing by default.
Every class in this repo is `final` for that reason.

---

## 6. `@objc`, `dynamic`, KVO, and the delegate pattern

**What it was for.** Objective C interop. `@objc` exposes a Swift symbol to
the Objective C runtime, `dynamic` forces dispatch through it, and KVO
(`observe(_:options:changeHandler:)`) is the runtime's property observation
mechanism, built on that dispatch.

**What replaced it.** `@Observable` for observation. Closures and protocols
for callbacks.

**Where you still need it.** Anything that talks to a framework written in
Objective C. `@objc` on a selector target, `@objc` on a protocol you want a
weak reference to (a Swift protocol must be `AnyObject` constrained or
`@objc` for `weak` to apply), and `NSObject` subclassing for anything the
older frameworks instantiate for you.

**The delegate pattern.** `weak var delegate: (any FooDelegate)?` is the UIKit
callback idiom and it is still correct where it appears. The `weak` is not
decoration: the delegate almost always owns the object it is a delegate of, so
a strong delegate reference is the retain cycle from chapter 10, drawn as an
API convention.

---

## 7. `UIViewRepresentable` and `UIViewControllerRepresentable`

**What it is for.** Wrapping a UIKit view so SwiftUI can use it. Not legacy in
the sense of deprecated, legacy in the sense that it is the escape hatch to
the older framework.

The shape: `makeUIView(context:)` builds it once, `updateUIView(_:context:)`
pushes new state into it on every SwiftUI update, and a nested `Coordinator`
class carries the delegate conformances, because a SwiftUI view struct cannot
be a delegate of anything (it is a value, and it is discarded).

**When you need it.** A control SwiftUI does not have. As of 2026 that list is
much shorter than it was, but it is not empty: rich text editing, some camera
and map configurations, and anything with a UIKit-only delegate surface.

**The thing that goes wrong.** `updateUIView` runs on every SwiftUI update,
which is often. Setting a property that triggers a layout pass, or resetting
state the user is currently editing, produces a control that fights the user.
Compare before you assign.

---

## 8. XCTest

```swift
import XCTest

final class ParserTests: XCTestCase {
    func testDecodesEmptyFeed() throws {
        XCTAssertEqual(try parse(empty).posts.count, 0)
    }
}
```

**What it was for.** All testing, until Swift Testing shipped.

**What replaced it.** Swift Testing: `@Test`, `@Suite`, `#expect`, `#require`,
parameterized tests, and traits. This repo uses it exclusively.

**The mapping:**

| XCTest | Swift Testing |
|---|---|
| `class X: XCTestCase`, methods named `test...` | `@Suite struct X`, functions marked `@Test` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTUnwrap(x)` | `try #require(x)` |
| `XCTAssertThrowsError` | `#expect(throws: MyError.self) { }` |
| `setUp` / `tearDown` | `init` and `deinit` on the suite type |
| `XCTestExpectation` | `confirmation()` |
| running serially by default | running in parallel by default |

**Two differences that bite.** Swift Testing runs in parallel in one process
by default, which is why a `fatalError` anywhere takes down the whole run and
why the ordering of reported failures is nondeterministic. And `#expect` is a
macro over an ordinary expression, so it reports the values of the
subexpressions on failure without you writing a message.

**Where XCTest is still required.** UI tests. `XCUIApplication` and the whole
UI testing surface are XCTest only, so a project with one XCUITest has both
frameworks in it, in different targets. That is normal and not a migration
you failed to finish.

---

## 9. Quick recognition table

If you see it, this is what it is.

| Sight | Era | Read it as |
|---|---|---|
| `@Published var` | 2019 to 2023 | a stored property with object-wide invalidation |
| `.sink { }` and `store(in: &cancellables)` | 2019+ | a subscription whose lifetime is the cancellable's |
| `DispatchQueue.main.async` | pre 2021 | `@MainActor` |
| `completion: @escaping (Result<T, Error>) -> Void` | pre 2021 | `async throws -> T` |
| `@objc dynamic var` plus `observe(\.foo)` | pre 2023 | KVO, replaced by `@Observable` |
| `class VC: UIViewController` | any | UIKit, out of scope for this course |
| `func testFoo()` in an `XCTestCase` | pre 2024 | `@Test func foo()` |
| `weak var delegate:` | any | still correct, and still for the same reason |
| `semaphore.wait()` near an `await` | any | a bug |

---

Related: [bridge.md](bridge.md), [glossary.md](glossary.md),
[testing-policy.md](testing-policy.md),
[core-data-literacy.md](core-data-literacy.md).
