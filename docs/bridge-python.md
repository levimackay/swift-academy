---
title: Python to Swift
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Python to Swift

A lookup table, not a chapter. It maps constructs you already own onto Swift
spellings and then says where the mapping stops being true, because the place
it stops is the only part worth reading twice. Nothing here is sequenced and
nothing here has exercises. Look up the construct you were about to type, read
where the analogy breaks, go back to the chapter.

Each Python anchored chapter README carries a `Coming from Python` section
holding only the rows that chapter owns, and links here. Three chapters anchor
on Python: 02-functions, 06-collections, and 09-codable. Section 5 says which
rows belong to which chapter, and [keywords.md](keywords.md) section 2 records
why each chapter got the anchor it did.

Every Swift sample below was compiled with `swiftc -swift-version 6
-enable-upcoming-feature ExistentialAny` on the toolchain named above, and
every sample that prints was run. Every Python sample was run on CPython 3.14.
Where the compiler contradicted a widely repeated rule, the row says so and
gives the narrower rule that is actually true; section 6 lists those
corrections.

Foundation is imported for `trimmingCharacters(in:)`, `String(format:)`,
`JSONDecoder`, and `KeyPathComparator`. Everything else is standard library.

---

## 1. Mapping table

| Python | Swift | Where the analogy breaks |
|---|---|---|
| `None`, `x: str \| None` | `Optional<String>`, spelled `String?` | `None` is a value that flows anywhere. `Optional` is a separate enum with cases `.some` and `.none`, so `String?` and `String` are not interchangeable and the compiler blocks the call until you unwrap. `Int??` is a real distinct type; `None` never nests. |
| Type hints, `mypy` | The type system itself | Hints are metadata stripped at runtime and checked only if you run a tool. Swift types decide overload resolution, memory layout, dispatch, and whether the program links. `Any` in Swift is not `typing.Any`: it is a box with runtime cost and almost no capabilities. |
| Truthiness, `x or default` | `Bool` only, `x ?? default` | `if x` needs an actual `Bool`. `??` substitutes for `nil` only, never for `0`, `""`, or `[]`. See FF2. |
| Duck typing, `hasattr`, `typing.Protocol` | `protocol` with declared conformance | Swift protocols are nominal. A type with a matching `area` is not a `Shape` until someone writes `: Shape`. You get retroactive conformance in exchange: add capability to a type you do not own, checked at compile time. |
| An ABC used as a parameter type | `some P` (constraint) or `any P` (box) | Python has one spelling. Swift has two, with different costs and different capabilities, and picking wrong is the most common structural mistake here. See FF8. |
| `__eq__`, `__hash__`, `__lt__` | `Equatable`, `Hashable`, `Comparable` | Dunders are independent and any subset is legal. Swift protocols refine each other (`Comparable: Equatable`) and synthesize implementations from stored properties, so you cannot ship `<` without `==` and never hand write a hash. |
| `__str__`, `__repr__` | `CustomStringConvertible`, `CustomDebugStringConvertible` | `description` is what `print` and `"\(x)"` use. Without the conformance Swift still prints something structural, so a missing `description` is silent, not an error. |
| `__getitem__`, `__setitem__`, `__call__` | `subscript`, `callAsFunction` | `subscript` declares get and set in one member rather than two dunders that can disagree. |
| `list`, `dict`, `set` | `Array`, `Dictionary`, `Set` | Value types: assignment copies (copy on write). `dict[key]` returns `Optional`, it does not raise. Arrays are homogeneous, so `[1, "a"]` is `[Any]` and nearly useless. Iteration order of `Dictionary` and `Set` is not insertion order and changes between runs. |
| Comprehensions, generator expressions | `map`, `filter`, `compactMap`, `flatMap`, `reduce`, `Dictionary(grouping:by:)`, `.lazy` | One fused syntactic form becomes several methods, each allocating unless you insert `.lazy`. `compactMap` has no Python name because Python has no "failure is already a value" idiom. A comprehension's trailing `if` becomes a `filter` written before the `map`. |
| Generators, `yield`, `itertools` | `Sequence` and `IteratorProtocol`, `sequence(first:next:)`, `.lazy` | Swift has no synchronous `yield`. You write the state machine yourself and its state becomes a visible stored property. Laziness inverts: Python generators are lazy by default, Swift chains are eager until `.lazy`. |
| `async def` generators, `async for` | `AsyncSequence`, `AsyncStream`, `for await` | This one genuinely lines up. The additions are cancellation, which a `for await` loop participates in, and a typed `Failure`. |
| `iter()`, `next()`, `StopIteration` | `makeIterator()`, `mutating func next() -> Element?` | Termination is `nil` from a value returning method, not a thrown control flow exception. `next()` is `mutating`, so two loops over the same iterator value each get their own copy. |
| Decorators | Higher order functions, `@propertyWrapper`, `@resultBuilder`, macros | One Python mechanism split across four Swift ones by purpose. A decorator runs at import time and can replace the function with a different signature. Swift's versions are compile time, checked, and cannot change the shape of what they decorate. |
| `try`/`except`/`raise`, exception hierarchy | `throws`, `throws(E)`, `try`, `do`/`catch`, `Result` | Any Python function can raise anything, so the failure set is documentation. In Swift it is in the signature, and with typed throws it is in the type. `try` marks one expression, it does not open a block. Errors are never used for flow control. |
| `finally`, `with`, `__enter__`/`__exit__` | `defer`, plus `deinit` for owned resources | `defer` is written at acquisition instead of wrapping the body, runs in reverse declaration order, fires at the end of the enclosing scope (an `if`, not the function), and cannot swallow an error the way `__exit__` returning `True` does. |
| `dataclass` | `struct` plus the synthesized memberwise init | Close. Breaks: the struct is a value type, `Equatable` and `Hashable` are synthesized only when declared, `frozen=True` maps onto declaring the instance `let` rather than onto the type, and the memberwise init is `internal`, so a `public` struct needs an explicit `public init`. |
| `field(default_factory=list)` | `var tracks: [String] = []` | No analogue needed. A Swift default is an expression evaluated at each call, and the value is copied anyway, so the shared mutable default bug is not expressible. |
| `__slots__`, `setattr`, `__getattr__` | Fixed stored properties, `MemoryLayout`, `Mirror` | Every Swift type is `__slots__` always. There is no per instance dictionary and no `setattr`. `@dynamicMemberLookup` is opt in and still statically typed; `Mirror` is read only. |
| Assignment and aliasing, `copy.deepcopy` | Value semantics with copy on write, reference semantics for `class` | The same line means two different things depending on whether the type is a `struct` or a `class`. `deepcopy` mostly disappears for value types. See FF1. |
| `class` as the way to make a type | `struct` and `enum` first, `class` when you need identity | `class` in Swift specifically buys reference semantics, inheritance, and ARC. It is a deliberate choice, not the default shape of a type. See FF13. |
| `is`, `isinstance` | `===`, `is` and `as?` | Swift's `is` is Python's `isinstance`. Python's `is` is Swift's `===` and exists only for class instances, because value types have no identity. |
| `json.loads`, pydantic | `Codable`, `CodingKeys`, `JSONDecoder` | Decoding is a typed operation that throws a `DecodingError` naming the failing key path, rather than producing a `dict` you index and hope. There is no dynamic model: the shape is the type. |
| `s[0]`, `s[::-1]`, `len(s)` | `String.Index`, `Character` as a grapheme cluster | `s[0]` does not compile. `count` is O(n). Indices are produced by the string. `array[1..<3]` is an `ArraySlice` sharing storage and keeping the parent's indices, so its `startIndex` is `1`. |
| `int` arbitrary precision, `/`, `//`, `%` | Fixed width `Int` that traps, truncating `/` | `2 ** 200` overflows. `5 / 2` is `2`. `-5 / 2` is `-2` in Swift and `-3` in Python (truncation versus flooring), and `-5 % 3` is `-2` in Swift and `1` in Python. `&+` is the explicit wrapping form. |
| Implicit numeric widening | No implicit conversion between named types | `1 + 1.5` compiles in both, because Swift's integer literal adopts `Double`. Given `let a = 1` and `let b = 1.5`, `a + b` is an error. Literals are polymorphic; variables are not. See FF16. |
| `sorted(key=)`, `list.sort()` | `sorted(by:)`, `sort()`, `sorted(using:)` | Swift's common overload takes a two argument predicate returning `Bool`, not a key extractor. `sorted(using: KeyPathComparator(\.age))` is the extractor shape when you want it. |
| GIL, `threading`, `asyncio` | Actors, `Sendable`, `@MainActor`, `Task`, `TaskGroup` | `asyncio` gives concurrency without parallelism, so shared mutable state between `await` points is usually fine. Swift tasks run with real parallelism, so the same code is a data race, and the compiler rejects most of it. See FF3. |
| `asyncio.create_task` | `withTaskGroup`, `async let`, `Task` | A group cannot return until every child finishes, and cancellation propagates down the tree. The orphaned task has no expressible form inside a task group. |
| Refcounting plus a cycle collector | ARC with no cycle collector | CPython refcounts like Swift, so the basic intuition carries, but CPython also collects cycles and Swift does not. A closure that captures `self` and is stored on `self` leaks forever. See FF10. |
| pytest, plain `assert` | swift-testing, `@Test`, `#expect` | Closer to pytest than to XCTest. Parameterized tests exist in both. Runs under plain `swift test`. |
| `pip`, `venv`, `pyproject.toml` | SwiftPM, `Package.swift` | Manifest, resolution, lockfile, test command. Nothing conceptually new. |

