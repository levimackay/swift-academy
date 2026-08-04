---
title: C# to Swift
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# C# to Swift

This is a reference, not a chapter. Nothing here is sequenced, nothing here
has exercises, and you are not meant to read it front to back. Look up the
construct you were about to type, read where the analogy breaks, go back to
the chapter.

Every Swift sample below was compiled with `swiftc -swift-version 6` on the
toolchain named above, and every sample that prints was run. Diagnostics are
pasted verbatim. Where the compiler contradicted a widely repeated rule, the
row says so and gives the narrower rule that is actually true.

Each C# anchored chapter README carries a `Coming from C#` section holding only
the rows that chapter owns, and section 7 says which chapters those are. Three
chapters anchor on Python instead and use
[bridge-python.md](bridge-python.md). This file is the union of those rows plus
the material
that is too long to live in a chapter.

---

## 1. Mapping table

Rows are grouped by the chapter that owns them.

### Types and values

| C# | Swift | Where the analogy breaks |
|---|---|---|
| `class` as the default choice | `struct` as the default choice | Swift inverts the norm. `class` is what you type when you need identity. See section 2, item 1. |
| `struct` (rare, perf tuning) | `class` (rare, identity needed) | C# structs carry boxing and mutable struct hazards, so the guidance is to avoid them. Swift structs are the mainstream tool and `mutating` is safe. |
| `record` | `struct` plus declared `Equatable` | Both give value equality. Swift has no `with` expression: you copy into a `var` and mutate. Synthesis needs no positional syntax. |
| `int?` / `string?` under NRT | `Int?` / `String?`, that is `Optional<Wrapped>` | NRT is an annotation erased at runtime and a warning by default. `Optional` is an enum with cases `.some` and `.none`, a distinct type, real at runtime. |
| `x!` (null forgiving) | `x!` (force unwrap) | Same glyph, opposite consequence. C# erases it. Swift traps and terminates the process. See section 2, item 2. |
| `if (x is not null)` | `if let x { }`, `guard let x else { }` | `guard let` binds for the rest of the enclosing scope and requires the else branch to exit. No C# equivalent. |
| Auto property `{ get; set; }` | `var name: String` | A Swift stored property already is the auto property. Backing field plus accessors is the habit to drop. |
| `=> _x * 2` expression bodied | `var y: Int { x * 2 }` | Direct match. |
| `{ get; private set; }` | `private(set) var` | Direct match, shorter, and it composes with `let`. |
| `INotifyPropertyChanged` boilerplate | `willSet` / `didSet` | Language level. Verified: neither fires for the assignment inside `init`. |
| `Lazy<T>` | `lazy var` | Language level, no wrapper type. Verified: not computed until first access, computed once. Cannot be `let`. |

Chapters: [01-optionals](../modules/01-optionals/README.md),
[03-value-semantics](../modules/03-value-semantics/README.md).

### Abstraction

| C# | Swift | Where the analogy breaks |
|---|---|---|
| `interface` | `protocol` | Protocols carry associated types and `Self` requirements, which C# interfaces cannot express. |
| Default interface members | `extension Protocol { }` | Primary mechanism in Swift, not a versioning escape hatch. A member declared only in the extension dispatches statically. Section 3.2. |
| `abstract class` | protocol plus extension, or a `class` | There is no `abstract` keyword. Shared stored state forces a base class. Shared behavior alone is a protocol extension. |
| `IFoo` as a variable type | `any Foo` | Swift spells the box. `some Foo` and `<T: Foo>` are static. This repo enables `ExistentialAny`, so `any` is mandatory at every existential site. |
| Reified generics, `typeof(T)`, `new T()` | generics via witness tables | No `typeof(T)`, no `new T()`. You buy capability with constraints, for example a protocol with an `init()` requirement. |
| `where T : IComparable<T>` | `where T: Comparable` | Reads almost identically. This is the closest thing to a free transfer in the whole table. |
| Extension methods on a static class | `extension` | Swift extensions add computed properties, initializers, subscripts, nested types, and protocol conformances. C# extension methods add methods only. |
| `partial class` | no equivalent | Split the type across `extension` blocks in several files. Each extension can carry its own conformance, which `partial` cannot. |
| Source generators | macros | Different mechanism, same job. Not covered in this course. |
| `System.Reflection` | `Mirror` | Not comparable. `Mirror` enumerates children for display. Verified working. No invoke by name, no dynamic construction, no attribute scanning. Swift's answer to codegen is macros and `Codable` synthesis. |

Chapters: [04-protocols](../modules/04-protocols/README.md),
[07-generics](../modules/07-generics/README.md).

### Collections and sequences

