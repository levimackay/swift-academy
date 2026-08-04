---
chapter: 08
slug: 08-errors
title: Errors, Typed Throws, and Result
anchor: csharp
concepts:
  - the nil versus throws(E) versus Result decision
  - typed throws
  - propagation and defer
requires: [01-optionals, 05-enums]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# 08. Errors, Typed Throws, and Result

## Cold open

Blank file, no notes: re-solve your chapter 06 drill before you read
anything below.

```bash
swift test --package-path drills --filter Ch06
```

## The question

Failure needs a channel and a language picks one. C# picked an out of band
channel: any call may raise, no signature says which, and the runtime walks
frames backwards hunting for a handler. That buys code which reads as though
nothing fails. It costs a program where you cannot tell by looking which line
leaves the function early, cannot enumerate what a call may produce, and pay
for a stack walk nobody budgeted. The question here is whether failure can
instead be an ordinary value on the ordinary return path, with the type
system keeping the books.

## Swift's answer

It can. `Error` is a protocol with no requirements of its own and no base
class, so a thrown value is a value of a type you designed. It does refine
`Sendable`, which chapter 11 cashes in. An enum is the usual shape,
because the failure set is then closed and the compiler can count it.

```swift
enum BuoyError: Error, Equatable {
    case offline
    case badRow(String)
    case stale(seconds: Int)
}
```

A function that can fail says so in its type, and typed throws names the one
type that can come out.

```swift
func windSpeed(fromRow row: String) throws(BuoyError) -> Int {
    let parts = row.split(separator: ",")
    guard parts.count == 2, let knots = Int(parts[1]) else {
        throw BuoyError.badRow(row)
    }
    return knots
}
```

Plain `throws` is the same feature spelled `throws(any Error)`, and `rethrows`
is its older narrow case: throws only if the closure you were handed throws.
Use `throws(E)` where the failure set is yours to close, plain `throws` at a
public boundary where adding a case later must not be a source break.

Absence, failure, and stored failure are three different jobs.

| Failure shape | Signature | Why |
|---|---|---|
| one reason, and the caller cannot use it | `-> Int?` | there is nothing to say beyond absent |
| several reasons the caller can act on | `throws(BuoyError)` | the set is named, closed, and exhaustive |
| the failure has to be stored or handed on | `Result<Int, BuoyError>` | a thrown error is not a value you can keep |
| an open set, across a module boundary | `throws` | that is `throws(any Error)` |

The caller marks every call, and the marker states the contract.

| Form | What you get | When it is right |
|---|---|---|
| `try f()` | propagation, unchanged, to your caller | your caller knows more than you do |
| `do { try f() } catch { }` | the error bound to `error` | you can actually do something |
| `try? f()` | `Int?`, the reason discarded | the reason genuinely does not matter |
| `try! f()` | a trap, and a dead process | almost never, same rule as `!` |

Typed throws pays off in `catch`, where the bound constant `error` has your
concrete type. A `switch` over it is exhaustive with no `default`, so adding a
case to `BuoyError` next quarter breaks every handler that stops covering it.

```swift
func retryDelay(after row: String) -> Duration? {
    do {
        _ = try windSpeed(fromRow: row)
        return nil
    } catch {
        switch error {
        case .offline: return .seconds(30)
        case .badRow: return nil
        case .stale(let seconds): return .seconds(seconds / 2)
        }
    }
}
```

Put in the error what a handler branches on, and nothing else. Reach for
`LocalizedError` only where a human reads the string.

`defer` schedules a block for scope exit by every path, including a throw, in
reverse order of declaration. The scope is the enclosing braces rather than the
enclosing function, which is why a `defer` in a loop body fires once per
iteration. `make probe CH=08 P=paths` runs four different exits past one
deferred block.

```swift
func sampleSpeed(_ row: String) -> Int? {
    print("open")
    defer { print("close") }
    guard let knots = try? windSpeed(fromRow: row) else {
        print("gave up")
        return nil
    }
    return knots
}
```

`Result` is that same information frozen into a value you can store, and
`get()` thaws it back into a throw.

```swift
let held: Result<Int, BuoyError> = .failure(.offline)
do { print(try held.get()) } catch { print(error) }
```

