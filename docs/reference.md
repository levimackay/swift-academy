---
title: Reference
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Reference

Two cheat sheets for material you have already learned and only need to recall.
Nothing here teaches. If a line does not make sense, the chapter that owns it
is named in [`docs/glossary.md`](glossary.md).

Part 1 is Swift syntax. Part 2 is the translation table from your C# and Python
reflexes.

Verified against Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0.

---

# Part 1: Syntax quick reference

## Declarations

```swift
let x = 1                     // immutable binding, type inferred Int
var y: Double = 1             // annotated, mutable
let (a, b) = (1, "two")       // tuple destructuring
typealias Handler = (Int) -> Void
```

## Optionals

```swift
var name: String?             // Optional<String>, defaults to nil
if let name { use(name) }     // shorthand binding, shadows
guard let name else { return }
let n = name ?? "anonymous"   // right side is @autoclosure
let count = name?.count       // Int?, chain short circuits
let upper = name.map { $0.uppercased() }   // Optional<String>
let flat = name.flatMap(Int.init)          // Optional<Int>, no nesting
let cast = value as? Duration              // Duration?
switch name {
case .some(let s): use(s)
case .none: break
}
```

## Functions

```swift
func move(from origin: Int, to target: Int) {}   // move(from:to:)
func f(_ x: Int) {}                              // f(3)
func g(count: Int = 0, _ rest: Int...) {}
func bump(_ x: inout Int) { x += 1 }             // call: bump(&n)
func first() throws(ParseError) -> Int { 0 }
func pick() -> some Equatable { 1 }
func take(_ p: some Shape) {}                    // == <T: Shape>(_ p: T)
func hold(_ p: any Shape) {}                     // existential
@discardableResult func log() -> Int { 0 }
```

## Closures

```swift
let add = { (a: Int, b: Int) -> Int in a + b }
values.map { $0 * 2 }
values.sorted { $0 > $1 }
run(after: 1) { print("done") }                  // trailing
Button { tap() } label: { Text("Go") }           // multiple trailing
func store(_ work: @escaping () -> Void) {}
onDone = { [weak self, snapshot = count] in       // capture list, evaluated now
    self?.count = snapshot
}
```

## Structs, classes, actors

```swift
struct Point { var x = 0.0; var y = 0.0 }        // memberwise init free
extension Point { mutating func reset() { self = Point() } }

final class Node {
    let id: UUID
    weak var parent: Node?
    unowned let owner: Tree
    init(id: UUID, owner: Tree) { self.id = id; self.owner = owner }
    deinit { print("gone") }
}

actor Counter {
    private var n = 0
    func bump() { n += 1 }
    nonisolated let id = UUID()
}
```

## Enums

```swift
enum Suit: String, CaseIterable { case hearts, spades }
enum Load<T> {
    case idle
    case loaded(T, at: Date)
    case failed(reason: String)
}
indirect enum Expr { case lit(Int); case add(Expr, Expr) }

Suit(rawValue: "hearts")                          // Suit?
Suit.allCases.count
```

## Pattern matching

```swift
switch state {
case .idle: break
case .loaded(let value, at: let date) where date > cutoff: use(value)
case .loaded(let value, at: _): use(value)
case .failed(let reason): report(reason)
}

if case .failed(let reason) = state { report(reason) }
guard case .loaded(let value, at: _) = state else { return }
for case .failed(let reason) in states { report(reason) }
```

## Protocols and extensions

```swift
protocol Shape: Sendable {
    associatedtype Unit: Numeric
    var area: Unit { get }
    mutating func scale(by factor: Unit)
}
protocol Container<Element> { associatedtype Element }   // primary associated type
protocol Delegate: AnyObject {}                          // class only

extension Shape { var isEmpty: Bool { area == .zero } }  // default impl, static dispatch
extension Stack: Equatable where Element: Equatable {}   // conditional conformance
```

## Generics

