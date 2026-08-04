---
project: 02
slug: 02-first-screen
title: First Screen (spike)
after_chapter: 05-enums
difficulty: 1 of 5
estimated_hours: 5
package: Xcode iOS app project (projects/02-first-screen/App/)
---

# Project 02. First Screen

> **This is a spike, not mastery.** Its budget is five hours and its only job is
> to put a running iOS app on the simulator using the Swift you already have.
> You will write SwiftUI here that chapters 13 and 14 will later tell you to
> restructure. That is expected and it is not a mistake you are making. Stop at
> five hours whether or not the stretch goals are done, and go back to chapter 06.

## What you are building

One screen in an iOS app: a `List` of items driven by an array held in view
state, a button in the toolbar that appends a new item, and a `NavigationStack`
so tapping a row pushes a detail screen showing that item. The item type is an
enum with associated values or a struct carrying one, your choice, so the row
rendering has to switch or destructure rather than print a string. When it is
done, the app launches in the iPhone 17 Pro simulator, the list scrolls, the
button adds a row that appears immediately, and the push and the back swipe both
work. There is no persistence: relaunching starts over. That is correct for a
spike.

## What this project forces you to use

| Concept | Chapter |
|---|---|
| An enum with associated values driving what a row displays | `05-enums` |
| `switch` over that enum with no `default` case | `05-enums` |
| Optional binding for the selected detail, no force unwrap | `01-optionals` |
| Trailing closures, which every SwiftUI modifier and `Button` uses | `02-functions` |
| Value semantics: the array is copied into the view, so what updates it | `03-value-semantics` |
| A protocol conformance you did not write yourself (`Identifiable`) | `04-protocols` |

Two things arrive here that no chapter has taught yet: `@State` and the fact that
a SwiftUI view body is a function of state that Swift re runs for you. Take them
on faith for five hours. Chapter 13 is where you earn them.

## Functional requirements

1. The project opens in Xcode and runs on the iPhone 17 Pro simulator with no
   code signing setup and no developer account.
2. The app launches directly to the list screen.
3. The list is driven by a collection of a domain type you declared, not by an
   array of `String`.
4. That domain type distinguishes at least three kinds of item, and the row view
   decides its label and its system image by exhaustively matching on the kind.
5. Rows are stable under insertion: SwiftUI must have a real identity for each
   row rather than an array position.
6. A toolbar button adds one item and the new row appears without any manual
   refresh.
7. Tapping a row pushes a detail screen inside a `NavigationStack`.
8. The detail screen shows at least two facts about the specific item tapped.
9. The navigation title on the list is set, and the detail screen sets its own.
10. Swiping back from the detail returns to the list with the list unchanged.
11. The list shows a visible empty state when there are no items, rather than a
    blank screen.
12. The app builds with no warnings.

## Non-goals

Every one of these is banned for the full five hours. They are not "later in this
project", they are not in this project.

- No networking, no URLSession, no API calls.
- No persistence. No SwiftData, no UserDefaults, no files.
- No architecture. No separate model layer, no store type, no dependency
  injection, no "view model" of any kind.
- No unit tests. This project ships zero tests on purpose. Acceptance is visual.
- No deletion, no editing, no search, no sorting.
- No custom design system, no custom fonts, no color palette work.
- No second screen beyond the one detail push.
- No `async`, no `Task`, no actors.

## Architecture: constraints and questions

There is deliberately almost no architecture here. The constraints below exist to
stop you from building any.

- Everything can live in two or three files. If you are creating a fourth
  directory, you are doing chapter 14's project four months early.
- The array of items is owned by exactly one view. Which one, and what happens to
  the array when the detail screen is on screen?
- Requirement 5 says rows need a real identity. `Identifiable` and the `id:`
  parameter of `List` are two ways to supply it. Look up which the compiler
  demands in each case rather than guessing.
- Your item kind is an enum. When you add a fourth kind later, do you want the
  compiler to point at the row view, or do you want a silent fallback? That is
  the `default` case decision, and requirement 4 has already made it for you.
  Notice what the compiler does when you add a case.
- Where does the detail screen get its item from: a value passed into its
  initializer, or a lookup by identifier? For five hours, pass the value. Write
  one sentence about what would break if the item could change while the detail
  screen is open. Do not fix it.
- If a modifier appears to do nothing, suspect the order you chained them in
  before you suspect the modifier. Chapter 13 makes that rule precise.

## Milestones

1. **It runs.** New Xcode project, iOS App, SwiftUI interface, launches on the
   iPhone 17 Pro simulator showing the default view. Budget: forty five minutes,
   most of it Xcode and not Swift.
2. **A static list.** Hardcoded items, no state, rows render.
3. **The item type.** Replace the hardcoded strings with your enum backed type
   and switch on it in the row.
4. **State.** The array moves into view state, the toolbar button appends, the
   list updates.
5. **Navigation.** Wrap in a `NavigationStack`, add the destination, titles on
   both screens.
6. **Empty state and polish.** Requirement 11, then stop.

## Definition of done

- [ ] The app runs on the iPhone 17 Pro simulator and every one of requirements 1
      through 12 is demonstrably true by tapping around.
- [ ] A screen recording or three screenshots (list, list after adding, detail)
      exist outside the repo, because you will want them and because they are the
      first visible evidence this course has produced.
- [ ] No test suite exists in this project, by design.
- [ ] Every Xcode or simulator error that cost more than ten minutes is in
      `NOTES/errors.md`, verbatim, including anything about signing or schemes.
- [ ] `PROGRESS.md` records the actual hours spent, including the Xcode time.
- [ ] You can name one thing in this screen you do not yet understand, and it is
      written down. Chapter 13 will answer it.

## Stretch goals

Not required to advance. If the five hours are gone, these do not happen.

- Add swipe to delete on the list.
- Give each item kind a distinct tint and see what `foregroundStyle` does inside
  a `Label`.
- Run the same app on the iPad Pro M5 simulator and note, in one sentence, what
  `NavigationStack` did differently.

## Self-review before you call it finished

1. Did I stop at five hours? If I did not, what did I add that was on the
   non-goals list?
2. Is there any `String` in my item type doing the job that a case should be
   doing?
3. Does my row view have a `default:` branch? If yes, delete it and see whether
   the compiler is now telling me something useful.
4. Can I explain what `@State` is protecting me from, even roughly, or is it a
   magic word right now? Either answer is acceptable today. Write down which.
5. Did anything about this feel like it required an architecture I do not have?
   Write that down too. It is the motivation for chapter 14.
