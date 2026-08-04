---
chapter: 06
slug: 06-collections
title: Collections and Transformations
anchor: python
concepts:
  - choosing a collection is choosing an Index and an Element, including String
  - the transformation chain
  - eager versus lazy
requires: [02-functions, 03-value-semantics, 04-protocols]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 06. Collections and Transformations

## The question

A collection is two decisions, not one. What is in it, and how you name a
position in it. Python answers the second the same way for every builtin: a
position is an `int` counted from zero, and arithmetic on it is free. That is
a comfortable lie. It is honest for `list`, absent for `dict`, and quietly
wrong for `str`, where an integer position names a code point that may be a
fragment of what the reader sees.

Swift refuses the lie. It makes position an associated type, so a collection
publishes the kind of position it can actually serve in constant time, and the
compiler stops you asking for one it cannot.

## Swift's answer

Two protocols carry the model. `Sequence` promises you can walk it front to
back once. `Collection` refines it with what makes a data structure rather
than a stream: a stable position, published as an associated type named
`Index`. Choosing a collection is choosing an `Index` and an `Element`.

| Type | Index and Element | What that buys, and what it costs |
|---|---|---|
| `Array` | `Int` from zero; what you stored | O(1) subscript and append; O(n) to search or remove in the middle |
| `Dictionary` | opaque index; a `(key, value)` pair | O(1) lookup by a `Hashable` key; no order, and iteration order changes per run |
| `Set` | opaque index; the member | O(1) membership and set algebra; no order, no duplicates, `Hashable` required |

All three are value types over chapter 03's copy on write, so `let` freezes
the collection and not merely the binding, and a copy costs nothing until
somebody writes. The vocabulary that consumes them is the same on every
`Sequence`.

| Call | Answers |
|---|---|
| `map`, `filter`, `reduce` | transform each, keep some, fold to one |
| `compactMap` | transform each and drop the failures in one pass |
| `flatMap` | transform each into a sequence, then concatenate |
| `zip`, `enumerated` | walk two together, or one with its offset |
| `prefix`, `dropFirst`, `first(where:)` | take, skip, or stop early |
| `sorted(by:)`, `sorted(using:)` | a predicate, or a `KeyPathComparator` |

`compactMap` earns a sentence, because Python has no name for it. A sequence
of optionals is not a problem to validate away, it is already a value, and
`compactMap` is a chain saying "attempt this, keep what worked".

```swift
let entered: [String?] = ["42", nil, "eight", "7"]
let accepted = entered.compactMap { $0.flatMap(Int.init) }   // [42, 7]
```

Dictionaries add two calls that each replace a loop. The default subscript
makes a miss behave like a hit, and `Dictionary(grouping:by:)` is a
`setdefault` loop with a name.

```swift
var tally: [String: Int] = [:]
for word in ["fig", "date", "fig"] { tally[word, default: 0] += 1 }
// tally == ["fig": 2, "date": 1]

let byLength = Dictionary(grouping: ["fig", "date", "plum"], by: \.count)
// byLength == [3: ["fig"], 4: ["date", "plum"]]
```

Every call above is eager. `.lazy` swaps the array for a view that computes on
demand: worth it when the source is long or infinite and the chain exits
early, a loss otherwise. `make probe CH=06 P=lazy` prints both evaluation
orders interleaved, and the trap where a contextual type silently restores the
eager overload.

Slices bite next. `base[1..<4]` is an `ArraySlice` sharing storage with its
base **and sharing its indices**, so `startIndex` is 1 and `slice[0]` traps.
Reach for `first`, or `Array(slice)`, which reindexes from zero and releases
the base.

Then the collection whose index was never an integer. `String` is a
`BidirectionalCollection` of `Character`, and a `Character` is an extended
grapheme cluster: one thing a reader sees. So `"Levi 👨‍👩‍👧".count` is 6, not
10, and `"e\u{301}" == "\u{e9}"` is true with both counting 1, because
comparison is canonical equivalence, not byte equality. Graphemes are variable
width, so no constant time answer to "position 4" exists. That is why `String`
is not `RandomAccessCollection`, and why integer subscripting is marked
unavailable rather than left out. Indices come from the string, and advancing
one is a walk.

```swift
let display = "Levi \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"
let fifth = display.index(display.startIndex, offsetBy: 5)
print(display[fifth], display.count)          // 👨‍👩‍👧 6
```

