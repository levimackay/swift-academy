---
title: Interview question bank
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Interview question bank

The questions iOS interviewers actually ask, organized by topic. Each entry has
the question, what a strong answer demonstrates, and the shape of the answer.
The shape names the moves the answer has to make. It does not make them.

## Why there are no model answers here

A written model answer is something you recognize, not something you can
produce. Reading one produces the feeling of knowing without the ability to
construct, and an interview tests construction under time pressure with someone
watching. So the conceptual questions ship as a scaffold you fill in out loud,
which is the same thing the exercises do and the same reason no answer key
exists on `main` anywhere in this repository.

Two other reasons this is not a compromise:

- Most of these have no single right answer. The good ones are trade off
  questions, and an interviewer is listening for whether you know what you are
  trading. A canned paragraph is detectable and it forecloses the follow up,
  which is the part of the conversation that actually scores.
- The factual questions are already answered, precisely, in
  [`docs/glossary.md`](glossary.md). Look the term up, then close the file and
  say it. Where a question is purely factual, the shape below points at the
  term rather than restating it.

The exception is the small number of questions marked **Check yourself** where
a claim is verifiable by running Swift. For those the toolchain is the answer
key, exactly as in the chapters.

## How to use it

Say the answer out loud, standing up, in under 90 seconds. Then say it again in
under 30. If you cannot compress it, you are reciting rather than modeling.
Anything you could not construct at all goes in the log at the bottom of
`PROGRESS.md` as the next concrete action, not into a flashcard pile.

Prepare one real code example per topic drawn from your own projects here. An
answer that ends with "I hit this in the event bus project and here is what the
test asserted" outscores a correct abstract answer, every time.

---

## 1. Value and reference semantics

### What is the difference between a struct and a class in Swift, and how do you choose?

**Demonstrates:** whether you have a decision rule or a preference. This is the
most common opening question for anyone arriving from a class first language,
and the interviewer is checking whether you brought your old default with you.

**Answer shape:** define the copy versus share distinction in one sentence.
Name the three reasons you would choose a class. Say which one is the default
and why. Close with a concrete case from your own code where you converted one
to the other and what broke.

### What is copy on write, and what does it cost?

**Demonstrates:** that you know value semantics is a guarantee about behavior,
not a statement about when memory is copied.

**Answer shape:** state what the guarantee is. State when the copy actually
happens and what the check is that decides. Then give the failure mode, which
is the performance cliff, and say what makes a linear loop become quadratic
without the code changing.

### `let` on a struct versus `let` on a class instance. What is immutable in each?

**Demonstrates:** that you understand `let` binds and does not freeze a heap
object.

**Answer shape:** two sentences, one per case, saying exactly what cannot
change. Then name the C# feature this is unlike and why. Follow up you should
expect: why `mutating` has to exist at all.

### Why can you not call a `mutating` method on a `let` value?

**Demonstrates:** whether you know `mutating` is a calling convention rather
than a label.

**Answer shape:** say what `self` becomes in a `mutating` method. Derive the
`let` restriction from that. Then name two further consequences that fall out
of the same fact.

**Check yourself.** Two variables hold the same array. One appends. What is the
memory behavior before and after the append?

Write it, print `isKnownUniquelyReferenced` on your own copy on write box, and
watch the branch.

---

## 2. ARC, retain cycles, and lifetime

### How does memory management work in Swift?

**Demonstrates:** that you know there is no tracing collector and that you
understand what follows from that.

**Answer shape:** say when the retain and release calls are inserted and what
that buys you in determinism. Then say the thing that determinism costs you,
which is the one category of garbage that is never collected. Do not describe
ARC as garbage collection.

### What is a retain cycle, and how do you find one you did not predict?

**Demonstrates:** debugging practice, not vocabulary. Everyone can define a
cycle. Fewer can say how they detected one.

**Answer shape:** define the cycle in one sentence. Then describe detection, in
two layers: the cheap evidence you can get from a test, and the tool you reach
for when that is not enough. Name the specific closure shape that causes most
of them in practice.

### `weak` versus `unowned`. When is `unowned` actually correct?

**Demonstrates:** whether you learned the real rule or the folk rule that
`unowned` is a faster `weak`.

**Answer shape:** contrast three properties, not one: optionality, what happens
at deallocation, and the storage cost. Then state the single condition that has
to hold before `unowned` is safe. Say what happens if that condition is
violated, precisely, since it is not a crash of the usual kind.