| C# | Swift | Where the analogy breaks |
|---|---|---|
| `List<T>`, `T[]` | `[T]`, that is `Array<T>` | Value type with copy on write. `var b = a` copies in Swift and aliases in C#. The single most common day one bug. |
| `Dictionary<K, V>` | `[K: V]` | Subscript returns `V?` instead of throwing on a missing key. `TryGetValue` has no reason to exist. |
| `IEnumerable<T>` | `Sequence`, `Collection` | `Sequence` promises one pass. `Collection` promises repeated passes, indices, and `count`. `IEnumerable<T>` blurs the two and you find out at runtime. |
| LINQ `Where` / `Select` / `Aggregate` | `filter` / `map` / `reduce` | Rename plus one inversion: Swift's are eager and return arrays. LINQ is deferred. Section 3.7. |
| `.AsEnumerable()` deferred pipeline | `.lazy` | `.lazy` restores the LINQ model. Verified: `(1...1_000_000).lazy.filter { $0 % 3 == 0 }.map { $0 * 2 }.prefix(3)` yields `[6, 12, 18]`. |
| `yield return` | `IteratorProtocol`, a lazy chain, or `AsyncStream` | There is no `yield return` for synchronous sequences. `AsyncStream` with a continuation is the async analogue. |
| `switch` on a type or a discriminated union library | `enum` with associated values plus `switch` | Swift enums carry payloads and `switch` over them is exhaustive with no `default`. C# has no equivalent, which is why so much C# models state with nullable fields. |

Chapters: [05-enums](../modules/05-enums/README.md),
[06-collections](../modules/06-collections/README.md).

### Failure

| C# | Swift | Where the analogy breaks |
|---|---|---|
| unchecked `throw` | `throws` plus `try` at every call site | Swift marks failure in the signature and again at every call. There is no implicit propagation. |
| arbitrary exception type | `throws(SpecificError)` | Typed throws name the one error type that can come out. The nearest C# analogue is a doc comment. |
| `TryParse` out param | Optional return, or `throws` | There are no `out` parameters. `func parse(_ s: String) -> Int?`. |
| `Result<T>` from a library | `Result<Success, Failure>` in the stdlib | `Result { try f() }` only builds `Result<T, any Error>`. Typed failure needs an explicit `do catch`. Section 3.8. |
| `catch (FooException e)` | `catch` binding the implicit constant `error` | Inside `catch`, the error is bound to `error` unless you pattern match. With typed throws, `error` has your concrete type. |
| `IDisposable` plus `using` | `defer`, plus `deinit` for owned resources | Different axis entirely. Section 3.4. |
| finalizer `~Foo()` | `deinit` | `deinit` runs the instant the last strong reference drops. A C# finalizer runs whenever the collector decides, possibly never. |

Chapters: [08-errors](../modules/08-errors/README.md),
[10-classes-and-arc](../modules/10-classes-and-arc/README.md).

### Serialization

| C# | Swift | Where the analogy breaks |
|---|---|---|
| `System.Text.Json` plus attributes | `Codable` with compiler synthesis | Conformance is synthesized from the stored properties. No attribute scanning at runtime, because there is no runtime attribute scanning. |
| `[JsonPropertyName("id")]` | `enum CodingKeys: String, CodingKey` | One nested enum replaces per property attributes, and it is checked against the stored properties by the compiler. |
| `JsonSerializerOptions` | an explicit `init(from:)` | Behavior that C# configures on the serializer, Swift writes in the type. More code, no reflection, all of it typed. |
| `JsonException` | `DecodingError` with a coding path | The thrown error carries the exact key path that failed. Section [09-codable](../modules/09-codable/README.md) leans on this. |

### Concurrency

| C# | Swift | Where the analogy breaks |
|---|---|---|
| `Task<T>` | `Task<Success, Failure>` | Not the same thing. Section 5. |
| `Task.WhenAll` | `async let`, `withTaskGroup` | Swift child tasks are scoped to the enclosing block and cancellation propagates down the tree with no token threading. |
| `CancellationToken` parameter | ambient task cancellation | Cancellation is carried by the task, not by an argument you pass through twelve signatures. You poll it with `Task.checkCancellation()` or `Task.isCancelled`. |
| `SynchronizationContext`, `ConfigureAwait(false)` | `actor`, `@MainActor`, `nonisolated` | C# inherits resumption context by ambient magic and opts out per await. Swift declares isolation in the type system. |
| `lock` / `Monitor` | `actor` | An actor serializes access to its own state by construction. There is no lock object to forget. |
| `delegate`, `event`, `+=` | closures, `AsyncStream` | Closures cover callbacks. `AsyncStream` covers the multi subscriber push case in pure Swift under `swift test`. There is no `+=` subscription: you hold a handle or an iteration. |
| `volatile`, `Interlocked`, "is this thread safe" by convention | `Sendable` | Thread safety becomes a type constraint the compiler checks, with the honest limits described in section 2, item 9. |

