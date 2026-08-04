---
chapter: 03
slug: 03-value-semantics
title: Value Semantics and Mutation
anchor: csharp
concepts:
  - copy versus share
  - mutating, and what let actually freezes
  - copy on write
requires: [01-optionals, 02-functions]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 03. Value Semantics and Mutation

## Cold open

Blank file, no notes: re-solve your chapter 01 drill on nested optionals
before you read anything below.

```bash
swift test --package-path drills --filter Ch01
```

## The question

When you hand a value to code you did not write, what is that code able to do
to you afterward? C# answers with `class`, so the callee receives a second
name for your object, and every defensive copy, every `IReadOnlyList<T>`,
every immutable DTO is a hand written patch over that one answer. The other
option is to make sharing the thing you ask for rather than the thing you get
by default. Then a signature stops being a promise about behavior and becomes
a fact about reach: if you are still holding it, nobody else can change it.
Swift took the second option, and had to make copying cheap enough to afford
it.

## Swift's answer

`struct` is the default and `class` is the exception that needs a stated
reason. A struct gets a memberwise initializer for free, one labeled
parameter per stored property, in declaration order.

```swift
struct Coordinate {
    var x: Int
    var y: Int
}

var here = Coordinate(x: 1, y: 1)
var there = here
there.x = 99
print(here.x, there.x)      // 1 99
```

`there` is not a view onto `here`. Assignment copied, and so does passing to a
function, returning from one, storing into an array, and capturing in a
closure. There is no operator that undoes this, which is the entire guarantee.

`let` on a struct freezes the value, not just the name. That is stronger than
it sounds, because it also withdraws every method that would write.

```swift
struct Playlist {
    private(set) var tracks: [String] = []
    var minutes = 0

    mutating func queue(_ title: String, running length: Int) {
        tracks.append(title)
        minutes += length
    }
}

var mix = Playlist()
mix.queue("Bloom", running: 4)      // fine
let frozen = mix
// frozen.queue("Bloom", running: 4)   // errors.swift block 2
```

`mutating` is not a permission flag bolted onto a method. It changes the
calling convention: `self` arrives as an `inout` parameter, so the body writes
into the caller's storage rather than into a local copy. A `let` struct has no
storage anyone is allowed to write into, so the method is not merely
discouraged there, it is unavailable. A class needs no such marker and cannot
have one, because its `self` is a reference either way, and `let` on a class
binds the reference while leaving the object writable. That asymmetry is
chapter 10's, and it is [10-classes-and-arc](../10-classes-and-arc/README.md).

Now the affordability problem. `Array`, `String`, `Dictionary`, `Set`, and
`Data` are all structs, so `var b = a` copies. Copying a million elements on
every assignment would be indefensible, so they do not: what is copied is a
reference to one shared buffer, and the buffer splits at the first write by
whichever side writes first. The standard library asks
`isKnownUniquelyReferenced` before it writes, which answers whether exactly
one strong reference to that buffer exists right now. That question is the
whole of copy on write, and you can watch it being asked:

```bash
make probe CH=03 P=cow
```

A value has no identity, only contents. Two `Coordinate(x: 1, y: 1)` are the
same coordinate, and asking which one is a category error, which is why `===`
refuses to compile on a struct. `Equatable` and `Hashable` are synthesized as
soon as every stored property conforms.

```swift
struct Tag: Hashable {
    var word: String
    var weight: Int
}
```

Declare `==` yourself and synthesis of `hash(into:)` continues from the stored
properties, so your rule and its rule disagree, no diagnostic fires, and a
`Set` starts holding values it believes are equal. Write both or neither.

Last, a forward pointer. A non public struct whose stored properties are all
`Sendable` is `Sendable` with nothing typed, which is the concurrency dividend
that value semantics pays. Chapter 11 spends it, including why a `public`
struct has to say `: Sendable` out loud.

## Predict

Write your prediction in the comment above each snippet in
`probes/predict.swift`, then run `make probe CH=03 P=predict`. Each one you
get wrong is a place where copy versus share, or equality versus hashing,
decides the answer.