### What does `[weak self]` do, and when does it not help?

**Demonstrates:** that you know a capture list is a set of edges evaluated at
closure creation, not a general safety incantation.

**Answer shape:** say when the capture list expressions are evaluated.
Distinguish the `weak self` entry from a value snapshot entry, since they
behave differently. Then name a case where adding `[weak self]` fixes nothing,
which is the part that separates a memorized answer from an understood one.

### Why does `@escaping` exist?

**Demonstrates:** that you connect closure lifetime to both performance and
cycles.

**Answer shape:** say what the compiler is allowed to do when a closure is non
escaping. Say what changes when it escapes. Then connect it to the previous
question in one sentence, because the interviewer is usually walking you toward
it.

**Check yourself.** Build the two object cycle, put a `print` in both
`deinit`s, and prove nothing is printed. Then break it and prove it is.

---

## 3. Protocol oriented design

### How is a Swift protocol different from a C# interface?

**Demonstrates:** the single highest value distinction for a candidate with
your background. Getting this right signals you did not translate your old
model.

**Answer shape:** name the primary role of a protocol first, before mentioning
the role that resembles an interface. Say what the compiler can do in the
primary role that it cannot do in the other one. Then name two things Swift
protocols do that C# interfaces cannot, and one thing C# interfaces do that
Swift's do differently.

### What is protocol oriented programming and when is it the wrong tool?

**Demonstrates:** judgment. Candidates who only rehearsed the conference talk
cannot answer the second half, and the second half is the question.

**Answer shape:** state the composition over inheritance argument in one
sentence, then spend the rest of the answer on the limits: where a protocol
adds a layer for nothing, where inheritance is genuinely the right model, and
what a large protocol hierarchy costs a reader. Close with what you personally
use as the trigger to introduce one.

### Protocol extension dispatch

A method is declared in a protocol extension but not in the protocol itself. A
conforming type defines its own version. Which one runs?

**Demonstrates:** knowledge of static versus dynamic dispatch through a witness
table. This is the classic gotcha and it does show up in real bugs.

**Answer shape:** answer that it depends on the static type of the reference,
then say which case gives which result. Explain the mechanism in one sentence.
Then say what you change to make it dispatch the way people expect.

### What is conditional conformance and why would you need it?

**Demonstrates:** that you can express a constraint the C# type system cannot
express at all.

**Answer shape:** give the declaration form. Give one standard library example
everyone knows. Then say what the alternative would be in a language without
it.

### When would you extend a type you do not own, and what is the risk?

**Answer shape:** name a legitimate use. Then name the collision problem and
the attribute the compiler now asks you to write, and say why the compiler
cannot resolve the conflict for you.

---

## 4. Generics, `some`, and `any`

### What is the difference between `some P` and `any P`?

**Demonstrates:** whether you have the right axis. The weak answer is a
performance answer. The strong answer is a type system answer, and performance
is a consequence of it.

**Answer shape:** state what happens to type identity in each case, and who
chooses the concrete type. Give the observable consequence that follows:
something you can do with two values of one form and cannot do with two of the
other. Only then mention cost, and say what the cost actually is rather than
saying "dynamic dispatch".

### What does `any P` cost at runtime?

**Demonstrates:** whether "existential" is a word you use or a layout you
understand.

**Answer shape:** describe the box: how many slots, what each one holds. State
the size threshold that decides whether the value is inline or heap allocated,
and say what that means for a copy. You can verify the number with
`MemoryLayout`, so verify it once and quote it.

### Why can a protocol with an associated type be awkward to use, and what changed?

**Demonstrates:** that your knowledge is current. Material written before Swift
5.7 says this is simply illegal, and repeating that in 2026 dates you
immediately.

**Answer shape:** say what an associated type makes a protocol (not a type).
Say what the old restriction was. Say what is legal now and what is still
limited about it. Then name the two ways to recover the associated type when
you need it.

### When do you reach for a generic and when for an existential?

**Answer shape:** give the default and the reason. Then give the concrete
signal that flips you to the other one, which is usually about heterogeneity in
storage. Mention that this repo makes every existential site spelled out, and
what habit that builds.

### What is type erasure and do you still need to hand write erasers?

**Answer shape:** define it in one sentence, name a standard library example,
and then give the honest current answer about how often you would write one
yourself now.

---

## 5. SwiftUI state and identity