Chapters: [11-isolation](../modules/11-isolation/README.md),
[12-async-await](../modules/12-async-await/README.md).

---

## 2. False friends, ranked by damage

Ranked by how much downstream Swift the mistake corrupts, not by how often
it happens.

**1. Reaching for `class` by default.** This one corrupts everything, which
is why classes are deferred to chapter
[10-classes-and-arc](../modules/10-classes-and-arc/README.md) and you will
write nine chapters of working Swift without one. In C#, `class` is the
neutral choice and `struct` is the exception you justify. In Swift that is
exactly backwards. Writing `class` by reflex costs you the synthesized
memberwise initializer, automatic `Equatable`, `Hashable`, and `Sendable`
conformance when the members qualify, copy semantics, and freedom from ARC.
It buys you aliasing bugs, a retain cycle surface, and a type that cannot
cross an isolation boundary without work. The only permitted justification
vocabulary in this repo is three items, and a `class` needs at least one:

1. The instance has an observable lifecycle, meaning `deinit` must run.
2. Two references must see the same mutation.
3. You need inheritance, or Objective C interop.

If none of the three applies, `struct` is not a preference, it is the
answer. "It felt more natural" is the tell that a C# reflex fired.

**2. Reading `!` as the null forgiving operator.** In C# `!` is a compile
time assertion that is erased before the program runs, so it is free and
mostly harmless. In Swift `!` is a runtime check that terminates the
process. Identical spelling, opposite risk. No sample in this repo uses a
force unwrap except in `modules/01-optionals/probes/` and
`modules/10-classes-and-arc/probes/`, where the crash is the lesson and the
file says so on line one.

**3. Assuming Swift `Task` means C# `Task`.** Different concept under the
same name. Section 5 is the long version. The short version: writing
`let t = Task { ... }` because you wanted a value you can await later
starts unstructured work, drops it out of the cancellation tree, and lets it
outlive the thing that created it. It compounds with item 1, because
unstructured tasks capturing a class is where real races live.

**4. Assuming reference semantics for collections.** `var b = a` on an
`Array`, `Dictionary`, `Set`, or `String` copies. In C# it aliases. No
compiler error, no crash, just a wrong answer somewhere else in the program.
Chapter [03-value-semantics](../modules/03-value-semantics/README.md) makes
you debug this rather than read about it.

**5. Assuming `filter` and `map` are deferred like LINQ.** Correct results,
silent allocation per stage. It ranks below item 4 because it costs
performance and not correctness. `.lazy` restores the LINQ behavior exactly.

**6. Assuming protocol members always dispatch dynamically.** A member
declared in the protocol body dispatches through the witness table and a
conforming type's version wins. A member that exists only in a protocol
extension dispatches statically, so calling it through `any P` runs the
extension version even when the concrete type declared its own. C# has no
equivalent hazard because interface members are always virtual. Verified
output in section 3.2.

**7. Treating `deinit` as a finalizer you can ignore.** Inverted from C#. A
C# finalizer is unreliable and the guidance is to avoid depending on it. A
Swift `deinit` is deterministic and is where you close files, cancel timers,
and remove observers. Which means a leaked reference cycle does not merely
waste memory, it silently skips your cleanup.

**8. Hunting for `using`, `partial`, `out`, and reflection.** Costs time,
not correctness. They do not exist. The replacements are `defer`,
`extension` blocks across files, an Optional or tuple return, and `Codable`
plus macros.

**9. Believing strict concurrency catches every data race.** It does not,
and the material will not tell you otherwise. Swift 6.2 uses region based
isolation, which is more permissive than the naive `Sendable` rule most
articles describe. Verified, both files compiled with plain `swiftc
-swift-version 6`:

```swift
final class Counter { var n = 0 }
func run() {
    let c = Counter()
    Task { c.n += 1 }   // compiles clean: c's region is transferred
}
```

Add one line and the same code is rejected:

```swift
    Task { c.n += 1 }
    c.n += 2            // now the region is used after transfer
```

```text
error: sending value of non-Sendable type '() async -> ()' risks causing
data races [#SendingRisksDataRace]
note: access can happen concurrently
```

The diagnostics that fire reliably are global actor isolation and genuine
`Sendable` requirements. Note also that these come from a compiler pass that
`-typecheck` does not run, so `swift build` is the source of truth and an
editor squiggle is not.

---

## 3. Paired examples

### 3.1 class default versus struct default