```swift
struct Stack<Element> { private var items: [Element] = [] }
extension Stack: Equatable where Element: Equatable {}
func merge<C: Collection>(_ c: C) -> [C.Element] where C.Element: Hashable { Array(c) }
func makeSeq() -> some Sequence<Int> { [1, 2] }
let boxes: [any Shape] = []
```

## Collections

```swift
var a = [1, 2, 3]; a.append(4); a[0...1]          // ArraySlice, parent indices
var d = ["k": 1]; d["missing"]                    // Int?
d["k", default: 0] += 1
var s: Set = [1, 2]; s.insert(3); s.isSubset(of: [1, 2, 3])

a.map { $0 * 2 }                                  // eager, allocates
a.lazy.map { $0 * 2 }.filter { $0 > 2 }           // fused, no allocation
["1", "x"].compactMap(Int.init)                   // [1], failures dropped
a.reduce(0, +)
a.reduce(into: [:]) { $0[$1] = true }
zip(a, b); a.enumerated(); a.sorted(by: <)
a.first(where: { $0 > 1 }); a.contains(2); a.allSatisfy { $0 > 0 }
stride(from: 0, to: 10, by: 2)
```

## Strings

```swift
let s = "cafe\u{301}"
s.count                       // 4 graphemes
s.unicodeScalars.count        // 5
s.utf8.count                  // 6
s[s.startIndex]               // Character, no s[0]
s.firstIndex(of: "c").map { s[$0...] }   // Substring
String(s.reversed())
"\(s) has \(s.count)"
```

## Errors

```swift
enum ParseError: Error { case empty, badDigit(at: Int) }

func parse(_ s: String) throws(ParseError) -> Int {
    guard !s.isEmpty else { throw ParseError.empty }
    return 0
}

do { _ = try parse("") }
catch .badDigit(let i) { print(i) }               // exhaustive, typed
catch { print(error) }

let opt = try? parse("")                          // Int?
let result = Result { try parse("") }             // Result<Int, any Error>
result.map { $0 + 1 }; try result.get()

func scoped() throws {
    let handle = try open()
    defer { handle.close() }                      // runs on every exit path
    try handle.write()
}
```

## Concurrency

```swift
func load() async throws -> Data { Data() }

async let left = load()                           // starts now
async let right = load()
let both = try await (left, right)                // awaited here

let items = try await withThrowingTaskGroup(of: Int.self) { group in
    for i in 0..<4 { group.addTask { try await work(i) } }
    return try await group.reduce(into: []) { $0.append($1) }
}

Task { await store.refresh() }                    // inherits isolation, not lifetime
try Task.checkCancellation(); Task.isCancelled
try await Task.sleep(for: .milliseconds(10))

for await line in stream { use(line) }

@MainActor final class Store { var items: [Int] = [] }
nonisolated func pure() {}
MainActor.assumeIsolated { store.items = [] }     // traps if wrong, no suspension
```

## Observation and SwiftUI

```swift
@Observable @MainActor final class Store { var count = 0 }

struct CounterView: View {
    @State private var store = Store()
    @State private var draft = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Text("\(store.count)")
            TextField("Name", text: $draft)
            Button("Add") { store.count += 1 }
        }
        .padding()
        .task { await store.load() }
    }
}

struct Row: View {
    @Binding var isOn: Bool
    @Bindable var store: Store
}

NavigationStack(path: $path) {
    List(items) { item in NavigationLink(item.name, value: item.id) }
        .navigationDestination(for: UUID.self) { id in DetailView(id: id) }
}
```

## Codable

```swift
struct User: Codable {
    let id: UUID
    let name: String
    let nickname: String?
    enum CodingKeys: String, CodingKey { case id, name, nickname = "nick_name" }
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601
let user = try decoder.decode(User.self, from: data)

// manual decoding: defaults, absent keys, unknown enum case
init(from decoder: any Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    name = try c.decode(String.self, forKey: .name)
    nickname = try c.decodeIfPresent(String.self, forKey: .nickname)   // nil if absent
    let raw = try c.decode(String.self, forKey: .kind)
    kind = Kind(rawValue: raw) ?? .unknown                             // fall back, do not fail
}
```

## Swift Testing