### Walk me through `@State`, `@Binding`, `@Environment`, and `@Bindable`.

**Demonstrates:** whether you understand ownership. Most candidates list them.
Fewer say who owns the storage in each case.

**Answer shape:** for each, answer one question in one sentence: who owns the
value. Then say what the `$` prefix actually gives you and where it comes from
mechanically. Close by saying which one you would use for a model object the
view creates itself, which is the follow up they are heading for.

### What is view identity and why does it matter?

**Demonstrates:** the concept that separates people who have shipped SwiftUI
from people who have followed tutorials. Almost every mysterious state bug is
an identity bug.

**Answer shape:** distinguish the two kinds of identity. Say what is attached
to identity and therefore what is destroyed when identity changes. Give the two
symptoms you see in a real app, which are opposites of each other. Then name
the two places you control identity explicitly.

### A view's `body` runs more often than you expect. Is that a bug?

**Answer shape:** say what `body` is and what that implies about how cheap it
must be and what it must not do. Then separate the acceptable case from the
real bug, and say what you would look at to tell them apart.

### How does `@Observable` know which views to update?

**Demonstrates:** that you can explain SwiftUI's dependency tracking as a
mechanism rather than as magic. This is a strong differentiator because you can
describe the generated code.

**Answer shape:** say what the macro rewrites a stored property into. Name the
two calls the accessors make and what records them. Then state the observable
payoff: what happens to a view that never read a given property when that
property changes. Contrast in one line with what the older mechanism did
instead.

### How would you structure state in a SwiftUI app? Do you use MVVM?

**Demonstrates:** that you have vocabulary for the modern answer and are not
just unaware of the old one. Answering "I do not use MVVM" without naming what
you do instead reads as a gap.

**Answer shape:** name what you own the state in and who holds it. Say what
survives from the MVVM idea and what does not follow from it. Say explicitly
what you do with the older `ObservableObject` stack when you meet it in an
existing codebase. Keep it to one paragraph, because this is a question people
ramble through.

**Check yourself.** Put a `print` in a body, move a stateful subview between
the branches of an `if`, and watch the state reset. Then make it survive.

---

## 6. Concurrency and data races

### What does an `actor` guarantee, and what does it not?

**Demonstrates:** the single most useful distinction in this section, and the
one a candidate from C# reliably gets wrong.

**Answer shape:** state the guarantee using the precise term for the class of
bug it eliminates. Then state the class of bug it does not eliminate, using the
other precise term. Give the canonical example where an actor is perfectly
correct and the program is still wrong. Do not say an actor is a lock.

### What is actor reentrancy?

**Demonstrates:** whether you can reason about suspension points, which is
where real concurrency bugs live.

**Answer shape:** say what happens to the actor at an `await` inside one of its
own methods. Say why the alternative design was rejected. Then state the
practical rule this forces on every method you write that awaits, and name the
bug you get when you forget it.

### What is `Sendable` and why do structs usually get it for free?

**Demonstrates:** the link between value semantics and concurrency safety,
which is the spine of the whole language design.

**Answer shape:** define what the conformance asserts. Explain why a struct of
`Sendable` parts can have it derived, in terms of what copying does to storage.
Then list the honest ways a class can get it, and say what `@unchecked` really
means about who is responsible.

### Why does the same line compile in one function and fail in another?

**Demonstrates:** current knowledge. This is region based isolation, and a
candidate who cannot explain it will describe Swift 6 diagnostics as arbitrary.

**Answer shape:** name the analysis and say what it groups values into. Say the
exact condition that makes the transfer legal. Then say what makes a region
grow, and add the tooling caveat about which compiler phase reports it and what
that means for your editor.

### `Task { }` versus `Task.detached { }`.

**Answer shape:** list what each inherits, in three items. Say which is the
default choice and why the other one is the source of `Sendable` errors people
then work around incorrectly. Give the narrow case where detached is right.

### How does cancellation work?

**Demonstrates:** that you know cancellation is cooperative and does not stop
anything by itself. This one transfers cleanly from C#, so say so.

**Answer shape:** say what `cancel()` actually does. Say what your code has to
do for it to mean anything, naming both the check and the throwing check. Say
how it propagates through structured children and where it stops.

### Compare `async let`, a task group, and an unstructured task.

**Answer shape:** organize by lifetime, since that is the axis that matters.
Say which of the three bounds the child to the enclosing scope. Then say what
error propagation does in the group case when one child throws.

