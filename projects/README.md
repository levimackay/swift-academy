# Projects

Six projects, each its own standalone SwiftPM package or Xcode project,
deliberately outside the root package. A project in progress can fail to build
without turning the fourteen chapters red, which is why the API pinning tests
inside a project are allowed to reference types that do not exist yet.

A project ships as a spec, a scaffold, and a failing test suite. Never as an
implementation. If a scaffold pre declares a symbol so that the package parses,
that declaration is called out in a comment in the file it lives in, and it is
part of the answer rather than part of the tests.

**Two of the six ship their suites today.** Projects 01 and 05 are the two the
design named load bearing, and both are written: project 01's copy independence
assertion, which no `class Grid` can pass, and project 05's subscriber
deallocation assertion, which no strong capture can pass. Both packages
currently fail to build with `cannot find 'Grid' in scope` and `cannot find
'Bus' in scope`, which is the mechanism working rather than a broken build.
Projects 03, 04, and 06 ship specs and scaffolds; their suites are not written
yet, and `swift test` in those directories runs zero tests. Project 04's
`Fixtures/` are written, because the spec says those are given to you rather
than authored by you.

The `Tests shipped` column below says which is which, and
[../PROGRESS.md](../PROGRESS.md) tracks it.

## The list

| # | Project | After | Hours | Tests shipped | Forces |
|---|---|---|---|---|---|
| 01 | [Life Grid](01-life-grid/SPEC.md) | `03-value-semantics` | 6 | yes, 7 | Copy versus share, `mutating`, `subscript` |
| 02 | [First Screen](02-first-screen/SPEC.md) | `05-enums` | 5 | not applicable | A running app on the simulator, deliberately shallow |
| 03 | [Collections Kit](03-collections-kit/SPEC.md) | `07-generics` | 8 | not yet | Generics, `Sequence`, `Collection`, associated types |
| 04 | [Feed Parser](04-feed-parser/SPEC.md) | `09-codable` | 10 | not yet, fixtures shipped | `Codable` against hostile JSON, typed errors |
| 05 | [Event Bus](05-event-bus/SPEC.md) | `10-classes-and-arc` | 7 | yes, 9 | ARC made observable: `weak`, capture lists, `deinit` |
| 06 | [Capstone](06-capstone/SPEC.md) | `14-swiftui-app` | 35 | not yet | Everything, against a spec you write yourself |

Hours total 71. With the fourteen chapters' 86, that is the 157 the README
states.

Do a project immediately after its prerequisite chapter, before starting the
next chapter. The projects are where the chapters stop being separate.

## Two things to know before starting any of them

**Project 02 is a spike.** Five hours, one screen, no architecture. It exists
so that chapter 06 is not the eleventh consecutive week of terminal output. It
is banner labeled inside its own spec and it is not a measure of your SwiftUI
ability.

**The capstone spec is written before chapter 11.** Not after chapter 14. Two
files, two authors, two names, one artifact between them:
`projects/06-capstone/SPEC.md` is the course's fixed shape and is already
committed, and `projects/06-capstone/CAPSTONE-SPEC.md` is yours to write from
the template inside it. Writing it early is what gives you four chapters of
runway to notice the idea is too big. The review question for it is always
"what can be cut".

## Where each one runs

| Project | Toolchain |
|---|---|
| 01, 03, 04, 05 | `swift build` and `swift test` from the project directory, CommandLineTools is enough |
| 02 | Xcode, iPhone 17 Pro simulator. See [02-first-screen/App/README.md](02-first-screen/App/README.md) |
| 06 | `swift test` for `Core/`, Xcode and a physical device for `App/`. See [06-capstone/App/README.md](06-capstone/App/README.md) |

These two are the only places in the whole course that need Xcode, together
with the throwaway preview apps in chapters 13 and 14. Every chapter, 01
through 14, builds and tests on CommandLineTools.