---

## 2. Paired samples

### 2.1 None versus Optional

Chapter: [01-optionals](../modules/01-optionals/README.md)

```python
@dataclass
class User:
    nickname: str | None = None

def display(user: User) -> str:
    if user.nickname:
        return user.nickname.upper()
    return "anonymous"

def lookup_port(config: dict[str, str], key: str) -> int | None:
    raw = config.get(key)
    if raw is None:
        return None
    try:
        return int(raw)
    except ValueError:
        return None
```

```swift
struct User {
    var nickname: String?
}

func display(_ user: User) -> String {
    guard let nickname = user.nickname, !nickname.isEmpty else { return "anonymous" }
    return nickname.uppercased()
}

func lookupPort(in config: [String: String], key: String) -> Int? {
    guard let raw = config[key] else { return nil }
    return Int(raw)
}
```

Both print `LEVI anonymous`. The Swift version writes `!nickname.isEmpty` out
loud because `if user.nickname` in Python asks three questions at once and
Swift only lets you ask one.

The second function is the payoff. Python needs `try`/`except` because `int()`
signals failure by raising. Swift's `Int(_:)` returns `Int?`, so failure and
absence are already the same shape and compose with no error handling at all.
The habit to build is asking what type the failure is, not whether something
went wrong. When the answer is "just absence", the answer is `Optional` and
there is no `throws`.

### 2.2 Duck typing versus protocols

Chapters: [04-protocols](../modules/04-protocols/README.md),
[07-generics](../modules/07-generics/README.md)

