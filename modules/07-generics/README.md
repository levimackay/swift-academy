---
chapter: 07
slug: 07-generics
title: Generics, `some`, and `any`
anchor: csharp
concepts:
  - generic types with constraints
  - some versus any
  - associated types and primary associated types
requires: [04-protocols, 06-collections]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 07. Generics, `some`, and `any`

## Cold open

Blank file, no notes: re-solve your chapter 05 drill on payload enums before
you read anything below.

```bash
swift test --package-path drills --filter Ch05
```

## The question

One algorithm, many types. Every language above assembly answers that, and
the answer decides what the compiler still knows when it reaches the call.
C++ stamps out a copy per instantiation and knows everything. Java throws the
type away at the boundary and knows nothing. C# keeps it and asks the runtime
at the call. Each answer buys speed or flexibility with the other one.

Swift refuses to pick for you. It gives you three spellings of "a value that
conforms to this protocol", they compile to different machine code, and
choosing between them is a design decision you make in the signature. This
chapter is about knowing which one you just wrote.

## Swift's answer

A type parameter with no constraint can do almost nothing, because Swift
compiles the body once against the constraints alone and never re-checks it
per caller. Capability is bought with constraints, and a `where` clause is
where the awkward ones go.

```swift
protocol Pulse {
    func level() -> Double
}

func loudest<S: Sequence>(_ signals: S) -> S.Element?
where S.Element: Pulse {
    signals.max { $0.level() < $1.level() }
}
```

Generic types read the same way, and the constraint sits on the declaration
so that every member can rely on it.

```swift
struct Bucket<Slot: Hashable> {
    private(set) var slots: Set<Slot> = []
    mutating func drop(_ slot: Slot) { slots.insert(slot) }
}
```

`some P` in parameter position is the same thing, shorter: `func f(_ x: some
Pulse)` and `func f<T: Pulse>(_ x: T)` compile identically. In return
position it means something else entirely, and this is the distinction the
chapter exists for.

```swift
struct Tick: Pulse { func level() -> Double { 1 } }
struct Silence: Pulse { func level() -> Double { 0 } }

func steady() -> some Pulse { Tick() }        // one type, name withheld
func mixed(_ n: Int) -> any Pulse {           // any number of types
    n > 0 ? Tick() : Silence()
}
```

`some Pulse` says there is exactly one concrete type here, the compiler knows
which, and you do not. Identity survives, so two calls to `steady()` are
known to return the same type. `any Pulse` says the type is decided at run
time and carries metadata to prove it, and identity is gone: two `any Pulse`
values may be two types, which is why `Equatable`'s `==` cannot be called on
them at all.

Protocols with associated types are where this stops being academic. An
associated type is a generic parameter written on the inside, and a protocol
that declares a primary one can be constrained in angle brackets.

```swift
protocol Feed<Payload> {
    associatedtype Payload
    func next() -> Payload?
}

struct Counter: Feed { func next() -> Int? { 1 } }

func drain<F: Feed>(_ feed: F) -> [F.Payload] { [] }  // fully static
let ints: any Feed<Int> = Counter()                   // boxed, Payload pinned
```

Without the `<Payload>` on the declaration, `any Feed<Int>` does not parse and
`any Feed` gives you a box whose `next()` returns `Any`. With it, the box
keeps one fact and stays useful.

You rarely need the box, because passing an existential into a generic
function opens it: inside `drain`, `F` is bound to the concrete type that was
in the box. When you do need one type to stand in for many, a hand written
eraser wraps the calls in stored closures. `AnySequence` and SwiftUI's
`AnyView` are exactly that, and their cost is one allocation plus the loss of
every static fact the wrapper did not choose to keep. `AnyView` in particular
throws away the structural identity SwiftUI uses to diff a hierarchy, which
is why it is a last resort rather than a convenience.

Conditional conformance is the last piece: a generic type conforms only when
its parameters do.

```swift
extension Bucket: Equatable where Slot: Equatable {}
```

That is a real conformance the compiler checks and specializes, not a runtime
cast.

## Predict

Write your prediction on the line above each numbered print in
`probes/predict.swift`, then run `make probe CH=07 P=predict`. Item 4 is the
one that catches most people, and item 2 is the one that quietly changes how
you design APIs.

