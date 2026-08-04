---
project: 06
slug: 06-capstone
title: Capstone
after_chapter: 14-swiftui-app
difficulty: 5 of 5
estimated_hours: 35
package: Core is a standalone package (projects/06-capstone/Core/), App is an Xcode iOS project (projects/06-capstone/App/)
---

# Project 06. Capstone

## Two spec files, and which is which

This file, `SPEC.md`, is the course's and it is fixed: the shape of the
project, the requirements that hold whatever you build, the milestones, and
the definition of done. You do not edit it.

`CAPSTONE-SPEC.md`, in this same directory, is yours and it does not exist
yet. It holds the content: what your app is, its screens, its nouns, and your
own acceptance criteria. The section below is the template for writing it.

Two files, two authors, two names, one artifact between them. That is
deliberate, not a mistake somebody made naming things.

## What you are building

Your app. Not an exercise dressed as an app: the one you actually want on your
phone. This document does not say what it does, because you write that part. What
this document fixes is the shape: a `CapstoneCore` package containing your domain
types, your state model, and your persistence contract, tested with `swift test`
and never importing SwiftUI, plus an Xcode iOS app target that imports it and
contains only views, navigation, and wiring. When it is done, a signed build of
that app is installed on your own iPhone and you use it for a week without
rebuilding. App Store submission is a goal for after this course. It is not a
completion gate and it is not part of the definition of done.

## The spec you write

Before you start chapter 11, you write `CAPSTONE-SPEC.md` in this directory. Not
after chapter 14, when you are impatient to build. Before chapter 11, when you
still have four chapters of runway to notice that your idea is too big.

It must contain, in your own words:

1. **One sentence.** What the app does, for whom, in one sentence with no "and".
2. **The three screens.** Not five. Name them and say what each is for.
3. **The core domain nouns,** with the state each one can be in. If a noun has
   more than five states, it is two nouns.
4. **What is persisted and what is derived.** Anything derived that you were
   about to persist is a bug you have not written yet.
5. **The one thing that would make you use this daily.** If you cannot name it,
   pick a different app.
6. **The explicit cut list.** At least eight features you are not building in
   version one, written down so that adding one later is a visible decision.
7. **Done means.** Your own acceptance criteria, in addition to this document's.

Bring it to a review before chapter 11 starts. The review question is only ever
"what can be cut", never "what is missing".

## What this project forces you to use

Everything, but specifically:

| Concept | Chapter |
|---|---|
| `@Observable @MainActor final class` state, owned by `@State` | `14-swiftui-app` |
| Value based `NavigationStack` routing with a `Hashable` route type | `14-swiftui-app` |
| Dependency injection so the model is testable with no simulator | `14-swiftui-app` |
| SwiftData for persistence, with a migration plan written before shipping | `14-swiftui-app` |
| `@State`, `@Binding`, `@Bindable`, and view identity that survives insertion | `13-swiftui-state` |
| Modifier order and layout that does not break at large Dynamic Type | `13-swiftui-state` |
| `async let`, `TaskGroup`, and cancellation on every cancellable operation | `12-async-await` |
| Isolation placed deliberately, with `nonisolated` used for a stated reason | `11-isolation` |
| Typed errors surfaced to the user as something actionable | `08-errors` |
| Enums for state, protocols for boundaries, generics only where they earn it | `05-enums`, `04-protocols`, `07-generics` |
| Value semantics for the domain, classes only for the three permitted reasons | `03-value-semantics`, `10-classes-and-arc` |

## Functional requirements

These are in addition to whatever `CAPSTONE-SPEC.md` says.

1. `CapstoneCore` builds and its tests run with plain `swift test`, with no Xcode
   and no simulator.
2. `CapstoneCore` does not import SwiftUI, does not import UIKit, and does not
   import SwiftData outside a single persistence boundary file.
3. The app target contains no domain logic. Any calculation you would want to
   test lives in `CapstoneCore`.
4. App state is owned by an `@Observable` `@MainActor` `final class` held in
   `@State` at exactly one place in the view tree.
5. Every dependency the state model uses (persistence, clock, network, anything
   with a side effect) is injected, and there is a test double for each.
6. Navigation is value driven: a `Hashable` route type, a path array owned by the
   state model, and no `NavigationLink(isActive:)` anywhere.