```python
class Shape(Protocol):
    @property
    def area(self) -> float: ...
    def scaled(self, factor: float) -> Self: ...

class Circle:
    def __init__(self, radius: float) -> None:
        self.radius = radius
    @property
    def area(self) -> float:
        return 3.141592653589793 * self.radius ** 2
    def scaled(self, factor: float) -> "Circle":
        return Circle(self.radius * factor)

def total_area(shapes: list[Shape]) -> float:
    return sum(shape.area for shape in shapes)
```

```swift
protocol Shape {
    var area: Double { get }
    func scaled(by factor: Double) -> Self
}

struct Circle: Shape {
    var radius: Double
    var area: Double { .pi * radius * radius }
    func scaled(by factor: Double) -> Circle { Circle(radius: radius * factor) }
}

func totalArea(of shapes: [any Shape]) -> Double {
    shapes.reduce(0) { $0 + $1.area }
}

func largest<S: Shape>(among shapes: [S]) -> S? {
    shapes.max { $0.area < $1.area }
}

// No Python equivalent short of monkeypatching.
protocol Describable { var label: String { get } }
extension Int: Describable { var label: String { "int \(self)" } }
```

In Python, `Shape` is documentation for a checker, and `total_area` works on
anything carrying an `area` whether or not anyone declared anything. In Swift,
conformance is declared, so the compiler knows the complete answer and can
spend it two different ways.

`[any Shape]` is the Python shaped answer: heterogeneous, boxed, dispatched
through a witness table, fine and slightly costly. `<S: Shape>` is the answer
Python has no version of: the element type is known at the call site, calls can
inline, and `largest` returns `S` rather than a box the caller must downcast.
That split, existential versus generic, is the largest structural difference
between the two polymorphism models, and it exists only because conformance is
static. Retroactive conformance on `Int` is the compensation for losing
structural typing: capability added to a type you do not control, checked at
compile time, without touching its definition.

### 2.3 Comprehensions versus map, filter, compactMap

Chapter: [06-collections](../modules/06-collections/README.md)

```python
def even_numbers(lines: list[str]) -> list[int]:
    out = []
    for line in lines:
        text = line.strip()
        try:
            value = int(text)
        except ValueError:
            continue
        if value % 2 == 0:
            out.append(value)
    return out

def grouped(words: list[str]) -> dict[int, list[str]]:
    out: dict[int, list[str]] = {}
    for word in words:
        out.setdefault(len(word), []).append(word)
    return out
```

```swift
func evenNumbers(in lines: [String]) -> [Int] {
    lines
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .compactMap(Int.init)
        .filter { $0 % 2 == 0 }
}

func grouped(_ words: [String]) -> [Int: [String]] {
    Dictionary(grouping: words, by: \.count)
}
```

Both return `[2, 4]` for `[" 1 ", "2", "abc", " 4"]`. Note what the Python
could not be: writing `even_numbers` as one comprehension needs a validity
predicate before converting, and `str.isdigit` is wrong for negatives and for
`"1_0"`, so the honest Python is a loop with a `try`. Swift inverts the order.
Attempt the conversion, get `Int?`, let `compactMap` drop the failures. You
never write the predicate, because the failure is already a value.

Two costs to carry. The Swift chain is three passes with two intermediate
arrays where the comprehension was one pass, and `.lazy` is what puts the
single pass back. And `Dictionary(grouping:by:)` with the key path `\.count`
shows the real skill: recognize which named standard library function a
comprehension already was, rather than translating it clause by clause.

### 2.4 Generators versus Sequence and AsyncSequence

Chapters: [06-collections](../modules/06-collections/README.md),
[12-async-await](../modules/12-async-await/README.md)

```python
def squares():
    for n in itertools.count(1):
        yield n * n

def first_square_over(limit: int) -> int:
    return next(sq for sq in squares() if sq > limit)

def countdown(start: int):
    while start > 0:
        yield start
        start -= 1

async def ticks(count: int):
    for index in range(count):
        yield index
```

```swift
func firstSquare(over limit: Int) -> Int? {
    sequence(first: 1) { $0 + 1 }
        .lazy
        .map { $0 * $0 }
        .first { $0 > limit }
}

struct Countdown: Sequence, IteratorProtocol {
    var current: Int
    mutating func next() -> Int? {
        guard current > 0 else { return nil }
        defer { current -= 1 }
        return current
    }
}

func ticks(count: Int) -> AsyncStream<Int> {
    AsyncStream { continuation in
        for index in 0..<count { continuation.yield(index) }
        continuation.finish()
    }
}
```

Both produce `64` and `[3, 2, 1]`. `yield` is a compiler transform that turns a
function into a resumable state machine and hides the frame. Swift has no
synchronous `yield`, so `Countdown` is that state machine with `current` as the
visible frame. That is why `next()` is `mutating`, and why handing a
`Countdown` to two loops gives each its own copy while a Python generator
handed to two loops gives the second one nothing.

Laziness runs the other way in each language. Python tells you which you got
from the brackets, `[...]` eager and `(...)` lazy. Swift is eager everywhere
and `.lazy` is the switch, which is the only reason `firstSquare(over:)`
terminates over an infinite sequence. The async half converges: `AsyncSequence`
and `for await` are `async def` plus `yield` and `async for`, with cancellation
added.

### 2.5 Dunder methods versus protocol conformances

Chapter: [04-protocols](../modules/04-protocols/README.md)

```python
@dataclass(frozen=True, order=True)
class Money:
    cents: int
    def __str__(self) -> str:
        return f"${self.cents / 100:.2f}"
    def __add__(self, other: "Money") -> "Money":
        return Money(self.cents + other.cents)

class Wallet:
    def __init__(self) -> None:
        self._slots: dict[str, Money] = {}
    def __getitem__(self, name: str) -> Money:
        return self._slots.get(name, Money(0))
    def __setitem__(self, name: str, value: Money) -> None:
        self._slots[name] = value
```