Thawing has a shortcut and freezing does not. A `Result { }` initializer
builds `Result<Int, any Error>` whatever you annotate, which is the
`invalid conversion of thrown error type` row in Where it goes wrong below,
so a typed failure is assembled by hand.

`async` and `throws` are independent axes composing as `try await`. An error
crossing an async boundary is still a returned value, so there is no stack to
unwind and the thread that resumes need not be the thread that suspended.

## Predict

Write your prediction in the comment above each snippet in
`probes/predict.swift`, then run `make probe CH=08 P=predict`. Three of the
four are below. The ones you get wrong are each a place where an error being
a returned value rather than an unwound exception changes the answer.

```swift
let parsed = try? windSpeed(fromRow: "buoy,12")
let failed = try? windSpeed(fromRow: "buoy")
print("1:", parsed as Any, failed as Any)          // 1

func trace() -> [String] {
    var marks = ["a"]
    defer { marks.append("b") }
    defer { marks.append("c") }
    return marks
}
print("2:", trace())                               // 2

func loop() {
    for n in 1...2 {
        defer { print("   close \(n)") }
        print("   open \(n)")
    }
}
loop()                                             // 3
```

## Coming from C#

### Where the analogy holds

| C# | Swift | Note |
|---|---|---|
| `throw new BuoyException()` | `throw BuoyError.offline` | both leave the function immediately |
| `try { } catch (Exception e) { }` | `do { } catch { }` | both bind the caught value, C# by name and Swift implicitly |
| `finally` | `defer` | both run on every exit path |
| `catch (FooException)` | `catch .badRow(let text)` | both select, one by class, one by pattern |

### Where it breaks

```csharp
static int Depth(string row) => row.Split(',')[1].Length;  // may throw, says nothing
static int Wrapper(string row) => Depth(row);              // silent conduit
```

| Claim | C# | Swift |
|---|---|---|
| the signature names failure | no, and the doc comment is unchecked | `throws(E)` is part of the function type |
| intermediate frames opt in | no, every frame is a conduit | every frame is marked or it does not compile |
| the call site is visible | no | `try`, and omitting it is an error |
| catching selects by | class hierarchy, plus `when` filters | pattern match, and typed throws makes it exhaustive |
| the cost model | a runtime stack walk on throw | a returned value, no walk, no frames revisited |

`catch (Exception)` exists because C# has a root class to catch by. Swift has
none, so a bare `catch { }` is the only catch all and catching everything is a
decision rather than a fallback. The same trade appears on the throwing side:
a C# method that adds an exception type breaks no build, while adding a case
to a typed throwing error breaks every exhaustive handler at compile time.
That break is the feature you are buying.

Full row set: [docs/bridge.md](../../docs/bridge.md).

## The model

```text
C#: one out of band channel, invisible in every signature

  caller ── calls ──▶  A  ── calls ──▶  B  ── calls ──▶  C   throw
     ▲                                                        │
     └──── runtime walks frames back, running finally ◀────────┘
           A and B declared nothing and get no say

Swift: the ordinary return path, marked at every single hop

  caller ◀── try ──  A  ◀── try ──  B  ◀── try ──  C   throw .offline
     ▲               ▲              ▲
     │               │              └ B is throws(BuoyError), or it
     │               │                does not compile
     │               └ A is throws(BuoyError), or it does not compile
     └ the error arrives the way a return value arrives
```

The picture is the cost model and the type model at once. Nothing is searched
for at runtime, so a throw costs about what a return costs and there is no
performance reason to keep one off a hot path. Propagation is not free at
compile time instead: every frame between the throw and the handler is named
in the type system, and every call site carries `try`.

## Where it goes wrong

Every row came from `make probe CH=08 P=errors`, a file that compiles as
written and carries each mistake commented out above the diagnostic it
produced. Blocks 9 through 12 in that file are four more, not tabled here.

