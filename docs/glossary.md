---
title: Glossary
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Glossary

Every Swift term this curriculum uses, defined for someone who already knows
Python and C#.

Each entry gives the definition, the nearest analogue in each language, and the
chapter that owns the term. "No analogue" means the concept does not exist in
that language, which is usually the most useful fact in the row.

Nearest analogue means nearest, not equivalent. Where the analogy breaks is
stated in the definition, and the long form comparison lives in
[`docs/bridge.md`](bridge.md).

**Jump to:** [A](#a) | [B](#b) | [C](#c) | [D](#d) | [E](#e) | [F](#f) |
[G](#g) | [H](#h) | [I](#i) | [K](#k) | [L](#l) | [M](#m) | [N](#n) | [O](#o) |
[P](#p) | [Q](#q) | [R](#r) | [S](#s) | [T](#t) | [U](#u) | [V](#v) | [W](#w) |
[X](#x) | [Z](#z)

## A

### `actor`

A reference type whose mutable state can only be reached through its own serial
executor, so all access to it is serialized. Calls from outside are `async`. An
actor is implicitly `Sendable`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A class plus a `lock`, except that an actor releases across `await` and a `lock` does not. | [`11-isolation`](../modules/11-isolation/README.md) |

### `actor hop`

The switch of execution from one isolation domain to another at an `await`. It
is not free, and it is why a tight loop calling one `await`ed actor method per
element is slower than one call passing the whole batch.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`12-async-await`](../modules/12-async-await/README.md) |

### `actor isolation`

The compile time property that a declaration belongs to an isolation domain. A
member of an actor is isolated to that instance unless marked `nonisolated`,
and access from outside must be awaited.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `actor reentrancy`

The rule that an actor is released at every `await` inside one of its methods,
so another message can run before the first resumes. It prevents deadlock and
it means state read before an `await` may be stale after it. Recheck invariants
after each `await`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; a `lock` is held across the whole body, which is why the intuition transfers badly. | [`11-isolation`](../modules/11-isolation/README.md) |

### `aliasing`

Two names referring to the same storage. Value semantics removes it by
construction; reference semantics is the deliberate reintroduction of it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `any`

The keyword marking an existential type. This repo enables the `ExistentialAny`
upcoming feature on every target, so the compiler requires the word at every
existential site and the cost becomes visible instead of implicit.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `AnyObject`

The protocol every class conforms to. `protocol P: AnyObject` restricts
conformance to classes, which is what makes a `weak var delegate: (any P)?`
legal.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `class` constraint on a generic parameter. | [`04-protocols`](../modules/04-protocols/README.md) |

### `App`

The protocol whose conforming type is marked `@main` and whose `body` returns a
`Scene`. It replaced the app delegate as the entry point.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `Program.Main`. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `ARC`

Automatic Reference Counting. Retain and release calls are inserted at compile
time, so deallocation is deterministic and `deinit` runs at a knowable point.
There is no tracing collector, so a reference cycle is never collected.

| Python | C# | Taught in |
| --- | --- | --- |
| CPython also refcounts, but a cycle collector cleans up cycles, so a Python developer has never had to break one. | A tracing garbage collector, so lifetime is not something you reason about. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `argument label`

The name written at the call site, which is part of the function's name.
`move(from:to:)` and `move(to:from:)` are different functions. Labels are load
bearing in Swift and are never omitted to save typing.

| Python | C# | Taught in |
| --- | --- | --- |
| Keyword arguments, which are optional at the call site. | Named arguments, which are optional at the call site. | [`02-functions`](../modules/02-functions/README.md) |

### `Array`

An ordered, integer indexed, copy on write value type with contiguous storage.
`var b = a` shares the buffer until either side writes.

| Python | C# | Taught in |
| --- | --- | --- |
| `list`, a reference object with no copy on assignment. | `List<T>`, a reference type with no copy on assignment. | [`06-collections`](../modules/06-collections/README.md) |

### `ArraySlice`

The slice type of `Array`, sharing the parent's storage and keeping the
parent's indices. Indexing a slice from zero is the classic off by everything
bug.

| Python | C# | Taught in |
| --- | --- | --- |
| A slice, which copies and reindexes from zero. | `Span<T>` or `ArraySegment<T>`. | [`06-collections`](../modules/06-collections/README.md) |

### `as?`

Conditional cast. Returns `Optional<T>`, giving `.none` when the dynamic type
is not `T`. `as!` traps instead, and `as` is the compile time form for casts
that always succeed.

| Python | C# | Taught in |
| --- | --- | --- |
| `isinstance` plus a manual branch. | `as`, which returns `null` on failure, versus a cast expression that throws. | [`01-optionals`](../modules/01-optionals/README.md) |

### `associated type`

A placeholder type declared inside a protocol, such as `Element` and `Index` on
`Collection`. It makes the protocol a family of types rather than one type, and
it is a generic parameter written on the inside.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Closest is `IEnumerable<T>`, but C# writes the parameter in angle brackets, which is why C# has no equivalent wall. | [`07-generics`](../modules/07-generics/README.md) |

### `associated value`

The payload a case carries, written `case failure(reason: String, code: Int)`.
Different cases can carry different payloads, which is what makes an enum a
domain model rather than a flag.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; you build a class hierarchy or a discriminated union by hand. | [`05-enums`](../modules/05-enums/README.md) |

### `async`

Marks a function that can suspend. It is part of the type, so `() async -> Int`
and `() -> Int` are different types, and an async function can only be called
from an async context.

| Python | C# | Taught in |
| --- | --- | --- |
| `async def`. | `async` methods, but C# permits `async void` and permits blocking on the result. Swift has neither. | [`12-async-await`](../modules/12-async-await/README.md) |

### `async let`

Declares a child task that begins immediately, and awaits it at the point of
first use. The scope cannot exit until it is resolved or cancelled, which is
what makes it structured.

| Python | C# | Taught in |
| --- | --- | --- |
| Binding the result of `create_task` and awaiting later, with no lifetime guarantee. | Starting a `Task` and awaiting it later, with no lifetime guarantee. | [`12-async-await`](../modules/12-async-await/README.md) |

### `AsyncSequence`

A sequence whose `next()` is async, consumed with `for await`. It is the
streaming counterpart to `Sequence` and the replacement for the reactive
pipelines an older codebase would use.

| Python | C# | Taught in |
| --- | --- | --- |
| An async generator consumed with `async for`. | `IAsyncEnumerable<T>` consumed with `await foreach`. | [`12-async-await`](../modules/12-async-await/README.md) |

### `AsyncStream`

The bridge that turns a callback or delegate based source into an
`AsyncSequence`, built from a continuation you yield values into and finish.

| Python | C# | Taught in |
| --- | --- | --- |
| An async generator with `yield`. | `Channel<T>`. | [`12-async-await`](../modules/12-async-await/README.md) |

### `attached macro`

A macro written as an attribute on a declaration, such as `@Observable` or
`@Model`. A freestanding macro is written with `#`, such as `#expect` and
`#Predicate`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `autoclosure`

`@autoclosure` wraps the argument expression in a closure automatically, so it
is evaluated lazily at the callee's discretion. `??` and `assert` use it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; `Lazy<T>` requires an explicit lambda at the call site. | [`02-functions`](../modules/02-functions/README.md) |

### `await`

Marks a potential suspension point. It does not start anything and it does not
block a thread; it says control may leave here and resume later, possibly on a
different thread and after other work has run.

| Python | C# | Taught in |
| --- | --- | --- |
| `await`. | `await`, similar in shape, but there is no `.Result`, no `.Wait()`, and no `GetAwaiter().GetResult()` to fall back on. | [`12-async-await`](../modules/12-async-await/README.md) |

## B

### `@Bindable`

Produces bindings into an `@Observable` reference model, so `$model.name`
works. It is the modern replacement for `@ObservedObject` in that role.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `@Binding`

A read and write reference to state owned somewhere else, made of a getter and
a setter rather than a stored value. It is how a child mutates a parent's state
without owning it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `ref` on a field, if `ref` could be stored. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `body`

The computed property returning a view's content. It is called whenever SwiftUI
decides the view may have changed, so it must be cheap, must be a pure function
of the view's state, and must not have side effects.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `borrowing`

A parameter modifier meaning the callee reads the value without taking
ownership. It is the default for most parameters and it becomes visible and
meaningful on noncopyable types.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `in`. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

## C

### `CancellationError`

The error thrown by `Task.checkCancellation()` and by cancellation aware calls
such as `Task.sleep`.

| Python | C# | Taught in |
| --- | --- | --- |
| `asyncio.CancelledError`. | `OperationCanceledException`. | [`12-async-await`](../modules/12-async-await/README.md) |

### `capture`

A closure's reference to a name from its enclosing scope. Captures are by
reference by default, so the closure sees later mutations of a captured `var`,
and captured variables are promoted to the heap when the closure escapes.

| Python | C# | Taught in |
| --- | --- | --- |
| Late binding by name, which is the classic loop variable capture surprise. | Captures the variable, not the value, with the same surprise before C# 5. | [`02-functions`](../modules/02-functions/README.md) |

### `capture list`

The `[weak self, count = self.count]` clause before a closure's parameters.
Each entry is evaluated at closure creation time, so `count =` snapshots a
value while `weak self` creates a weak edge rather than a snapshot.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `case`

One alternative of an enum. It may have a raw value, or associated values, but
never both.

| Python | C# | Taught in |
| --- | --- | --- |
| A member of an `Enum` class. | A named constant. | [`05-enums`](../modules/05-enums/README.md) |

### `CaseIterable`

Supplies `allCases` for an enum with no associated values. The compiler
synthesizes it, and it stops being synthesizable the moment a case carries a
payload.

| Python | C# | Taught in |
| --- | --- | --- |
| `list(MyEnum)`. | `Enum.GetValues`, which is reflection based. | [`05-enums`](../modules/05-enums/README.md) |

### `Character`

One extended grapheme cluster, which is what a reader perceives as a single
character. It can be many Unicode scalars and many bytes wide.

| Python | C# | Taught in |
| --- | --- | --- |
| No equivalent; `str[0]` yields one code point. | No equivalent; `char` is one UTF-16 code unit. | [`01-optionals`](../modules/01-optionals/README.md) |

### `class`

A reference type with inheritance, `deinit`, and identity. In this curriculum
it needs one of three justifications: an observable lifecycle, shared mutation
seen through two references, or inheritance and interop.

| Python | C# | Taught in |
| --- | --- | --- |
| The only kind of type. | The default kind of type. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `closure`

A function literal plus the storage it captured. Written `{ (x: Int) -> Int in
x + 1 }`, with types and `return` omitted where inferable.

| Python | C# | Taught in |
| --- | --- | --- |
| `lambda` (single expression only) or a nested `def`. | A lambda, with the same capture semantics for reference types. | [`02-functions`](../modules/02-functions/README.md) |

### `Codable`

A typealias for `Encodable & Decodable`. The compiler synthesizes the
conformance when every stored property is itself `Codable` and you declare it.

| Python | C# | Taught in |
| --- | --- | --- |
| No equivalent; serializers use runtime reflection over `__dict__`. | Attributes plus a reflection based serializer, resolved at runtime rather than compile time. | [`09-codable`](../modules/09-codable/README.md) |

### `CodingKeys`

A nested enum with `String` (or `Int`) raw values naming the keys on the wire.
Declaring it replaces the synthesized key set, so omitting a property from it
excludes that property.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `[JsonPropertyName]`. | [`09-codable`](../modules/09-codable/README.md) |

### `Collection`

Refines `Sequence` with stable indices, a `startIndex`, an `endIndex`, and non
destructive multi pass iteration. `BidirectionalCollection` adds backward
traversal and `RandomAccessCollection` adds O(1) index movement.

| Python | C# | Taught in |
| --- | --- | --- |
| `Sequence` from `collections.abc`. | `ICollection<T>` and `IList<T>`, though the index model is integer only. | [`06-collections`](../modules/06-collections/README.md) |

### `Combine`

Apple's reactive framework. It is effectively frozen, its `Sendable` story
under Swift 6 is poor, and Observation plus `AsyncSequence` covers its ground.
Read it, do not write it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Rx.NET. | [`docs/legacy-swift.md`](legacy-swift.md) |

### `compactMap`

Maps and drops the `nil` results in one pass, returning a collection of
unwrapped values. It is the idiomatic parse and discard failures pipeline.

| Python | C# | Taught in |
| --- | --- | --- |
| A comprehension with an `if` clause. | `Select` then `Where` then `Value`, by hand. | [`06-collections`](../modules/06-collections/README.md) |

### `Comparable`

Refines `Equatable` and requires `<`. The other three operators come free from
a protocol extension.

| Python | C# | Taught in |
| --- | --- | --- |
| `__lt__` plus `functools.total_ordering`. | `IComparable<T>`. | [`04-protocols`](../modules/04-protocols/README.md) |

### `computed property`

A property with a `get` and optionally a `set` and no storage. It is not a
method, has no parentheses at the use site, and cannot have parameters.

| Python | C# | Taught in |
| --- | --- | --- |
| `@property`. | A property with a getter body. | [`02-functions`](../modules/02-functions/README.md) |

### `@concurrent`

Marks an async function as running off the caller's actor, on the cooperative
pool. The dual of `nonisolated(nonsending)`, and new in Swift 6.2.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `conditional conformance`

`extension Stack: Equatable where Element: Equatable`. The conformance exists
only when the constraint holds, which is how `[Int]` is `Equatable` and `[() ->
Void]` is not.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; a generic type either implements an interface or does not. | [`04-protocols`](../modules/04-protocols/README.md) |

### `conformance`

A declaration that a type satisfies a protocol, written on the type or in an
extension. It is nominal, not structural: having the right methods is not
enough, the conformance must be declared.

| Python | C# | Taught in |
| --- | --- | --- |
| Duck typing means no declaration is needed. | Declared in the type's base list only; there is no way to add one after the fact. | [`04-protocols`](../modules/04-protocols/README.md) |

### `consuming`

A parameter modifier meaning the callee takes ownership, so the caller cannot
use the value afterward. On a noncopyable type with a `deinit`, this is what
makes resource release deterministic and single.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `continuation`

`withCheckedContinuation` and `withCheckedThrowingContinuation` bridge a
completion handler API into `async`. The checked forms trap if you resume twice
or never resume, which turns the classic bridging bug into a loud failure.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `TaskCompletionSource<T>`. | [`12-async-await`](../modules/12-async-await/README.md) |

### `cooperative cancellation`

`cancel()` sets a flag. It stops nothing on its own. Code that never reads
`Task.isCancelled` or calls `try Task.checkCancellation()` runs to completion
after being cancelled. A `CancellationToken` intuition transfers directly here,
which is a rare free transfer.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `CancellationToken`, which behaves the same way. | [`12-async-await`](../modules/12-async-await/README.md) |

### `cooperative thread pool`

The fixed width thread pool that runs Swift concurrency work, sized to the core
count. Blocking one of its threads (a semaphore, `Thread.sleep`) can starve the
very task you are waiting on, which makes blocking on async work a deadlock
rather than merely bad style.

| Python | C# | Taught in |
| --- | --- | --- |
| No equivalent; `asyncio` is one loop on one thread. | The thread pool, which grows under starvation. Swift's does not, so `.Result` style blocking has a worse failure mode here. | [`12-async-await`](../modules/12-async-await/README.md) |

### `copy-on-write`

The implementation technique behind the standard library's value types.
Assignment shares one buffer, and the first write checks
`isKnownUniquelyReferenced` and copies only when the buffer has more than one
owner. Reference counting is being used as a proof of uniqueness, not as a
memory strategy.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `CustomStringConvertible`

Supplies `description`, which is what `String(describing:)` and string
interpolation prefer. It is opt in, so a type without it interpolates as a
synthesized reflection dump.

| Python | C# | Taught in |
| --- | --- | --- |
| `__str__`. | `ToString`, which every type overrides from `object`. | [`04-protocols`](../modules/04-protocols/README.md) |

## D

### `Data`

A value type holding bytes, with copy on write storage. It is the input and
output type of the JSON coders and of `URLSession`.

| Python | C# | Taught in |
| --- | --- | --- |
| `bytes`, which is immutable, and `bytearray`. | `byte[]`, a reference type. | [`09-codable`](../modules/09-codable/README.md) |

### `data race`

Two threads accessing the same memory with at least one write and no
synchronization. It is undefined behavior. Swift 6 attacks this class of bug at
compile time.

| Python | C# | Taught in |
| --- | --- | --- |
| The GIL hides most of them and does not eliminate them. | Possible, and detected only by testing. | [`11-isolation`](../modules/11-isolation/README.md) |

### `decodeIfPresent`

Returns `nil` when the key is absent, where `decode` throws `keyNotFound`. Note
the distinction from a key present with a JSON `null`, which `decode` into an
optional handles.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`09-codable`](../modules/09-codable/README.md) |

### `DecodingError`

The typed failure set: `.keyNotFound`, `.typeMismatch`, `.valueNotFound`, and
`.dataCorrupted`. Each carries a `codingPath`, which names the exact location
in the document and is the most useful part of the error.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `JsonException`, with a path only sometimes. | [`09-codable`](../modules/09-codable/README.md) |

### `default parameter value`

A parameter with `= expr`. The expression is evaluated per call, at the call
site, so a mutable default is not shared between calls.

| Python | C# | Taught in |
| --- | --- | --- |
| Defaults are evaluated once at definition time, which is the mutable default argument trap. Swift does not have that trap. | Defaults must be compile time constants. | [`02-functions`](../modules/02-functions/README.md) |

### `defer`

Schedules a block to run when the current scope exits, by any path including a
thrown error. Deferred blocks run in reverse order of declaration and are
scoped, not block structured like `finally`.

| Python | C# | Taught in |
| --- | --- | --- |
| `try/finally`, or a context manager. | `finally`, or `using` for disposal. | [`08-errors`](../modules/08-errors/README.md) |

### `deinit`

The deallocation hook on a class. It runs when the last strong reference goes
away, at a deterministic point, which is why a `print` in `deinit` is
admissible evidence in a test that a cycle is gone.

| Python | C# | Taught in |
| --- | --- | --- |
| `__del__`, whose timing is not guaranteed. | A finalizer, which runs at an unpredictable time on a separate thread, if at all. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `dependency injection`

In SwiftUI, passing a collaborator through an initializer or through
`@Environment`. This repo injects a closure or a small protocol so a model can
be tested with no network and no database.

| Python | C# | Taught in |
| --- | --- | --- |
| Passing an object, or patching a module. | A container plus constructor injection, resolved at startup. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `designated initializer`

An initializer that fully initializes the type's own stored properties and then
calls a superclass designated initializer. `convenience` initializers must
delegate across to another initializer in the same class.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Any constructor; there is no designated versus convenience distinction, because C# permits observing a partially constructed object. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `Dictionary`

An unordered hashed value type whose `Key` must be `Hashable`. Iteration order
is not insertion order and it genuinely varies between runs because hashing is
seeded per process. Subscripting by key returns an `Optional`.

| Python | C# | Taught in |
| --- | --- | --- |
| `dict`, which has guaranteed insertion order since 3.7. | `Dictionary<K,V>`, unordered, and indexing throws instead of returning null. | [`06-collections`](../modules/06-collections/README.md) |

### `discardable result`

`@discardableResult` suppresses the warning that a returned value is unused.
The warning exists by default because ignoring a result is usually a bug.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`02-functions`](../modules/02-functions/README.md) |

### `do/catch`

The handling form. `catch` takes patterns, so you can match specific enum
cases, and with typed throws the compiler checks that the catches are
exhaustive.

| Python | C# | Taught in |
| --- | --- | --- |
| `try/except`, with `except` clauses matching classes. | `try/catch`, with `when` filters. | [`08-errors`](../modules/08-errors/README.md) |

### `dynamic dispatch`

A call resolved at runtime through a witness table (for `any P`) or a vtable
(for a non `final` class method). Marking a class `final` removes the vtable
indirection.

| Python | C# | Taught in |
| --- | --- | --- |
| Every attribute access. | Virtual and interface calls. | [`04-protocols`](../modules/04-protocols/README.md) |

## E

### `enum`

A type whose value is exactly one of a fixed set of cases, each of which may
carry its own associated values. This is a sum type, not a named integer, and
it is the main modeling tool the curriculum leans on.

| Python | C# | Taught in |
| --- | --- | --- |
| `enum.Enum`, which is a named constant set with no payloads. | `enum`, which is a named integer with no payloads. | [`05-enums`](../modules/05-enums/README.md) |

### `@Environment`

Reads a value supplied by an ancestor view or by the system, keyed by an
`EnvironmentValues` key path. It is the dependency injection channel of a
SwiftUI app.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Constructor injection from a container, except that it is resolved by position in the view tree. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `equality`

Structural sameness, tested with `==` from the `Equatable` protocol. Swift
synthesizes it for a struct or enum whose stored parts are all `Equatable`.

| Python | C# | Taught in |
| --- | --- | --- |
| `__eq__`, defaulting to identity when not written. | `Equals`, defaulting to identity for classes and to field comparison for structs. | [`04-protocols`](../modules/04-protocols/README.md) |

### `Equatable`

The protocol requiring `==`. Synthesized when all stored parts are `Equatable`
and you declare the conformance.

| Python | C# | Taught in |
| --- | --- | --- |
| `__eq__`. | `IEquatable<T>`. | [`04-protocols`](../modules/04-protocols/README.md) |

### `Error`

The empty protocol a thrown type must conform to. Any type can conform, and an
`enum` with associated values is the idiomatic choice because it makes the
failure set exhaustive.

| Python | C# | Taught in |
| --- | --- | --- |
| `BaseException`, a class hierarchy. | `Exception`, a class hierarchy. | [`08-errors`](../modules/08-errors/README.md) |

### `escaping closure`

A closure parameter marked `@escaping`, meaning its lifetime may outlive the
call. That is exactly when a stored closure can form a retain cycle, so
`@escaping` and capture lists are learned together.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Every delegate is effectively escaping; there is no non escaping form. | [`02-functions`](../modules/02-functions/README.md) |

### `exclusivity`

The rule that a variable cannot be accessed in two overlapping ways when one of
them is a write. It is what makes `inout` safe and what makes `swap(&a, &a)` an
error rather than a corruption.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `exhaustiveness`

The compiler requirement that a `switch` covers every case. It is what makes
adding an enum case surface every place that must change, and it is the reason
to avoid a `default` clause on your own enums.

| Python | C# | Taught in |
| --- | --- | --- |
| No checking. | No checking on `enum`; a `switch` expression can warn but the type is still an integer. | [`05-enums`](../modules/05-enums/README.md) |

### `existential`

A value of protocol type, spelled `any P`. The concrete type is not known
statically and type identity is discarded, so two `any P` values may be
different types and cannot be compared just because `P: Equatable`.

| Python | C# | Taught in |
| --- | --- | --- |
| Every value; types are checked at use. | An interface typed reference. | [`07-generics`](../modules/07-generics/README.md) |

### `existential box`

The runtime layout of `any P`: a three word inline buffer, a value witness
table pointer, and one protocol witness table pointer per protocol.
`MemoryLayout<any P>.size` is 40 on this toolchain. A value larger than three
words is heap allocated, so a copy can allocate.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `#expect`

Records a failure and continues. The message interpolates the evaluated sub
expressions, so a failing assertion reports what your function actually
returned without any answer key existing in the repository.

| Python | C# | Taught in |
| --- | --- | --- |
| A bare `assert` in `pytest`. | `Assert.Equal`. | [`docs/testing-policy.md`](testing-policy.md) |

### `explicit identity`

Identity you supply, with `.id(value)` or with `ForEach(items, id: \.id)`.
Changing the value resets the subtree's state deliberately, which is both a
tool and a bug source.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `ExpressibleByArrayLiteral`

The protocol that lets your own type be initialized from `[1, 2, 3]`.
Conforming requires supplying `ArrayLiteralElement` and `init(arrayLiteral:)`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A collection initializer, which needs `Add` plus `IEnumerable`. | [`06-collections`](../modules/06-collections/README.md) |

### `extension`

Adds methods, computed properties, initializers, nested types, and conformances
to an existing type, including one you do not own. It can never add a stored
property, because stored properties fix the type's memory layout at compile
time.

| Python | C# | Taught in |
| --- | --- | --- |
| Monkey patching, which can add anything including state. | Extension methods, which add only static methods and never conformances. | [`04-protocols`](../modules/04-protocols/README.md) |

## F

### `filter`

Keeps elements satisfying a predicate. Eager on `Array`, like `map`.

| Python | C# | Taught in |
| --- | --- | --- |
| `filter`, lazy. | `Where`, lazy. | [`06-collections`](../modules/06-collections/README.md) |

### `final`

Forbids subclassing and overriding, which lets the compiler devirtualize calls.
It is a reasonable default on classes you write.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `sealed`. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `flatMap`

Concatenates the sequences produced per element. On an optional it is the
flattening `map` instead, which is why the optional overload was renamed
`compactMap` on sequences.

| Python | C# | Taught in |
| --- | --- | --- |
| `itertools.chain.from_iterable`. | `SelectMany`. | [`06-collections`](../modules/06-collections/README.md) |

### `for case let`

`for case let .some(x) in values` iterates and matches in one step, skipping
elements that do not match the pattern.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`05-enums`](../modules/05-enums/README.md) |