```swift
struct Money: Hashable, Comparable, CustomStringConvertible, AdditiveArithmetic {
    var cents: Int
    static let zero = Money(cents: 0)
    var description: String { String(format: "$%.2f", Double(cents) / 100) }
    static func < (lhs: Money, rhs: Money) -> Bool { lhs.cents < rhs.cents }
    static func + (lhs: Money, rhs: Money) -> Money { Money(cents: lhs.cents + rhs.cents) }
    static func - (lhs: Money, rhs: Money) -> Money { Money(cents: lhs.cents - rhs.cents) }
}

struct Wallet {
    private var slots: [String: Money] = [:]
    subscript(name: String) -> Money {
        get { slots[name] ?? .zero }
        set { slots[name] = newValue }
    }
}
```

Both print `$13.49` for twelve fifty plus ninety nine cents. Python resolves `a
+ b` by looking for `__add__` on the left operand and then `__radd__` on the
right, and any subset of dunders is legal. Swift's operators are `static func`,
so there is no left operand privilege and no `__radd__` counterpart, and the
protocols carry three things a naming convention cannot.

**Refinement.** `Comparable` inherits `Equatable`, so you cannot ship a type
that sorts but does not deduplicate.

**Synthesis.** Declaring `Hashable` on a struct whose stored properties are all
`Hashable` generates `==` and `hash(into:)`. You never hand write a hash, and
never hit the Python bug where defining `__eq__` silently makes the type
unhashable.

**Generic access.** Because `Money` declares `AdditiveArithmetic`, every
algorithm constrained on that protocol accepts it, including `reduce(.zero,
+)`. Python has no name for "the set of types that support addition and a
zero", so no amount of dunder definition buys this.

### 2.6 Exceptions versus typed throws

Chapter: [08-errors](../modules/08-errors/README.md)

```python
class ParseError(Exception): pass
class EmptyInput(ParseError): pass
class NotANumber(ParseError): pass
class OutOfRange(ParseError): pass

def report(raw: str) -> str:
    try:
        return f"score {parse_score(raw)}"
    except EmptyInput:
        return "nothing entered"
    except NotANumber as exc:
        return f"not a number: {exc.args[0]}"
    except OutOfRange as exc:
        return f"out of range: {exc.args[0]}"
```

```swift
enum ParseError: Error, Equatable {
    case empty
    case notANumber(String)
    case outOfRange(Int)
}

func parseScore(_ raw: String) throws(ParseError) -> Int {
    let trimmed = raw.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { throw .empty }
    guard let value = Int(trimmed) else { throw .notANumber(trimmed) }
    guard (0...100).contains(value) else { throw .outOfRange(value) }
    return value
}

func report(for raw: String) -> String {
    do {
        return "score \(try parseScore(raw))"
    } catch {
        switch error {
        case .empty: return "nothing entered"
        case .notANumber(let text): return "not a number: \(text)"
        case .outOfRange(let value): return "out of range: \(value)"
        }
    }
}
```

Both produce `score 42`, `nothing entered`, `not a number: abc`, `out of range:
500`. Python models the failure taxonomy as a class hierarchy because `except`
matches by subclass, so the failure set of a function is unbounded and
undocumented. Swift models it as one enum because `catch` matches by pattern,
and `throws(ParseError)` puts the set in the signature. That is what makes the
`switch` exhaustive with no `default`, so adding a fourth case produces a
compile error at every site that handles them. Typed throws in one sentence: it
converts "I hope I handled everything" into "the compiler lists what I missed".

Three mechanical notes.

- `throw .empty` works because the thrown type is known from the signature.
  Without typed throws you write `throw ParseError.empty`.
- Separate pattern matched clauses (`catch .empty { } catch .notANumber { }`)
  do not prove exhaustiveness even under typed throws. The reliable shape is
  one `catch` containing a `switch`, which is what this sample ships.
- `rethrows` standard library functions such as `reduce` erase a typed error
  back to `any Error`. A function that wants to keep its error type and return
  `Result<Int, ParseError>` writes the explicit loop instead.

`try?` converts a throwing call to an `Optional` and is the correct translation
of `except: pass` when you truly do not care why. It is exactly as suspicious
in Swift as bare `except` is in Python.

### 2.7 GIL and asyncio versus actors and structured concurrency

Chapters: [11-isolation](../modules/11-isolation/README.md),
[12-async-await](../modules/12-async-await/README.md)

```python
class Tally:
    def __init__(self) -> None:
        self.count = 0
    def bump(self, amount: int) -> None:
        self.count += amount

async def gather(names: list[str], tally: Tally) -> list[tuple[str, int]]:
    async with asyncio.TaskGroup() as group:
        tasks = [group.create_task(fetch_length(name)) for name in names]
    results = []
    for name, task in zip(names, tasks):
        length = task.result()
        tally.bump(length)
        results.append((name, length))
    return results

async def pair_length() -> int:
    left, right = await asyncio.gather(fetch_length("levi"), fetch_length("mackay"))
    return left + right
```

```swift
actor Tally {
    private(set) var count = 0
    func bump(by amount: Int) { count += amount }
}

struct Report: Sendable {
    var name: String
    var length: Int
}

func gather(_ names: [String], into tally: Tally) async -> [Report] {
    await withTaskGroup(of: Report.self) { group in
        for name in names {
            group.addTask {
                let length = await fetchLength(of: name)
                await tally.bump(by: length)
                return Report(name: name, length: length)
            }
        }
        var results: [Report] = []
        for await report in group { results.append(report) }
        return results
    }
}

func pairLength() async -> Int {
    async let left = fetchLength(of: "levi")
    async let right = fetchLength(of: "mackay")
    return await left + right
}
```