```swift
print(MemoryLayout<Blip>.size,
      MemoryLayout<Burst>.size,
      MemoryLayout<any Signal>.size)                            // 1

func typeSeen<R: Signal>(_ value: R) -> String { "\(R.self)" }
let probe: any Signal = Burst(a: 1, b: 2, c: 3, d: 4)
print(typeSeen(probe))                                           // 2

func firstOrNil<C: Collection>(_ items: C) -> C.Element? { items.first }
print(type(of: firstOrNil(boxes)), type(of: firstOrNil(plain)))  // 4
```

## Coming from C#

### Where the analogy holds

| C# | Swift | Note |
|---|---|---|
| `class Box<T>` | `struct Box<T>` | same idea, and Swift's is usually a value type |
| `where T : IComparable<T>` | `where T: Comparable` | closest to a free transfer in the language |
| `List<T>`, `Dictionary<K, V>` | `[T]`, `[K: V]` | both generic all the way down, no boxing of `Int` |

### Where it breaks

```csharp
static T Fresh<T>() where T : new() => new T();
static string Name<T>() => typeof(T).Name;   // the runtime knows T
IShape shape = new Circle();                 // the default spelling
```

| Claim | C# | Swift |
|---|---|---|
| a type argument exists at run time | reified, so `typeof(T)` and `new T()` work | no `typeof(T)`, no `new T()`; you buy `init()` with a constraint |
| dispatch through an abstraction | interface reference, one vtable indirection | witness table for `any P`, and often nothing at all after specialization |
| the default spelling | `IShape` as a variable type, boxing for structs | `some P` or `<T: P>`, static; `any P` is the exception you ask for |
| protocol members can be abstract over `Self` | no equivalent | `Self` requirements and associated types, which is why some protocols resist boxing |

C# reified generics to fix Java's erasure, and the fix is a runtime service:
the JIT shares one body across reference types and instantiates value types
on demand. Swift's is a compile time service. One body is compiled against
the constraints, and the optimizer emits specialized copies for the concrete
types it can see, which is where the abstraction becomes free. Across a
module boundary it needs `@inlinable` to see that body at all.

Full row set: [docs/bridge.md](../../docs/bridge.md).

## The model

```text
Verified with `make probe CH=07 P=layout`:

  struct Tick   8 bytes        struct Wave  32 bytes    any Pulse  40 bytes

  <T: Pulse>    the caller picks T, the body is compiled knowing only
                the constraints, and the optimizer may stamp out a copy
    Tick  --------------------> [ 8 bytes, direct call, inlinable ]
    Wave  --------------------> [ 32 bytes, direct call, inlinable ]
                                type identity kept, name known to both

  some Pulse    the callee picks one type, once, for every call
    Tick  --------------------> [ 8 bytes, direct call, inlinable ]
                                type identity kept, name withheld

  any Pulse     one box, contents decided at run time
    Tick  --> |ttt.....|.......|.......| meta | wtbl |   fits inline
    Wave  --> |ptr ---------> heap      | meta | wtbl |   spilled
                                type identity discarded, call goes
                                through wtbl, and copying may allocate
```

Two spellings keep the type and one discards it. That is the whole model, and
every rule in the next table is a consequence of it. The drawn to scale
version of the box, with the measurements, is
[docs/diagrams/existentials.md](../../docs/diagrams/existentials.md).

## Where it goes wrong