### `force unwrap`

The postfix `!` operator. It returns the payload of `.some` and traps the
process on `.none`. It discards the proof obligation the type system created,
so it appears in this repo only where the lesson is why it is dangerous.

| Python | C# | Taught in |
| --- | --- | --- |
| `x` used directly and raising `AttributeError` later, at an unrelated line. | Dereferencing and getting a `NullReferenceException` at the use site. | [`01-optionals`](../modules/01-optionals/README.md) |

### `frozen enum`

An enum from a library compiled with library evolution that promises never to
gain a case, marked `@frozen`. Your own enums inside one module are effectively
frozen, which is why a plain exhaustive `switch` is right there.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`05-enums`](../modules/05-enums/README.md) |

### `function type`

`(Int, String) -> Bool` is a first class type. Argument labels are not part of
a function type, so assigning a function to a variable drops its labels.

| Python | C# | Taught in |
| --- | --- | --- |
| Callables are objects; the signature is untyped. | `Func<int, string, bool>` and delegates. | [`02-functions`](../modules/02-functions/README.md) |

## G

### `GCD`

Grand Central Dispatch, the queue based concurrency API that predates
async/await. `DispatchQueue.main.async` maps to `@MainActor`, and
`DispatchSemaphore` used to wait on async work is a deadlock on the cooperative
pool, not merely poor style.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | The thread pool plus `SynchronizationContext`. | [`docs/legacy-swift.md`](legacy-swift.md) |

