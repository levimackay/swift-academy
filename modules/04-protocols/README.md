---
chapter: 04
slug: 04-protocols
title: Protocols and Extensions
anchor: csharp
concepts:
  - constraints instead of inheritance
  - extensions, including retroactive conformance
  - witness dispatch versus extension dispatch
requires: [02-functions, 03-value-semantics]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 04. Protocols and Extensions

## The question

Chapter 03 made the default type a `struct`, and a `struct` cannot inherit.
That removes the tool most object oriented code reaches for when two types
need to share behavior, so something has to replace it.

The replacement has to answer three things an abstract base class answered at
once. Where does shared behavior live when there is no base to put it in. How
does a type acquire a capability it was not born with, including a type
someone else compiled. And how does a function say what it needs without
naming a hierarchy that the caller then has to join.

## Swift's answer

A protocol is a list of requirements. A conforming type promises to satisfy
every one of them, and the compiler checks the whole promise at the
conformance site.

```swift
protocol Gauge {
    var level: Double { get }
    var unitSymbol: String { get }
}
```

An extension on that protocol supplies default implementations, and this is
the move that makes Swift protocol oriented rather than merely interface
oriented. A default satisfies a requirement, so a conforming type only writes
what is genuinely its own.

```swift
extension Gauge {
    var unitSymbol: String { "raw" }
    var isDrained: Bool { level == 0 }
}

struct Barometer: Gauge {
    var level: Double
    var unitSymbol: String { "hPa" }
}

struct Odometer: Gauge {
    var level: Double
}
```

`Barometer` writes its own symbol. `Odometer` takes the default. Neither one
inherits anything, and adding a fourth requirement with a default breaks no
existing conformance.

An extension can carry a constraint, which is how one protocol grows behavior
that only some conformers can support.

```swift
extension Gauge where Self: Comparable {
    func exceeds(_ other: Self) -> Bool { self > other }
}
```

A conformance can carry a constraint too. Conditional conformance is the
statement that a generic type is a `Gauge` exactly when its parameter is.

```swift
struct Bank<Instrument> {
    var instruments: [Instrument]
}

extension Bank: Gauge where Instrument: Gauge {
    var level: Double { instruments.reduce(0) { $0 + $1.level } }
}
```

An extension can also conform a type you did not write. `Double` is not yours
and `Gauge` is, so this is fine and needs no ceremony.

```swift
extension Double: Gauge {
    var level: Double { self }
}
```

Retroactive conformance is the case where you own neither side, and Swift 6
warns about it. Two modules that both conform `Int` to a third party protocol
produce a conflict no downstream package can fix, so the compiler asks you to
write `@retroactive` and take responsibility for it. Row 7 below is the exact
wording.

Now the trap. `unitSymbol` is a requirement, so it dispatches through the
witness table and the conforming type's version always wins. `isDrained`
exists only in the extension, so it is resolved from the static type at the
call site. A type that declares its own `isDrained` without adding it to the
protocol gets its version on a concrete value and the extension's version
through `any Gauge`. Nothing warns.

```bash
make probe CH=04 P=dispatch
```

Existentials are spelled out loud. `any Gauge` is a box, `some Gauge` and
`<T: Gauge>` are not, and every target in this package enables
`ExistentialAny` so the choice is compiler enforced rather than advisory. The
full treatment is [07-generics](../07-generics/README.md); here, prefer the
constraint and reach for `any` only when the values must be heterogeneous.

## Predict

Write your prediction in the comment above each snippet in
`probes/predict.swift`, then run `make probe CH=04 P=predict`. Seven values
are printed and exactly one of them changes when the value is held as an
existential rather than as itself. Finding which one is the chapter.

```bash
make probe CH=04 P=predict
```

## Coming from C#

### Where the analogy holds

| C# | Swift | Note |
|---|---|---|
| `interface IShape` | `protocol Shape` | both are a contract a type opts into by name |
| `where T : IComparable<T>` | `where T: Comparable` | the closest thing to a free transfer in the language |
| `IShape s = c;` | `let s: any Shape = c` | Swift makes you spell the box |
| extension methods | `extension` | Swift adds properties, initializers, and conformances too |

### Where it breaks

```csharp
public interface IShape { double Area { get; } string Describe() => $"area {Area}"; }
public sealed record Circle(double R) : IShape
{
    public double Area => Math.PI * R * R;
    public string Describe() => "circle";
}
```

A default interface member is still virtual, so `Circle` wins through
`IShape`. A Swift member declared only in a protocol extension does not, and
that asymmetry is the single most expensive thing on this page. Verified in
[docs/bridge.md](../../docs/bridge.md) section 3.2.

| Claim | C# | Swift |
|---|---|---|
| default member dispatch | virtual, the type's version wins | static, the extension's version wins through a box |
| retrofitting an interface | impossible after the fact | an `extension` on any type, in any module |
| conditional conformance | no equivalent, a type implements or does not | `extension Bank: Gauge where Instrument: Gauge` |
| associated types and `Self` | inexpressible | ordinary, and they constrain what a box can do |
| culture | default members are a versioning escape hatch | protocol extensions are the primary mechanism |

Full row set: [docs/bridge.md](../../docs/bridge.md).

## The model

```text
Verified with `make probe CH=04 P=layout` and `P=dispatch`:

  LoudPin, the value          any Marker, the box, 40 bytes
  |vvvvvvvv|                  |iiiiiiiiiiiiiiiiiiiiiiii|m|w|
   8 bytes                     3 inline words           | |
                              type metadata ------------' |
                              witness table --------------'

  .tint      declared in the protocol body, so it is a requirement
             value -> LoudPin.tint                       "red"
             box   -> witness table -> LoudPin.tint      "red"

  .caption   declared only in the extension
             value -> LoudPin.caption               "LOUD red"
             box   -> Marker.caption               "caption red"

  A conforming value wider than 3 words does not fit inline, so the
  box holds a heap pointer instead: `Wide` measures 40 bytes on its
  own and `any Sample & Stamped` measures 48, one word per protocol.
```