7. Deep navigation state can be restored: pushing three screens, backgrounding,
   and relaunching returns you to a sensible place. You define sensible.
8. Persistence uses SwiftData, and `@Query` does not appear in any view more than
   one level below a screen root.
9. A schema migration path is written down before the first build lands on your
   phone, and there is a note saying what happens to existing data when the
   model changes.
10. Every operation that can fail surfaces a message a user could act on. No
    error is silently swallowed and no error shows a raw type name.
11. Every operation that can take longer than a moment shows progress and can be
    cancelled, and cancellation actually stops the work.
12. The app has a real empty state, a real loading state, and a real error state
    on every screen that can have them. Three screens times three states is a
    checklist, not a feeling.
13. All text scales with Dynamic Type up to the accessibility sizes without
    truncation or overlap.
14. Every control has an accessibility label, and no information is conveyed by
    color alone.
15. The app works in both light and dark appearance.
16. The app launches to first usable content in under two seconds on your own
    device.
17. There are no `print` statements in the shipped build path.
18. `CapstoneCore` has tests for every state transition in the state model,
    including the failure branch of every injected dependency.

## Non-goals

- No account system, no sign in, no server, unless your one sentence in
  `CAPSTONE-SPEC.md` is impossible without one. It usually is not.
- No push notifications, no widgets, no App Intents, no watch app, no iPad
  specific layout in version one.
- No CloudKit sync.
- No analytics SDK, no crash reporter, no third party dependency at all unless
  you can name what you would have to write yourself and how long it would take.
- No custom design system. Use the system components until the app exists.
- No App Store submission as part of finishing. It comes after, and
  `docs/shipping.md` covers it.
- No feature from your cut list. That is what the list is for.

## Architecture: constraints and questions

**The core must not import SwiftUI.** This is the load bearing constraint of the
whole project. Why does it matter here, when there is exactly one app and it is
a SwiftUI app? Answer that in writing in `CAPSTONE-SPEC.md`, because the answer
is what makes requirement 1 worth the friction.

- Where is the boundary between "domain value" and "SwiftData model"? Are they
  the same type, or does the persistence layer map between them? Both are real
  answers and they have different costs when the schema changes. Pick, and write
  the cost you accepted.
- Your state model is `@MainActor`. What in it is `nonisolated`, and why? If the
  answer is nothing, either you have no expensive work or you have not looked.
- Requirement 5 says every dependency is injected. Injected as a protocol
  existential, as a generic parameter, or as a struct of closures? Chapter 07 and
  chapter 14 both bear on this. Choose per dependency, not once globally, and say
  what drove each choice.
- Requirement 6 makes the path a value the model owns. That means a test can
  assert on navigation without a simulator. Does yours? If not, the path is in
  the wrong place.
- A route type that carries a whole domain value and a route type that carries an
  identifier behave differently when the underlying data changes while the screen
  is open. Which failure would your users notice, and which did you choose?
- Requirement 11 says cancellation actually stops the work. Cooperative
  cancellation only stops work that checks. Where do you check, and what happens
  to partially written persistence when you stop?
- Requirement 12 multiplies out to a table. Build the table before you build the
  views. Most of the states you were going to forget are the ones you cannot see
  from the happy path.
- If a type is a class, name which of the three permitted reasons applies. The
  state model has one of them. Most of your domain does not.
- Draw the isolation map once: what is `@MainActor`, what is an `actor`, what is
  `Sendable` and what merely never crosses a boundary. Chapter 11's diagram
  format works fine for this.

## Milestones

1. **`CAPSTONE-SPEC.md`, reviewed and cut, before chapter 11.**
2. **Core domain, no app.** Types, states, transitions, tests. `swift test` only.
   You should be able to play the entire app in tests before any view exists.
3. **State model with injected fakes.** Every dependency is a test double. Every
   state transition has a test, including failures.
4. **One screen, real.** Wire the app target to the core. One screen with its
   three states. No navigation yet.
5. **Navigation.** The route type, the path, all three screens reachable, tested
   at the model level.
6. **Persistence.** SwiftData behind the boundary, the migration note written,
   data surviving relaunch.
