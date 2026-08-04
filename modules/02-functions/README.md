---
chapter: 02
slug: 02-functions
title: Functions, Argument Labels, and Closures
anchor: python
concepts:
  - argument labels are part of the function's name
  - functions and closures are values
  - escaping and capture
requires: [01-optionals]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 02. Functions, Argument Labels, and Closures

## The question

A call site is read many more times than it is written, and by then the
declaration is in another file. `resize(400, 300, true)` is four facts, three
of them unreadable. Every language has an answer: comments, hungarian
parameter names, a settings object, or keyword arguments the caller may use if
they feel like it. Each of those puts the burden on the person writing the
call, which is the person who already knows.

Swift moved the burden. The label is not something a caller opts into, it is
part of the declared name, so the call reads the way the author intended or it
does not compile.

## Swift's answer

A parameter has two names. The first is the argument label, written at the
call site. The second is the parameter name, used inside the body. When you
write only one name it plays both roles, and `_` deletes the label.

```swift
func move(from source: Int, to destination: Int) -> Int { destination - source }
func stepped(by steps: Int) -> Int { steps }
func negated(_ value: Int) -> Int { -value }

print(move(from: 3, to: 9), stepped(by: 4), negated(4))   // 6 4 -4
```

The full name of the first one is `move(from:to:)`. That is the identity the
compiler resolves, not a documentation convention, which is why
`move(to:from:)` is a different function and why an overload set can differ by
labels alone. Three functions named `area` coexist in `probes/predict.swift`
on exactly that basis.

Defaults, variadics, and `inout` all hang off the same declaration.

```swift
func banner(_ text: String, width: Int = 20, fill: Character = ".") -> String {
    String(repeating: String(fill), count: max(0, width - text.count)) + text
}
func total(of values: Int...) -> Int { values.reduce(0, +) }
func bump(_ value: inout Int, by step: Int = 1) { value += step }

var tally = 10
bump(&tally, by: 5)
print(banner("ok", width: 6), total(of: 1, 2, 3), total(), tally)  // ....ok 6 0 15
```

A default is an expression evaluated per call, so Python's mutable default
argument trap has no Swift spelling. A variadic parameter arrives as an
`Array` inside the body and accepts zero arguments. `inout` is copy in, copy
out: the argument is copied in, mutated, and written back at return. Not a
pointer, not an alias, which is why the caller writes `&`, why two `inout`
arguments may not name one variable, and why handing it a computed property
calls the getter on the way in and the setter on the way out. That last one is
audible in `probes/predict.swift`.

A function is also a value. Drop the parentheses and you have one, typed
`(Int) -> Int`, with the labels stripped off because labels belong to the name
and a type has no name.

```swift
let operations: [String: (Int) -> Int] = ["negate": negated, "step": stepped(by:)]
print(operations["negate"].map { $0(7) } as Any)     // Optional(-7)
```

A closure is the same value written inline. Swift infers the parameter and
return types from context, so the body is usually all that survives, and `$0`
is the first argument.

```swift
let doubled = [1, 2, 3].map { value in value * 2 }
let tripled = [1, 2, 3].map { $0 * 3 }
```

Both use trailing closure syntax: a closure that is the last argument moves
outside the parentheses, and empty parentheses disappear. It exists so a
function taking a body reads like a built in statement instead of a call with
a lambda wedged into it, which is the entire basis of SwiftUI's syntax in
chapter 13.

The last piece is lifetime. A closure parameter is non escaping by default:
the compiler guarantees it does not outlive the call, so the captures can stay
on the stack. Storing one, returning it, or handing it to a `Task` breaks that
guarantee, and `@escaping` is you telling the compiler to allocate
accordingly.

```swift
func applyTwice(_ transform: (Int) -> Int, to value: Int) -> Int {
    transform(transform(value))
}
func delayed(_ work: @escaping () -> Int) -> () -> Int { work }
```

Captures are by variable, not by value, so a closure sees writes made after it
was built and can write back. `@autoclosure` does one job: it wraps the
caller's expression in a closure automatically so it is evaluated only if
needed. `??` is declared that way, which is why the right side of
`port ?? expensiveDefault()` costs nothing when `port` is present. Use it when
the argument is an expression the callee may skip, and nowhere else, because
it makes an ordinary looking expression run at an unordinary time.