Python's `asyncio` gives concurrency without parallelism. One thread runs the
coroutines, so between two `await` points nothing else touches your data, which
is why the Python `Tally` needs no lock at all inside an event loop. Swift
tasks run on a cooperative pool with real parallelism, so the same sharing is a
data race. Each Swift mechanism replaces a specific Python habit.

**`actor Tally`** replaces the lock, or replaces the assumption that no lock
was needed. The actor owns its state, calls from outside are `await` and
serialized, and `count` is unreachable except through the actor.

**`Sendable` on `Report`** replaces "I assume this is safe to pass across
tasks". A value type composed of value types gets the conformance for free, and
the compiler checks it at the boundary.

**`@MainActor`** replaces "remember to hop back to the UI thread". Touching
main actor state from elsewhere is a compile error rather than a flicker.

Structurally, `withTaskGroup` versus a bare `create_task` is the real
difference: the group cannot return until every child finishes, cancellation
propagates down automatically, and a child result cannot be silently dropped.
The orphaned task, the most common asyncio bug, has no expressible form inside
a task group. One piece of intuition to keep unchanged: `await` marks a
suspension point in both languages and means "other work may run here", not
"run this in the background". `async let` is the `asyncio.gather` shape.

Do not read Swift 6 as catching every data race. It does not. It reliably
diagnoses global actor isolation violations, and it is defeated by `@unchecked
Sendable` and `nonisolated(unsafe)`, which are exactly the escape hatches
frustration reaches for.

### 2.8 Aliasing versus value semantics

Chapters: [03-value-semantics](../modules/03-value-semantics/README.md),
[10-classes-and-arc](../modules/10-classes-and-arc/README.md)

```python
@dataclass
class Playlist:
    name: str
    tracks: list[str] = field(default_factory=list)
    def add(self, track: str) -> None:
        self.tracks.append(track)

def aliasing_demo() -> tuple[int, int]:
    first = Playlist("one")
    second = first
    first.add("a")
    second.add("b")
    second.add("c")
    return len(first.tracks), len(second.tracks)   # (3, 3)

def mutable_default_trap(track: str, tracks: list[str] = []) -> list[str]:
    tracks.append(track)
    return tracks
# first call  -> ['a']
# second call -> ['a', 'b']
```

```swift
struct Playlist: Equatable {
    var name: String
    var tracks: [String] = []
    mutating func add(_ track: String) { tracks.append(track) }
}

func aliasingDemo() -> (Int, Int) {
    var first = Playlist(name: "one")
    var second = first
    first.add("a")
    second.add("b")
    second.add("c")
    return (first.tracks.count, second.tracks.count)   // (1, 2)
}

final class PlaylistBox {
    var tracks: [String] = []
}

func referenceDemo() -> Int {
    let first = PlaylistBox()
    let second = first
    first.tracks.append("a")
    second.tracks.append("b")
    return first.tracks.count   // 2
}
```

Verified: Python returns `(3, 3)`, Swift returns `(1, 2)`. Same seven lines,
different answers, no syntax difference to warn you. In Python `second = first`
binds a second name to one object. In Swift it copies the struct including its
array, lazily via copy on write but observably.

The mutable default trap disappears, and the mirror image trap arrives with it.
Because a struct handed to a function is a copy, a function cannot mutate the
caller's struct unless the parameter is `inout`, and `for playlist in
playlists` gives you copies, so mutating inside that loop changes nothing.
`mutating` on `add` is Swift saying at the signature level that this method
changes the value, and calling it on a `let` is a compile error. Python has no
way to express that.

`PlaylistBox` is the escape hatch: `class` restores Python semantics exactly,
aliasing included. The decision rule is `struct` when the thing is a value you
compare and copy, `class` when the thing has identity and everyone must see the
same one.

### 2.9 json.loads versus Codable

Chapter: [09-codable](../modules/09-codable/README.md)

```python
@dataclass
class Track:
    title: str
    seconds: int

def decode_track(raw: str) -> Track:
    payload = json.loads(raw)
    return Track(title=payload["title"], seconds=payload["duration_s"])
```

```swift
struct Track: Codable, Equatable {
    var title: String
    var seconds: Int
    enum CodingKeys: String, CodingKey {
        case title
        case seconds = "duration_s"
    }
}