### `generic constraint`

The `: P` in `<T: P>`, restricting what `T` can be and simultaneously telling
the body what it may call. Without a constraint the body can do almost nothing
with `T`.

| Python | C# | Taught in |
| --- | --- | --- |
| A bound `TypeVar`. | A `where T : IFoo` clause. | [`07-generics`](../modules/07-generics/README.md) |

### `generic parameter`

The `T` in `func f<T>(_ x: T)`. It is resolved at compile time and the compiler
can emit a specialized copy per concrete type, so a generic call has no
inherent runtime cost.

| Python | C# | Taught in |
| --- | --- | --- |
| A `TypeVar`, erased at runtime. | A type parameter, reified at runtime and shared for reference types. | [`07-generics`](../modules/07-generics/README.md) |

### `global actor`

A singleton isolation domain declared with `@globalActor`. `@MainActor` is the
one you use daily. A type isolated to a global actor is implicitly `Sendable`,
which is why so much SwiftUI code satisfies `Sendable` with nothing written.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `grapheme cluster`

The Unicode unit of a user perceived character. `"e\u{301}"` is two scalars and
one grapheme, which is why its `count` is 1 and its UTF-8 byte count is 3.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`01-optionals`](../modules/01-optionals/README.md) |

### `guard`

An early exit statement whose `else` branch must leave the scope. `guard let`
binds for the remainder of the enclosing scope rather than for a nested block,
which is what makes it different from `if let`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`01-optionals`](../modules/01-optionals/README.md) |