Every row is blocks 1 through 8 of `make probe CH=07 P=errors`, pasted from
that file's output on the toolchain in the front matter. Blocks 9 through 11
are the follow ups: opaque identity, failed inference, and conditional
conformance.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: referencing operator function '>' on 'Comparable' requires that 'T' conform to 'Comparable'` | An unconstrained parameter has no operations. `>` is a protocol requirement, not a builtin. | Constrain it: `<T: Comparable>`. |
| `error: type 'Note' does not conform to protocol 'Hashable'` | A constraint on a generic type is checked where the type is named, not where a member is called. | Conform the argument type, or loosen the constraint. |
| `error: result values in '? :' expression have mismatching types 'Circle' and 'Square'` | `some` promises one concrete type on every path. Two return types is two promises. | Return `any Shape`, or unify the two branches on one type. |
| `error: type 'any Shape' cannot conform to 'Shape' [#ProtocolTypeNonConformance]` | The box holds a conformer and is not one, so it cannot satisfy `S: Shape`. | Open it: pass one element to a generic function, or drop the box. |
| `error: member 'add' cannot be used on value of type 'any Container'; consider using a generic constraint instead [#ExistentialMemberAccess]` | The member takes the associated type, and the box does not say which type it will accept. | Take `some Container` or `<C: Container>`, as the note says. |
| `error: binary operator '==' cannot be applied to two 'any Equatable' operands` | A `Self` requirement needs one type. Two boxes may hold two. | Use a generic parameter, where there is exactly one `Self`. |
| `error: protocol 'Store' does not have primary associated types that can be constrained` | Angle brackets on an existential need a primary associated type on the declaration. | Declare `protocol Store<Value>`. |
| `warning: use of protocol 'Keyed' as a type must be written 'any Keyed'; this will be an error in a future Swift language mode [#ExistentialAny]` | You wrote a box without asking for one. Every target here enables `ExistentialAny` so the wording follows you around. | Write `any Keyed` if you meant it, `some Keyed` if you did not. |

## Exercises

Stubs are in `exercises/Generics.swift`, in the order below. Run
`swift test --filter Chapter07Tests`.

1. `firstRepeated(in:)` finds the first element that repeats, over any
   `Collection` of `Hashable` elements.
2. `extremes(of:)` returns the low and high of a `Sequence` in one pass.
3. `Tally` counts occurrences of a constrained generic `Item`, and names a
   leader with a stated tie break.
4. `evenlySpaced(from:step:count:)` returns `some Collection<Int>`, so the
   caller cannot name what it got.
5. `AnyGauge` erases a protocol with an associated type. The stub is the
   plausible wrong version, and one test exists to prove it wrong.
6. `mergeSorted(_:_:)` merges two sequences of the same element type. This is
   the integrative one: it is the only exercise where a `where` clause is
   carrying the whole design.

<details><summary>Hint 1, a nudge</summary>

Exercise 5's stub calls `read()` once and keeps the answer. A tape recorder
that plays back one note is not a recording. What does the wrapper have to
store so that the call happens later, and what is the only kind of Swift
value that can hold a call?
</details>

<details><summary>Hint 2, an approach</summary>

Exercise 6 walks both sequences at once, which means neither one can be a
`for in` loop. Get something you can advance by hand from each side, look at
both fronts, take one, repeat until one side is empty, then take the rest.
</details>

<details><summary>Hint 3, the API to look up</summary>

`Sequence.makeIterator()` and `IteratorProtocol.next()` for exercise 6.
`Sequence.max(by:)` and `min(by:)` for 2, or one `reduce`. `stride(from:to:by:)`
and `Array(_:)` for 4.
</details>

## Retrieval checkpoint

Answer in writing first, then check the runnable ones with Swift. Nothing
here has a committed answer.

1. Rewrite `func f<T: Pulse>(_ x: T) -> T` with `some`. Now rewrite
   `func g() -> some Pulse` with a generic parameter, and say why you cannot.
2. `[any Pulse]` and `[some Pulse]`: one of these is not a legal element
   type. Predict which, then run it and read the diagnostic.
3. `MemoryLayout<any Pulse>.size` for a one field struct and a ten field
   struct. Predict both numbers before running.
4. You hold `any Feed<Int>` and need a function that also works on
   `[Int]`. Write the signature. How many type parameters does it have?
5. Judgment, no single right answer. SwiftUI ships `AnyView` even though the
   framework's own docs discourage it. Name the problem it solves that
   `some View` cannot, then name what it costs the diffing algorithm, and say
   which of the two you would accept in a list of one thousand rows.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Run `make probe CH=07 P=specialize` and then again with
  `ARGS=2000000`. Which line grows linearly and which one stays flat.
- Read SE-0335 (`any`) and SE-0346 (primary associated types) in
  <https://github.com/swiftlang/swift-evolution/tree/main/proposals>. The
  motivation sections are the argument this chapter compresses.
- Write your own `AnyIterator` equivalent over a protocol you invent, then
  compare it with the standard library's.

## Done when

- [ ] `swift test --filter Chapter07Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] No existential survives in my solutions:
      `grep -n 'any ' modules/07-generics/exercises/*.swift` prints nothing

This chapter does not cover generic constraints that involve concurrency,
where `Sendable` becomes another thing a parameter has to promise. That is
chapter 11, and the same three spellings are waiting there with an isolation
question attached.
