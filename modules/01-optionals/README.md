---
chapter: 01
slug: 01-optionals
title: Values, Types, and Optionals
anchor: csharp
concepts:
  - Optional<Wrapped> is an enum with cases .none and .some(Wrapped)
  - unwrapping is pattern matching, and each form states a control flow contract
  - optionals nest, because Optional is an ordinary generic type
requires: []
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 01. Values, Types, and Optionals

## The question

Every language answers one question before it answers any other: what does a
program do when a value is not there. C# and Python answered it the same way,
by letting one special value inhabit every reference type. That is cheap to
implement and it costs a possible failure at every single dereference, in
every program, forever. Tony Hoare called his 1965 version of it his billion
dollar mistake, and the bill is still arriving.

The alternative is to spend type system budget instead. Make absence a
separate type, so a value that might be missing cannot be handed to code that
requires a value that is present. Swift spent the budget.

## Swift's answer

`String?` is not a flag attached to `String`. It is this, which the standard
library declares, minus its attributes:

```swift
enum Optional<Wrapped> {
    case none
    case some(Wrapped)
}
```

`String?` is sugar for `Optional<String>` and `nil` is sugar for `.none`. Both
are ordinary values: you can compare them, store them in an array, and pass
them to a generic function.

```swift
let found: String? = "Levi"
let absent: String? = nil
print(found == .some("Levi"), absent == .none)   // true true
```

Because it is an enum, the general way to consume one is the general way to
consume any enum, and the compiler checks that both cases are covered.

```swift
switch found {
case .some(let name):
    print(name.count)
case .none:
    print("nothing to count")
}
```

Every other form is shorthand for that `switch`. Picking between them is a
statement about control flow, not about taste.

| Form | What it does | When it is the right one |
|---|---|---|
| `if let found { }` | binds the payload for one branch | both branches have real work |
| `guard let found else { return }` | binds for the rest of the scope, and the else branch must exit | absence means stop |
| `found ?? "anonymous"` | payload, or a default of the payload's type | you have a defensible default |
| `found?.count` | reaches into the payload, whole expression becomes optional | reaching through a chain |
| `switch found` | full pattern matching, with `where`, ranges, tuples | more than two outcomes |
| `found.map`, `found.flatMap` | transforms the payload, leaves `.none` alone | you want an optional back out |
| `found!` | asserts `.some`, terminates the process otherwise | almost never, see below |

`guard` takes several conditions at once, and everything it binds stays bound
for the rest of the enclosing scope, which is what keeps the happy path flat
and unindented. `if let x` with no `= x` on the right is shorthand for
rebinding a name onto itself.

```swift
func middleName(of parts: [String]) -> String {
    guard parts.count == 3,
          let middle = parts.dropFirst().first,
          !middle.isEmpty
    else { return "none" }
    return middle
}
```

`map` applies the closure to the payload. When the closure itself returns an
optional you get two layers, and `flatMap` collapses one.

```swift
let text: String? = "12"
let mapped = text.map { Int($0) }        // Optional<Optional<Int>>
let flattened = text.flatMap { Int($0) } // Optional<Int>
```

Nesting is a feature, not an accident. A `[String: Int?]` lookup has two
different answers to give: the key was absent, or the key was present and
stored nothing. That is exactly `Optional<Optional<Int>>`, and flattening it
would throw one of the two answers away. Optional chaining flattens because a
chain has only one answer to give, which is why `scores["ada"]?.first` is
`Int?` while `scores["ada"].map { $0.first }` is `Int??`.

Force unwrap exists because the type system cannot prove everything you know.
`!` is the spelling of a claim: this is `.some`, and if I am wrong, terminate
the process. That is honest for a literal you built two lines up. It is
dishonest as a way of getting past a compiler error.

```swift
let port: Int? = Int("8080")
// print(port!)   // make probe CH=01 P=forceunwrap
```

An implicitly unwrapped optional is not a third type. `String!` is
`Optional<String>` carrying an instruction to insert a force unwrap at every
use, so the trap fires far from the line that made the bad assumption. It
exists for two phase initialization and for imported Objective C APIs that
carry no nullability annotation. Outside those, `String?` unwrapped once is
strictly better.

## Predict