```swift
var earlier = [1, 2, 3]
var later = earlier
later.append(4)
print(earlier.count, later.count)                      // 1

final class Dial { var ticks = 0 }
struct Cluster { var dial = Dial(); var scale = 1 }
var one = Cluster(); var two = one
two.scale = 5; two.dial.ticks = 7
print(one.scale, one.dial.ticks)                       // 2

struct Pin: Hashable {
    let mark: String
    let visits: Int
    static func == (lhs: Pin, rhs: Pin) -> Bool { lhs.mark == rhs.mark }
}
let leftPin = Pin(mark: "a", visits: 1)
let rightPin = Pin(mark: "a", visits: 2)
print(leftPin == rightPin, leftPin.hashValue == rightPin.hashValue)   // 3
```

Snippet 3b is only in the probe, and it is the one worth running three times.

## Coming from C#

### Where the analogy holds

| C# | Swift | Note |
|---|---|---|
| `struct` copies on assignment | `struct` copies on assignment | Same mechanic. Opposite frequency of use. |
| `record` value equality | `struct: Equatable` | Both synthesize member by member equality. |
| `readonly struct` | struct with `let` properties | Both refuse writes after construction. |

### Where it breaks

```csharp
public sealed class Crew { public List<string> Names { get; } = []; }

var a = new Crew();
a.Names.Add("ada");
var b = a;
b.Names.Add("grace");
// a.Names is ["ada", "grace"]. One object, two names, no copy anywhere.
```

| C# | Swift | Why the reasoning differs |
|---|---|---|
| `class` is the default choice | `struct` is the default choice | The CLR made identity cheap and aliasing normal. Swift made copies cheap instead. |
| mutable structs are a hazard, so the advice is to avoid them | `mutating` is the ordinary way to write a method | A C# struct mutated through an interface, a `readonly` field, or an `in` parameter silently hits a copy. Swift's `self` is `inout` there. |
| `List<T> b = a` aliases | `var b = a` copies | The day one bug. No error, no crash, a wrong number somewhere else. |
| defensive copies and `IReadOnlyList<T>` | nothing to write | The callee's copy is unreachable from you, so there is nothing to defend. |
| a large struct is a performance smell | a large struct is ordinary | Its stored collections are copy on write, so the copy is a retain until someone writes. |

Full row set: [docs/bridge.md](../../docs/bridge.md).

## The model

```text
Verified with `make probe CH=03 P=cow`:

  var earlier = [1, 2, 3]

      earlier --------+
                      v
                +-------------------+
                | buffer   refs 1   |  1 2 3
                +-------------------+

  var later = earlier         assignment: one retain, nothing moved

      earlier --------+
                      v
                +-------------------+
      later --->| buffer   refs 2   |  1 2 3
                +-------------------+

  later.append(4)             the write asks: refs == 1?  no.  split.

      earlier ------->+-------------------+
                      | buffer   refs 1   |  1 2 3
                      +-------------------+
      later --------->+-------------------+
                      | buffer   refs 1   |  1 2 3 4
                      +-------------------+
```

The copy is charged to the write, not to the assignment, and it is charged
once: after the split, `later` is holding its buffer alone, so the next
`append` writes in place. Read the refs counts rather than the arrows. That is
the whole mechanism, and `isKnownUniquelyReferenced` is the function that reads
the middle number.

## Where it goes wrong

Every row was reproduced from `probes/errors.swift` on the toolchain in the
front matter. Uncomment one block at a time and read it yourself.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: cannot assign to property: 'crate' is a 'let' constant` | `let` on a struct freezes the value, so every stored property inside it is frozen too. | `var`, or build a changed copy and bind that. |
| `error: cannot use mutating member on immutable value: 'crate' is a 'let' constant` | Same freeze, reached through a method. A `let` struct has no mutating methods at all. | `var`, or give the type a nonmutating form that returns a new value. |
| `error: left side of mutating operator isn't mutable: 'self' is immutable` | Inside a struct, `self` is a constant until the method says otherwise. | Mark the method `mutating`. |
| `error: 'mutating' is not valid on instance methods in classes` | A class method already writes through a reference, so there is nothing for the marker to change. | Delete the keyword, and ask whether you wanted a struct. |
| `error: argument passed to call that takes no arguments` | Declaring any initializer in the struct body withdraws the memberwise one. | Move your initializer into an `extension`, which keeps both. |
| `error: type 'Crate' does not conform to protocol 'Equatable'` | Synthesis is member by member, so one stored property that cannot answer sinks the conformance. | Conform that property's type, or write `==` yourself and `hash(into:)` beside it. |
| `error: escaping closure captures mutating 'self' parameter` | `mutating` makes `self` an `inout` parameter, and nothing outliving the call may capture one. | Capture the fields you need, or make the type a class if the callback truly owns it. |
| `error: stored property 'marker' of 'Sendable'-conforming struct 'Crate' has non-Sendable type 'Marker'` | A struct is `Sendable` only when every stored property is, and a plain class is not. | Store a value instead. The full treatment is chapter 11. |