func decodeTrack(from json: Data) throws -> Track {
    try JSONDecoder().decode(Track.self, from: json)
}
```

Both produce a `Track` with `seconds: 261`. `json.loads` gives you a `dict`,
and every field access is an unchecked bet that fails as a `KeyError` at the
point of use, arbitrarily far from the decode. `JSONDecoder` validates the
whole shape at the boundary and throws a `DecodingError` naming the key path
and the expected type. The renaming Python does by hand at construction is
declarative in `CodingKeys`. The cost is that the shape must be a type, so
there is no equivalent of poking at an unknown payload, which is the point.

---

## 3. False friends, ranked by damage

Ranked by cost, not by frequency. A silent wrong answer costs a week, a crash
costs a day, a compile error costs an hour, so they rank in that order.

**FF1. `second = first` aliases in Python and copies in Swift.** Silent wrong
answer, highest damage in this file. No syntax differs and both programs run.
Every Python instinct about passing an object around and mutating it produces
Swift that mutates a copy and discards it. The two common forms are mutating a
struct inside a `for` loop and mutating a struct parameter without `inout`.
Chapter [03-value-semantics](../modules/03-value-semantics/README.md).

**FF2. Truthiness, and `??` is not `or`.** Silent wrong answer. `if x`
requiring `Bool` catches most of it at compile time, but `name ?? "anonymous"`
compiles fine and accepts an empty string where the Python original would not,
and `count ?? 0` differs from `count or 0` when `count` is zero. Rule: `??` is
`x if x is not None else default`, never `or`. Chapter
[01-optionals](../modules/01-optionals/README.md).

**FF3. The GIL safety assumption.** Silent wrong answer, and the one that
survives into shipped apps. Years of sharing mutable objects across coroutines
works in Python because one thread runs them. In Swift that is a data race with
real parallelism. Swift 6 catches much of it, which is why the diagnostics are
a safety net rather than a nuisance, but it does not catch what you launder
through `@unchecked Sendable` or `nonisolated(unsafe)`. When the compiler
complains about concurrency, the fix is almost never an annotation, it is
moving state into an actor or onto `@MainActor`. Chapter
[11-isolation](../modules/11-isolation/README.md).

**FF4. Integer division and modulo differ from `/`, and also from `//` and
`%`.** Silent wrong answer. `5 / 2` is `2` in Swift, which everyone warns
about. The unadvertised half: Swift truncates toward zero and Python floors, so
`-5 / 2` is `-2` in Swift and `-3` in Python, and `-5 % 3` is `-2` in Swift and
`1` in Python. Index wrapping or bucketing code ported straight across is wrong
for negative inputs. Overflow traps rather than promoting, so a factorial or
fibonacci drill that runs forever in Python crashes in Swift, and `&+` is the
explicit wrapping form. Chapter
[01-optionals](../modules/01-optionals/README.md).

**FF5. `d[key]` returns an Optional, and the reflex fix is a crash.** Crash.
The lookup itself is safe. The damage is what gets written to make the type
error go away: `d[k]!` turns a handled miss into a process kill and is strictly
worse than `KeyError`. Reach for `d[k, default: 0]`, `guard let`, or `??`.
Chapter [06-collections](../modules/06-collections/README.md).

**FF6. `!` means four things and three of them crash.** Crash. Postfix `x!`,
`try!`, `as!`, and prefix `!flag` share one character. Python has no operator
that terminates the process. Compounding it, the fastest way to silence any
Optional related compiler error is to add `!`, so the compiler's most valuable
feedback is suppressed by the easiest key on the keyboard. The repo ban on
force unwraps exists for this reason. Chapter
[01-optionals](../modules/01-optionals/README.md).

**FF7. Slices share storage and keep the parent's indices.** Silent wrong
answer plus a retention surprise. `array[1..<3]` is an `ArraySlice` whose
`startIndex` is `1`, so `slice[0]` traps and `slice.first` is what you meant.
Python's `list[1:3]` is a fresh zero indexed copy. The merciful failure is an
off by one that crashes. The unmerciful one is holding a small slice of a huge
array and keeping the whole array alive. Chapter
[06-collections](../modules/06-collections/README.md).

**FF8. `any Protocol` used everywhere Python would use an ABC.** Compile error
walls, then bad design. The habit of annotating with the interface becomes
`[any Shape]` reflexively. That works until the protocol has `Self` or an
associated type, at which point the errors get opaque, and it throws away the
concrete type at every boundary so the code fills with `as?` downcasts where
Python used `isinstance`. Frame: a protocol used as a type is a box, a protocol
used as a constraint is information. Prefer `some` and generics for parameters,
reserve `any` for genuinely heterogeneous storage. This repo enables
`ExistentialAny`, so every existential site must be spelled `any` and the
choice is visible: `warning: use of protocol 'Shape' as a type must be written
'any Shape'; this will be an error in a future Swift language mode
[#ExistentialAny]`. Chapters [04-protocols](../modules/04-protocols/README.md)
and [07-generics](../modules/07-generics/README.md).

**FF9. Dictionary and Set iteration order is not insertion order and is not
stable across runs.** Flaky tests, the most expensive failure mode in a
learning repo. Python dicts have preserved insertion order since 3.7 and Python
programmers have quietly stopped thinking about it. Swift `Dictionary`
iteration depends on a per process hash seed. Measured on this toolchain: five
runs of the same six key literal printed five different orders, among them
`["a", "b", "d", "f", "c", "e"]` and `["e", "f", "a", "c", "d", "b"]`. Assert
on sorted output, on `Set` equality, or on the dictionary itself, never on
element order. Chapter [06-collections](../modules/06-collections/README.md).

**FF10. Reference cycles leak, because ARC has no cycle collector.** Memory
growth with no error and no crash. CPython's generational collector reclaims
cycles, so you have never once had to think about a closure capturing the
object that stores it. In Swift that is permanent, and closures capture `self`
strongly by default. The tell is any class storing a closure, a delegate, or a
`Task`. This is the item Python experience least prepares you for, which is why
it ranks despite producing no wrong answers. Chapter
[10-classes-and-arc](../modules/10-classes-and-arc/README.md).

**FF11. `try` does not open a block, and errors are not exceptions.** Bad
structure plus swallowed errors. Python wraps large regions in `try:` and uses
exceptions for flow control (`StopIteration`, `KeyError`, sentinel raising). In
Swift `try` annotates one expression, `defer` replaces `finally`, and control
flow never uses errors. The wrap everything habit produces `do` blocks so large
the `catch` cannot say anything useful. The specific damage pattern is `try?`
used the way bare `except: pass` is used, turning a real error into a `nil`
that then gets `??`'d into a default. Chapter
[08-errors](../modules/08-errors/README.md).

