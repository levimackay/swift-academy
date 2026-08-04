---
title: Keyword and concept ownership
kind: specification
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Which chapter owns what

Two tables and a rule. This file is how the three concept budget in
[how-this-repo-works.md](how-this-repo-works.md) is checkable rather than
aspirational.

**The rule: a keyword is owned by exactly one chapter.** The owning chapter is
where it is introduced, explained, and exercised. Any other chapter that
mentions it either previews it with a forward pointer or recalls it with a
backward one, and either way does not teach it a second time. A pull request
that teaches an owned keyword in a chapter that does not own it is rejected,
because two authorings of one idea drift, and the second one is the wrong one
by the time anyone notices.

---

## 1. Concept budget

Three core concepts per chapter, declared in the chapter's front matter, drawn
from this column. If a chapter needs a fourth, something moves out.

| # | Chapter | The three concepts it owns |
|---|---|---|
| 01 | 01-optionals | `Optional<Wrapped>` is an enum; unwrapping is pattern matching and each form states a control flow contract; optionals nest |
| 02 | 02-functions | argument labels are part of the name; functions and closures are values; escaping and capture |
| 03 | 03-value-semantics | copy versus share; `mutating` and what `let` freezes; copy on write |
| 04 | 04-protocols | constraints instead of inheritance; extensions including retroactive conformance; witness dispatch versus extension dispatch |
| 05 | 05-enums | payloads make an enum a sum type; exhaustive `switch` with no default; destructuring with `if case` and `guard case` |
| 06 | 06-collections | choosing a collection is choosing an `Index` and an `Element`, including `String`; the transformation chain; eager versus `lazy` |
| 07 | 07-generics | generic types with constraints; `some` versus `any`; associated types and primary associated types |
| 08 | 08-errors | the nil versus `throws(E)` versus `Result` decision; typed throws; propagation and `defer` |
| 09 | 09-codable | synthesis and where it stops; `CodingKeys` and custom `init(from:)`; the data boundary and typed decoding errors |
| 10 | 10-classes-and-arc | reference semantics and identity; ARC as deterministic ownership and `deinit`; capture lists and reference cycles |
| 11 | 11-isolation | `Sendable` as a type constraint; `actor` and `@MainActor` and `nonisolated`; region based isolation and `sending` |
| 12 | 12-async-await | structured concurrency and the task tree; `async let` and `TaskGroup`; cooperative cancellation |
| 13 | 13-swiftui-state | view as a function of state; state ownership and single source of truth; view identity |
| 14 | 14-swiftui-app | value based navigation as state; dependency injection seams; SwiftData as the persistence layer |

Chapter 03 also carries a short forward preview of `Sendable` and no actor
vocabulary, because strict concurrency is ambient on this toolchain and the
diagnostics arrive whether or not the syllabus is ready. That preview is not
one of chapter 03's three concepts. If chapter 03 runs long, the preview moves
wholesale to chapter 11.

---

## 2. Anchor language

Exactly one anchor per chapter, named in front matter, assigned here and
nowhere else. A chapter never carries both comparison sections. At most two
rows inside a comparison table may cite the non anchor language, and only
where it diverges enough to matter.

| Chapter | Anchor | Why that one |
|---|---|---|
| 01-optionals | csharp | Nullable reference types are the near miss worth dissecting. Python has only an annotation nobody reads. |
| 02-functions | python | Keyword arguments and default arguments map directly onto argument labels. C# optional parameters do not. |
| 03-value-semantics | csharp | `struct` in C# is the closest analogue in either language and it is wrong in instructive ways. |
| 04-protocols | csharp | `interface` is the schema to correct. Duck typing has no compile time story to compare against. |
| 05-enums | csharp | The lesson is why C# reaches for nullable fields and sealed hierarchies where Swift writes one enum. |
| 06-collections | python | `list`, `dict`, `set`, comprehensions, and generators are a closer fit than LINQ, and generators versus `lazy` is the sharpest row in either bridge. |
| 07-generics | csharp | Reified generics versus witness tables is the single highest value comparison in the chapter. |
| 08-errors | csharp | Exceptions, checked call sites, and `TryParse` are all C# shaped questions. |
| 09-codable | python | `json.loads` into dicts and pydantic are what the learner reaches for, and both make the wrong shape here. |
| 10-classes-and-arc | csharp | GC versus ARC and finalizers versus `deinit` is the chapter. CPython refcounting appears as two rows. |
| 11-isolation | csharp | `SynchronizationContext` and `ConfigureAwait` are the habits being replaced. |
| 12-async-await | csharp | C# `Task` versus Swift `Task` is the most load bearing single comparison in the course. |
| 13-swiftui-state | csharp | WPF with MVVM and `INotifyPropertyChanged` is a real analogue that inverts at exactly one point. |
| 14-swiftui-app | csharp | DI containers, EF Core, and the MVVM conversation are all C# vocabulary the interview will use. |

Eleven C#, three Python. [bridge.md](bridge.md) section 7 and
[bridge-python.md](bridge-python.md) section 5 partition the chapters along
this table: a chapter appears as owned in exactly one of them, and as a
reference row in the other.

---

## 3. Keyword ownership

Alphabetical inside each group. The owning chapter is where the keyword is
taught.

### Declarations and types