## Exercises

Stubs are in `exercises/ValueSemantics.swift` and `exercises/CopyOnWrite.swift`.
Run `swift test --filter Chapter03Tests`.

1. `Basket` stocks items in place with `stock(_:)` and out of place with
   `stocking(_:)`, and copies of it never see each other's items.
2. `Roster` enrolls and releases players by team, refuses a duplicate, and
   drops a team's key rather than leaving an empty array behind.
3. `SeatCode` treats letter case and surrounding spaces as noise, and keeps
   `==` and `hash(into:)` agreeing so a `Set` does not hold two of one seat.
4. `Ledger` is the integrative one: `post(_:)` must never let two ledgers see
   each other's writes, and must never copy a buffer nobody else is holding.
   Both halves are graded.
5. `snapshots(of:applying:)` replays moves over a `Panel` and returns the
   state after each one, leaving the panel it was handed alone.

<details><summary>Hint 1, a nudge</summary>

Exercise 5 asks for a history, and you already have the only tool that makes
histories free. Say out loud what happens to a `Panel` you have already put
into the result array when you change the one you are still working with.

Exercise 3: run `make probe CH=03 P=predict` snippet 3 first if it has not
already cost you an hour.
</details>

<details><summary>Hint 2, an approach</summary>

Exercise 3: build the one normalized string that both halves of the
conformance agree to speak, and have `==` and `hash(into:)` each ask for it
rather than each inventing it.

Exercise 4: the decision happens before the write, it concerns the buffer and
not the ledger, and its answer changes depending on who else is holding it at
that instant. `copied()` is already written for you.

Exercise 2: a dictionary value you have taken out is a copy, so putting it
back is part of the job.
</details>

<details><summary>Hint 3, the API to look up</summary>

`String.trimmingCharacters(in:)` with `CharacterSet.whitespaces`, or
`Substring.trimmingPrefix`, plus `lowercased()`, then `Hasher.combine`.
`isKnownUniquelyReferenced(_:)`, and note the ampersand its parameter needs.
`Dictionary.removeValue(forKey:)`, and the `subscript(_:default:)` form.
</details>

## Retrieval checkpoint

Answer in writing first, then check the runnable ones with Swift. Nothing here
has a committed answer.

1. `let` a struct and `let` a class, each with one `var` property. One
   property assignment compiles. State the single rule producing both results.
2. A `mutating` method and a nonmutating one returning a modified copy do the
   same work. Name one thing each can do that the other cannot.
3. `var a = [1, 2, 3]; let b = a; a[0] = 9`. How many heap buffers exist after
   each of the three statements?
4. A struct holds a `var` property of class type. Copy the struct, mutate
   through that property, and say which copies observe it.
5. Judgment, no single right answer. Model a bank account that many screens
   display and one screen edits. Argue struct, then class, and name the fact
   about who must observe a change that decides it.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Add a fifth snippet to `probes/cow.swift` that shows whether
  `Dictionary` and `String` behave the same way `Array` does.
- SE-0390, Noncopyable structs and enums, is the value type that cannot be
  copied at all:
  <https://github.com/swiftlang/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md>
- Read the `isKnownUniquelyReferenced` reference and find the sentence that
  explains why it takes its argument as `inout`:
  <https://developer.apple.com/documentation/swift/isknownuniquelyreferenced(_:)>

## Done when

- [ ] `swift test --filter Chapter03Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] `make probe CH=03 P=cow` prints `shared: true` then `shared: false`, and
      I can point at the line that split the buffer and say why it split there

This chapter does not cover reference counting, `deinit`, or capture lists,
which are [10-classes-and-arc](../10-classes-and-arc/README.md), nor what
makes a type safe to send across an isolation boundary, which is chapter 11.