```csharp
namespace Academy.Bridge;

public sealed class Inventory
{
    public List<string> Items { get; } = [];
    public void Add(string item) => Items.Add(item);
}

var a = new Inventory();
a.Add("axe");
var b = a;
b.Add("bow");
// a.Items is ["axe", "bow"]. One object, two names.
```

```swift
struct Inventory {
    private(set) var items: [String] = []
    mutating func add(_ item: String) {
        items.append(item)
    }
}

var a = Inventory()
a.add("axe")
var b = a
b.add("bow")
```

Verified output: `["axe"] ["axe", "bow"]`.

The CLR was built around a tracing collector where object identity is cheap
and aliasing is the normal way to share, so reference semantics is the
sensible default there. Swift picks value semantics because a copy is only
conceptually a copy: copy on write shares the buffer until someone writes,
so `[Int]` and `String` copies cost a retain until the first mutation.

The consequence is that most of the defensive copying and the
`IReadOnlyList<T>` ceremony that careful C# needs simply evaporates, because
distant code cannot reach your value. `mutating` is not a restriction. It is
the marker saying this method changes the value in place, which C# has no
way to express.

### 3.2 Interface members versus protocol extension members

```csharp
public interface IShape
{
    double Area { get; }
    string DescribedArea => $"area {Area}";   // default interface member
}

public sealed record Circle(double R) : IShape
{
    public double Area => Math.PI * R * R;
}
```

```swift
protocol Shape {
    var area: Double { get }
}

extension Shape {
    var describedArea: String { "extension \(area)" }
}

struct Circle: Shape {
    let r: Double
    var area: Double { 3.14159 * r * r }
    var describedArea: String { "circle override" }
}
```

Verified. `Circle(r: 1)` reports `circle override`, and the same value held
as `any Shape` reports `extension 3.14159`. Meanwhile `area` reports
`3.14159` through both, because it is declared in the protocol body.

That is the whole rule, and it is the one protocol fact worth memorizing.
Declared in the protocol body means dynamic dispatch through the witness
table, so an override wins. Declared only in an extension means static
dispatch on the static type, so the override is invisible through `any
Shape`. C# cannot reproduce this because interface dispatch is always
virtual.

The second difference is cultural. C# added default interface members late,
mostly so library authors could add members without breaking implementers,
and the community still treats them as a smell. In Swift, protocol
extensions are the main way behavior is shared, and they cover most of what
you would reach for an abstract base class to do.

### 3.3 Nullable reference types versus Optional

```csharp
#nullable enable
string? FindName(int id) => id == 1 ? "Levi" : null;

var name = FindName(2) ?? "unknown";
var length = FindName(1)?.Length;     // int?
var forced = FindName(2)!.Length;     // compiles, throws at runtime
```

```swift
func findName(id: Int) -> String? {
    id == 1 ? "Levi" : nil
}

let name = findName(id: 2) ?? "unknown"
let length = findName(id: 1)?.count

guard let found = findName(id: 1) else { return }
// `found` is a plain String for the rest of the scope.
```

C# nullable annotations are a static analysis layer painted over a runtime
that has always allowed null everywhere. Turn the flag off and the meaning
of the program does not change. `Optional<Wrapped>` is an ordinary generic
enum in the standard library, so `String?` is a genuinely different type
from `String`, with different storage and different capabilities, and there
is no path to the value that skips the empty case.

Two consequences you will not anticipate. Nesting is real: verified, a
`[String: Int?]` lookup has type `Optional<Optional<Int>>`, where the outer
level means the key was missing and the inner level means the stored value
was `nil`. And `Optional` composes with generics, so `map` and `flatMap`
work on it the way they work on `Array`.

Optional chaining flattens rather than nesting. Verified: with `a: A?` whose
`b: B?` holds `c: String?`, the expression `a?.b?.c` has type
`Optional<String>`, not a triple optional.

Chapter: [01-optionals](../modules/01-optionals/README.md).

### 3.4 IDisposable and using versus defer

```csharp
public void Process(string path)
{
    using var reader = new StreamReader(path);
    using var log = new StreamWriter("out.log");
    log.WriteLine(reader.ReadLine());
    // Disposed in reverse order at scope exit, including on exception.
}
```

```swift
func process(path: String) throws {
    let handle = try openResource(at: path)
    defer { handle.close() }

    let log = try openResource(at: "out.log")
    defer { log.close() }

    try log.write(handle.readLine())
}
```

Verified: `defer { print("closed") }` written above `print("open")` prints
`open` then `closed`.