**FF12. `sorted(key:)` versus `sorted(by:)`.** Silent wrong answer. Python
takes a key extractor, Swift's common overload takes a two argument predicate
returning `Bool`. `sorted { $0.age }` does not compile, and shapes that do
compile may not order the way you meant. Write `sorted { $0.age < $1.age }`, or
`sorted(using: KeyPathComparator(\.age))` when you want the extractor shape.
Related: `list.sort()` returns `None` while Swift's `sort()` is in place and
`sorted()` returns, so the naming rule is the same idea with different return
values. Chapter [06-collections](../modules/06-collections/README.md).

**FF13. `class` in Swift is not how you define a type.** Design damage,
accumulating slowly. In Python `class` is the only way to make a type, so the
reflex is to reach for `class`, add inheritance, and build a hierarchy. In
Swift `class` specifically buys reference semantics, inheritance, and ARC
overhead, and the default answer is `struct` or `enum`. Nothing breaks; the
code just stops benefiting from value semantics and starts needing the care
FF10 describes. The three reasons that justify a class: an observable
lifecycle, shared mutation seen through two references, or inheritance and
interop. Chapter [10-classes-and-arc](../modules/10-classes-and-arc/README.md).

**FF14. `is` and `isinstance` swap places.** Compile errors plus one real trap.
Swift's `is` is Python's `isinstance`; Python's `is` is Swift's `===` and
exists only for classes. The trap is assuming `==` is always available:
comparing values of a type that does not conform to `Equatable` is a compile
error rather than `False`. Chapter [05-enums](../modules/05-enums/README.md).

**FF15. String indexing and length.** Compile errors leading to bad
workarounds. `s[0]` fails with `error: 'subscript(_:)' is unavailable: cannot
subscript String with an Int, use a String.Index instead.`, and `s[::-1]` and
`len(s)` as a random access primitive have no direct form. The bad workaround
is `Array(s)` everywhere, which costs O(n) memory and hides the lesson: a
`Character` is an extended grapheme cluster, `count` is O(n), and indices come
from the string. Ranked low only because it fails loudly and immediately.
Chapter [01-optionals](../modules/01-optionals/README.md).

**FF16. Literals convert, variables do not.** Compile errors, plus a wrong
mental rule if you learn it from the literal case. `1 + 1.5` compiles, because
the integer literal adopts `Double`. That makes it easy to conclude Swift
widens numbers. It does not: given `let a = 1` and `let b = 1.5`, `a + b` is
`error: binary operator '+' cannot be applied to operands of type 'Int' and
'Double'`. `Double(count) / Double(total)` has to be written out. Chapter
[01-optionals](../modules/01-optionals/README.md).

**FF17. Default isolation differs between a package and an app target.**
Confusion at the seam between chapters 12 and 13. Under plain `swift test` a
package target is `nonisolated` by default. Xcode app templates in this era
turn on main actor by default isolation, so code that needed `@MainActor` in
the package needs nothing in the app, and code that built in the package can
report actor isolation errors in the app. Related and worth knowing before you
trust an editor: isolation diagnostics come from a SIL pass, so `swift build`
is the source of truth and a type check only editor can show a green file that
the build rejects. Chapters [11-isolation](../modules/11-isolation/README.md)
and [13-swiftui-state](../modules/13-swiftui-state/README.md).

---

## 4. Where Python instincts help

Not consolation prizes. Each row is a place to move fast because the concept is
already yours and only the spelling changed.

| Instinct you already have | What it buys you |
|---|---|
| `await` marks a suspension point, not a thread hop | Async colouring, "only inside async", and "sequential awaits are slower than concurrent ones" transfer exactly. Only isolation and `Sendable` are new. [12-async-await](../modules/12-async-await/README.md) |
| Comprehension thinking is pipeline thinking | You already decompose a loop into shape, filter, transform. Chapter 6 is renaming plus one new idea (`compactMap`) plus one cost model. [06-collections](../modules/06-collections/README.md) |
| Duck typing is protocol oriented design | "What can this do" rather than "what is it" is the standard library's actual philosophy, and it is what trips up people arriving from heavy inheritance. Your instinct is right; only enforcement changed. [04-protocols](../modules/04-protocols/README.md) |
| Generators map onto Sequence and AsyncSequence | Laziness, infinite streams, pipelines, and one shot consumption are already understood. Only the state machine becomes visible. [06-collections](../modules/06-collections/README.md) |
| `with` maps onto `defer` | Acquire, guarantee release at scope exit. The only new thing is that `defer` is written at acquisition. [08-errors](../modules/08-errors/README.md) |
| Decorators prepare property wrappers and result builders | You already accept that an annotation above a declaration changes behavior and that `@thing(arg)` is a factory. `@State` and SwiftUI's `body` builder land as familiar. [13-swiftui-state](../modules/13-swiftui-state/README.md) |
| `__eq__` and `__hash__` contract knowledge | Equal things hash equally, hashing is consistent, mutating a key in a set is a bug. Same laws, with synthesis on top. [04-protocols](../modules/04-protocols/README.md) |
| `match` statements and `enum.Enum` | Structural pattern matching, capture patterns, guards, and exhaustiveness intent are all in modern Python. Genuinely new: cases carry typed payloads and exhaustiveness is enforced. [05-enums](../modules/05-enums/README.md) |
| Keyword argument culture | You already write `f(timeout=5)` and already value call site readability, so `move(from:to:)` reads as an improvement rather than as ceremony. [02-functions](../modules/02-functions/README.md) |
| Early return validation at the top of a function | That is `guard ... else { return }`, and Swift's version is stronger because the compiler forces the else branch to leave scope. [01-optionals](../modules/01-optionals/README.md) |
| dataclasses, `json.loads`, pydantic | Memberwise init, equality, printing, and "a bag of typed fields" carry to structs, and schema first decoding carries to `Codable` with less friction than most people get. [09-codable](../modules/09-codable/README.md) |
| pytest | `@Test` and `#expect` are closer to plain `assert` than to `XCTAssertEqual`, parameterized tests exist in both, and it runs under plain `swift test`. [testing-policy.md](testing-policy.md) |
| `pip`, `venv`, `pyproject.toml` | SwiftPM is a manifest, resolution, a lockfile, and a test command. Nothing conceptually new. [how-this-repo-works.md](how-this-repo-works.md) |
| "Explicit is better than implicit" | The Zen of Python describes Swift's Optional and error handling better than it describes most Python. Swift's verbosity is a value you already hold. |