Write your prediction in the comment above each snippet in
`probes/predict.swift`, then run `make probe CH=01 P=predict`. The toolchain is
the answer key, and no answer key exists in this repository. The ones you get
right cost you a minute. The ones you get wrong are each a place where absence
being a type rather than a flag changes the answer.

```swift
let a: String?? = nil
let b: String?? = .some(nil)
print(a == nil, b == nil)                                // 1

let scores = ["ada": [7, 8]]
print(type(of: scores["ada"]?.first),
      type(of: scores["ada"].map { $0.first }))          // 2

let readings: [String: Int?] = ["pier": nil]
print(readings["pier"] as Any, readings["dock"] as Any)  // 3
```

## Coming from C#

### Where the analogy holds

| C# | Swift | Note |
|---|---|---|
| `string? name` | `let name: String?` | both declare that the value may be absent |
| `x ?? "d"` | `x ?? "d"` | same operator, same short circuit |
| `x?.Length` | `x?.count` | both flatten a chain instead of nesting it |
| `if (x is not null)` | `if let x { }` | both narrow, and Swift names the narrowed value |

### Where it breaks

```csharp
#nullable enable
string? Find(int id) => id == 1 ? "Levi" : null;
int n = Find(2)!.Length;    // compiles clean, throws at run time
```

```python
def find(user_id: int) -> str | None:
    return "Levi" if user_id == 1 else None

n = len(find(2))    # TypeError at run time, and the annotation was never read
```

| Claim | C# nullable reference types | Swift |
|---|---|---|
| absence is a type | annotation only, same runtime type either way | a distinct enum type with its own layout |
| it can be switched off | per file, per line, per project | there is no flag |
| `!` | erased before run time, free | traps at run time, kills the process, nothing to catch |
| it nests | `string??` does not parse | `String??` is ordinary, and useful |
| Python's `str \| None` | (row applies to Python) | the interpreter never reads the annotation |

C# added nullability nine versions in, over a runtime where null already
inhabited every reference, so it had to be defeatable and it has to trust
every boundary it cannot see: a library compiled without it, a deserializer,
reflection. Swift had no legacy null to annotate, so it spent type system
budget instead. There is no boundary where the wrapper falls off, because the
wrapper is the type.

Full row set: [docs/bridge.md](../../docs/bridge.md).

## The model

```text
Verified with `make probe CH=01 P=layout`:

  String     |pppppppppppppppppppppppppppppp|     size 16
  String?    |pppppppppppppppppppppppppppppp|     size 16
  String??   |pppppppppppppppppppppppppppppp|     size 16
             .none is a pointer pattern that no live String
             can hold, so the tag is free, twice over.

  Int        |vvvvvvvvvvvvvvvv|                   size 8
  Int?       |vvvvvvvvvvvvvvvv|t|                 size 9
  Int??      |vvvvvvvvvvvvvvvv|t|t|               size 10
             every one of Int's 2^64 patterns is a valid Int,
             so each tag has to buy its own byte.
```

`Optional` has a runtime representation, and that is the point of the diagram.
An annotation could not change a type's size. The sizes also show why `.none`
is free for pointer backed types and costs a byte for `Int`: the compiler uses
spare bit patterns when the wrapped type has any, and adds a discriminator byte
when it does not.

## Where it goes wrong