## H

### `Hashable`

Refines `Equatable` and requires `hash(into:)`. Required for `Set` members and
`Dictionary` keys. Equal values must hash equally, and Swift seeds the hasher
per process, so hash values are not stable across runs.

| Python | C# | Taught in |
| --- | --- | --- |
| `__hash__`. | `GetHashCode`. | [`04-protocols`](../modules/04-protocols/README.md) |

### `higher-order function`

A function taking or returning a function. In Swift these specialize when the
closure is known statically, so `map` with a literal closure usually costs
nothing at runtime.

| Python | C# | Taught in |
| --- | --- | --- |
| Same shape, always dynamic. | Same shape, with delegate invocation cost unless inlined. | [`02-functions`](../modules/02-functions/README.md) |

## I

### `Identifiable`

Requires an `id` whose type is `Hashable`. `ForEach` and `List` use it to
establish view identity, so getting `id` wrong shows up as animations and state
attaching to the wrong row.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `identity`

Which instance a reference points at, tested with `===`. Only reference types
have it, and asking for the identity of a struct is not a well formed question.

| Python | C# | Taught in |
| --- | --- | --- |
| `is`, and `id()`. | `ReferenceEquals`. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `if case`

`if case .failure(let reason) = state { }` matches one pattern and binds in a
branch. `guard case` is the early exit form and binds for the rest of the
scope.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`05-enums`](../modules/05-enums/README.md) |

### `implicit existential opening`

Passing an `any P` to a generic function `f<T: P>`, which recovers the concrete
type inside the callee's body. It is how you use an existential where its
associated types matter.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `implicitly unwrapped optional`

`String!` declares an `Optional` that force unwraps on every use. It exists for
Objective C interop and for the two phase initialization of outlets, not for
convenience.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`01-optionals`](../modules/01-optionals/README.md) |

### `Index`

A collection's position type, which is not necessarily an `Int`. A `String`
index and a slice's index prove the point: a slice keeps its parent's indices,
so a slice's `startIndex` is not `0`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`06-collections`](../modules/06-collections/README.md) |

### `indirect enum`

`indirect` inserts a box so a case can hold the enum itself, which is required
for recursive types such as a tree or an expression, since a value type cannot
contain itself directly.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`05-enums`](../modules/05-enums/README.md) |

### `init(from:)`

The manual decoding initializer, written when the synthesized one cannot
express the document: a defaulted field, a union, a date in two formats, or an
unknown enum case that must fall back rather than fail.

| Python | C# | Taught in |
| --- | --- | --- |
| `__init__` plus a dict, unchecked. | A custom `JsonConverter`. | [`09-codable`](../modules/09-codable/README.md) |

### `inout`

A parameter modifier meaning the argument is copied in, mutated, and copied
back out at return. It is not a pointer, and the caller must write `&` at the
call site. Overlapping `inout` accesses to the same storage are illegal.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `ref`, but `inout` has copy in copy out semantics rather than aliasing. | [`02-functions`](../modules/02-functions/README.md) |

### `isKnownUniquelyReferenced`

The standard library function that returns whether a class instance has exactly
one strong reference. It is how you implement copy on write in your own value
type.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `isolated conformance`

A conformance that is itself confined to an actor, letting a `@MainActor` type
conform to a nonisolated protocol without a `nonisolated` shim. Older material
states this is impossible, which is no longer true on this toolchain.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `isolated parameter`

A parameter written `isolated actor: MyActor`, which runs the function body
inside that actor's domain. `#isolation` is the expression giving the current
isolation, and Swift Testing's `@Test` macro expands to use it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `isolation domain`

The region within which state can only be touched serially: one actor instance,
one global actor, or nothing at all for `nonisolated` code. Every `await` is a
place where control may leave one domain and arrive in another.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `IteratorProtocol`

Requires `mutating func next() -> Element?`. The `nil` return is the
termination signal, which is why the iterator protocol needs no separate
`hasNext`.

| Python | C# | Taught in |
| --- | --- | --- |
| `__next__` plus `StopIteration`. | `IEnumerator<T>` with `MoveNext` plus `Current`. | [`06-collections`](../modules/06-collections/README.md) |

## K

### `keyed container`

`KeyedDecodingContainer` decodes by key. `nestedContainer(keyedBy:forKey:)`
reaches into a nested object without declaring a nested Swift type, and
`unkeyedContainer` handles arrays positionally.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `Utf8JsonReader` level access. | [`09-codable`](../modules/09-codable/README.md) |

## L

### `language mode`

The dialect a target is compiled in, set by `swiftLanguageMode` in the
manifest. This repo is at tools version 6.2, where Swift 6 mode with full
concurrency checking is the default, so the setting is never written down and
`-strict-concurrency=complete` (a Swift 5 migration flag) never appears.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A language version in the project file. | [`docs/how-this-repo-works.md`](how-this-repo-works.md) |

### `lazy`

`.lazy` wraps a collection so that `map` and `filter` build a view rather than
an array, fusing the passes and allocating nothing until the result is
consumed. This is the LINQ behavior a C# developer already expects by default.

| Python | C# | Taught in |
| --- | --- | --- |
| The default for `map` and `filter`. | The default for LINQ operators. | [`06-collections`](../modules/06-collections/README.md) |

### `lazy var`

A stored property initialized on first read. It is not thread safe, and it
cannot be `let`, and reading it from a `let` value of a struct is not allowed
because the read mutates.

| Python | C# | Taught in |
| --- | --- | --- |
| `functools.cached_property`. | `Lazy<T>`, which is thread safe by default. Swift's `lazy var` is not. | [`02-functions`](../modules/02-functions/README.md) |

### `let`

Binds a name to a value exactly once. On a value type it makes the entire value
immutable, transitively through every stored property. On a reference type it
makes only the reference immutable.

| Python | C# | Taught in |
| --- | --- | --- |
| No equivalent. `Final` in a type checker annotation is advisory. | `readonly` on a field, but that only pins the reference, never the object. | [`01-optionals`](../modules/01-optionals/README.md) |

## M

### `macro`

A compile time source to source transform that runs in a separate sandboxed
process, takes a syntax tree, and returns a syntax tree that is then type
checked normally. Nothing is hidden at runtime and the expansion is
inspectable, which is the whole reason Swift chose macros over runtime
reflection.

| Python | C# | Taught in |
| --- | --- | --- |
| Decorators and metaclasses, which act at runtime. | Source generators, which are the closest analogue, plus reflection, which is not. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `@MainActor`

The global actor for the main thread. On a type it isolates every member, on a
function just that function, and closures created in an isolated context
inherit it. It turns a documentation rule into a fact the compiler checks.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `SynchronizationContext` plus discipline, checked only by a runtime exception. | [`11-isolation`](../modules/11-isolation/README.md) |

### `MainActor.assumeIsolated`

A checked assertion that the current context already is the main actor, letting
you call main actor code synchronously. It traps if the assumption is false,
and it introduces no suspension, which is why it beats `Task { @MainActor in }`
for a delegate callback that is already on main.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `map`

Transforms each element into a new collection. On `Array` it is eager and
allocates, so a chain of three transforms allocates three arrays unless you go
through `lazy`.

| Python | C# | Taught in |
| --- | --- | --- |
| `map`, which is lazy and returns an iterator. | `Select`, which is lazy. | [`06-collections`](../modules/06-collections/README.md) |

### `marker protocol`

A protocol with no requirements that exists only to record a compile time fact,
and that has no runtime representation. `Sendable` is one, which is why you
cannot write `x is Sendable`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A marker interface, which does exist at runtime. | [`11-isolation`](../modules/11-isolation/README.md) |

### `memberwise initializer`

The initializer a `struct` gets for free, with one labeled parameter per stored
property in declaration order. It is internal by default, so a public struct
still needs its own public initializer.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; you write the constructor. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `MemoryLayout`

A compile time query for the `size`, `stride`, and `alignment` of a type.
`MemoryLayout<String>.size` and `MemoryLayout<String?>.size` are both 16, while
`Int?` is one byte wider than `Int`, which is direct evidence that `Optional`
uses spare bit patterns when a type has them.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `sizeof`, which requires an unsafe context. | [`01-optionals`](../modules/01-optionals/README.md) |

### `@Model`

The macro that makes a class persistable, rewriting its stored properties into
tracked accessors much as `@Observable` does, and adding the schema metadata.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | An entity class plus attributes and a `DbContext` registration. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `ModelActor`

An actor that owns its own `ModelContext` for background work, which is how
SwiftData expresses the thread confinement rule that Core Data enforced only by
convention.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `ModelContext`

The unit of work that tracks inserts, updates, and deletes and saves them to
the container. The view context is main actor isolated, and background work
goes through a `ModelActor`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `DbContext`. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `modifier order`

`.padding().background(.red)` and `.background(.red).padding()` produce
different results, because each modifier wraps the view it is called on rather
than setting a property on it. Modifiers are not a property bag.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | CSS style cascades do not apply; the nearest analogue is nesting containers. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `mutable global state`

