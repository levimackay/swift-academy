---
project: 05
slug: 05-event-bus
title: Event Bus
after_chapter: 10-classes-and-arc
difficulty: 4 of 5
estimated_hours: 7
package: standalone (projects/05-event-bus/Package.swift)
---

# Project 05. Event Bus

## What you are building

A synchronous in process publish and subscribe bus that does not keep its
subscribers alive. Any object can subscribe to an event type with a handler, gets
a token back, and receives every event published afterward. When that object is
released by everything else in the program, it deallocates immediately, its
handler stops being called, and the bus reclaims the slot. When it is done,
`swift test` is green, and the test that proves it works is not an assertion
about behavior but an assertion about memory: a subscriber created inside a scope
has its `deinit` run when that scope ends, while the bus is still alive and still
holding a registration for it. Every naive implementation, and every
implementation where a closure captures `self` without thinking, fails that test.

This is the first project where you write classes on purpose, and you must be
able to justify each one with one of the three permitted reasons.

## What this project forces you to use

| Concept | Chapter |
|---|---|
| `weak` storage, and what a weak reference reads as after deallocation | `10-classes-and-arc` |
| Capture lists, `[weak self]`, and the unowned decision | `10-classes-and-arc` |
| `deinit` as observable evidence, not as a cleanup habit | `10-classes-and-arc` |
| Class identity, `===`, and `ObjectIdentifier` as a key | `10-classes-and-arc` |
| The three reasons a class is allowed, applied to each type you write | `10-classes-and-arc` |
| Generic event types and the `some` versus `any` decision at the registry | `07-generics` |
| Type erasure over heterogeneous handlers | `07-generics`, `04-protocols` |
| `throws(E)` or optional for a publish to a dead subscriber, decided | `08-errors` |
| Value semantics for the events themselves | `03-value-semantics` |

## Functional requirements

1. An event is a value type. The bus is generic or type keyed over event types,
   so subscribing to event `A` never delivers event `B`.
2. Subscribing takes an event type, an owner object, and a handler, and returns a
   token.
3. Publishing an event calls every live handler subscribed to that event type,
   synchronously, before `publish` returns.
4. The bus holds no strong reference to any subscriber owner. A subscriber whose
   only other reference goes out of scope deallocates at end of scope.
5. `deinit` on a subscriber runs even while the bus is alive and its registration
   has not been explicitly removed.
6. After a subscriber deallocates, publishing does not call its handler and does
   not crash.
7. Dead registrations are reclaimed. After a subscriber deallocates, the bus's
   count of registrations for that event type drops, either eagerly or on the
   next publish. Say which and why.
8. Unsubscribing with a token removes exactly that registration and no other,
   including when the same owner subscribed twice to the same event.
9. Unsubscribing with a token twice is safe and is not an error the caller must
   handle.
10. Handler invocation order for a single event type is deterministic and
    documented (registration order is the obvious choice, and it is a choice).
11. A handler that subscribes or unsubscribes during a publish must not corrupt
    the in flight iteration, and the new subscription must not receive the event
    currently being delivered.
12. A handler that publishes another event during a publish must terminate rather
    than recurse forever, or must be documented as the caller's problem, with a
    test that pins whichever you chose.
13. The bus itself can be deallocated while tokens are still held, and using a
    stale token afterward is safe.
14. There is a way to ask the bus how many live subscribers exist for an event
    type, for tests and diagnostics.

## Non-goals

- No thread safety. Not one lock, not one queue, not one actor. Chapter 11 is
  next and it will make you revisit this on purpose.
- No `async` handlers, no `AsyncSequence`, no `Combine`, no `NotificationCenter`
  bridging.
- No event history, replay, or buffering for late subscribers.
- No priorities, no filtering predicates, no wildcard subscriptions.
- No `NSMapTable`, no `NSHashTable`, no Objective C collections. The point is to
  build the weak container, not to import one.
- No cross process or cross module dispatch.

## Architecture: constraints and questions

**Every class in this project needs a written justification.** One of: an
observable lifecycle, shared mutation seen through two references, or inheritance
and interop. Write it as a comment on the declaration. If you cannot pick one,
the type wants to be a struct.

- Swift has no built in weak collection. What does an array of a small struct
  that holds one `weak var` give you that `[Subscriber]` does not, and what does
  it cost when the array grows?
- A handler closure will want to touch the subscriber. If the bus stores that
  closure, and the closure captures the subscriber strongly, requirement 4 is
  dead no matter how weak your storage is. Where exactly does `[weak owner]` have
  to appear, and can your API make it impossible to get wrong rather than
  documented as a rule?
- Consider a shape where the handler takes the owner as a parameter instead of
  capturing it. What does that buy, and what does it cost in ergonomics? Try both
  and keep the one you can defend.
- The bus is heterogeneous: many event types, one registry. A dictionary keyed by
  what, holding values of what type? `any` shows up here for a real reason.
  Name it.
- Requirement 8 needs token identity. A token that is a class instance, a token
  that is a `UUID`, and a token that is an `ObjectIdentifier` are three different
  designs with three different lifetimes. Which of them can accidentally keep
  something alive?
- Requirement 13 says a token outliving the bus must be safe. That means the
  token either does not reference the bus, or references it weakly. Which did you
  do, and what does `unsubscribe` on an orphaned token now mean?
- Requirement 11 is the classic mutation during iteration bug. Copying the
  registration list before dispatch fixes iteration. Does it also satisfy the
  "must not receive the in flight event" half? Check both halves separately.
