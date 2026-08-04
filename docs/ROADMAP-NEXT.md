---
title: Roadmap, what comes after the current design
kind: backlog
verified: not applicable, this file contains no code samples
---

# Roadmap: what comes next

Everything in [CURRICULUM-DESIGN.md](CURRICULUM-DESIGN.md) is the course as
specified today. Everything here is a change to that specification that a
review panel argued for and that is too large to apply halfway. Nothing below
is authored, scaffolded, or referenced from the README, on purpose: a
half applied structural change is worse than either applying it or deferring
it, because it leaves the repo describing behavior it does not have.

Ordered by value, highest first. Effort estimates are authoring hours for
whoever writes the material, not learner hours. Learner hours are stated
separately where the item adds course time.

---

## Tier 1: the two gaps that change a hiring decision

### 1. Project: API Client, replacing project 05 Event Bus

**What it is.** A new project after chapter 12, against a real public API:
`URLSession` with async/await, an injected transport protocol so tests never
touch the network, HTTP status mapped to a domain `throws(E)`, a 401 driving
a token refresh through a single-flight actor, retry with backoff and jitter,
cancellation that actually cancels the underlying `URLSessionTask`, cursor
pagination, and a cached read path when offline. Test doubles via a stubbed
`URLProtocol` or the injected transport, both taught.

**Why the panel wants it.** Networking does not exist anywhere in the
curriculum. `URLSession` appears three times in the whole repo, twice inside
"no URLSession" non-goals. A graduate has never issued an HTTP request in
Swift, never mapped a status code to a typed error, never refreshed a token,
never handled offline, never paginated, never retried. Nearly every production
iOS app is a networking client and nearly every take-home is one. The single
flight token refresh is also the best actor exercise in all of iOS, which
means chapters 11 and 12 currently teach actors with no application that
forces them.

Project 05 Event Bus is the one it replaces, for three reasons: its seven
hours buy an ARC lesson chapter 10's exercises already deliver, the artifact is a
hand rolled synchronous weak-subscriber registry that would draw pushback in
review of a Swift 6 codebase, and it sits immediately before the fourteen
hours that teach its modern replacements (`AsyncStream`, actors, structured
concurrency). Keep its memory proof by moving the deinit assertion into
chapter 10 as one exercise.

**Effort.** 20 to 26 authoring hours (spec, scaffold, transport seam, fixture
server, eight or nine test suites). Learner hours roughly 14, replacing 7, so
about +7 to the course total. Requires deciding on a stable public API that
will not disappear.

### 2. Project: Bug Hunt, after chapter 13

**What it is.** A deliberately broken SwiftUI app, authored and committed,
containing five planted defects: a retain cycle, a main-thread hang, a view
that invalidates far more than it should, a layout that breaks at accessibility
text sizes, and a control VoiceOver cannot use. Each must be found with its
intended instrument rather than by reading the source: Memory Graph Debugger,
Time Profiler, the SwiftUI instrument plus `Self._printChanges()`, the view
debugger, Accessibility Inspector. Acceptance is a before/after trace committed
as evidence.