A nonisolated global `var` is an error in Swift 6. The three honest fixes are
making it a `let`, isolating it to a global actor, or marking it
`nonisolated(unsafe)` with a real lock behind it. The Swift 5 `static var
shared` singleton does not compile.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `mutating`

A method modifier on a value type meaning the method may change `self`. It
changes the calling convention: `self` becomes an `inout` parameter, which is
why it cannot be called on a `let`, cannot be used as an escaping closure, and
is unavailable through an existential held in a `let`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `MVVM`

A naming convention, not a Swift feature. What survives is that a model type
separate from the view is correct. What does not follow is that every view
needs its own view model. This repo teaches an `@Observable` `@MainActor` model
owned by `@State`, and names MVVM explicitly so you have an answer when an
interviewer asks.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | The pattern most WPF and MAUI codebases use, with `INotifyPropertyChanged` underneath. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

## N

### `NavigationPath`

A type erased collection of `Hashable` route values representing the current
stack. Appending pushes, removing pops, and setting it wholesale performs a
deep link.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `NavigationStack`

The value driven navigation container. You bind it to a path and register
destinations with `navigationDestination(for:)`, so navigation state is data
you can save, restore, and test rather than a stack of view controllers.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `Never`

The uninhabited type. A function returning `Never` cannot return normally, so
the compiler treats a call to it as the end of the control flow path.
`fatalError()` returns `Never`.

| Python | C# | Taught in |
| --- | --- | --- |
| `typing.NoReturn`, checked only by the type checker. | No analogue. | [`01-optionals`](../modules/01-optionals/README.md) |

### `nil`

The literal for `Optional.none`. It is not a pointer value and it does not
inhabit non optional types, so `var s: String = nil` does not compile.

| Python | C# | Taught in |
| --- | --- | --- |
| `None`, which is a real object that any name can hold. | `null`, which any reference type can hold. | [`01-optionals`](../modules/01-optionals/README.md) |

### `nil coalescing operator`

`a ?? b` returns the payload of `a` when it is `.some`, otherwise evaluates and
returns `b`. The right side is an autoclosure, so it is not evaluated when the
left side has a value.

| Python | C# | Taught in |
| --- | --- | --- |
| `a if a is not None else b`, which always evaluates both operands unless written lazily. | `a ?? b`, the same operator with the same short circuiting. | [`01-optionals`](../modules/01-optionals/README.md) |

### `non-escaping closure`

The default for a closure parameter. The compiler knows the closure does not
outlive the call, so it can stack allocate the context and permit capturing
`inout` parameters.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`02-functions`](../modules/02-functions/README.md) |

### `noncopyable type`

`struct H: ~Copyable` removes the implicit copy, so assigning it moves it and
the source becomes unusable. It is how a unique resource (a file descriptor, a
lock token) becomes compiler enforced rather than convention.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `IDisposable` plus `using` is the nearest intent, but nothing stops you copying or reusing the handle. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `nonisolated`

Removes a member from its type's isolation domain. It is how a `@MainActor`
type exposes something callable synchronously from anywhere, and the compiler
then forbids that member from touching isolated state.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `nonisolated(nonsending)`

An async function that runs on the caller's actor rather than hopping off it.
It parses in plain Swift 6.2 with no flag, and the
`NonisolatedNonsendingByDefault` upcoming feature flips whether it is the
default for unannotated nonisolated async functions.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `nonisolated(unsafe)`

Opts a declaration out of the concurrency checks with no runtime enforcement.
The honest use is a global protected by an external lock, and the dishonest use
is silencing a diagnostic you did not read.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `nonmutating`

A setter modifier meaning the setter does not change the value's own storage,
used when the write goes somewhere else, as `@Binding`'s setter does.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `NSFetchedResultsController`

The Core Data object that keeps a table view in sync with a query. `@Query` is
its SwiftUI successor.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`docs/core-data-literacy.md`](core-data-literacy.md) |

### `NSManagedObject`

A Core Data managed object, which is a faulted proxy: its property storage is
not loaded until touched. Reading a fault triggers a fetch, which is why an
innocent loop can produce hundreds of queries.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | An EF Core lazy loaded proxy entity. | [`docs/core-data-literacy.md`](core-data-literacy.md) |

## O

### `ObjectIdentifier`

A `Hashable` wrapper around a class instance's address, letting you key a
dictionary or a set by identity. It does not keep the object alive on its own.

| Python | C# | Taught in |
| --- | --- | --- |
| `id()`. | `RuntimeHelpers.GetHashCode`. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `@Observable`

A macro that rewrites each stored property into a computed property calling
`access(keyPath:)` on read and `withMutation(keyPath:)` on write, against an
`ObservationRegistrar`. A body that never read a property does not re execute
when that property changes.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `INotifyPropertyChanged`, but per property and hand written. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `ObservableObject`

The Combine era observation protocol, used with `@Published`, `@StateObject`,
and `@ObservedObject`. It invalidates a view on any published change rather
than per key path. You will meet it in every existing codebase, and it is not
the path this repo teaches.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `INotifyPropertyChanged`. | [`docs/legacy-swift.md`](legacy-swift.md) |

### `ObservationRegistrar`

The table that records which key paths a given body read and notifies exactly
those readers on mutation. Expanding the `@Observable` macro and reading this
is what turns SwiftUI dependency tracking from magic into a mechanism.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `@ObservedObject`

The Combine era non owning reference to an `ObservableObject`. With
`@Observable`, you pass the model directly and use `@Bindable` where bindings
are needed.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`docs/legacy-swift.md`](legacy-swift.md) |

### `opaque parameter type`

`func f(_ x: some P)` is shorthand for `func f<T: P>(_ x: T)`. It is a generic
parameter, not an existential, and the two spellings compile identically.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `opaque type`

A type that is one specific concrete type the caller cannot name. Because the
identity survives, two values of `some P` returned by the same function are
known to be the same type and can be compared when `P: Equatable`, which is
exactly what `any P` cannot do.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `Optional`

`Optional<Wrapped>` is a standard library enum with exactly two cases, `.none`
and `.some(Wrapped)`. `String?` is sugar for `Optional<String>` and is a
genuinely different type from `String`, with its own layout and its own set of
legal operations.

| Python | C# | Taught in |
| --- | --- | --- |
| `Optional[str]` is a type checker annotation with no runtime existence; `None` still inhabits every type. | `string?` is an annotation over a runtime where `null` still inhabits every reference type. | [`01-optionals`](../modules/01-optionals/README.md) |

### `optional binding`

The `if let` and `guard let` forms, which pattern match `.some(x)` and bind the
payload to a new constant that is non optional inside the branch.

| Python | C# | Taught in |
| --- | --- | --- |
| `if x is not None:` with no type narrowing at runtime. | `if (x is string s)` pattern matching, the closest form. | [`01-optionals`](../modules/01-optionals/README.md) |

### `optional chaining`

`a?.b.c` short circuits the whole chain to `nil` the moment any link is
`.none`. The result type of the chain is always optional, and it flattens
rather than nesting.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `a?.b.c`, the same operator. | [`01-optionals`](../modules/01-optionals/README.md) |

### `optional map`

`Optional.map` applies a function to the payload when present and returns `nil`
otherwise. `flatMap` does the same and flattens a nested optional result.

| Python | C# | Taught in |
| --- | --- | --- |
| No method form; you write an `if`. | No method form; LINQ does not operate on `Nullable`. | [`01-optionals`](../modules/01-optionals/README.md) |

### `overflow trap`

Swift integer arithmetic traps on overflow rather than wrapping or promoting.
`&+`, `&-`, and `&*` opt into wrapping, and `addingReportingOverflow` returns a
tuple.

| Python | C# | Taught in |
| --- | --- | --- |
| `int` promotes to arbitrary precision, so overflow does not exist. | Unchecked by default, wrapping silently, unless inside a `checked` block. | [`01-optionals`](../modules/01-optionals/README.md) |

### `overloading`

Multiple functions sharing a base name, distinguished by parameter types,
labels, or return type. Swift overloads on return type, which C# does not.

| Python | C# | Taught in |
| --- | --- | --- |
| Not supported. | Supported, but never on return type alone. | [`02-functions`](../modules/02-functions/README.md) |

### `override`

Explicitly required on a member that replaces a superclass member. The absence
of the keyword is an error rather than an accidental shadow.

| Python | C# | Taught in |
| --- | --- | --- |
| Silent replacement. | `override`, but only on members declared `virtual`; Swift methods are overridable unless the class or member is `final`. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

## P

### `parameter name`

The name used inside the function body. When only one name is written it serves
as both label and parameter name; `func f(_ x: Int)` suppresses the label.

| Python | C# | Taught in |
| --- | --- | --- |
| The same name serves both roles. | The same name serves both roles. | [`02-functions`](../modules/02-functions/README.md) |

### `pattern matching`

The structural destructuring performed by `switch`, `if case`, `guard case`,
`for case`, and `catch`. It binds payloads with `let` inside the pattern rather
than testing then extracting.

| Python | C# | Taught in |
| --- | --- | --- |
| `match` statements, structurally similar and dynamically checked. | `switch` patterns, similar since C# 8 but without exhaustiveness over payloads. | [`05-enums`](../modules/05-enums/README.md) |

### `platforms clause`