```swift
func lazily(_ makeValue: @autoclosure () -> Int) -> Int { makeValue() }
```

## Predict

Write your prediction in the comment above each `print`, then run the file.
The toolchain is the answer key and no answer key lives in this repository.

```bash
make probe CH=02 P=predict
make probe CH=02 P=capture
```

```swift
func widths(of leading: Int..., and trailing: Int...) -> (Int, Int) {
    (leading.count, trailing.count)
}
print(widths(of: 1, 2, 3, and: 4), widths())            // 1

var built: [() -> Int] = []
for step in 1...3 { built.append { step * 10 } }
print(built.map { $0() })                               // 2
```

## Coming from Python

### Where the analogy holds

| Python | Swift | Note |
|---|---|---|
| `f(timeout: 5)` at the call site | `f(timeout: 5)` | you already write keyword arguments for readability |
| `def f(x, retries=3)` | `func f(_ x: Int, retries: Int = 3)` | same defaulting, same call site |
| `def f(*args)` | `func f(_ values: Int...)` | both arrive as a sequence in the body |
| a function is an object | a function is a value of function type | passing, storing, and returning all carry over |
| `sorted(key=lambda p: p.age)` | `sorted { $0.age < $1.age }` | both take a function; the shape differs, see FF12 |

### Where it breaks

```python
def tag(text, marker=[]):
    marker.append(text)     # the same list on every call, forever
    return marker

adders = [lambda: i * 10 for i in range(1, 4)]
print([a() for a in adders])     # [30, 30, 30]
```

| Claim | Python | Swift |
|---|---|---|
| labels are optional | positional is normal, keywords are a courtesy | part of the name, so omitting one is a compile error |
| defaults evaluate | once, at definition | per call, at the call site, so a mutable default cannot be shared |
| a lambda closes over | the name, looked up when it runs | the variable, bound where it was written, fresh per loop iteration |
| decorators | rewrite the function at import, any new signature | no analogue; a higher order function returning a closure, checked at compile time |
| lifetime of a passed function | always heap, always indefinite | non escaping by default, and `@escaping` is a declared promise |

The loop above prints `[10, 20, 30]` in Swift, verified in `probes/capture.swift`.
Decorators are the real gap: `@retry` in Python replaces a function with
another one at import time and nothing checks the result. Swift splits that
work across higher order functions, `@propertyWrapper`, and macros, none of
which can change the shape of what they decorate.

Full row set: [docs/bridge-python.md](../../docs/bridge-python.md).

## The model

```text
  declaration        func move(from source: Int, to destination: Int)
                               ^^^^ ^^^^^^         ^^ ^^^^^^^^^^^
                               |    |              |  |
                               |    body only      |  body only
                               call site only      call site only

  full name          move(from:to:)          two labels, in this order
  call               move(from: 3, to: 9)
  as a value         let f = move            f: (Int, Int) -> Int
  through f          f(3, 9)                 the labels are gone with the name

  captures           non escaping                 escaping
                     caller's frame               heap box
                     [ tally ] <- closure         [ tally ] <- closure
                     dies at the closing brace    outlives the call
```

Two erasures, one diagram. A function type carries parameter types and a
return type and nothing else, so assigning `move` to a variable throws away
the part that made the call site readable. And `@escaping` is not decoration:
it selects which of the two storage pictures the compiler emits, which is why
it has to be in the signature rather than inferred at the call.

## Where it goes wrong

