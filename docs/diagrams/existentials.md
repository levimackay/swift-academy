---
title: The existential box
kind: diagram
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# The existential box

Cross cutting. Chapter
[07-generics](../../modules/07-generics/README.md) owns the teaching and
carries its own diagram. This file is the long version: `any P` drawn to
scale, with the measured numbers, because `some` versus `any` is the highest
value non obvious distinction for a developer arriving from C# and it is
invisible until you can see what the two spellings cost.

This repo enables `ExistentialAny` on every target, so every existential site
must be spelled `any P`. That flag exists to make this page's subject visible
in every file you write.

## Measured, not recalled

Every number below came from these two lines on the toolchain in the front
matter:

```swift
print(MemoryLayout<any P>.size, MemoryLayout<any P>.stride, MemoryLayout<any P>.alignment)
print(MemoryLayout<Small>.size, MemoryLayout<Big>.size)
```

```text
40 40 8
8 32
```

So `any P` is 40 bytes regardless of what is inside it, while the concrete
`Small` is 8 and `Big` is 32.

## The box, to scale

Five machine words. One byte of the drawing is one byte of the value.

```text
any P, 40 bytes on a 64 bit target, always, for every P

  0        8        16       24       32       40
  +--------+--------+--------+--------+--------+
  | inline | inline | inline | type   | witness|
  | buffer | buffer | buffer | meta   | table  |
  +--------+--------+--------+--------+--------+
  \______  3 words  ______/  \_ 1 _/  \_ 1 _/

  struct Small { var a: Int }              size 8
  +--------+
  | a      |                fits: stored inline, no allocation
  +--------+
  |....................|    the other two words go unused

  struct Big { var a, b, c, d: Int }       size 32
  +--------+--------+--------+--------+
  | a      | b      | c      | d      |    does not fit in 3 words
  +--------+--------+--------+--------+
        |
        +--> heap allocation; the inline buffer holds a pointer to it

  The last two words never vary:
    type metadata  ->  what type is actually in here, at run time
    witness table  ->  where P's methods are, for this specific type
```

Three things to read off it.

**The box is a fixed size and the contents are not.** That is the entire
purpose: an `[any Shape]` can hold a `Circle` next to a `Square` because every
element is 40 bytes whatever it holds. A `[Circle]` cannot.

**Three words is the whole inline budget.** A value of 24 bytes or less lives
in the box. Anything larger is boxed onto the heap, and the array of
existentials becomes an array of pointers to separate allocations. That is a
real cost in a loop and it is invisible in the source.

**The witness table is the dispatch.** Calling `shape.area()` on an `any
Shape` reads the function's address out of that table at run time. There is no
vtable in the value and no inheritance anywhere; the table is chosen when the
value goes into the box.

## `some` against `any`, at the call site

```text
func totalGeneric<S: Shape>(_ xs: [S]) -> Double
                  \___ one type, chosen by the caller ___/

    [Circle] ---> specialized: Circle.area is known here, inlinable,
                  no box, no table lookup, elements are 8 bytes each

func totalAny(_ xs: [any Shape]) -> Double
              \___ any number of types, chosen at run time ___/

    [any Shape] -> boxed: each element is 40 bytes, each area() call
                   goes through that element's witness table


func makeOne() -> some Shape
                  \_ exactly one type, hidden from the caller _/

    the caller cannot name it and cannot rely on it,
    but the compiler knows it, so this is the generic path with
    the type kept private, not the existential path
```

`some` in a return position is a promise: there is one concrete type here, it
is the same one every time, and you do not get to know which. `any` is a
different promise: there could be several, and I will carry enough metadata to
find out at run time.

The compiler enforces the difference. Verified:

```swift
func pick(_ flag: Bool) -> some Shape { flag ? Circle() : Square() }
```

```text
error: result values in '? :' expression have mismatching types 'Circle' and 'Square'
```

Change `some` to `any` and it compiles, because now the box is what is being
returned.

## The rule about `Self` requirements, stated precisely

The widely published rule is that a protocol with `Self` or associated type
requirements cannot be used as a type. That is out of date and teaching it
will get you contradicted by the compiler within a week.

What is actually true: **holding and passing `any P` is fine. Calling a member
that mentions `Self` in a position the box cannot satisfy is what fails.**

Verified. This compiles:

```swift
protocol Rankable { static func combine(_ a: Self, _ b: Self) -> Self }
struct Score: Rankable { let n: Int
    static func combine(_ a: Score, _ b: Score) -> Score { Score(n: a.n + b.n) } }

let boxed: any Rankable = Score(n: 1)
let list: [any Rankable] = [boxed]
```

And this does not:

```swift
func fuse(_ a: any Rankable, _ b: any Rankable) -> any Rankable {
    type(of: a).combine(a, b)
}
```

```text
error: member 'combine' cannot be used on value of type 'any Rankable.Type';
consider using a generic constraint instead [#ExistentialMemberAccess]
```

The reason is visible in the diagram. Two boxes carry two witness tables, and
nothing guarantees they are the same one, so there is no single `Self` for
`combine` to be about. The fix the diagnostic names is the fix: take a generic
parameter, where there is exactly one type and the compiler knows it.

## Choosing

| Situation | Spelling |
|---|---|
| A collection holding more than one concrete type | `[any P]` |
| A stored property whose type varies per instance | `any P` |
| A parameter you will call protocol members on, one type per call | `<T: P>` or `some P` in parameter position |
| A return type where you want to hide the concrete type | `some P` |
| A member using `Self` in a parameter or return position | generic, never existential |
| You are not sure | generic first. Reach for `any` when the compiler makes you. |

The default is the generic one. `any` is what you write when you genuinely
need heterogeneity, and heterogeneity is rarer than a C# habit expects,
because `IFoo` as a variable type is the C# default and the boxed existential
is the Swift exception.

---

Related: [actor-isolation.md](actor-isolation.md),
[arc-and-cycles.md](arc-and-cycles.md), [../glossary.md](../glossary.md),
and chapter [07-generics](../../modules/07-generics/README.md).