The `platforms:` entry in a manifest. It is mandatory in this repo: omitting it
fails Swift Testing macro expansion with a misleading `'isolation()' is only
available in macOS 10.15 or newer`, because `@Test` expands to code using
`#isolation`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`docs/how-this-repo-works.md`](how-this-repo-works.md) |

### `@preconcurrency`

An attribute on an import or a conformance that relaxes checking against a
module that predates strict concurrency, downgrading errors from that boundary
to warnings. It is the tool for consuming an unaudited dependency.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `precondition`

A runtime check that traps on failure in both debug and release builds.
`assert` is checked only in debug, and `fatalError` always traps. None of the
three is catchable, because they signal a programming mistake rather than an
expected failure.

| Python | C# | Taught in |
| --- | --- | --- |
| `assert`, which is removable with `-O`. | `Debug.Assert` versus `Trace.Assert`. | [`08-errors`](../modules/08-errors/README.md) |

### `#Predicate`

A macro that builds a query predicate from a Swift closure, checked at compile
time. It is the answer to why Swift needs no runtime expression trees for this.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A LINQ lambda, translated at runtime through an `Expression` tree. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `primary associated type`

The associated type exposed in angle brackets, declared `protocol
Container<Element>`. It lets you constrain an existential or an opaque type:
`any Container<Int>` and `some Sequence<String>`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `projectedValue`

The value a property wrapper presents through `$name`. For `@State` it is a
`Binding`, which is why `$isOn` passes write access down.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `property observer`

`willSet` and `didSet` blocks that run around a write to a stored property.
They do not fire during initialization and they do not fire on mutation through
`self` inside `init`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Hand written in a property setter, or `INotifyPropertyChanged` plumbing. | [`02-functions`](../modules/02-functions/README.md) |

### `property wrapper`

A type marked `@propertyWrapper` supplying `wrappedValue` and optionally
`projectedValue`. The attribute rewrites the property into a stored instance of
the wrapper plus computed access, and `$name` reaches the projected value.

| Python | C# | Taught in |
| --- | --- | --- |
| A descriptor. | No equivalent; source generators are the closest and they are not per property. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `protocol`

A set of requirements a type can declare it satisfies. It is primarily a
constraint used in `<T: P>`, where the compiler knows the concrete type and can
specialize. Using it as a type (`any P`) is the secondary and more expensive
mode. Treating it as a synonym for interface is the single most costly
assumption a C# developer brings to Swift.

| Python | C# | Taught in |
| --- | --- | --- |
| A `Protocol` from `typing`, structurally checked and erased at runtime, or an ABC. | An `interface`, which is always a reference type and always dynamically dispatched. | [`04-protocols`](../modules/04-protocols/README.md) |

### `protocol composition`

`any Shape & Equatable` or `some Shape & Sendable`, a type built from several
protocols at once. There is no name to declare and it can include one class
constraint.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; you declare a new interface inheriting both. | [`04-protocols`](../modules/04-protocols/README.md) |

### `protocol extension`

An extension on a protocol supplying default implementations. A member declared
only in the extension and not in the protocol body is statically dispatched, so
a conforming type's own version is not called through an existential. That
asymmetry is a real source of bugs.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A default interface member, which does dispatch dynamically. | [`04-protocols`](../modules/04-protocols/README.md) |

### `@Published`

The property wrapper that emits on an `ObservableObject`'s publisher when the
value changes. Superseded by `@Observable`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`docs/legacy-swift.md`](legacy-swift.md) |

## Q

### `@Query`

A property wrapper that fetches model objects and keeps the view updated. Keep
it out of deeply nested views, because it couples the view tree to the
persistence layer and is awkward to test.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A `DbSet` query in the view layer, which is the same coupling mistake. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

## R

### `race condition`

An ordering dependent bug at the level of program logic, such as two callers
both passing a cache check. Actors prevent data races, not race conditions.
Confusing the two is the most expensive mistake a C# developer brings to
`actor`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `Range`

`a..<b` is a half open range and `a...b` is closed. They are generic over
`Comparable`, are themselves collections when the bound is `Strideable`, and
are the argument to slicing subscripts.

| Python | C# | Taught in |
| --- | --- | --- |
| `range`, integers only, and slice objects. | `Range` with `Index`, integers only. | [`06-collections`](../modules/06-collections/README.md) |

### `raw value`

A literal backing value for every case, declared as `enum Suit: String`. It
gives you a failable `init(rawValue:)` and a `rawValue` property, and it is a
completely different feature from associated values.

| Python | C# | Taught in |
| --- | --- | --- |
| `Enum` member values. | The underlying integer. | [`05-enums`](../modules/05-enums/README.md) |

### `reduce`

Folds a sequence into one value from an initial result. `reduce(into:)` is the
variant that mutates an accumulator in place and avoids a copy per element,
which matters when the accumulator is an array or a dictionary.

| Python | C# | Taught in |
| --- | --- | --- |
| `functools.reduce`. | `Aggregate`. | [`06-collections`](../modules/06-collections/README.md) |

### `reference semantics`

The property that two names can refer to one instance, so a mutation through
one is visible through the other. Deliberate in Swift, and the reason to
justify each `class` you write.

| Python | C# | Taught in |
| --- | --- | --- |
| The only model available. | The default for `class`. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `reference type`

A `class` or `actor`. Assignment copies the reference, so two names can observe
one object's mutations. Every reference type in Swift is heap allocated and ARC
managed.

| Python | C# | Taught in |
| --- | --- | --- |
| Every object. | Every `class`. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `region-based isolation`

The flow sensitive analysis that groups values into regions and permits
transferring a whole disconnected region across an isolation boundary, as long
as the sender does not use it afterward. It is why the identical `Task` capture
compiles in one function and fails in another. Regions merge when values are
assigned to each other.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `#require`

Like `#expect` but throws on failure, ending the test. `try #require(optional)`
unwraps and continues with the value, which is what makes it the replacement
for `XCTUnwrap`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `Assert.NotNull` followed by a manual dereference. | [`docs/testing-policy.md`](testing-policy.md) |

### `required initializer`

An initializer every subclass must provide, marked `required`. It is what makes
an initializer callable on a metatype in a generic context.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; constructors are not inherited or required. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `Result`

`Result<Success, Failure>` is an enum with `.success` and `.failure`. It turns
a failure into a value you can store, pass, and return from a completion
handler, and `get()` converts it back into a throw. Prefer `throws` for a
synchronous call and reach for `Result` when the failure must be held.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No standard equivalent; teams hand roll one. | [`08-errors`](../modules/08-errors/README.md) |

### `result builder`

A type marked `@resultBuilder` that turns a sequence of statements into one
value by calling `buildBlock`, `buildOptional`, `buildEither`, and (in modern
SwiftUI) `buildPartialBlock`. `ViewBuilder` is one, and it is why a view body
reads like a list of statements with no commas and no `return`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | LINQ query syntax lowering to method calls is the nearest idea, and it is much narrower. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `retain cycle`

Two or more objects holding each other strongly, so no count reaches zero and
none is ever deallocated. ARC cannot detect it and there is no collector that
will. You break it by making one edge `weak` or `unowned`.

| Python | C# | Taught in |
| --- | --- | --- |
| Possible, but the cycle collector hides it. | Not possible to leak this way; the collector handles cycles. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `rethrows`

A function that throws only if the closure it was given throws. Typed throws
generalizes this for new code, so `rethrows` is mostly a standard library idiom
you read rather than write.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`08-errors`](../modules/08-errors/README.md) |

### `retroactive conformance`

Conforming a type you do not own to a protocol you do not own. It compiles with
a warning asking you to write `@retroactive`, because two modules doing it
produce a conflict no one can fix.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`04-protocols`](../modules/04-protocols/README.md) |

## S

### `Scene`

A container for a window's content. `WindowGroup` is the common one and it is
what a `NavigationStack` lives inside.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `Self requirement`

A protocol requirement mentioning `Self`, such as `Equatable`'s `==`. It makes
the protocol usable as a constraint freely, and constrains what you can do with
it as an existential, since two `any Equatable` values may not share a type.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `Sendable`

A marker protocol meaning values of the type can cross an isolation boundary
without introducing a data race. A struct of `Sendable` parts gets it
automatically because copying it shares no storage, which is the direct link
between value semantics and concurrency safety.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; thread safety is documentation. | [`11-isolation`](../modules/11-isolation/README.md) |

### `sending`

A parameter or result annotation meaning the value's region is transferred to
the callee. The caller may not use it afterward.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `Sequence`

The protocol for something you can iterate once, requiring `makeIterator()`. It
carries no promise that iterating twice gives the same elements or that it
terminates.

| Python | C# | Taught in |
| --- | --- | --- |
| The iterable protocol (`__iter__`). | `IEnumerable<T>`. | [`06-collections`](../modules/06-collections/README.md) |

### `Set`

An unordered collection of unique `Hashable` elements with the usual algebra
(`union`, `intersection`, `subtracting`, `isSubset(of:)`).

| Python | C# | Taught in |
| --- | --- | --- |
| `set`. | `HashSet<T>`. | [`06-collections`](../modules/06-collections/README.md) |

### `shorthand argument name`

`$0`, `$1`, and so on, available when a closure omits its parameter list. Using
any of them fixes the closure's arity.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`02-functions`](../modules/02-functions/README.md) |

### `shorthand optional binding`