The bytes were not hidden, they were made explicit. `characters`,
`unicodeScalars`, `utf8`, and `utf16` are four real `Collection`s over one
storage, each with its own `Element` and `count`; pick the one whose unit
matches the question. Slicing a `String` yields a `Substring`, which shares
the parent's storage and indices and is converted with `String(part)` where it
is stored or returned. The rest, index arithmetic, normalization, encoding
conversion, and `StringProtocol`, is lookup:
[docs/strings.md](../../docs/strings.md).

## Predict

Write your prediction in the comment above each snippet in
`probes/predict.swift`, then run `make probe CH=06 P=predict`. The toolchain is
the answer key, and no answer key exists in this repository.

```swift
let lengths = ["fig": 3, "date": 4]
print(type(of: lengths.mapValues { $0 * 2 }),
      type(of: lengths.map { $0.value * 2 }))       // 1

var stock = ["fig": 2]
print(stock["fig", default: 0], stock["plum", default: 0])
print(stock.keys.sorted())                          // 2

print(Array([1, 2].prefix(10)), Array([1, 2].dropFirst(10)))   // 3
```

## Coming from Python

### Where the analogy holds

| Python | Swift | Note |
|---|---|---|
| `[f(x) for x in xs if p(x)]` | `xs.filter(p).map(f)` | same two clauses, in the order they run |
| `d.setdefault(k, []).append(v)` | `d[k, default: []].append(v)` | one lookup, one mutation, no sentinel |
| `functools.reduce` | `reduce`, `reduce(into:)` | `into:` does not copy the accumulator |
| `zip`, `enumerate`, `itertools.chain` | `zip`, `enumerated`, `flatMap` | same semantics, zip included |

### Where it breaks

```python
name = "Levi 👨‍👩‍👧"
print(len(name), name[0])       # 10 L
```

```swift
let name = "Levi \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"
print(name.count, name.first as Any)   // 6 Optional("L")
```

| Claim | Python | Swift |
|---|---|---|
| length of that name | 10, because `str` is a sequence of code points | 6, because `String` is a sequence of grapheme clusters |
| `name[0]` | O(1), and may hand back half an emoji | does not compile; indices come from the string, O(n) to advance |
| laziness | from the brackets: `[...]` eager, `(...)` lazy | eager everywhere, `.lazy` is the switch, and a contextual type can undo it |
| `d[k]` on a miss | raises `KeyError` | returns `nil`, and the reflex `d[k]!` is worse than the exception |
| `xs[1:3]` | a fresh copy, reindexed from zero | an `ArraySlice` sharing storage and keeping the base's indices |
| `sorted(key=)` | a key extractor | a two argument predicate, or `sorted(using: KeyPathComparator(\.age))` |

Full row set, including FF5, FF7, FF9, and FF12:
[docs/bridge-python.md](../../docs/bridge-python.md).

## The model

```text
"Levi 👨‍👩‍👧" across its four views, drawn to scale in UTF-8 bytes.
Verified with `make probe CH=06 P=views`.

characters      |L|e|v|i|_|one family emoji, one Character    |   6
unicodeScalars  |L|e|v|i|_|U+1F468|ZWJ  |U+1F469|ZWJ  |U+1F467|  10
utf8            |L|e|v|i|_|.|.|.|.|.|.|.|.|.|.|.|.|.|.|.|.|.|.|  23
utf16           |L|e|v|i|_|hi |lo |ZWJ  |hi |lo |ZWJ  |hi |lo |  13

                 `_` is the space. Every row spans the same 23 bytes.
```

One storage, four rulers laid along it. The views do not disagree; they answer
four questions, and `count` differs because the unit differs. `characters` for
anything a person reads, `utf8` for anything crossing a wire or a file,
`unicodeScalars` when you genuinely mean a code point, `utf16` only when an
API demands it.

## Where it goes wrong