7. **Async and cancellation.** Requirement 11 wherever it applies.
8. **States and errors.** The full requirement 12 table, requirement 10
   everywhere.
9. **Accessibility and appearance.** Requirements 13 through 15, checked with
   VoiceOver on and text at the largest accessibility size.
10. **On device.** Signed build installed on your iPhone.
11. **The week.** Use it daily for seven days without rebuilding. Keep a list of
    what annoyed you. Do not fix any of it until the week is over.

### A note on milestone 11 and the seven day count

A provisioning profile signed with a free Apple ID expires in seven days. The
app stops launching, and the fix is to reconnect the phone and rebuild from
Xcode. So milestone 11 and the free tier collide exactly, and the collision
arrives on the last day of the milestone.

Two honest resolutions, and you pick one before day one rather than on day
seven:

1. **Hold an Apple Developer Program membership** by the time you reach this
   milestone. Profiles last a year and the milestone means what it says. This
   is 99 USD a year and it is also what TestFlight and the App Store need.
2. **Read the milestone as "reinstall on day seven and keep going"** and
   record that you did. The point of the week is finding out what annoys you
   in daily use, and one reinstall does not damage that.

Write which one you chose into `CAPSTONE-SPEC.md`. What is not acceptable is
discovering the expiry on day seven and calling the milestone failed, because
that is a provisioning fact rather than anything about your app.

The deeper version of this, including a real TestFlight round trip with one
external tester, is item 8 in
[../../docs/ROADMAP-NEXT.md](../../docs/ROADMAP-NEXT.md) and is not part of
this project today. The mechanics you do need are
[../../docs/shipping.md](../../docs/shipping.md).

## Definition of done

- [ ] `swift test` in `projects/06-capstone/Core` is green, with tests covering
      every state transition and every injected dependency's failure branch.
- [ ] `CapstoneCore` compiles with no warnings and imports no UI framework.
- [ ] The app builds in Xcode with no warnings.
- [ ] A signed build is installed on your own iPhone and launches.
- [ ] You used it for seven consecutive days without reinstalling, and the
      annoyance list from milestone 11 exists. **Read the note below before
      you start counting days.**
- [ ] Requirements 1 through 18 each have a yes, checked one at a time rather
      than assumed as a group.
- [ ] Every acceptance criterion in your own `CAPSTONE-SPEC.md` is met, or is
      struck through with a written reason.
- [ ] `NOTES/errors.md` carries the diagnostics from this project, including at
      least one isolation diagnostic and at least one SwiftData one.
- [ ] `PROGRESS.md` has its final entry and its next action line points at
      `docs/shipping.md`.
- [ ] You can give a five minute walkthrough of the architecture out loud, with
      no notes, including why the core does not import SwiftUI and what MVVM has
      to do with any of it.

## Stretch goals

Not required to advance, and specifically not required to call this project done.

- Submit to the App Store. Follow `docs/shipping.md`. This is the post course
  goal, deliberately outside the completion gate.
- Add one item from the cut list, and note how long it took now that the
  architecture exists. That number is the honest measure of whether the
  architecture was worth it.
- Add a widget or an App Intent and find out how much of the core you can reuse
  unchanged. Anything you cannot reuse is a boundary you drew in the wrong place.
- Write the same state model once more using `ObservableObject` and `@Published`
  from `docs/legacy-swift.md`, keep both, and be able to say out loud what the
  differences cost.
- Set up CloudKit sync and discover what it demands of your schema.

## Self-review before you call it finished

1. Can I run my whole app's logic in tests, with no simulator? If not, what
   escaped into the view layer and why?
2. Is there any calculation in a `body` that I would want to unit test?
3. How many types in this project are classes, and can I justify each one?
4. Does my state model have a method that does two things? Can I name a state
   transition that has no test?
5. What happens on first launch with no data, on launch with corrupt data, and on
   launch after the schema changed? Did I test all three or only the first?
6. Turn VoiceOver on and use the app with the screen off. Where did I get stuck?
7. Set text to the largest accessibility size. What overlapped?
8. Is there anything in this app that only I know how to use because I built it?
9. Which requirement did I most want to skip, and did I skip it?
10. If someone asked to see one repository as evidence I can write Swift, would I
    send this one? If not, what is the specific thing that is missing?