| Diagnostic | What it means | Fix |
|---|---|---|
| `error: call can throw but is not marked with 'try'` | the call site marker is not optional, even inside a throwing function | add `try`, or `try?` if the reason is disposable |
| `error: errors thrown from here are not handled` | the call is marked and the enclosing function never signed up | mark it `throws(E)`, or wrap the call in `do catch` |
| `error: thrown expression type 'String' does not conform to 'Error'` | there is no root error class and no implicit conformance | declare an enum and conform it to `Error` |
| `error: thrown expression type 'WireError' cannot be converted to error type 'FuseError'` | typed throws means exactly that one type leaves | catch the inner error and throw one of your own cases |
| `error: errors thrown from here are not handled because the enclosing catch is not exhaustive` | your catches cover some cases of the typed error, not all | add the pattern, or a bare `catch` switching over `error` |
| `error: invalid conversion of thrown error type 'any Error' to 'ParseError'` | `Result { }` infers `any Error` whatever you annotate | build it from an explicit `do catch` instead |
| `error: 'return' cannot transfer control out of a defer statement` | `defer` runs during an exit already under way and cannot start a second | leave `defer` to cleanup only |
| `error: value of optional type 'Int?' not unwrapped; did you mean to use 'try!' or chain with '?'?` | `try?` changed the type of the expression, it did not suppress anything | unwrap it with `??`, `if let`, or `guard let` |

## Exercises

Stubs are in `exercises/Errors.swift`, in the order below. `shelfNumber(of:)`
at the top of that file is written for you, and is what exercises 2 through 6
call. Run `swift test --filter Chapter08Tests`.

1. `ticketCount(from:)` throws a distinct `TicketError` case for blank,
   unparseable, and out of range input.
2. `knownShelves(in:)` keeps the codes that resolve and drops the rest.
3. `shelfReport(for:)` gives success and each failure case its own line of
   text, with no `default` anywhere in it.
4. `auditedShelves(in:into:)` logs open, outcome, and close for every code,
   on the failing path as well as the succeeding one.
5. `shelfResults(for:)` returns one `Result` per code, keeping the failure.
6. `firstShelf(in:using:)` propagates whatever the lookup it was handed
   throws, touching no more of the array than it must.

<details><summary>Hint 1, a nudge</summary>

Exercise 4 is graded on the log. Read the expected log for a code that fails
and ask which entry has to appear even though the lookup did not return.
</details>

<details><summary>Hint 2, an approach</summary>

In exercise 4 the thing opened and closed is one code, not the array, so the
scope that has to end cleanly is one turn of the loop. In exercise 6 the
signature already says the error type is the caller's, so no concrete error
type belongs in the body.
</details>

<details><summary>Hint 3, the API to look up</summary>

`defer`, and its scope being the enclosing braces. For exercise 5,
`Result.success` and `Result.failure`. For exercise 6, `throws(E)` on a
generic parameter `E: Error`.
</details>

## Retrieval checkpoint

Answer in writing first, then check the four runnable ones with Swift.
Nothing here has a committed answer.

1. Two `defer` blocks in one body with a `throw` between them. Which run, and
   in what order?
2. `func f() throws(Never) -> Int`. Does a caller need `try`? Predict, then
   compile it.
3. `let x = try? windSpeed(fromRow: "buoy")` inside a function that already
   throws `BuoyError`. What is the type of `x`, and where did the error go?
4. A `do` block whose body cannot throw at all, with a `catch` attached.
   Predict the diagnostic before you compile it.
5. Judgment, no single right answer. A decoder fails for eleven distinct
   reasons and ships in a library other teams compile against. Argue for
   `throws(DecodeError)` or for plain `throws`, then name what the option you
   rejected would have cost you.

## Stretch

Not required to advance. Skipping all of it costs you nothing.

- Read SE-0413, "Typed throws", in
  <https://github.com/swiftlang/swift-evolution/tree/main/proposals>, for why
  plain `throws` did not simply become typed everywhere.
- Add a case to `BuoyError` in a scratch file and count what stops compiling.
  Do it again with plain `throws` and compare.
- Write a `LocalizedError` conformance for `TicketError` and see what
  `error.localizedDescription` prints with and without it.

## Done when

- [ ] `swift test --filter Chapter08Tests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
- [ ] Neither escape hatch survives in my solutions:
      `grep -nE '^[^/]*(try!|default:)' modules/08-errors/exercises/*.swift` prints nothing

Errors crossing an isolation boundary, and cancellation as a thrown error,
belong to [11-isolation](../11-isolation/README.md) and
[12-async-await](../12-async-await/README.md). The first row of the decision
table above is [01-optionals](../01-optionals/README.md), and the enum shape
every error type here uses is [05-enums](../05-enums/README.md).