These solve the same problem from opposite ends. C# puts the contract on the
type, so `IDisposable` is a visible promise, analyzers can warn when you drop
one, and the requirement is discoverable from the API surface. Swift puts the
contract on the call site: `defer` attaches cleanup to a scope and runs it on
every exit path including a thrown error, in reverse order of declaration,
but nothing in the type system says a resource needs cleanup at all.

The tradeoff is that `defer` is more general (it can undo any action, not
only disposal) and less enforced (forget it and the compiler is silent). The
working rule: if a type owns an operating system resource, give it a `deinit`
that releases it, so ARC handles the common case. Use `defer` for scope local
unwinding such as restoring a flag or unlocking. Do not go looking for
`using`. It does not exist, and `defer` is not a keyword level substitute.

### 3.5 Enums with payloads versus what C# makes you do

```csharp
public sealed record LoadState
{
    public bool IsLoading { get; init; }
    public string? Value { get; init; }
    public Exception? Error { get; init; }
    // Nothing prevents IsLoading && Error is not null.
}
```

```swift
enum LoadState {
    case idle
    case loading
    case loaded(String)
    case failed(any Error)
}

func label(for state: LoadState) -> String {
    switch state {
    case .idle: "idle"
    case .loading: "loading"
    case .loaded(let value): "loaded \(value)"
    case .failed(let error): "failed \(error)"
    }
}
```

C# has no discriminated union, so multi state models get encoded as a bag of
nullable fields plus an unwritten rule about which combinations are legal.
Swift makes the illegal combinations unrepresentable, and `switch` over the
enum is exhaustive with no `default`, so adding a case turns every incomplete
`switch` into a compile error. That last property is the actual payoff, and
it is why chapter [05-enums](../modules/05-enums/README.md) tells you never
to write `default` over a domain enum you own.

### 3.6 Reflection versus Mirror and Codable

```csharp
var props = typeof(Point).GetProperties();
var instance = Activator.CreateInstance(typeof(Point));
var method = typeof(Point).GetMethod("Translate");
```

```swift
struct Point { let x: Int; let y: Int }
let children = Mirror(reflecting: Point(x: 1, y: 2)).children
print(children.map { "\($0.label ?? "?")=\($0.value)" })
```

Verified output: `["x=1", "y=2"]`.

That is the whole surface. `Mirror` enumerates children for display and
debugging. There is no invoke by name, no dynamic construction, no attribute
scanning, and no assembly scanning. Expect to lose this tool entirely rather
than to find a Swift spelling for it. The work you did with reflection moves
to two places: `Codable` synthesis for the serialization case, and macros for
the code generation case. Both run at compile time, which is why the runtime
has nothing to offer.

### 3.7 LINQ versus eager transforms and lazy

```csharp
var firstThree = Enumerable.Range(1, 1_000_000)
    .Where(n => n % 3 == 0)
    .Select(n => n * 2)
    .Take(3)
    .ToList();
// Deferred. Touches about nine elements.
```

```swift
let eager = (1...1_000_000)
    .filter { $0 % 3 == 0 }
    .map { $0 * 2 }
    .prefix(3)
// Builds a 333,333 element array, then another, then takes three.

let deferred = (1...1_000_000)
    .lazy
    .filter { $0 % 3 == 0 }
    .map { $0 * 2 }
    .prefix(3)
```

Verified: both yield `[6, 12, 18]`, and `(1...20).filter { ... }` has static
type `Array<Int>`, which is the proof that the eager chain materializes.

This is the one row where your C# habit is safer than the Swift default. LINQ
trained you to think in pipelines and to expect deferred execution, and the
pipeline half transfers intact. What inverts is that `filter` and `map` on a
`Collection` return concrete arrays, so a chain that reads identically
allocates once per stage. `.lazy` returns composing wrapper views and
restores the LINQ model exactly.

Swift chose eager defaults because arrays are the overwhelmingly common case,
the result is multi pass and indexable, and copy on write makes the
allocation cheap enough that predictability beats cleverness. The rule:
default to eager, reach for `.lazy` when the source is large or unbounded, or
when you are taking only a prefix.

The second thing LINQ did not prepare you for is the `Sequence` versus
`Collection` split. `Sequence` makes no promise that you can iterate twice.
`Collection` does, and adds `count` and indices. `IEnumerable<T>` collapsed
both and let you discover the difference at runtime.

### 3.8 Exceptions versus typed throws and Result

```csharp
public int ParseCount(string text)
{
    if (string.IsNullOrEmpty(text))
        throw new FormatException("empty");
    return int.Parse(text);        // caller cannot see this can throw
}

var total = ParseCount(input) + 1; // no syntactic marker at all
```