`if let name { }` with no `= name`, which shadows the outer optional with a non
optional constant of the same name.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`01-optionals`](../modules/01-optionals/README.md) |

### `side table`

The out of line allocation ARC uses to track weak references to an object, so
that zeroing a weak reference has somewhere to look after the object is gone.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `SIL`

Swift Intermediate Language, the phase where region based isolation diagnostics
are produced. Consequence: `swiftc -typecheck` reports nothing for those
errors, so an editor that only type checks can show a green file that `swift
build` rejects. Trust the build.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `some`

The keyword marking an opaque type. In a return position the callee picks
exactly one concrete type and the compiler remembers which, while the caller
does not. In a parameter position it is shorthand for a generic parameter.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `some View`

The return type of `body`. It is an opaque type, so the concrete generic view
type (which is enormous and encodes the whole hierarchy) is known to the
compiler and unnameable by you.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`07-generics`](../modules/07-generics/README.md) |

### `specialization`

The optimizer emitting a dedicated copy of a generic function for a concrete
type, which permits inlining and removes witness table calls. It happens across
module boundaries only when the function is `@inlinable`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | The runtime does this for value type instantiations. | [`07-generics`](../modules/07-generics/README.md) |

### `@State`

View local storage owned by SwiftUI, keyed by the view's identity rather than
by the struct instance. It survives body re execution and dies when the view's
identity changes. It is the correct owner for a value the view itself creates,
including an `@Observable` model instance.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `@StateObject`

The Combine era owner of a reference model, ensuring it is created once per
view identity. With `@Observable`, plain `@State` does this job.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`docs/legacy-swift.md`](legacy-swift.md) |

### `static dispatch`

A call whose target is known at compile time, so it can be inlined. Calls on a
concrete type and on a generic parameter after specialization are static.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Non virtual calls. | [`04-protocols`](../modules/04-protocols/README.md) |

### `stored property`

A property that occupies storage in the instance. Extensions can never add one,
because that would change the type's memory layout, which is fixed at compile
time.

| Python | C# | Taught in |
| --- | --- | --- |
| An instance attribute, addable at runtime. | A field. | [`02-functions`](../modules/02-functions/README.md) |

### `stride`

`stride(from:to:by:)` and `stride(from:through:by:)` produce a sequence with an
arbitrary step, including a negative or floating point step, which `..<` cannot
express.

| Python | C# | Taught in |
| --- | --- | --- |
| `range` with a step. | No built in; `Enumerable.Range` plus arithmetic. | [`06-collections`](../modules/06-collections/README.md) |

### `String`

A collection of `Character` values (extended grapheme clusters) over UTF-8
storage. It is not integer indexable, because a grapheme has variable width in
the underlying bytes.

| Python | C# | Taught in |
| --- | --- | --- |
| `str` is a sequence of code points and `s[0]` works. | `string` is a sequence of UTF-16 code units and `s[0]` works. | [`01-optionals`](../modules/01-optionals/README.md) |

### `string interpolation`

`"x is \(x)"`, which is a result builder style protocol
(`ExpressibleByStringInterpolation`) rather than a formatting call, so it is
type checked and extensible per type.

| Python | C# | Taught in |
| --- | --- | --- |
| f strings. | Interpolated strings, which lower to `string.Format` or a handler. | [`01-optionals`](../modules/01-optionals/README.md) |

### `String.Index`

An opaque index into a `String`, obtained from the string itself. It cannot be
constructed from an `Int` because the offset of a character depends on the
contents before it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`01-optionals`](../modules/01-optionals/README.md) |

### `strong reference`

The default reference kind. It keeps the referent alive and contributes to its
retain count.

| Python | C# | Taught in |
| --- | --- | --- |
| Every name binding. | Every reference. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `struct`

A value type with stored properties, methods, initializers, and protocol
conformances. It cannot inherit. It is the default choice in Swift, and `class`
is the exception that needs a reason.

| Python | C# | Taught in |
| --- | --- | --- |
| No equivalent. `dataclass` is still a reference object. | `struct`, but Swift structs get a memberwise initializer and can be arbitrarily large without a performance warning, because of copy on write in the standard library types they hold. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `structural identity`

Identity derived from a view's position in the view tree. An `if/else` produces
two structurally different views, so state does not survive moving between the
branches, whereas a modifier applied conditionally to one view keeps it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `structured concurrency`

The model where a child task's lifetime is bounded by the syntactic scope that
created it. The parent cannot return before its children complete, errors
propagate to the parent, and cancellation propagates down.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; `Task.Run` produces an unparented task. | [`12-async-await`](../modules/12-async-await/README.md) |

### `subscript`

A member declared with the `subscript` keyword, giving `x[i]` syntax. It can
take any number of parameters with argument labels, can be generic, and can
have a setter.

| Python | C# | Taught in |
| --- | --- | --- |
| `__getitem__` and `__setitem__`. | An indexer. | [`06-collections`](../modules/06-collections/README.md) |

### `Substring`

A slice of a `String` that shares the parent's storage. It is a distinct type
so that holding a slice of a huge string is a visible decision, and you convert
with `String(sub)`.

| Python | C# | Taught in |
| --- | --- | --- |
| Slicing copies, so there is no separate type. | `ReadOnlySpan<char>`, but `Substring` is not stack constrained. | [`01-optionals`](../modules/01-optionals/README.md) |

### `suspension point`

The place an `await` appears. It is the unit of reasoning for concurrency: any
actor state, any captured value, and any invariant may have changed across it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`12-async-await`](../modules/12-async-await/README.md) |

### `Swift Testing`

The testing framework this repo uses: `@Test`, `@Suite`, `#expect`, `#require`,
and `@Test(arguments:)` for parameterized cases. It runs tests in parallel and
concurrently in one process, so tests sharing global mutable state will
interfere, which XCTest's serial execution hid.

| Python | C# | Taught in |
| --- | --- | --- |
| `pytest`. | xUnit, which also parallelizes by default at the collection level. | [`docs/testing-policy.md`](testing-policy.md) |

### `SwiftData`

The persistence layer taught in this repo. `@Model` is a macro over a class,
`ModelContainer` owns the store, `ModelContext` tracks changes, and
`#Predicate` builds a query checked at compile time.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | EF Core, except that `#Predicate` is compile time constructed where LINQ builds a runtime expression tree. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `synthesized conformance`

The compiler writing a conformance for you when every stored part qualifies.
Available for `Equatable`, `Hashable`, `Comparable` (enums without associated
values), `Codable`, and `CaseIterable`, and only when you declare the
conformance.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Records give value equality, but there is no opt in synthesis for arbitrary interfaces. | [`04-protocols`](../modules/04-protocols/README.md) |

## T

### `target`

A unit of compilation in a SwiftPM package. One directory is one target,
`internal` (the default access level) is visible within a target, and this repo
uses one root package with an exercise target and a test target per chapter.

| Python | C# | Taught in |
| --- | --- | --- |
| A package or module. | A project or assembly, which is also the boundary `internal` refers to. | [`docs/how-this-repo-works.md`](how-this-repo-works.md) |

### `Task`

An unstructured unit of async work. `Task { }` inherits the actor isolation,
priority, and task local values of the context that created it, but not its
lifetime, so nothing awaits it unless you keep the handle.

| Python | C# | Taught in |
| --- | --- | --- |
| `asyncio.create_task`. | `Task.Run`, except that a Swift `Task` inherits isolation and cannot be blocked on. | [`12-async-await`](../modules/12-async-await/README.md) |

### `task modifier`

`.task { }` starts async work tied to the view's lifetime and cancels it
automatically when the view goes away, which is what makes it correct where a
bare `Task { }` in `onAppear` leaks.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `task tree`

The parent and child relationship formed by `async let` and task groups.
Cancellation flows down every edge of it, and it is what makes structured
concurrency structured.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`12-async-await`](../modules/12-async-await/README.md) |

### `task-local value`

A value declared `@TaskLocal` that propagates to child tasks and to
unstructured `Task { }` children, but not to `Task.detached`. It is the
structured alternative to a thread local.

| Python | C# | Taught in |
| --- | --- | --- |
| `contextvars`. | `AsyncLocal<T>`. | [`12-async-await`](../modules/12-async-await/README.md) |

### `Task.detached`

Creates a task inheriting nothing: no isolation, no priority, no task locals.
It is the source of most gratuitous `Sendable` errors, because a plain `Task`
would have inherited the isolation that made the capture safe. Treat it as an
anti pattern needing a stated reason.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`12-async-await`](../modules/12-async-await/README.md) |

### `Task.sleep`

The async, throwing, cancellation aware delay. `Thread.sleep` blocks a pool
thread and must not appear in async code.

| Python | C# | Taught in |
| --- | --- | --- |
| `asyncio.sleep`. | `Task.Delay`. | [`12-async-await`](../modules/12-async-await/README.md) |

### `TaskGroup`

A dynamic number of child tasks created inside `withTaskGroup(of:)` or
`withThrowingTaskGroup(of:)`. Results arrive in completion order, not
submission order, and a thrown error from one child cancels the siblings.

| Python | C# | Taught in |
| --- | --- | --- |
| `asyncio.TaskGroup`. | `Task.WhenAll`, which has no cancellation propagation between siblings. | [`12-async-await`](../modules/12-async-await/README.md) |

### `throws`

Part of a function's type, not an ambient capability. A caller must write `try`
at every call, and there is no way to catch a throw from three frames down
without those frames being marked `throws` too.

