---
project: 03
slug: 03-collections-kit
title: Collections Kit
after_chapter: 07-generics
difficulty: 3 of 5
estimated_hours: 8
package: standalone (projects/03-collections-kit/Package.swift)
---

# Project 03. Collections Kit

## What you are building

A small library of two generic data structures that behave like Swift's own
collections rather than like containers with methods bolted on. `Deque<Element>`
is a double ended queue that you can build from an array literal, iterate in a
`for in` loop, index into, and slice. `LRUCache<Key, Value>` is a fixed capacity
cache that evicts the least recently used entry on insertion and treats a
successful lookup as a use. Both are value types. Both work with any element type
that satisfies the constraints you declare and no more. When it is done,
`swift test` is green and the test file reads like code written against the
standard library, because the tests use `for element in deque`, array literal
initialization, `.map`, and `count`, none of which compile until you have
supplied the right associated types.

Third, you port one data structure you already wrote in C# into this package. Not
a fresh one: an actual file from your own history. The point is the diff between
what you wrote there and what Swift makes you write here.

## What this project forces you to use

| Concept | Chapter |
|---|---|
| Generic types with `where` constraints, and constraint minimalism | `07-generics` |
| `some` versus `any` at every return and parameter position | `07-generics` |
| Associated types supplied, not consumed: `Element`, `Index`, `Iterator` | `04-protocols`, `07-generics` |
| Conditional conformance (`extension Deque: Equatable where Element: Equatable`) | `04-protocols` |
| `Hashable` for cache keys, and what a bad `hash(into:)` costs you | `04-protocols` |
| Value semantics under an internal buffer, and `mutating` on a lookup | `03-value-semantics` |
| `Dictionary` and `Array` chosen deliberately, plus `lazy` where it earns it | `06-collections` |
| Optional returns for empty and missing, never a sentinel | `01-optionals` |

Every chapter to date shows up here. That is what makes it the first project you
can put in front of a stranger.

## Functional requirements

### Deque

1. `Deque<Element>` is generic over an unconstrained `Element`. Adding a
   constraint to the type itself is a failure, not a shortcut.
2. Append and prepend, both amortized constant time, both with argument labels
   that read at the call site.
3. Remove from the front and remove from the back, each returning the removed
   element or `nil` when empty. No trapping, no sentinel value.
4. Peek at the front and at the back without removing, again optional.
5. `count` and `isEmpty` are available and do not iterate.
6. Conforms to `Sequence`, so `for element in deque` compiles and iterates front
   to back.
7. Conforms to `Collection`, so `deque[i]`, `deque.first`, `deque.map`, and
   slicing work with no extra code from you.
8. Conforms to `ExpressibleByArrayLiteral`, so a deque can be written as an array
   literal with the element order preserved.
9. Conforms to `Equatable` only when `Element` does, and to `CustomStringConvertible`
   always.
10. Copying a deque and mutating one copy leaves the other unchanged, at every
    size including empty and one element.
11. Removing every element and then appending again works. A structure that
    breaks after being drained is the classic index bug this requirement exists
    to catch.

### LRUCache

12. `LRUCache<Key: Hashable, Value>` is created with a capacity, and a capacity of
    zero or less is rejected at initialization rather than misbehaving later.
13. Insert stores a value for a key and returns the evicted entry, if any, so the
    caller can observe eviction without inspecting internals.
14. Lookup returns the value or `nil`, and a successful lookup makes that key the
    most recently used.
15. Re inserting an existing key updates the value and refreshes recency without
    growing the count.
16. Count never exceeds capacity, at any point, under any sequence of operations.
17. Eviction order is strictly least recently used, where "used" means inserted or
    successfully looked up.
18. Lookup is expected constant time, not a scan. Your tests will not prove this,
    so your design has to.
19. The cache is a value type with copy independence, same as the deque.
20. Removal of a specific key and removal of everything are both supported.

### The port

21. One data structure you previously wrote in C# is ported into this package,
    with the original C# kept in a comment block or a sibling file for
    comparison.
22. A short `PORT.md` in this project directory answers three questions in a
    paragraph each: what the C# version relied on that Swift does not have, what
    Swift made you decide that C# let you leave implicit, and which version you
    would rather maintain and why.

## Non-goals

- No thread safety, no locks, no actors, no `Sendable` conformance work. Chapter
  11 owns that and adding it now will teach you the wrong reflex.
- No reference types. If you reach for a class, the reason must be one of the
  three permitted reasons, and none of the three apply to either structure here.
- No third structure. Not a heap, not a trie, not a ring buffer as a separate
  public type.
- No benchmarking harness and no performance tuning past choosing the right
  storage.
- No `MutableCollection`, `RandomAccessCollection`, or
  `RangeReplaceableCollection` conformance in the required scope. Those are
  stretch goals with real teeth.

## Architecture: constraints and questions

