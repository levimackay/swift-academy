# Module 01 — Values, Types, and Optionals

**Goal:** understand how Swift thinks about *the absence of a value*, and why that
one idea shapes the entire language.

**Prereq:** none. This is the ground floor.

---

## Why this module is first

Every language has to answer one question: what do you do when a value might not
be there?

- **Python** says: it's there or it's `None`, and you find out at runtime.
  `user.name` on a `None` crashes in production.
- **C#** says: reference types can be `null`, and you find out at runtime — the
  billion-dollar mistake. (Modern C# bolted on nullable reference types to patch
  this, which you may have seen as `string?`.)
- **Swift** says: absence is part of the type, checked at compile time, and there
  is no way to ignore it.

That last one is not a small syntax difference. It is the thing that makes Swift
feel foreign for the first week and obvious forever after. Get it now and the
rest of the language unfolds from it.

---

## 1. `let` and `var`

```swift
let name = "Levi"     // constant — cannot be reassigned
var count = 0         // variable — can be reassigned
count += 1
```

| Swift | Python | C# |
|---|---|---|
| `let x = 5` | `X = 5` (convention only) | `const int x = 5` / `readonly` |
| `var x = 5` | `x = 5` | `var x = 5` |

Swift's `let` is enforced, not a naming convention. **Default to `let`.** Write
`var` only when the compiler makes you. This isn't style advice — immutability by
default is load-bearing for the value-semantics stuff in Module 03.

## 2. Types are inferred but static

```swift
let x = 5          // inferred Int
let y = 5.0        // inferred Double
let z: Double = 5  // explicit annotation
```

Coming from Python, `let x = 5` *looks* dynamically typed. It is not. `x` is an
`Int` forever. Coming from C#, this is exactly `var` — same idea, same rules.

And Swift will not silently convert for you:

```swift
let a = 5
let b = 2.0
let c = a + b        // ERROR — no implicit numeric conversion
let c = Double(a) + b  // fine
```

C# would happily widen `int` to `double` here. Swift refuses. Every conversion is
something you wrote on purpose.

## 3. Optionals — the main event

A `String` always holds a string. A `String?` holds a string **or** nothing.

```swift
var name: String = "Levi"
name = nil            // ERROR — String cannot be nil

var nickname: String? = "Lev"
nickname = nil        // fine
```

`String?` is a genuinely different type from `String`. You cannot use one where
the other is expected. The compiler forces you to handle the empty case before
you're allowed to touch the value.

### Unwrapping

**`if let`** — do something when it's there:

```swift
if let nickname {
    print("Hi \(nickname)")   // nickname is String here, not String?
} else {
    print("No nickname")
}
```

**`guard let`** — bail out early when it isn't:

```swift
func greet(_ nickname: String?) -> String {
    guard let nickname else { return "Hi stranger" }
    return "Hi \(nickname)"    // nickname is String for the rest of the function
}
```

`guard` is Swift's flat-happy-path idiom. It's the closest thing to Python's
early `if not x: return`, except the unwrapped value survives past the block.
Use `guard` when absence means "stop"; use `if let` when both branches do work.

**`??`** — supply a default:

```swift
let display = nickname ?? "anonymous"   // String, never nil
```

Same as Python's `x or "default"` (but without the falsy-value bug) and C#'s
`x ?? "default"` (exactly the same).

**`!`** — force unwrap. Crashes if nil.

```swift
let shout = nickname!.uppercased()   // 💥 if nickname is nil
```

You will see this in tutorials and Stack Overflow answers everywhere. **Treat it
as a code smell.** It is the one escape hatch that throws away everything the
type system just did for you. There are legitimate uses; you have not earned any
of them yet. In this module, using `!` counts as not solving the problem.

### Optional chaining

```swift
let length = nickname?.count        // Int? — nil if nickname was nil
```

The `?.` short-circuits the whole chain to nil. Same shape as C#'s `?.`. Python
has no equivalent — you'd write nested `if x is not None`.

## 4. Strings are not arrays

This one catches everyone from Python:

```swift
let name = "Levi"
let first = name[0]        // ERROR — does not compile
```

Swift strings are collections of `Character` (full Unicode grapheme clusters, so
emoji and accented letters count as one), and they are not integer-indexable —
because finding character *n* isn't a constant-time jump. You get:

```swift
name.first          // Character? — "L"
name.count          // 4
name.uppercased()   // "LEVI"
name.split(separator: " ")   // [Substring]
name.isEmpty
Array(name)         // [Character] — now you CAN index, at a cost
```

Note `first` returns `Character?`, not `Character`. Empty string, no first
character. Optionals again, everywhere, on purpose.

---

## Your problems

Open `Sources/ValuesAndOptionals/Problems.swift`. Six functions, each a
`fatalError` waiting to be replaced.

```bash
cd ~/swift-academy/modules/01-values-and-optionals
swift test
```

Suggested order — they build on each other:

1. `clamp` — warm-up, no optionals, just syntax and argument labels
2. `safeDivide` — your first optional return
3. `describe` — your first unwrap
4. `parseAge` — failable conversion plus validation
5. `firstNonEmpty` — optionals meet collections
6. `initials` — strings will fight you; that's the point

## Done when

- [ ] `swift test` passes all 10 tests
- [ ] Zero force unwraps (`!`) in your solutions
- [ ] You can explain, out loud, why `String` and `String?` are different types
- [ ] You can explain when you'd reach for `guard let` over `if let`

## Rules

You type every line. Ask me for hints, not answers — "why won't this compile,"
"is this idiomatic," "review what I wrote." Not "write `initials` for me."

There is no `solution/` folder in this module, and that is deliberate. It gets
written after you solve it, by you.
