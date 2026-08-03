# Swift Academy

Learning Swift from the ground up, module by module, in order to build and ship
an iOS app.

Same format as `csharp-dsa-academy`: each module is a self-contained Swift
package with a lesson, stubbed problems, and a test suite. You implement against
the tests.

## Ground rules

1. **I type every line.** AI is a tutor, not an author. Hints, explanations, and
   review of code I already wrote — not generated implementations.
2. **No force unwrapping (`!`)** unless a module explicitly introduces it.
3. A module is done when its tests pass *and* I can explain the concept out loud
   without notes.
4. Solutions get committed after I solve them, never before.

## Curriculum

Modules 01–10 are pure Swift, run from the terminal with `swift test`. No Xcode
required — the language first, so the app later is only one new thing at a time.

| # | Module | Core idea | Closest thing you know |
|---|---|---|---|
| 01 | Values, Types, Optionals | absence is a type | C# nullable, but enforced |
| 02 | Functions & Closures | argument labels, first-class functions | Python lambdas / C# delegates |
| 03 | Structs vs Classes | value vs reference semantics | C# struct/class, sharpened |
| 04 | Protocols & Extensions | composition over inheritance | C# interfaces + extension methods |
| 05 | Enums & Pattern Matching | enums that carry data | nothing in Python/C# — this is new |
| 06 | Generics | constrained polymorphism | C# generics + where clauses |
| 07 | Collections & Transformations | map/filter/reduce, Sequence | Python comprehensions / LINQ |
| 08 | Error Handling | typed throws, Result | C# exceptions, but explicit |
| 09 | Memory & ARC | ownership, retain cycles, weak | C# GC, but deterministic |
| 10 | Concurrency | async/await, actors, Sendable | C# async/await, stricter |
| 11 | SwiftUI Fundamentals | declarative UI, state | React, if anything |
| 12 | Ship the App | Xcode → TestFlight → App Store | — |

## Running a module

```bash
cd modules/01-values-and-optionals
swift test
```

## Progress

See [PROGRESS.md](PROGRESS.md).