Every row was produced by `make probe CH=01 P=errors`, except rows 6 and 8,
which come from `P=guardfall` and `P=forceunwrap`. Row 8 carries the
implicitly unwrapped wording because that trap fires first. Comment out that
line and the plain `!` below it prints `Unexpectedly found nil while
unwrapping an Optional value` instead.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: 'nil' cannot be assigned to type 'String'` | `String` and `String?` are different types, and only one of them has a `.none` case | declare it `String?` if absence is real, otherwise stop assigning `nil` |
| `error: value of optional type 'Int?' must be unwrapped to a value of type 'Int'` | you applied an operator to the wrapper instead of the payload | `??` for a default, `if let` or `guard let` to bind |
| `error: value of optional type 'Bool?' must be unwrapped to a value of type 'Bool'` | there is no truthiness, and `Bool?` has three states | `if flag == true`, or bind it, and decide what `nil` means |
| `error: value of optional type 'String?' must be unwrapped to refer to member 'count' of wrapped base type 'String'` | the member belongs to `String`, and you are holding the enum | `s?.count` for an `Int?` back, or bind first |
| `error: initializer for conditional binding must have Optional type, not 'String'` | `if let` on something already present | delete the binding, the value is already usable |
| `error: 'guard' body must not fall through, consider using a 'return' or 'throw' to exit the scope` | `guard` binds for the rest of the scope, so its else branch must leave | `return`, `throw`, `break`, or `continue` in the else |
| `warning: string interpolation produces a debug description for an optional value; did you mean to make this explicit?` | it compiles and prints `Optional("Lev")` to a user | interpolate `nickname ?? "none"`, or bind before interpolating |
| `Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value` | a force unwrap was wrong at run time, and `String!` traps at a use site, not at the assignment | remove the `!`, the compiler already asked for a decision here |

## Exercises

Stubs are in `exercises/Optionals.swift`, in the order below. Run
`swift test --filter Chapter01Tests`.

1. `displayName(for:fallback:)` returns the nickname when it holds a non empty
   string, and the fallback otherwise.
2. `firstInitial(of:)` returns the first `Character` of a name, or nil when the
   name is absent or empty.
3. `parsedPort(from:)` parses text as a TCP port in 1 through 65535, nil for
   anything else.
4. `label(for:)` describes a score, with distinct answers for absent, negative,
   zero, and everything else.
5. `absenceKind(of:)` distinguishes the two levels of an `Int??`: outer empty,
   inner empty, or fully present.
6. `summarize(_:)` folds `[Reading]` into a `Report`, counting reported and
   missing readings, and giving the warmest station and the mean of the
   temperatures that exist. This one is the integrative exercise: it is the
   only one where getting an optional wrong shows up as a wrong number rather
   than a compiler error.

<details><summary>Hint 1, a nudge</summary>

Exercise 6 asks four questions of one array. Answer them one at a time and
combine at the end, rather than looping once and tracking four variables.
</details>

<details><summary>Hint 2, an approach</summary>

Two of the four answers only concern readings that carried a temperature. Get
that shorter array first, and both counts fall out of its length.
</details>

<details><summary>Hint 3, the API to look up</summary>

`Sequence.compactMap`, and its key path form `compactMap(\.celsius)`. Then
`isEmpty` before you divide by anything.
</details>

## Retrieval checkpoint

Answer in writing first, then check the four runnable ones with Swift. Nothing
here has a committed answer.

1. `let x: Int?? = .some(nil)`. What does `x == nil` print, and what does
   `x.flatMap { $0 } == nil` print? Explain the difference in one sentence.
2. Does `let n: Int = someOptional ?? 0` compile when `someOptional` is
   `Int??`? Predict the type of `someOptional ?? 0` before running it.
3. `Optional<Int>.none.map { $0 + 1 }`. Does the closure run? What is the type
   and value of the result?
4. `var d: [String: Int] = [:]`. Both `d["a"]! += 1` and
   `d["a", default: 0] += 1` compile. Predict what each does at run time.
5. Judgment, no single right answer. `firstIndex(of:)` returns `Int?` where
   C#'s `IndexOf` returns `-1`. Name one bug the Swift signature makes
   impossible. Then argue whether a missing key in a config file should be
   `Int?` or an error, and say what the option you rejected costs you.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Read the `Optional` reference at
  <https://developer.apple.com/documentation/swift/optional> and find three
  members this chapter never used.
- Read SE-0054, "Abolish ImplicitlyUnwrappedOptional type", in
  <https://github.com/swiftlang/swift-evolution/tree/main/proposals>. It is the
  argument for why `String!` is not a type.

## Done when

- [ ] `swift test --filter Chapter01Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] No force unwrap survives in my solutions:
      `grep -nE '[A-Za-z_)\]]!' modules/01-optionals/exercises/*.swift` prints nothing

This chapter does not cover the other two ways Swift models failure, `throws`
and `Result`, or how to choose between all three. That decision belongs to
chapter 08, and the C# exception comparison behind it is in
[docs/bridge.md](../../docs/bridge.md). Nor does it cover why exercise 2 treats
a family emoji as one `Character`: that model belongs to chapter 06, and the
lookup behind it is [docs/strings.md](../../docs/strings.md).