### Why can you not just block and wait for an async result?

**Answer shape:** name the pool and its defining property. Say what blocking
one of its threads does to the task you are waiting on. Then name the two C#
habits that do not port and say what replaces them.

---

## 7. App architecture

### Describe the architecture of an app you built. Why that way?

**Demonstrates:** everything. This is usually the question the whole interview
hinges on, and the specificity of the trade offs you name is what gets scored.

**Answer shape:** open with the constraint that drove the design, not with a
diagram. Describe the layers with one sentence each and name the boundary
between the domain model and the framework. Say what you would do differently,
concretely, and why. Have the capstone in this repo ready, since it is code you
can defend line by line.

### How do you make a view model or a store testable?

**Answer shape:** name the dependency that would otherwise make the test slow
or flaky, and name the seam you injected in its place. Say what the test
asserts, including the failure path, not only the success path. Say where
isolation lives in that design and why it does not prevent the test from
running.

### How do you handle navigation?

**Answer shape:** say what navigation state is represented as, and what that
representation makes possible that a view based push does not. Name the two
features that fall out of it for free. Then say where that state is owned.

### How do you decide what to persist and how?

**Answer shape:** separate the three tiers of state by lifetime and size, and
say what you would use for each. Name the current framework and what its API is
built out of. Then give the caveat about coupling the view tree to the store,
and say when you would still choose the older framework.

### What is the difference between Core Data and SwiftData, and when would you still pick Core Data?

**Demonstrates:** literacy about the codebase you would be hired into, since
the large ones are years old.

**Answer shape:** describe the newer one as a response to the older one rather
than as a replacement. Explain what a fault is and what a context is, since
those are the terms they will use. Then give the honest reasons a team stays on
the older framework, which is the part that shows you are not just repeating
marketing.

### How do you test an iOS codebase, and what do you not test?

**Answer shape:** name the framework you use and one thing about its execution
model that changes how you write tests. Say what you push into a testable layer
to avoid needing a UI test. Then state what you deliberately do not test and
why, since an answer with no boundary reads as inexperience.

---

## 8. Language mechanics they use as warm ups

Short answers expected. If the term alone does not trigger a fluent 20 seconds,
look it up in the glossary and try again tomorrow.

| Question | What it demonstrates |
| --- | --- |
| What is an `Optional`, at the type level? | Whether you say "enum with two cases" or "a wrapper" |
| List the ways to get a value out of one, and when each is right | Breadth beyond `if let`, and the judgment about `!` |
| Why is `String` not integer indexable? | Understanding of graphemes, not a complaint |
| `map` versus `compactMap` versus `flatMap` | Precision about what each one flattens or drops |
| When is `map` on an array lazy? | Knowing the default is eager, unlike LINQ |
| What does `defer` do, and how does it differ from `finally`? | Scope versus block, and reverse ordering |
| `throws` versus `Result` versus a nil return | A stated rule for choosing per API |
| What are typed throws and what do they buy you? | Current knowledge, and exhaustive `catch` |
| Why model state as an enum with associated values? | Exhaustiveness, and illegal states being unrepresentable |
| What does `@unknown default` mean and when is it wrong? | Library evolution, and not using it on your own enums |
| What is a macro and how is it different from reflection? | Compile time expansion, inspectable, no runtime cost |
| Why is `Dictionary` iteration order not stable? | Per process hash seeding, not a bug |
| What does `final` change? | Devirtualization, and default overridability |

---

## 9. Live coding prompts

Given without solutions, for the same reason. Do them in a blank file with
`swift test`, not in your head.

- Implement a generic `Deque` conforming to `Sequence` and
  `ExpressibleByArrayLiteral`.
- Implement an LRU cache with O(1) get and set, and say what you chose for
  storage and why.
- Given a JSON fixture with a null, a missing key, two date formats, and an
  unrecognized enum value, decode it into strict domain types without failing
  the document.
- Write a registry that holds subscribers weakly and prove with a test that a
  subscriber deallocates after leaving scope.
- Fetch three independent resources concurrently, fail fast if any fails, and
  cancel the rest.
- Take a synchronous callback API and expose it as an `AsyncSequence`.
- Take a piece of code with a data race and make the compiler prove it is gone.
  Say which fix you chose and what it cost.
- Debounce a text field's input and cancel the in flight request when the text
  changes.

For each one, be ready for the same two follow ups: what would break under
concurrency, and how would you test it.