```swift
enum ParseError: Error {
    case empty
    case badDigit(Character)
}

func parseCount(_ text: String) throws(ParseError) -> Int {
    guard !text.isEmpty else { throw .empty }
    var total = 0
    for character in text {
        guard let digit = character.wholeNumberValue,
              (0...9).contains(digit) else { throw .badDigit(character) }
        total = total * 10 + digit
    }
    return total
}
```

`throw .empty` uses leading dot inference because `throws(ParseError)` pins
the thrown type. That only works with typed throws.

Three call site shapes, all verified:

```swift
let count = try parseCount(input) + 1         // marker is mandatory
let fallback = (try? parseCount(input)) ?? 0  // opt out into Optional
let outcome: Result<Int, ParseError>
do { outcome = .success(try parseCount(input)) }
catch { outcome = .failure(error) }
```

**Correction to a claim you will read elsewhere.** Typed throws do not make
a list of `catch` clauses exhaustive. Writing `catch .empty` and
`catch .badDigit(let c)` with no bare `catch` is rejected:

```text
error: errors thrown from here are not handled because the enclosing catch
is not exhaustive
```

What you get instead is that inside a bare `catch`, the constant `error` has
type `ParseError`, so a `switch` over it is exhaustive with no `default`, and
adding a case to `ParseError` breaks every handler that no longer covers it.
That is the real payoff and it is one level deeper than the folk version.

**Second correction.** `Result { try parseCount(text) }` produces
`Result<Int, any Error>`. Annotating the target type does not change the
inference:

```text
error: invalid conversion of thrown error type 'any Error' to 'ParseError'
```

Building a `Result` with a typed failure needs the explicit `do catch` shown
above. Chapter [08-errors](../modules/08-errors/README.md) owns this.

---

## 4. ARC versus GC

This is the hardest shift, and it is not a syntax difference or an API
difference. It is a change in what the word "reference" costs.

Your current model is correct and complete for C#: an object lives until
nothing can reach it, the runtime decides when, and you never think about
it. Hold onto that sentence, because exactly one clause of it stops being
true.

A tracing collector starts from roots and walks outward, so its question is
"can I reach this". ARC keeps a count on each object and its question is
"does anyone still hold this". Those two questions give the same answer for
every object graph except one shape.

### The shape

```csharp
public sealed class Player
{
    public string Name { get; }
    public Action? OnScore;
    public Player(string name) => Name = name;
}

public sealed class Scoreboard
{
    public int Total { get; private set; }
    private Player? _player;

    public void Track(Player p)
    {
        _player = p;
        p.OnScore = () => Total++;   // captures this strongly
    }
}
```

`Scoreboard` to `Player` to closure to `Scoreboard` is a cycle. The collector
takes it anyway. That C# has no bug.

```swift
final class Player {
    let name: String
    var onScore: (() -> Void)?
    init(name: String) { self.name = name }
    deinit { print("  Player \(name) deinit") }
}
```

```swift
final class Scoreboard {
    private(set) var total = 0
    private var player: Player?
    deinit { print("  Scoreboard deinit") }

    func trackLeaking(_ p: Player) {
        player = p
        p.onScore = { self.total += 1 }
    }

    func trackClean(_ p: Player) {
        player = p
        p.onScore = { [weak self] in self?.total += 1 }
    }
}
```

Verified output when each pair is created and released inside a function:

```text
-- leaking --
  total = 1
  (scope exited)
-- clean --
  total = 1
  Scoreboard clean deinit
  Player clean deinit
  (scope exited)
```

The leaking pair prints no `deinit` at all. Both objects are unreachable and
still alive.

The `private var player: Player?` line is load bearing. Without it the graph
is a chain and not a cycle, both objects deinit normally, and the demo
quietly teaches that `[weak self]` is superstition. If you write your own
version, check that both arrows exist.

### The diagram

```text
Frame 1: inside the function scope
   +- scope ------------------------------+
   |   p ----------+       s ----------+  |
   +---------------|-------------------|--+
                   v                   v
              +---------+        +--------------+
              | Player  |<-------|  Scoreboard  |
              | count 2 |        |   count 2    |
              +---------+------->+--------------+
                 (via the onScore closure capturing self)

Frame 2: scope exits, both locals release
   +- scope (gone) -----------------------+
   +--------------------------------------+
              +---------+        +--------------+
              | Player  |<-------|  Scoreboard  |
              | count 1 |        |   count 1    |
              +---------+------->+--------------+
        Neither reaches zero. No deinit. Unreachable and immortal.

Frame 3: the same graph with [weak self] in the closure
              +---------+        +--------------+
              | Player  |<-------|  Scoreboard  |
              | count 1 | .weak. |   count 0    | -> deinit fires
              +---------+. . . .>+--------------+
        Scoreboard dies, releases Player, count 1 -> 0 -> deinit fires
```