**Why the panel wants it.** Zero coverage of the debugger as a tool anywhere
in the repo: no LLDB (`po`, `p`, `expression`, conditional and symbolic
breakpoints), no view debugger, no Memory Graph Debugger, no Instruments, no
crash symbolication, no scheme or build-setting literacy. Everything the
curriculum teaches about finding bugs is "read the compiler error", which it
teaches superbly and which stops working the moment the code compiles and is
still wrong. The irony is specific: chapter 10 proves deallocation by printing
from `deinit`, which is the workaround people use precisely because they do not
know the Memory Graph Debugger exists. Capstone requirement 16 ("launches to
first usable content in under two seconds") currently gives the learner no
instrument with which to measure it.

This one project closes the debugging, performance, and accessibility
instrumentation gaps at once. The authored broken app is not an answer key to
any exercise, so the tutor rule survives intact.

**Effort.** 14 to 18 authoring hours (write the app, plant five defects that
are each findable by exactly one tool, write the acceptance rubric). Learner
hours roughly 6, so +6 to the course total. Also needs a short
`docs/debugging.md`: LLDB commands, breakpoint types, reading a crash report,
about 3 hours.

---

## Tier 2: teaching behind criteria that already exist

### 3. Accessibility as instruction, not as acceptance criteria

**What it is.** An accessibility section in chapter 13 with its own exercises:
label a composed row so VoiceOver reads one coherent sentence rather than four
fragments, make a status indicator legible without color, make a control a
switch-control user can reach. Then an Accessibility Inspector audit as a
required (not stretch) step of project 02 and of Bug Hunt.

**Why the panel wants it.** Accessibility currently exists only as capstone
requirements 13, 14, and 15, with no instruction behind them anywhere.
VoiceOver appears twice in the entire repo, Dynamic Type three times,
localization zero times. Nothing teaches `accessibilityLabel` versus value
versus hint versus traits, `accessibilityElement(children:)`, custom actions,
focus management, the rotor, or reduce-motion. An acceptance criterion with no
teaching behind it is exactly how accessibility fails on real teams, which the
design elsewhere calls out about other topics.

**Effort.** 8 to 10 authoring hours. Chapter 13 is already at its word cap, so
this either splits chapter 13 or lands as `docs/accessibility.md` with the
exercises in chapter 13's `exercises/`. Decide that first.

### 4. Animation and UI craft in chapter 13

**What it is.** A required animation and gesture section with two exercises:
an implicitly animated state change where the wrong `.animation` placement
visibly animates the wrong thing, and a transition on insertion and removal in
a `List`. Plus one capstone requirement: every user-caused state change is
either instant or animated deliberately, with no unintentional pops.

**Why the panel wants it.** The brief asks about a *polished* app and polish is
never taught or graded. `withAnimation`, `.animation`, `.transition`,
`matchedGeometryEffect`, gestures, `ViewThatFits`, custom `Layout`, and SF
Symbols usage appear nowhere. An app with correct state and zero motion design
does not read as polished to anyone, including an interviewer looking at a
screen recording. The wrong `.animation` placement is also a superb modifier
order lesson, so it pays twice. Keep the existing ban on a custom design
system, which is the correct scope call.

**Effort.** 5 to 7 authoring hours.

### 5. Testing skills the learner is graded on and never taught

**What it is.** Required exercises in chapter 12 on testing async code: an
injected `Clock` so a timeout test runs in microseconds rather than seconds, a
cancellation test, and `confirmation()` over a callback API. Plus a section on
designing a seam (protocol existential versus generic parameter versus
struct-of-closures). Plus exactly one XCUITest in the capstone, with the
explicit lesson being why it is one and not thirty.

**Why the panel wants it.** The learner reads fourteen chapters of expertly
written Swift Testing suites and never writes one. Swift Testing (`@Test`,
`@Suite`, parameterized tests, `#require` versus `#expect`, traits) is a
hiring-relevant skill currently acquired by osmosis. Meanwhile the capstone
requires "a test double for each dependency" and requirement 18 requires
testing every dependency's failure branch, and no chapter teaches how to
design a seam or build a double.

Note that `docs/testing-policy.md` now exists and states the policy. This item
is the *skill*, which the policy does not teach.

**Effort.** 6 to 8 authoring hours.

### 6. Reading Apple documentation as a graded skill

**What it is.** `docs/reading-apple-docs.md`, plus one required exercise per
chapter from 04 onward that is answerable only from documentation: given a
symbol name, report its availability, its isolation, whether it is deprecated
and what replaced it, and one thing the page does not tell you. Plus one
swift-evolution proposal per chapter moved from Stretch onto the required
path.

**Why the panel wants it.** Reading Apple documentation is named as a target
skill and treated in the repo as a link. Every Apple and swift-evolution
reference currently sits in an optional Stretch section, which by the design's
own reasoning about optional sections means most will be skipped. The hint
ladder deliberately stops at "the name of the API to go look up", which is
exactly the right seam, and then the looking-up is never taught.

**Effort.** 4 hours for the doc, plus about 20 minutes per chapter for the
exercise, so roughly 8 total across the eleven chapters that get one.

---

## Tier 3: structural, and expensive

### 7. Split chapter 14 into 14 Navigation and 15 Dependencies and Persistence

**What it is.** Chapter 14 becomes Navigation: `NavigationStack`, tabs with
per-tab stacks, sheets and `fullScreenCover` and popovers as navigation state
rather than scattered booleans, a URL-to-route parser, `NavigationSplitView`,
and `Codable` route persistence for state restoration. Chapter 15 becomes
dependency injection, SwiftData, `scenePhase` and save points, and the MVVM
section.

**Why the panel wants it.** Eight hours cannot carry `NavigationStack`,
dependency injection, and SwiftData, and it is the last chapter before a forty
hour capstone that depends on all three. Capstone requirement 7 demands
restorable deep navigation state, which nothing currently teaches. A URL-to-
route parser is a pure function, so it is fully testable under plain
`swift test` with no simulator, which fits the existing constraint exactly.
Sixteen chapters is still below the eighteen the design rejected as
unfinishable.

**Cost of not doing it.** Chapter 14 is currently specified to teach three
large topics in eight hours and will either overrun its word cap or arrive
skeletal.

**Effort.** This is a design change before it is an authoring change: it moves
the chapter count, the hour total, the README table, `PROGRESS.md`, the
manifest, `keywords.md`, and both bridge chapter indexes. 4 hours of
specification changes, then normal chapter authoring for two chapters instead
of one, so about +12 authoring hours and +6 learner hours.

### 8. Post-capstone project: Ship It

**What it is.** Roughly eight learner hours after the capstone: a paid account
or an explicit acknowledgement of the free-profile expiry, bundle ID and
capabilities configured by hand at least once rather than only through
automatic signing, certificates versus profiles, archive to validate to App
Store Connect, the privacy manifest (`PrivacyInfo.xcprivacy`, mandatory since
2024), screenshots, TestFlight to one real external tester, then reading back
a real crash or piece of feedback.

**Why the panel wants it.** `docs/shipping.md` now exists and covers the
mechanics as reading, but the capstone's definition of done stops at "a signed
build is installed on your own iPhone", which with a free Apple ID is about
twenty minutes of automatic signing. There is also a concrete bug in the
current capstone spec that this item resolves properly: milestone 11 requires
seven consecutive days of use without rebuilding, and a free provisioning
profile expires in seven days. The interim fix applied today names the expiry
in the spec; the real fix is to change the gate to "a TestFlight build one
other human installed and used".

**Effort.** 6 authoring hours, +8 learner hours. Gated on a real Apple
Developer Program membership, so it cannot be authored speculatively.

### 9. Persistence decision framework, and migration as an exercise

**What it is.** A short required section in the persistence chapter on the
decision itself: `@AppStorage` for small user preferences, files for large
opaque blobs, SwiftData for queried domain data, Keychain for secrets, with the
size, lifetime, and security reasoning that picks each. Plus SwiftData
migration as a real exercise with a schema change against existing data, rather
than the current "write a note saying what happens".

**Why the panel wants it.** SwiftData is the only persistence taught. Core
Data literacy now exists as a document, but `UserDefaults`, `@AppStorage`,
`FileManager`, and Keychain appear nowhere, and `UserDefaults` is banned by
name in project 02 and never introduced afterward.
`docs/interview-questions.md` asks the learner to "separate the three tiers of
state by lifetime and size", a framework no chapter gives them. Keychain
becomes mandatory the moment auth exists, and auth is item 1 above.

**Effort.** 4 to 6 authoring hours, more if the migration exercise ships with
a seeded store.

### 10. App lifecycle and system integration

**What it is.** A required section on `scenePhase` and the save points it
implies, plus one permission flow end to end including the user saying no and
the user having previously said no. Keep push notifications and background
tasks as non-goals, but name them as deliberately deferred with a pointer
rather than leaving them unmentioned.

**Why the panel wants it.** Zero coverage of `scenePhase`, background and
foreground transitions, `UIApplicationDelegateAdaptor`, permission prompts and
their denied path, `Info.plist` usage strings, or what happens when the system
kills a suspended app. Capstone requirement 7 asks for behavior after
backgrounding and relaunch, which requires knowing when to save.

**Effort.** 3 to 4 authoring hours. Lands naturally inside item 7's chapter 15
if that split happens.

---

## Tier 4: cheap, and worth doing when convenient

### 11. Strings, Characters, and Unicode

Swift's `String` is the largest day-one stumbling block for a C# or Python
developer: no integer subscripting, `String.Index`, grapheme clusters, the
views. No chapter owns it. It currently appears only as a test trick in
chapter 01's multi-scalar emoji assertion, which teaches the gotcha without
ever teaching the model. The design routed it to `reference.md` as a lookup,
which is defensible for `String.Index` arithmetic and indefensible for "why
does `count` disagree with what I see". Half a page in chapter 01 or a named
section in chapter 06. **2 to 3 hours.**

### 12. Access control and modules

Every exercise file is written in `public` and `private(set)`, and
`@testable import Chapter01` appears in the first test file a learner opens,
and none of it is ever explained. internal-by-default, `package`,
`fileprivate`, and why the exercises are `public` are worth half a page.
**1 to 2 hours.**

### 13. Adopting a third-party SwiftPM dependency

The repo has an unusually good manifest story and never once adds a
dependency. Adding one, reading `Package.resolved`, and version pinning is
something every real project and every interview touches. One capstone step:
adopt exactly one third-party package and write the paragraph the capstone
non-goals already demand about what you would have written yourself.
**1 to 2 hours.**

### 14. Localization

Zero mentions anywhere. One paragraph in chapter 13 on why `Text("hello")` is
a localization key and not a string (which surprises people when interpolated
strings behave unexpectedly), and one capstone requirement that all
user-facing strings live in a String Catalog even though only one language
ships. Roughly thirty minutes of work that prevents a week-long retrofit.
**1 hour.**

### 15. Reading an unfamiliar existing codebase

One exercise late in the course: clone a well-regarded open source SwiftUI
app, find the state model, and write half a page on where it differs from what
this course taught and which of those differences are the app's age versus its
judgment. `docs/interview-questions.md` correctly says the large iOS codebases
are years old, and the curriculum never has the learner open one.
**1 to 2 hours.**

---

## Explicitly not on this list

- **Combine.** Cut on merit in CURRICULUM-DESIGN section 4 and the reasoning
  still holds. `legacy-swift.md` covers reading it.
- **UIKit, storyboards, xibs.** Same.
- **A separate Xcode interlude chapter.** The Xcode gate does not exist; see
  CURRICULUM-DESIGN section 2.
- **`academyctl` or any generated progress pipeline.** Ruled out because the
  learner's first substantial Swift project must not be this course's build
  tooling.
- **Snapshot testing.** `testing-policy.md` argues against it for a solo
  project and that argument is not weakened by anything above.