Every row was produced by `make probe CH=02 P=errors`, in that file's order.
Rows 5 and 7 are not type errors: they come from a later pass, so an editor
that only type checks can show both of those lines green.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: missing argument labels 'from:to:' in call` | the labels are the name, and you called something with no name | write them, and stop reading them as ceremony |
| `error: argument 'from' must precede argument 'to'` | order is part of the name too, so labels do not reorder arguments the way Python keywords do | put them back in declared order |
| `error: extraneous argument labels 'from:to:' in call` | you are calling through a function type, and a type has no labels | call it positionally, or keep the function's own name |
| `error: passing value of type 'Int' to an inout parameter requires explicit '&'` | mutation of a caller's variable is never invisible at the call site | write `&`, or ask whether a return value is the better shape |
| `error: inout arguments are not allowed to alias each other` | copy in copy out cannot write two results back into one variable | copy to a local, pass that, assign the result yourself |
| `error: converting non-escaping parameter 'handler' to generic parameter 'Element' may allow it to escape` | you stored a closure the compiler promised would not outlive the call | mark the parameter `@escaping` and accept the allocation |
| `error: escaping closure captures mutating 'self' parameter` | a value type's `self` is copy in copy out for the duration of the call, so a closure cannot hold it past that | capture the fields you need, or move the state into a reference type in chapter 10 |
| `error: contextual closure type '() -> Int' expects 0 arguments, but 1 was used in closure body` | `$0` invented a parameter the expected function type does not have | check what the callee actually passes you |

## Exercises

Stubs are in `exercises/Functions.swift`, in the order below. Run
`swift test --filter Chapter02Tests`.

1. `initials(of:separatedBy:)` builds initials from a name, with a default
   separator and no empty initials from runs of spaces.
2. `spread(of:)` is variadic. Zero arguments is a legal call.
3. `clamp(_:into:)` moves a value into a closed range in place, returning
   nothing, so `inout` is the only observable effect.
4. `makeAccumulator(startingAt:)` returns a closure holding a running total.
   Two accumulators never share one.
5. `either(_:or:)` is `??` by hand, and the `@autoclosure` earns its keep: one
   test asserts the fallback expression never ran.
6. `Dispatcher` stores named handlers. The integrative one: it needs storage
   you declare yourself, and the signature it ships with stops compiling the
   moment you store a handler. Row 6 above is that diagnostic.

<details><summary>Hint 1, a nudge</summary>

Exercise 4 asks where the total lives. It cannot be a global and it cannot be
a parameter, so there is exactly one place left.
</details>

<details><summary>Hint 2, an approach</summary>

Declare the variable in the function body, before you build the closure, and
let the closure refer to it. The closure captures the variable rather than
copying its value, which is what makes the total survive between calls.
</details>

<details><summary>Hint 3, the API to look up</summary>

For exercise 1, `String.split(separator:)` and its `omittingEmptySubsequences`
parameter, then `uppercased()` and `joined(separator:)`. For exercise 6,
`Dictionary` keyed by `String`, and `keys.sorted()`.
</details>

## Retrieval checkpoint

Answer in writing first, then check the four runnable ones with Swift.
Nothing here has a committed answer.

1. Write two functions named `send` that differ only in argument labels.
   Predict whether the file compiles, then whether `send` alone is usable as a
   value.
2. Given `func f(_ a: Int, b: Int = 2, c: Int...)`, which of `f(1)`,
   `f(1, c: 3, 4)`, and `f(1, b: 2, c: [3])` compile?
3. A closure captures a local `var`, the function returns, and the closure is
   still alive. Where does that variable live now, and what in the signature
   said so?
4. Replace `@autoclosure` with a plain `() -> Int` parameter in exercise 5 and
   fix every call site. What did the caller have to write instead?
5. Judgment, no single right answer. `inout` and returning a new value can
   both express "change this". Name a case where `inout` is clearly right,
   then argue the general default, and say what your choice costs.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Read SE-0111, "Remove type system significance of function argument labels",
  in <https://github.com/swiftlang/swift-evolution/tree/main/proposals>. It
  argues why labels belong to the name and not to the type.
- Add a fifth block to `probes/capture.swift` capturing one variable in two
  closures, and predict whether they share it.
- Find three standard library functions taking `@autoclosure`.

## Done when

- [ ] `swift test --filter Chapter02Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] No force unwrap survives in my solutions:
      `grep -nE '[A-Za-z_)\]]!' modules/02-functions/exercises/*.swift` prints nothing

Capture lists, `[weak self]`, and the reference cycle that makes them
necessary are chapter 10. They are only visible once a type has identity, and
nothing in this chapter has any.