```swift
import Testing

@Suite("Grid") struct GridTests {
    @Test func stepsOnce() {
        #expect(Grid().stepped().liveCount == 0)
    }

    @Test(arguments: [0, 1, 2]) func handles(_ n: Int) {
        #expect(n >= 0)
    }

    @Test func unwraps() throws {
        let value = try #require(Int("3"))        // unwraps and continues
        #expect(value == 3)
    }

    @Test func fails() {
        #expect(throws: ParseError.self) { try parse("") }
    }
}
```

Run: `swift test`, `swift test --filter 03`, `swift run probe-name`.

## Package manifest

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftAcademy",
    platforms: [.macOS(.v14)],          // mandatory, see docs/how-this-repo-works.md
    targets: [
        .target(
            name: "Ch01",
            path: "modules/01-optionals/exercises",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "Ch01Tests",
            dependencies: ["Ch01"],
            path: "modules/01-optionals/tests",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
    ]
)
```

Never write `swiftLanguageMode(.v6)` (it is the default) or
`-strict-concurrency=complete` (a Swift 5 migration flag).

## Access levels

| Level | Visible in |
| --- | --- |
| `private` | The enclosing declaration and its extensions in the same file |
| `fileprivate` | The file |
| `internal` (default) | The target |
| `package` | The package |
| `public` | Anywhere, not subclassable or overridable outside |
| `open` | Anywhere, subclassable and overridable |

---

# Part 2: Swift idioms for C# and Python developers

The reflex on the left produces working code in the other language and either
fails to compile or silently misbehaves in Swift. Written for recall, not for
persuasion. The reasoning is in [`docs/bridge.md`](bridge.md).

## Reflexes to retire

| Your reflex | Write instead | Because |
| --- | --- | --- |
| `class Foo` by default | `struct Foo` | `class` needs a lifecycle, shared mutation, or inheritance |
| `IFoo x` everywhere | `<T: Foo>` or `some Foo` | `any Foo` erases type identity and can allocate |
| `null` check after use | `guard let` at the boundary | absence is a different type, not a value |
| `x!` to move on | `guard let`, `??`, `map` | `!` traps and discards the proof |
| `task.Result`, `.Wait()` | `await` all the way up | blocking the cooperative pool can deadlock |
| `lock` around state | `actor`, or `@MainActor` | actors serialize but release at every `await` |
| `Task.Run` | `Task { }`, `async let`, `TaskGroup` | `Task.detached` inherits nothing |
| `DispatchQueue.main.async` | `@MainActor`, `MainActor.assumeIsolated` | no suspension, and checked |
| `static var shared` | `static let` or `@MainActor static let` | nonisolated global `var` is an error |
| `try/catch` around everything | typed `throws(E)` plus `guard` | `throws` is in the signature, per call |
| `finally` | `defer` | scope based, runs in reverse order |
| `IDisposable` plus `using` | `deinit`, `defer`, or `consuming` on `~Copyable` | there is no `using` statement |
| `ToString()` | `CustomStringConvertible` | `description` is opt in |
| `s[0]` on a string | `s[s.startIndex]`, `s.first` | indices are opaque, graphemes vary in width |
| `if x:` on a number or list | `if x != 0`, `if !x.isEmpty` | there is no truthiness |
| monkey patching | `extension` | extensions add behavior, never stored properties |
| duck typing | declared conformance | conformance is nominal |
| `int` that grows | `Int` traps on overflow, `&+` wraps | fixed width, no promotion |
| `1 + 1.0` | `Double(1) + 1.0` | no implicit numeric conversion |
| `dict` iteration order | sort explicitly | `Dictionary` order varies per process |
| mutable default argument | write it plainly | defaults evaluate per call, so the trap does not exist |

## Direct translations

| C# | Python | Swift |
| --- | --- | --- |
| `IEnumerable<T>` | iterable | `Sequence`, or `some Sequence<T>` |
| `IAsyncEnumerable<T>` | async generator | `AsyncSequence`, `for await` |
| `Select` / `Where` | `map` / `filter` (lazy) | `map` / `filter` (eager), `.lazy` to fuse |
| `Aggregate` | `functools.reduce` | `reduce`, or `reduce(into:)` |
| `SelectMany` | `chain.from_iterable` | `flatMap` |
| `FirstOrDefault` | `next(gen, None)` | `first(where:)`, returns an `Optional` |
| `Any` / `All` | `any` / `all` | `contains(where:)` / `allSatisfy` |
| `Dictionary<K,V>` | `dict` | `Dictionary`, subscript returns `Optional` |
| `HashSet<T>` | `set` | `Set`, `Element: Hashable` |
| `List<T>` | `list` | `Array`, a value type |
| indexer | `__getitem__` | `subscript` |
| property | `@property` | computed property |
| `readonly` field | none | `let` (deep on a value type) |
| `sealed` | none | `final` |
| `params T[]` | `*args` | `_ xs: T...` |
| named arguments | keyword arguments | argument labels, required |
| `ref` | none | `inout` plus `&` at the call site |
| `out` | tuple return | tuple return |
| extension method | monkey patch | `extension` |
| default interface member | mixin | protocol extension (static dispatch) |
| `IEquatable<T>` | `__eq__` | `Equatable` (synthesized) |
| `GetHashCode` | `__hash__` | `Hashable` (synthesized) |
| `IComparable<T>` | `__lt__` | `Comparable` (`<` only) |
| `Nullable<T>` | `Optional[T]` | `Optional<Wrapped>`, a real enum |
| `Task<T>` | coroutine | `async` function, or `Task<T, E>` |
| `CancellationToken` | `CancelledError` | `Task.isCancelled`, cooperative |
| `Task.WhenAll` | `asyncio.gather` | `async let`, or `withTaskGroup` |
| `TaskCompletionSource` | `Future` | `withCheckedContinuation` |
| `AsyncLocal<T>` | `contextvars` | `@TaskLocal` |
| `WeakReference<T>` | `weakref.ref` | `weak var` (auto zeroing) |
| `INotifyPropertyChanged` | none | `@Observable` |
| `Lazy<T>` (thread safe) | `cached_property` | `lazy var` (not thread safe) |
| `Expression<Func<..>>` | none | `#Predicate`, built at compile time |
| source generator | decorator | macro |
| `sizeof` | none | `MemoryLayout<T>.size` |