The box is why `any` costs something and why the requirement column is the
one you can rely on. The witness table is a per conformance table of function
pointers, so a requirement is one indirect call and an extension only member
is not in the table at all.

## Where it goes wrong

Rows 1 through 7 came from `make probe CH=04 P=errors`. Row 8 needs the
package setting, so it comes from pasting that block's line into
`exercises/Protocols.swift` and running `make test CH=04`.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: type 'Carafe' does not conform to protocol 'Vessel'` | one or more requirements are unmet, and the notes name each one | read the notes, or accept the `add stubs for conformance` fixit |
| `note: candidate is marked 'mutating' but protocol does not allow it` | the protocol did not declare the requirement `mutating`, so no value type may mutate in it | add `mutating` to the requirement, or stop mutating |
| `error: extensions must not contain stored properties` | an extension adds behavior, never storage, because storage would change a size already compiled | use a computed property, or move the storage into the type |
| `error: redundant conformance of 'Flask' to protocol 'Vessel'` | the conformance is declared twice, and which one is real has no answer | declare it once, on the type or on exactly one extension |
| `error: operator function '==' requires that 'Sigil' conform to 'Equatable'` | the conditional conformance exists but its condition is not met here | conform the element type, or stop asking for `==` at this element type |
| `error: member 'accepts' cannot be used on value of type 'any Rack'; consider using a generic constraint instead [#ExistentialMemberAccess]` | the signature mentions an associated type the box erased | take `some Rack` or a constrained generic parameter instead |
| `warning: extension declares a conformance of imported type 'Int' to imported protocol 'Error'; this will not behave correctly if the owners of 'Swift' introduce this conformance in the future` | retroactive conformance, and a future release of either module can collide with it | wrap your own type, or write `@retroactive` and own the risk |
| `warning: use of protocol 'Vessel' as a type must be written 'any Vessel'; this will be an error in a future Swift language mode [#ExistentialAny]` | a bare protocol name in type position is an existential you did not ask for | write `any Vessel`, or make it `some Vessel` or a generic parameter |

## Exercises

Stubs are in `exercises/Protocols.swift`, in the order below. Run
`swift test --filter Chapter04Tests`.

1. `TrackID` conforms to `Equatable`, `Hashable`, and `Comparable` by hand,
   with a side letter that is not case sensitive. `Hashable` has to agree
   with `==` or a `Set` will hold both copies.
2. `MarkedCrate` and `StencilledCrate` conform to `Tagged`. One takes the
   extension's `shortTag`, the other declares its own, and the suite checks
   both through the concrete type and through `any Tagged`.
3. `Reel` gets `Equatable` conditionally and one member that exists only for
   `Reel<String>`.
4. `Compact` is bolted onto `Int`, `String`, and conditionally onto `Array`.
5. `loadPlan(for:)` summarizes `[any Weighed & Labeled]`. This is the
   integrative one: two protocols, no base type, and four answers from one
   pass.

<details><summary>Hint 1, a nudge</summary>

Exercise 1 has three conformances and only one decision. Write the rule that
decides sameness in words first, then make `==`, `hash(into:)`, and `<` all
three read from that same rule.
</details>

<details><summary>Hint 2, an approach</summary>

Exercise 3 asks for equality that is exactly the equality of the frames in
order. The standard library already conforms `Array` to `Equatable` under the
same condition, so the body you want is one comparison. Ask what an empty
body would do here before writing a longer one.
</details>

<details><summary>Hint 3, the API to look up</summary>

`Character.lowercased()`, `Hasher.combine`, `Sequence.max(by:)`,
`Collection.prefix`, and `Array.joined(separator:)`. For exercise 4, look at
`quotientAndRemainder(dividingBy:)` and at `magnitude`.
</details>

## Retrieval checkpoint

Answer in writing first, then check the four runnable ones with Swift.
Nothing here has a committed answer.

1. A protocol declares `var name: String { get }`. A conforming struct
   declares `var name: String` as a stored `var`. Does that satisfy a `get`
   only requirement, and does the reverse hold?
2. Move `isDrained` from the extension into the `Gauge` protocol body and
   predict which of the four lines in `probes/dispatch.swift` change.
3. `extension Array: Gauge where Element: Gauge`. Predict whether
   `[[Barometer]]` is a `Gauge`, and say why in one sentence.
4. Predict `MemoryLayout<any Gauge>.size` and
   `MemoryLayout<any Gauge & Comparable>.size`, then check with
   `probes/layout.swift`.
5. Judgment, no single right answer. You need three types to share both
   behavior and stored state. Argue for a protocol with an extension against a
   base class, and say what the option you rejected costs you.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Read SE-0143, "Conditional conformances", in
  <https://github.com/swiftlang/swift-evolution/tree/main/proposals>.
- Add a fourth protocol to `probes/layout.swift` and predict the box size
  before you run it.
- Find one type in your own code that inherits, and write down what it would
  cost to express it as a protocol plus an extension instead.

## Done when

- [ ] `swift test --filter Chapter04Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] No `class` and no inheritance survives in my solutions:
      `grep -nE '\bclass\b' modules/04-protocols/exercises/*.swift` prints nothing

`some` and `any`, associated types, and generic types with constraints are
chapter [07-generics](../07-generics/README.md). This chapter used `any` in
two places because `ExistentialAny` makes the spelling mandatory, and left the
cost model there.
