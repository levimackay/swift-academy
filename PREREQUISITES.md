# Prerequisites

Read this once, before chapter 01. It is the list of things this course
assumes you already have, and the list of things it will cost you that are not
hours.

## What you already know

| Requirement | Detail |
|---|---|
| Language fluency | Python or C# at a working professional level. Both is better, one is enough. |
| Fundamentals | Types, generics, collections, OOP, recursion, big O, exceptions. |
| Tooling | git, a terminal you are comfortable in, an editor you are fast in. |
| Swift | None assumed, and none expected. |

Nothing in this course explains what a variable, a loop, a class, an
interface, a generic parameter, a hash map, a test, or git is. Every chapter
is framed as the delta: how Swift's model differs from the one you already
carry, and why it made that choice.

If you cannot write a correct binary search in a language you know, without
looking it up, this course is not the right next thing. Not because Swift
needs it, but because the exercises assume that the algorithm is never the
hard part and the language always is.

## Hardware

An Apple silicon Mac. This is not negotiable: the toolchain, the simulators,
and the signing flow are macOS only, and the capstone's acceptance criterion
is a build installed on a device you own.

You also need an iPhone. Any iPhone that runs a current iOS release. The
capstone is done when a signed build is installed on it and you have used that
build for real. A simulator does not satisfy that criterion, on purpose:
installing on hardware is where provisioning becomes concrete.

Disk: budget 40 GB. Xcode is about 3.7 GB installed, each simulator runtime is
several GB more, and every SwiftPM package in this repo builds into its own
`.build` directory. `make clean` removes all of them when you need the space
back.

## Software

| Item | Requirement |
|---|---|
| macOS | Current enough to run the Swift 6.2 toolchain. |
| Swift | 6.2. `swift --version` must report `swift-6.2-RELEASE` or newer. |
| Xcode | Needed for the simulator and device work only. See [SETUP.md](SETUP.md). |
| git | Any recent version. |

Run `make verify` after cloning. It reports your Swift version, where
`xcode-select` points, which chapters are runnable right now, and the exact
command to fix anything that is wrong.

## Money

Two costs, and only one of them is required.

**The Apple Developer Program costs 99 USD a year.** You do not need it to
work any chapter, any project, or the capstone up to the point of installing
on your own device. A free Apple ID signs a build onto your own hardware.

**What the free tier costs you instead is a seven day provisioning profile.**
A build signed with a free Apple ID stops launching after seven days and has
to be reinstalled from Xcode. The capstone has a milestone asking you to use
your own app for seven consecutive days without rebuilding, and on the free
tier that milestone and the profile expiry collide. Either pay the 99 USD
before you reach the capstone, or read that milestone as "reinstall on day
seven and keep going", and write down which you chose.

You need the paid program for TestFlight and for App Store submission.
Neither is a completion gate for this course.

## Time, and the shape of it

About 157 hours: 86 across fourteen chapters, 71 across six projects. At ten
hours a week that is roughly four months.

That number is a guess and the design says so. After chapter 03, compare your
actual hours against the estimate and re-forecast. If you are off by more than
thirty percent, cut scope rather than extending the calendar, because
finishing is the product.

Two things about the calendar that are not hours:

- **App Store submission has multi day external latency.** Review time is not
  yours to schedule. That is why submission is a stated post course goal and
  not a completion gate. See [docs/shipping.md](docs/shipping.md).
- **The capstone spec is due before chapter 11, not after chapter 14.** You
  write `projects/06-capstone/CAPSTONE-SPEC.md` yourself from the template in
  `projects/06-capstone/SPEC.md`. Writing it early is what gives you four
  chapters of runway to notice the idea is too big.

## What this course does not make you

It makes you a strong Swift programmer and an incomplete iOS engineer, and
saying so up front is cheaper than you discovering it in an interview.

Specifically, as specified today it does not cover networking with
`URLSession`, the debugger and Instruments as instruments, App Store
submission mechanics beyond reading about them, or accessibility as
instruction rather than as capstone acceptance criteria. Those are known gaps
with owners and effort estimates in [docs/ROADMAP-NEXT.md](docs/ROADMAP-NEXT.md).
Read that file before you decide this course is the only thing you need.

## The one habit that decides whether you finish

Solo learners quit stuck far more often than they quit bored. So:

- Every chapter ships three progressive `<details>` hints: a nudge, an
  approach, then the name of an API to look up. Use them. They are not
  cheating; the implementation is never in them.
- Time box at sixty minutes. Past that, write the specific question in
  `NOTES/errors.md`, move to the next exercise, and come back cold next
  session.
- You may leave one exercise per chapter unfinished and still mark the chapter
  done. This is stated so that unfinished work does not accumulate into guilt,
  which is a quit driver and is free to eliminate.

Next: [SETUP.md](SETUP.md).