Read three things off it. The count is a number inside the box, so reaching
zero is something you watch rather than a rule you recall. The scope is a
dashed container that disappears between frames, which is what makes frame 2
the point: unreachable and alive is a state C# has no name for. And the weak
arrow is dashed and one directional, so the asymmetry that fixes the cycle is
visual.

Full version with the accompanying probe:
[docs/diagrams/arc-and-cycles.md](diagrams/arc-and-cycles.md).

### weak, unowned, and capture lists

**`weak`** does not increment the count and becomes `nil` when the referent
deallocates. Because it can become `nil`, a `weak` reference must be Optional
and must be `var`. Use it when the referent may plausibly die first: a
delegate, an observer registry, a back reference from child to parent where
the parent is not guaranteed to outlive you.

**`unowned`** does not increment the count and does not become `nil`. If you
touch it after the referent died, the program traps. Use it only when the
referent provably outlives the reference, and prefer `weak` when you are not
certain. `unowned` buys you a non Optional spelling and nothing else.

**A capture list** is the same idea applied to a closure. `[weak self]`
captures `self` weakly, which is why the body reads `self?.total += 1`: that
is the Optional machinery from chapter 01 showing up in a new place. Closures
capture strongly by default, and the shape to watch for is a closure stored
on an object that the closure also references.

Two facts that matter more than the vocabulary. `deinit` is deterministic and
runs the instant the last strong reference drops, which C# cannot promise, so
it is the right place for cleanup. And because it is the right place for
cleanup, a leaked cycle does not merely waste memory, it skips the cleanup
silently. That is the correctness cost, and it is why this gets its own
chapter and its own project.

Chapter: [10-classes-and-arc](../modules/10-classes-and-arc/README.md).
Project: [05-event-bus](../projects/05-event-bus/SPEC.md), whose test asserts
that a subscriber deallocates after leaving scope, so any strong capture
fails it.

---

## 5. C# Task and Swift Task are different things

The words match and the models do not.

A C# `Task<int>` is a handle to work that is already in flight. Calling
`FetchAsync(1)` without awaiting still runs it. `await` observes a result
that is being produced whether or not you look.

A Swift `async` function does nothing until you call and await it. There is
no eagerly started future value. `Task { }` is the separate, explicitly
unstructured escape hatch that starts detached work, and the closest analogue
to a C# `Task<T>` value is an `async` function you have not called yet.

So `let t = Task { await load() }` written because you wanted a
`Task<T>` value is a real bug pattern: it starts work outside the structured
tree, and cancellation of the surrounding work will not reach it.

```csharp
public async Task<int> TotalAsync()
{
    var a = FetchAsync(1);              // already running
    var b = FetchAsync(2);
    var results = await Task.WhenAll(a, b);
    return results.Sum();
}
```

```swift
func total() async -> Int {
    await withTaskGroup(of: Int.self) { group in
        for id in 1...3 { group.addTask { await fetch(id: id) } }
        var sum = 0
        for await value in group { sum += value }
        return sum
    }
}
```

Verified: with `fetch(id:)` returning `id * 10`, `total()` returns `60`.

`withTaskGroup` scopes its children to the block. The group cannot outlive
it, and cancellation propagates down the tree with no `CancellationToken`
threaded through twelve signatures. For a fixed small number of concurrent
operations, `async let` is the shorter form.

### Where you resume

The deeper difference is where the answer to "which context do I resume on"
lives. C# hides it in an ambient `SynchronizationContext`, which is why
`ConfigureAwait(false)` exists and why blocking on `.Result` deadlocks. Swift
promotes it into the type system.

```swift
actor Bank {
    private var balance = 0
    func deposit(_ amount: Int) { balance += amount }
    func read() -> Int { balance }
}

@MainActor final class Screen {
    private(set) var title = ""
    func load() async { title = "loaded" }
}
```

Verified compiling and running. Touch the isolated state from outside and you
get, verbatim:

```text
error: main actor-isolated property 'title' can not be mutated from a
nonisolated context
note: add '@MainActor' to make global function 'offMain' part of global
actor 'MainActor'
```

Read that as the feature. The compiler is telling you the isolation you
declared, and the note names the fix. What you relearn from C# is isolation
and cancellation, which is a much smaller delta than learning async from
zero, because you already understand suspension points.

Chapters: [11-isolation](../modules/11-isolation/README.md),
[12-async-await](../modules/12-async-await/README.md).

---

## 6. What you already have

A bridge that only lists your wrong assumptions will make you underestimate
how much transfers. These carry over intact.