| Keyword or symbol | Owner |
|---|---|
| `actor` | 11-isolation |
| `associatedtype` | 07-generics |
| `class` | 10-classes-and-arc |
| `deinit` | 10-classes-and-arc |
| `enum` (no payload) | 01-optionals |
| `enum` (with payload) | 05-enums |
| `extension` | 04-protocols |
| `final` | 10-classes-and-arc |
| `func` | 02-functions |
| `indirect` | 05-enums |
| `init`, `init?`, `init(from:)` | 01-optionals, 05-enums, 09-codable |
| `lazy var` | 06-collections |
| `let` and `var` | 01-optionals |
| `mutating` and `nonmutating` | 03-value-semantics |
| `protocol` | 04-protocols |
| `struct` | 03-value-semantics |
| `subscript` | 06-collections |
| `typealias` | 07-generics |
| `~Copyable` | reference.md, not taught |

### Control flow and pattern matching

| Keyword or symbol | Owner |
|---|---|
| `case`, `default` | 05-enums |
| `defer` | 08-errors |
| `guard`, `guard let` | 01-optionals |
| `guard case`, `if case` | 05-enums |
| `if let` | 01-optionals |
| `switch` (exhaustive, over an enum) | 05-enums |
| `where` (in a pattern) | 05-enums |
| `where` (in a generic constraint) | 07-generics |

### Optionality and failure

| Keyword or symbol | Owner |
|---|---|
| `?` and `!` as type sugar | 01-optionals |
| `??` | 01-optionals |
| `?.` optional chaining | 01-optionals |
| `catch` | 08-errors |
| `Error` and `LocalizedError` | 08-errors |
| `Result<Success, Failure>` | 08-errors |
| `rethrows` | 08-errors |
| `throw`, `throws`, `throws(E)` | 08-errors |
| `try`, `try?`, `try!` | 08-errors |

### Generics and abstraction

| Keyword or symbol | Owner |
|---|---|
| `any` | 07-generics |
| `Comparable`, `Equatable`, `Hashable` | 04-protocols |
| `opaque return types`, `some` | 07-generics |
| `primary associated types`, `Collection<Int>` | 07-generics |
| `Self` requirement | 07-generics |
| `Sequence`, `Collection`, `IteratorProtocol` | 06-collections |

### Concurrency

| Keyword or symbol | Owner |
|---|---|
| `@MainActor` and global actors | 11-isolation |
| `@Sendable` on a closure | 11-isolation |
| `async`, `await` | 12-async-await |
| `async let` | 12-async-await |
| `AsyncSequence`, `AsyncStream`, `for await` | 12-async-await |
| `isolated` and `nonisolated` | 11-isolation |
| `Sendable` | 11-isolation, previewed in 03-value-semantics |
| `sending` and region based isolation | 11-isolation |
| `Task`, `Task.detached` | 12-async-await |
| `Task.checkCancellation()`, `Task.isCancelled` | 12-async-await |
| `TaskGroup`, `withTaskGroup` | 12-async-await |
| `withCheckedContinuation` | legacy-swift.md, not taught |

### Strings and text

| Keyword or symbol | Owner |
|---|---|
| `Character` as a grapheme cluster | 06-collections |
| `String` | 06-collections |
| `String.Index` | 06-collections |
| `Substring` | 06-collections |
| the four views: `characters`, `unicodeScalars`, `utf8`, `utf16` | 06-collections |
| normalization forms and `localizedStandardCompare` | strings.md, not taught |
| `Regex` and regex literals | strings.md, not taught |
| `StringProtocol` | strings.md, not taught |

### Serialization

| Keyword or symbol | Owner |
|---|---|
| `Codable`, `Decodable`, `Encodable` | 09-codable |
| `CodingKey`, `CodingKeys` | 09-codable |
| `DecodingError` | 09-codable |
| `JSONDecoder`, `JSONEncoder` | 09-codable |
| `KeyedDecodingContainer`, nested containers | 09-codable |

### Memory

| Keyword or symbol | Owner |
|---|---|
| `===` and `!==` | 10-classes-and-arc |
| capture lists `[weak self]`, `[unowned self]`, `[x]` | 10-classes-and-arc |
| `@escaping` | 02-functions |
| `unowned` | 10-classes-and-arc |
| `weak` | 10-classes-and-arc |

### SwiftUI and app

| Keyword or symbol | Owner |
|---|---|
| `@Bindable` | 13-swiftui-state |
| `@Binding` | 13-swiftui-state |
| `@Environment` | 13-swiftui-state |
| `@Model`, `#Predicate`, `ModelActor` | 14-swiftui-app |
| `@Observable`, `withObservationTracking` | 13-swiftui-state |
| `@Query` | 14-swiftui-app |
| `@State` | 13-swiftui-state |
| `.id()` and view identity | 13-swiftui-state |
| `.task` versus `.onAppear` | 13-swiftui-state |
| `NavigationStack`, `NavigationPath`, `navigationDestination` | 14-swiftui-app |
| `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject` | legacy-swift.md, recognised in 13 |
| `View`, `body`, `some View` | 13-swiftui-state |

### Access control

`public`, `internal`, `private`, `private(set)`, `fileprivate`, `package`, and
`@testable` are used throughout the exercises and are currently owned by
nothing. That is a known gap: see item 12 in
[ROADMAP-NEXT.md](ROADMAP-NEXT.md). Until it is closed, treat them as reading
knowledge and do not build an exercise that turns on them.

---

## 4. Terminology, pinned

Lint for the banned synonym, not for the preferred word.

| Use | Never |
|---|---|
| Chapter, for a numbered unit under `modules/` | Module, in prose. The directory keeps the name because one directory is one Swift module. |
| Exercise, for a stub in `exercises/` | Problem, kata, challenge |
| Drill, only for an entry in `drills/` | Exercise, quiz |
| Project, only for a directory under `projects/` | Assignment, lab |
| Force unwrap, two words | Force-unwrap |
| Model type, or state type | View model. The phrase is banned from target names and exercise descriptions. |