**Constraints belong on extensions, not on types.** Requirement 1 and requirement
9 are the same lesson twice. Ask yourself at every `where` clause: does the type
need this to exist, or does one operation need it to work?

- `Sequence` needs an `Iterator`. You can supply one by writing a struct, or by
  returning an existing iterator type. One of those choices leaks your storage
  into your public API. Which, and does it matter here?
- `Collection` needs `startIndex`, `endIndex`, `index(after:)`, and a subscript.
  If your storage is a ring buffer, your `Index` is not an `Int` offset into that
  buffer. What goes wrong first if you pretend it is, and does it go wrong loudly
  or quietly?
- Requirement 8 (`ExpressibleByArrayLiteral`) and requirement 7 (`Collection`)
  both talk about element order. Write down the invariant that ties them
  together in one sentence before you write either.
- Requirement 14 says a lookup changes the cache. In Swift that makes it
  `mutating`, which makes it unavailable on a `let` cache, which will feel wrong
  and is correct. What is that restriction actually protecting?
- The cache needs constant time lookup and ordered recency at once. No single
  standard library type gives you both. What pair does, and what invariant must
  hold between the two at all times? Write that invariant as a comment above the
  stored properties and then check your code against it line by line.
- Amortized constant time at both ends of the deque rules out one obvious
  implementation. Name the ruled out one and why, in a comment.
- Copy on write: `Array` and `Dictionary` already give it to you for free if your
  stored properties are values. If you find yourself writing `isKnownUniquelyReferenced`,
  stop, because that means you introduced a reference you did not need.
- Your public API should not expose an index type, a bucket, a node, or a
  capacity detail that a caller could depend on. What is `internal` and what is
  `public` here, and did you decide or did you default?

### Scaffold honesty

The test suite in `Tests/CollectionsKitTests/` will not compile until you have
declared the types and supplied the conformances. That is intentional and it is
why this project is a standalone package: a red build here cannot turn the
fourteen chapters red. If the scaffold pre declares any symbol just so the
package parses, that declaration is part of the answer and it is called out in a
comment in that file. Delete it and write your own as soon as you can.

## Milestones

1. **Deque, array backed, no conformances.** Append, prepend, remove, peek,
   count. Passing tests that use only methods.
2. **`Sequence`.** The `for in` tests go green.
3. **`Collection`.** The subscript, slicing, and `map` tests go green. This is
   the hardest single step in the project, because `Index` is where the design
   either holds or collapses.
4. **Literals and conditional conformance.** Requirements 8 and 9.
5. **Ring buffer or two stack rewrite,** if your first storage cannot meet
   requirement 2. Your existing tests must stay green through the rewrite with no
   edits. If they do not, your tests were testing your implementation.
6. **LRUCache, correctness first.** Capacity, insert, lookup, eviction order,
   with an intentionally slow recency scan if that gets it correct.
7. **LRUCache, constant time.** Replace the scan. Same tests, no edits.
8. **The port and `PORT.md`.**

## Definition of done

- [ ] `swift build` in `projects/03-collections-kit` is clean with no warnings.
- [ ] `swift test` is green, including the `for in` suite, the array literal
      suite, the copy independence suite, the drain and refill suite, and the
      eviction order suite.
- [ ] The `Collection` conformance is not faked by converting to an `Array`
      internally on every access.
- [ ] `Element` carries no constraint on either type declaration.
- [ ] There is no `class` in `Sources/`.
- [ ] There is no force unwrap in `Sources/`.
- [ ] `PORT.md` exists and answers all three questions.
- [ ] You can explain out loud, with no notes, what `Collection` requires and why
      `Index` is an associated type instead of `Int`.

## Stretch goals

Not required to advance.

- Conform `Deque` to `RangeReplaceableCollection` and find out how much of your
  API you get to delete.
- Conform to `MutableCollection` and think carefully about whether a settable
  subscript can preserve your invariants.
- Add a `lazy` view over the deque that filters without allocating an
  intermediate array, and prove it with a counter in a closure.
- Make `LRUCache` report a hit rate, and expose it without exposing the storage.
- Write a small randomized test that performs a thousand random operations
  against your cache and against a deliberately naive reference implementation,
  and asserts they agree.

## Self-review before you call it finished

1. For every `where` clause I wrote, can I name the operation that needs it? If
   it is on the type, why?
2. Did I write `any` anywhere? If so, what did I gain over `some` and could a
   generic parameter have done it instead?
3. If I hand my `Deque` to a function that only takes a `Sequence`, does anything
   surprising happen with iteration order?
4. Does my `Collection` conformance survive being sliced and then iterated?
5. Are my empty, single element, and full capacity cases all tested, or only the
   comfortable middle?
6. Can a caller put my cache into a state where `count > capacity` for even one
   statement? Walk the insert path and prove it.
7. Did my step 5 or step 7 rewrite force me to change any test? If yes, which
   assertion was about implementation rather than behavior?
8. Is anything `public` that a caller has no business calling?