**Static typing with real generics.** You skip the entire "why must I declare
types" adjustment. Generic constraints read almost identically:
`where T: Comparable` against `where T : IComparable<T>`. Chapter
[07-generics](../modules/07-generics/README.md) can move fast, and the new
material there is `some` versus `any`, not generics themselves.

**LINQ fluency.** You already think in pipelines instead of index loops,
which is most of what chapter
[06-collections](../modules/06-collections/README.md) teaches. The delta is a
rename plus the eager versus lazy correction in section 3.7.

**Interface driven design.** Programming to abstractions, dependency
inversion, accepting the abstraction and returning the concrete type: all of
it maps onto protocol oriented design. Swift extends that approach, it does
not contradict it.

**The async mental model.** "The function suspends here and the thread goes
elsewhere" is the genuinely hard part for newcomers and you already have it.

**Exception discipline.** Anyone who has designed a custom exception
hierarchy takes to error enums immediately. `throws` is stricter, not
stranger, and typed throws will read as a feature you always wanted.

**`record` primed you for value equality.** A `struct` with declared
`Equatable` is a record without the `with` expression.

**Property syntax.** Computed properties, get only properties, and access
control are all familiar, and `private(set)` reads better than
`{ get; private set; }`.

**Data structures and algorithms.** This is the largest advantage and the
most underrated. Everything in your C# DSA work is portable, and rebuilding a
structure you already wrote means the algorithm is settled so all of your
attention goes to the language. Project
[03-collections-kit](../projects/03-collections-kit/SPEC.md) requires exactly
that, and the spec asks you to pick a structure whose design changes under
value semantics.

**Tooling.** Git, VS Code, the command line, package manifests, and test
first development all carry over. `swift test` will feel like `dotnet test`.

---

## 7. Chapter index

Eleven of the fourteen chapters anchor on C# and carry a `Coming from C#`
section built from the rows below. Three anchor on Python (02, 06, and 09)
and carry `Coming from Python` instead, built from
[bridge-python.md](bridge-python.md) section 5. A chapter never carries both.

The anchor for every chapter is assigned once, in
[keywords.md](keywords.md) section 2, with the reason for each. This table and
bridge-python.md's partition the fourteen along it rather than both claiming
all of them.

| Chapter | Anchor | Owns these rows |
|---|---|---|
| [01-optionals](../modules/01-optionals/README.md) | C# | NRT versus `Optional`, `!`, `??`, `?.`, `if let`, `guard let` |
| [02-functions](../modules/02-functions/README.md) | Python | not this file. Reference only, for a C# reader: argument labels, closures, functions as values, trailing closure syntax |
| [03-value-semantics](../modules/03-value-semantics/README.md) | C# | `class` versus `struct` defaults, `mutating`, copy on write, collection aliasing |
| [04-protocols](../modules/04-protocols/README.md) | C# | `interface` versus `protocol`, default members, extension dispatch, retroactive conformance |
| [05-enums](../modules/05-enums/README.md) | C# | payload enums, exhaustive `switch`, why C# reaches for nullable fields |
| [06-collections](../modules/06-collections/README.md) | Python | not this file. Reference only, for a C# reader: LINQ mapping, eager versus `.lazy`, `Sequence` versus `Collection` |
| [07-generics](../modules/07-generics/README.md) | C# | reification, witness tables, `some` versus `any`, `where` clauses |
| [08-errors](../modules/08-errors/README.md) | C# | checked call sites, typed throws, `try?`, typed `Result` |
| [09-codable](../modules/09-codable/README.md) | Python | not this file. Reference only, for a C# reader: `System.Text.Json` mapping, `CodingKeys`, `DecodingError` |
| [10-classes-and-arc](../modules/10-classes-and-arc/README.md) | C# | ARC versus GC, `deinit` versus finalizers, `weak`, `unowned`, capture lists |
| [11-isolation](../modules/11-isolation/README.md) | C# | `SynchronizationContext` versus declared isolation, `Sendable`, `actor`, `@MainActor` |
| [12-async-await](../modules/12-async-await/README.md) | C# | C# `Task` versus Swift `Task`, `Task.WhenAll` versus `async let` and `withTaskGroup`, cancellation |
| [13-swiftui-state](../modules/13-swiftui-state/README.md) | C# | WPF and MVVM, `INotifyPropertyChanged`, `Binding`, `Dispatcher`, template reuse versus view identity |
| [14-swiftui-app](../modules/14-swiftui-app/README.md) | C# | DI containers versus injected closures, EF Core versus SwiftData, the MVVM conversation |
Related references: [glossary.md](glossary.md), [keywords.md](keywords.md),
[legacy-swift.md](legacy-swift.md),
[how-this-repo-works.md](how-this-repo-works.md).