## Things Swift does that neither language does

| Feature | One line |
| --- | --- |
| Enums with payloads | `case failed(reason: String)`, exhaustively switched |
| Value semantics by default | `var b = a` cannot alias |
| Copy on write | value semantics at reference cost until the first write |
| Deterministic `deinit` | no collector, so a cycle leaks forever |
| Compiler checked isolation | `Sendable`, `actor`, `@MainActor` |
| Typed throws | `throws(ParseError)` makes `catch` exhaustive |
| `some` versus `any` | keeps or discards type identity, on purpose |
| Conditional conformance | `Stack: Equatable where Element: Equatable` |
| Overload on return type | `let x: Int = .init("3") ?? 0` resolves by context |
| Noncopyable types | `~Copyable` plus `consuming` |

## Traps unique to Swift that cost the most time

| Trap | Symptom | Fix |
| --- | --- | --- |
| Slice indices | crash on `slice[0]` | use `slice.startIndex`, or `Array(slice)` |
| Protocol extension dispatch | your override is not called | move the requirement into the protocol body |
| Modifier order | wrong padding or background | modifiers wrap, they do not set fields |
| View identity | state resets or sticks to the wrong row | fix `ForEach` `id`, or `.id(...)` |
| Actor reentrancy | duplicated work under load | recheck state after every `await` |
| Region isolation | same line compiles in one function only | stop using the value after transfer |
| Editor shows green | `swift build` rejects it | isolation errors are a SIL pass, trust the build |
| Retain cycle | `deinit` never prints | `[weak self]` on the stored closure |
| COW performance | linear loop becomes quadratic | drop the extra stored copy of the array |
| Eager `map` chains | allocation per stage | insert `.lazy` |