| Python | C# | Taught in |
| --- | --- | --- |
| Any call can raise; nothing is declared. | Any call can throw; `throws` documentation is not checked. | [`08-errors`](../modules/08-errors/README.md) |

### `trailing closure`

A closure written after the call's closing parenthesis. The first trailing
closure drops its label, and further ones keep theirs, which is why `Button { }
label: { }` reads the way it does.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`02-functions`](../modules/02-functions/README.md) |

### `trap`

A deliberate, immediate process termination on a violated precondition (integer
overflow, force unwrap of `nil`, array index out of bounds). It is not an error
you can catch and it is not undefined behavior.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Closest is a `FailFast`; ordinary exceptions are catchable and traps are not. | [`01-optionals`](../modules/01-optionals/README.md) |

### `try`

The marker required at every call to a throwing function. It is a visibility
rule, not an operation: it does nothing at runtime and it does not catch
anything.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`08-errors`](../modules/08-errors/README.md) |

### `try!`

Asserts the call cannot throw and traps if it does. Same category as force
unwrap, and the same rule applies here: it does not appear in this repo outside
the probes where its danger is the lesson.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`08-errors`](../modules/08-errors/README.md) |

### `try?`

Converts a throw into `nil`, producing an `Optional`. It discards the error, so
it is right only where the reason genuinely does not matter.

| Python | C# | Taught in |
| --- | --- | --- |
| `except: pass` around an assignment. | An empty `catch` around a `TryParse` style call. | [`08-errors`](../modules/08-errors/README.md) |

### `two-phase initialization`

Phase one initializes every stored property from the subclass upward until all
storage is valid. Only in phase two may you read `self`, call an overridable
method, or capture `self`. Because there is no null, there is no partially
initialized readable state to observe, and the designated and convenience rules
exist to enforce this ordering.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A constructor can call a virtual method before derived fields are set, and you observe default values. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `type annotation`

The `: Type` on a declaration. Swift requires the type to be known at compile
time, but infers it from the initializer in most declarations, so annotations
appear mostly where inference is ambiguous or where you want to widen the type.

| Python | C# | Taught in |
| --- | --- | --- |
| An optional hint with no runtime effect. | Required except where `var` infers it. | [`01-optionals`](../modules/01-optionals/README.md) |

### `type erasure`

Wrapping a value so the concrete type is discarded, as `AnySequence` and
`AnyHashable` do. Since SE-0309 lifted the ban on existentials of protocols
with associated types, hand written erasers are needed far less often than
older material claims.

| Python | C# | Taught in |
| --- | --- | --- |
| The default state of everything. | Casting to a non generic interface. | [`07-generics`](../modules/07-generics/README.md) |

### `type inference`

Swift infers declaration types from initializer expressions and infers generic
parameters from arguments. Inference is bidirectional and whole expression,
which is why an unrelated line can change an error message.

| Python | C# | Taught in |
| --- | --- | --- |
| No inference; names are untyped. | `var` infers, but only from the right hand side of one assignment. | [`01-optionals`](../modules/01-optionals/README.md) |

### `typed throws`

`func f() throws(ParseError)` declares exactly which error type can be thrown,
so a `catch` over it is exhaustive and no `as?` is needed. `throws(Never)` is
equivalent to not throwing at all.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No equivalent; checked exceptions do not exist in C#. | [`08-errors`](../modules/08-errors/README.md) |

## U

### `@unchecked Sendable`

A promise to the compiler that you have synchronized the type yourself, usually
with a lock. It suppresses the check and moves the burden of proof onto you, so
it is a claim, not a fix.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`11-isolation`](../modules/11-isolation/README.md) |

### `unknown case fallback`

Decoding a raw value enum through `init(rawValue:)` and mapping `nil` to a
designated `.unknown` case, so a server adding a value does not fail the whole
document.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`09-codable`](../modules/09-codable/README.md) |

### `@unknown default`

A `default` clause that still warns when a new case appears. It exists for non
frozen enums from libraries that can add cases in a future release, and it is
the correct choice for a system framework enum and the wrong choice for your
own.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`05-enums`](../modules/05-enums/README.md) |

### `unowned reference`

A non optional, non zeroing, non owning reference that traps when accessed
after the referent is deallocated. Correct only where the referent provably
outlives the reference. It is not a faster `weak`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `upcoming feature`

A source breaking change available before the language mode that makes it
mandatory, enabled per target with `enableUpcomingFeature`. This repo enables
`ExistentialAny` on every target, so every existential must be written `any P`
and the cost of an existential is visible at every site.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`docs/how-this-repo-works.md`](how-this-repo-works.md) |

## V

### `value semantics`

The property that a value's observable behavior depends only on its own
contents. It is what lets you reason locally: if you hold it, nobody else can
change it.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `value type`

A `struct`, `enum`, or tuple. Assignment and argument passing copy the value,
so no two names can observe each other's mutations.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A `struct`, but Swift makes value types the default choice rather than the exception. | [`03-value-semantics`](../modules/03-value-semantics/README.md) |

### `value-based navigation`

Pushing a `Hashable` value rather than a view, so the destination is resolved
by type at the container. It is what makes deep linking and state restoration
ordinary rather than special.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`14-swiftui-app`](../modules/14-swiftui-app/README.md) |

### `var`

Binds a name to a value that can be reassigned, and permits `mutating` methods
when the value is a value type.

| Python | C# | Taught in |
| --- | --- | --- |
| Every plain name. | A field or local without `readonly`. | [`01-optionals`](../modules/01-optionals/README.md) |

### `variadic parameter`

`_ values: Int...` receives an `Array` inside the body. A function can have
more than one variadic parameter as long as later ones are labeled.

| Python | C# | Taught in |
| --- | --- | --- |
| `*args`. | `params int[]`. | [`02-functions`](../modules/02-functions/README.md) |

### `variance`

Swift generics are invariant, so `[Dog]` is not accepted where `[Animal]` is
expected, and there is no `in` or `out` annotation. A few standard library
types get covariance as a special case.

| Python | C# | Taught in |
| --- | --- | --- |
| No static variance rules. | Declaration site variance with `in` and `out` on interfaces. | [`07-generics`](../modules/07-generics/README.md) |

### `View`

A protocol with one requirement, `body`, whose value is a lightweight value
type describing the desired UI. Views are structs that are created and
discarded constantly; they are not the objects on screen.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | Nothing analogous; a `Control` is a long lived object. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `view identity`

How SwiftUI decides whether two body evaluations describe the same view.
Structural identity comes from the view's position in the tree, and explicit
identity comes from `.id(...)` or from `ForEach`'s `id`. State is attached to
identity, so changing identity destroys and recreates the state.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

### `ViewBuilder`

The result builder that assembles view bodies. `buildPartialBlock` removed the
old ten child limit, so `Group` is no longer a workaround you need.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

## W

### `weak reference`

A reference that does not keep the referent alive and is set to `nil`
automatically on deallocation. It is therefore always optional and always a
`var`, and it costs a side table entry.

| Python | C# | Taught in |
| --- | --- | --- |
| `weakref.ref`, which needs an explicit call to read. | `WeakReference<T>`, which needs `TryGetTarget`. | [`10-classes-and-arc`](../modules/10-classes-and-arc/README.md) |

### `where clause`

Additional constraints written after the signature or on an extension, able to
constrain associated types and to state same type requirements: `where
C.Element == String`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | `where` constrains only the parameters, never their associated types, because C# has none. | [`07-generics`](../modules/07-generics/README.md) |

### `where clause in a pattern`

An extra boolean condition on a `case`, as in `case .count(let n) where n >
10`. It does not count toward exhaustiveness, so a `switch` made only of
guarded cases still needs an unguarded one.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | A `when` clause. | [`05-enums`](../modules/05-enums/README.md) |

### `wildcard label`

The `_` in `func f(_ x: Int)`, which removes the argument label so the call
site reads `f(3)`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`02-functions`](../modules/02-functions/README.md) |

### `witness table`

The table of function pointers the compiler emits for one type's conformance to
one protocol. Dynamic dispatch through `any P` is a call through this table,
and it is the second pointer in an existential box.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | The interface method table on the object's type. | [`07-generics`](../modules/07-generics/README.md) |

### `Wrapped`

The generic parameter of `Optional`. In `Int?` the wrapped type is `Int`.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | The `T` in `Nullable<T>`, but only for value types. | [`01-optionals`](../modules/01-optionals/README.md) |

### `wrappedValue`

The value a property wrapper presents when you use the property by name.

| Python | C# | Taught in |
| --- | --- | --- |
| No analogue. | No analogue. | [`13-swiftui-state`](../modules/13-swiftui-state/README.md) |

## X

### `XCTest`

The pre Swift Testing framework, with `XCTAssert`, `XCTestExpectation`, and
serial execution. `#expect` replaces the assert family and `try #require`
replaces `XCTUnwrap`, additionally continuing with the unwrapped value.

| Python | C# | Taught in |
| --- | --- | --- |
| `unittest`. | MSTest or NUnit. | [`docs/legacy-swift.md`](legacy-swift.md) |

## Z

### `zip`

Pairs two sequences into a sequence of tuples, stopping at the shorter one. It
is lazy.

| Python | C# | Taught in |
| --- | --- | --- |
| `zip`. | `Zip`. | [`06-collections`](../modules/06-collections/README.md) |