---

## 5. Which chapter owns which rows

Three of the fourteen chapters anchor on Python and carry a `Coming from
Python` section built from the rows below, capped at 250 words, ending with one
link to this file. The other eleven anchor on C# and carry `Coming from C#`
instead, built from [bridge.md](bridge.md) section 7. A chapter never carries
both.

The anchor for every chapter is assigned once, in [keywords.md](keywords.md)
section 2, with the reason for each. Python owns 02, 06, and 09 because
Python's model is the closer and more instructive one there: keyword arguments
map onto argument labels, comprehensions and generators map onto the
transformation chain and `lazy`, and `json.loads` into dicts is exactly the
habit chapter 09 exists to correct.

Rows for a C# anchored chapter stay in this file as reference. They are not
quoted into that chapter, because two comparison sections in one chapter is a
split attention tax paid at the chapter's hardest moment.

| Chapter | Anchor | Rows it owns | False friends |
|---|---|---|---|
| [01-optionals](../modules/01-optionals/README.md) | C# | reference only: `None` versus `Optional`, hints versus a type system, truthiness, numeric semantics, string indexing | FF2, FF4, FF6, FF15, FF16 |
| [02-functions](../modules/02-functions/README.md) | Python | Keyword arguments versus argument labels, decorators as higher order functions, mutable default arguments | None owned |
| [03-value-semantics](../modules/03-value-semantics/README.md) | C# | reference only: Assignment and aliasing, `dataclass` versus `struct`, `__slots__` versus fixed layout | FF1 |
| [04-protocols](../modules/04-protocols/README.md) | C# | reference only: Duck typing versus protocols, dunders versus conformances | FF8 (introduced) |
| [05-enums](../modules/05-enums/README.md) | C# | reference only: `match` and `enum.Enum` versus enums with payloads, `is` and `isinstance` | FF14 |
| [06-collections](../modules/06-collections/README.md) | Python | `list`, `dict`, `set`, comprehensions, generators, `.lazy`, sorting | FF5, FF7, FF9, FF12 |
| [07-generics](../modules/07-generics/README.md) | C# | reference only: `TypeVar` versus constrained generics, ABC parameters versus `some` and `any` | FF8 (resolved) |
| [08-errors](../modules/08-errors/README.md) | C# | reference only: Exceptions versus typed throws, `with` versus `defer` | FF11 |
| [09-codable](../modules/09-codable/README.md) | Python | `json.loads` and pydantic versus `Codable` | None owned |
| [10-classes-and-arc](../modules/10-classes-and-arc/README.md) | C# | reference only: Refcounting versus CPython's collector, `class` as the default type | FF10, FF13 |
| [11-isolation](../modules/11-isolation/README.md) | C# | reference only: GIL assumptions versus `Sendable`, actors, `@MainActor` | FF3, FF17 (warned) |
| [12-async-await](../modules/12-async-await/README.md) | C# | reference only: `asyncio` tasks versus structured concurrency, `async for` versus `for await` | None owned |
| [13-swiftui-state](../modules/13-swiftui-state/README.md) | C# | reference only: Decorators versus property wrappers and result builders | FF17 (hit) |
| [14-swiftui-app](../modules/14-swiftui-app/README.md) | C# | reference only: `Django` and `SQLAlchemy` models versus `@Model`, and the absence of a routing analogue | None owned |

---
## 6. Claims corrected during verification

Kept because a mapping file that has been wrong once is worth auditing.

- `1 + 1.5` was going to be listed as a compile error. It is not: the integer
  literal adopts `Double`. The error appears only between typed variables,
  which is FF16 and a sharper lesson than the original claim.
- Truncation versus flooring was missing entirely. `-5 / 2` and `-5 % 3`
  disagree between the languages in both magnitude and sign, which is FF4.
- Typed throws does not make separate pattern matched `catch` clauses
  exhaustive. The compiler rejects it. The working shape is one `catch`
  containing a `switch`, which is what 2.6 ships.
- `rethrows` standard library functions such as `reduce` erase a typed error
  back to `any Error`, so a typed throws function that wants to keep its error
  type writes an explicit loop. If a chapter later leans on typed throws
  through higher order functions, re-test rather than trusting this note; the
  compiler has been iterating in that area.
- Dictionary order instability (FF9) was asserted from documented per process
  seeding in the source material. It is now measured: five runs, five different
  orders.
- The Xcode app template default isolation claim in FF17 is about Xcode, and
  was verified only indirectly through the SwiftPM `defaultIsolation` setting.
  Confirm in Xcode before chapter 13 ships.
- `Money.description` uses `String(format:)`, which requires Foundation. A
  Foundation free variant needs different formatting.