Rows 1 to 7 came from `make probe CH=06 P=errors`. Row 8 is a run time trap
rather than a diagnostic, and came from `make probe CH=06 P=slices`.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: 'subscript(_:)' is unavailable: cannot subscript String with an Int, use a String.Index instead.` | the overload exists to say no, because no constant time answer exists | `first`, `prefix`, `dropFirst`, or an index from the string |
| `error: cannot convert value of type 'String.Index' to specified type 'Int'` | an index is opaque, not a distance from the start | `distance(from:to:)` when you truly need a number |
| `error: cannot convert value of type 'ArraySlice<Int>' to specified type '[Int]'` | slicing gives a view over the base, and a view is its own type | `Array(slice)`, or accept `ArraySlice` |
| `error: contextual closure type '(Entry, Entry) throws -> Bool' expects 2 arguments, but 1 was used in closure body` | `sorted(by:)` takes a comparison, not a key extractor | `sorted { $0.plays < $1.plays }`, or `sorted(using:)` |
| `error: value of optional type 'Int?' must be unwrapped to a value of type 'Int'` | a lookup that misses is `nil`, so `+=` has nothing to add to | `tally[key, default: 0] += 1` |
| `error: type 'Point' does not conform to protocol 'Hashable'` | membership is decided by hashing | declare `: Hashable` and let it be synthesised |
| `error: cannot convert value of type 'String.SubSequence' (aka 'Substring') to type 'String' in coercion` | a slice of a `String` is a `Substring`, and there is no coercion | `String(part)` |
| `Swift/SliceBuffer.swift:307: Fatal error: Index out of bounds` | a slice keeps the base's indices, so `slice[0]` is out of range unless the slice starts at zero | `slice.first`, or offsets from `slice.startIndex` |

## Exercises

Stubs are in `exercises/Collections.swift`. Run
`swift test --filter Chapter06Tests`.

1. `uniqueInOrder(_:)` removes later duplicates, keeping arrival order.
2. `parsedReadings(from:)` folds `[String?]` down to the readings that are
   both present and whole numbers.
3. `wordCounts(in:)` tallies appearances, with no key for a word that never
   appeared.
4. `groupedByInitial(_:)` groups names by first `Character`; a name with no
   characters joins no group.
5. `offsetOfPeak(in:)` reports the position of the largest value **within the
   slice**, which is not its index in the base array.
6. `truncatedDisplayName(_:limit:)` shortens a name to a character limit
   without cutting a grapheme in half. This is the integrative one: the only
   exercise where a wrong model of `Character` gives a mangled string rather
   than a compiler error.

<details><summary>Hint 1, a nudge</summary>

Exercise 6 asks two questions before it asks any string question: is the name
already short enough, and how much room is left once the marker has taken its
share.
</details>

<details><summary>Hint 2, an approach</summary>

Nothing in exercise 6 needs an index. Every operation you need takes or drops
elements from an end, and what comes back is not a `String`.
</details>

<details><summary>Hint 3, the API to look up</summary>

`Collection.prefix(_:)`, `Collection.dropLast()`, and `String.init(_:)` for
the boundary. Exercise 1 wants `Set.insert(_:)`, whose return value is a pair
you can filter on.
</details>

## Retrieval checkpoint

Answer in writing first, then check the four runnable ones with Swift. Nothing
here has a committed answer.

1. `"e\u{301}" == "\u{e9}"` is true. Give their `count`, `unicodeScalars.count`,
   and `utf8.count`, and say which of the three `==` compared.
2. `let s = base[2..<5]`. Predict `s.startIndex`, `s.count`, and what
   `s.firstIndex(of: x)` returns relative to `base`.
3. Predict the type of `xs.lazy.map(f)`, then of `let ys: [Int] =
   xs.lazy.map(f)`. Explain the difference in one sentence.
4. `Dictionary(grouping:by:)` over an empty array. What comes back, and what
   is its type?
5. Judgment, no single right answer. You store usernames and must reject
   duplicates. Argue for `Set<String>` against `[String]` plus a `contains`
   check, then say what the rejected option would have given you.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Read <https://developer.apple.com/documentation/swift/collection> and find
  three members this chapter never used.
- Add a pipeline to `probes/lazy.swift` with two `map` steps and a `filter`
  between them, and predict the interleaving before running it.
- Read SE-0163, "String Revision: Collection Conformance, C Interop,
  Transcoding", in
  <https://github.com/swiftlang/swift-evolution/tree/main/proposals>.

## Done when

- [ ] `swift test --filter Chapter06Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] No force unwrap and no `Array(` over a `String` survives in my solutions:
      `grep -nE '[A-Za-z_)\]]!|Array\(' modules/06-collections/exercises/*.swift`
      prints nothing

This chapter consumes `Sequence` and `Collection`; writing your own
conformance to either needs associated types, and that belongs to chapter 07
and to project 03.