- If you add a `deinit` to the token so that dropping the token unsubscribes
  automatically, you have built a very common and very convenient design. You
  have also created a way for a caller to lose their subscription by not storing
  the return value. Decide, and if you build it, put a `@discardableResult`
  decision in writing.
- Draw the object graph before you write the second type: bus, registration,
  token, owner, closure. Mark each arrow strong or weak. Every cycle you can see
  in that drawing is one you will not have to find with a `deinit` print
  statement at midnight.

### Scaffold honesty, and the pinned API

The test suite declares its own subscriber classes with `deinit` bodies that
record deallocation, because a test cannot observe ARC any other way. Those test
types are test fixtures, not part of your answer, and they pin your public API's
shape: whatever they call, you must provide with that spelling. That is stated
here rather than pretended away.

`Tests/EventBusTests/DeallocationTests.swift` is shipped, nine tests, and it
calls the names below. Right now the package does not build:

```text
error: cannot find 'Bus' in scope
```

That is the mechanism working, not a broken checkout.

The type is `Bus` and not `EventBus`, deliberately. The module is already
named `EventBus`, so `EventBus.EventBus` stutters at every use site, and the
Swift API Design Guidelines say not to repeat the module name in a type name.
There is a practical half too: a type sharing its module's name makes
`EventBus()` ambiguous before you have written it, and the compiler reports
`cannot call value of non-function type 'module<EventBus>'`, which explains
nothing. Worth knowing the first time you name a library's main type.

| Symbol | Shape |
|---|---|
| `Bus()` | no argument initializer |
| `subscribe(to:owner:handler:)` | takes `Event.Type`, an `AnyObject` owner, and `(Event) -> Void`, returns a token |
| `publish(_:)` | takes an event value, delivers synchronously |
| `unsubscribe(_:)` | takes a token |
| `subscriberCount(for:)` | takes `Event.Type`, returns `Int` |
| `SubscriptionToken` | the returned token type, whatever you make it |

Two things that pinning costs you, said out loud. The handler shape is fixed
as `(Event) -> Void`, so the "handler takes the owner as a parameter" variant
in the questions above is now something you argue in writing rather than
build. And requirement 13's stale token behavior is deliberately not pinned:
the suite asserts only that a token outliving the bus keeps neither the bus
nor the subscriber alive, so what `unsubscribe` on an orphaned token means is
still your decision.

Verified: with weak owner storage the suite is nine green tests, and changing
the single word `weak` to `let` in the registration makes three of them fail,
starting with `Expectation failed: (log.deallocations -> []) == ["scoped"]`.
That one word is the project.

## Milestones

1. **One event type, strong storage, working delivery.** Deliberately wrong on
   requirement 4. Get delivery correct first.
2. **The deallocation test goes red.** Write the failing test that proves your
   step 1 leaks. Look at it. This is the whole project in one assertion.
3. **Weak storage.** Make step 2 green for a single event type.
4. **Capture lists.** Now make it green when the handler actually uses the
   subscriber, which is when step 3's fix stops being enough.
5. **Multiple event types.** The heterogeneous registry and the type erasure it
   needs.
6. **Tokens and unsubscribe.** Requirements 8, 9, and 13.
7. **Reclamation and counting.** Requirements 7 and 14.
8. **Reentrancy.** Requirements 11 and 12, each with a pinning test.

## Definition of done

- [ ] `swift build` is clean with no warnings.
- [ ] `swift test` is green, including the deallocation suite, the double
      subscribe and single unsubscribe suite, the stale token suite, and the
      reentrancy suite.
- [ ] Every `class` in `Sources/` carries a one line justification comment naming
      one of the three permitted reasons.
- [ ] There is no retain cycle: a written object graph diagram exists in a
      comment or in this project's directory, with every arrow marked strong or
      weak.
- [ ] No force unwrap in `Sources/`.
- [ ] `NOTES/errors.md` records at least one diagnostic from this project
      verbatim.
- [ ] You can explain out loud, no notes, why a closure stored by the bus is the
      real owner of the leak, and why weak storage alone does not fix it.

## Stretch goals

Not required to advance.

- Add an automatic unsubscribe on token deallocation and measure how many test
  cases it simplifies versus how many footguns it adds.
- Add a debug description that prints the live registration table, including
  which slots are dead but not yet reclaimed.
- Write a test that creates ten thousand subscribers in a loop, drops them, and
  asserts the registry does not grow without bound.
- After chapter 11, come back and make the bus safe to use from more than one
  isolation domain. Note what had to change and what could not be fixed without
  changing the public API.

## Self-review before you call it finished

1. For each class I wrote, which of the three reasons applies, and would a
   skeptical reviewer accept it?
2. If I delete every `[weak ...]` in my code, which test fails first? If the
   answer is none, my tests do not test what I think.
3. Does any stored closure capture `self` implicitly? Search for `self.` inside
   closures and for the ones where Swift let me omit it.
4. Can a caller hold a token forever and leak nothing?
5. What happens if a subscriber deallocates in the middle of a publish, between
   two handler calls? Did I test that or assume it?
6. Is the count in requirement 14 counting live subscribers or registration
   slots? Are those ever different, and does the name say which?
7. If two different objects subscribe with identical handler closures, can I
   still tell their registrations apart?
8. Did I use `unowned` anywhere? Can I state the lifetime guarantee that makes it
   safe, or did I use it to silence a warning?
