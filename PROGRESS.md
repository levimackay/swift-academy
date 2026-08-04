# Progress

Started 2026-08-02. Hand maintained. Update it when you finish a chapter's
`Done when` checklist, not when you start one.

Two columns, and they answer different questions.

- **Written** is about the repository: has this chapter been authored yet.
  Values: `yes`, `placeholder`.
- **Status** is about you: have you worked it. Values: `not started`,
  `in progress`, `done`.

A chapter you have not started because it does not exist yet is not the same
as one you have not started because you have not got there, and the old single
column read as the second when it meant the first.

## Chapters

| # | Chapter | Hours | Written | Status | Tests | Finished |
|---|---|---|---|---|---|---|
| 01 | Values, Types, and Optionals | 4 | yes | in progress | 29 | |
| 02 | Functions, Argument Labels, and Closures | 5 | yes | not started | 31 | |
| 03 | Value Semantics and Mutation | 6 | yes | not started | 37 | |
| 04 | Protocols and Extensions | 6 | yes | not started | 38 | |
| 05 | Enums That Carry Data | 6 | yes | not started | 37 | |
| 06 | Collections and Transformations | 6 | yes | not started | 32 | |
| 07 | Generics, some, and any | 7 | yes | not started | 39 | |
| 08 | Errors, Typed Throws, and Result | 5 | yes | not started | 37 | |
| 09 | Codable and the Data Boundary | 5 | yes | not started | 35 | |
| 10 | Reference Types, ARC, and Capture | 6 | yes | not started | 15 | |
| 11 | Sendable, Actors, and MainActor | 7 | yes | not started | 17 | |
| 12 | Structured Concurrency | 7 | yes | not started | 27 | |
| 13 | SwiftUI: Views, State, and Identity | 8 | yes | not started | 20 | |
| 14 | Navigation, Dependencies, and Persistence | 8 | yes | not started | 34 | |

All fourteen chapters are written, so no chapter is a `placeholder` today.
Chapters 01 to 12 run under the Command Line Tools. Chapters 13 and 14 build
and test there too, but their `preview-app/` work needs full Xcode and the
simulator.

Chapter hours total 86. The fourteen chapters contribute 428 tests across 76
suites, which is what `swift test` at the root reports today.

## Projects

| # | Project | Unlocks after | Hours | Tests shipped | Status | Finished |
|---|---|---|---|---|---|---|
| 01 | Life Grid | Chapter 03 | 6 | yes, 7 | not started | |
| 02 | First Screen (spike) | Chapter 05 | 5 | not applicable, Xcode app | not started | |
| 03 | Collections Kit | Chapter 07 | 8 | no | not started | |
| 04 | Feed Parser | Chapter 09 | 10 | no, fixtures shipped | not started | |
| 05 | Event Bus | Chapter 10 | 7 | yes, 9 | not started | |
| 06 | Capstone | Chapter 14 | 35 | no | not started | |

Project hours total 71. 86 plus 71 is the 157 hours the README states.

Projects 01 and 05 ship their failing suites, which are the two the design
named load bearing: the copy independence assertion that no class can pass,
and the subscriber deallocation assertion that no strong capture can pass.
Both packages fail to build until the types exist, which is the intended
state of an unstarted project and cannot red a chapter. Projects 03, 04, and
06 ship specs and scaffolds and their suites are not written yet.

The capstone spec is written by you, and it must exist before chapter 11
begins. `SPEC.md` in that directory is the course's fixed shape and is already
committed. `CAPSTONE-SPEC.md` is the one you write.

| Milestone | Due by | Done |
|---|---|---|
| `projects/06-capstone/CAPSTONE-SPEC.md` drafted | Start of chapter 11 | no |

## Chapter checklist

Every chapter closes on the same four items, plus any chapter specific fifth
listed in its README.

- [ ] `swift test --filter ChapterNNTests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes

Filter on the target name, never on the bare number. `swift test --filter 10`
also runs two chapter 01 tests, because the filter regex matches the source
line inside each test ID. `make done CH=10` builds the target name for you and
refuses to call a chapter with zero tests green.

## Log

Append only. Newest entry at the bottom. The file ends with a `**Next
action:**` entry, which `make next` prints in full, so reopening the repo
after a gap costs nothing.

- **2026-08-02** Academy started. First chapter scaffolded, lesson drafted,
  tests failing as expected.
- **2026-08-03** Repository rebuilt against the canonical design: fourteen
  chapters, six projects, one root package, chapter directories renamed to
  their final slugs. Old twelve module table retired. Chapter 01 carries over
  as in progress.
- **2026-08-03** Review pass applied. Deleted the pre rebuild
  `modules/01-values-and-optionals/`, which was a duplicate chapter 01 and
  carried every em dash, every `fatalError` stub, and the only stale manifest
  in the tree. Wrote the nine missing documents, the eleven placeholder
  chapter READMEs, and the two load bearing project suites. Changed every
  chapter gate from `--filter NN` to `--filter ChapterNNTests`, which was
  provably selecting other chapters' tests. Corrected the claim that chapters
  13 and 14 need Xcode: verified, they build and test on CommandLineTools,
  and only the simulator work needs Xcode.

- **2026-08-04** Review pass across chapters 02 to 14 applied. Corrected
  eleven false claims about Python, C#, and Swift (Python keyword argument
  syntax, Python `match` on a misspelled member, C# `catch` syntax, C#
  `readonly` locals, C# `Self` constraints, C# LINQ expression trees, C#
  synchronous callers of async methods, `String.characters`, `Error` as an
  empty protocol, `Sendable` inference on `public` types, and throwing task
  group sibling cancellation). Repointed four chapter references that named
  the wrong probe, row, or count. Replaced two leaked exercise answers in
  chapter 06 and one in chapter 08. Renamed every type and function name that
  a lesson sample shared with an exercise stub, so that half of the tutor rule
  scan is clean. Fixed chapter 13's diagnostics probe, which declared one
  class name twice and did not compile. Chapter 14's MVVM section moved into
  `docs/legacy-swift.md`, bringing the chapter back under the 1800 word cap.
  All fourteen chapters are now marked written.

**Next action:** open `modules/01-optionals/README.md`, work the six exercises
in `modules/01-optionals/exercises/Optionals.swift` in the order the chapter
lists them, and get `swift test --filter Chapter01Tests` green. It is 29 tests
across 6 suites and all 29 are red today. Start with
`displayName(for:fallback:)`, which is the only one whose failure is a plain
string comparison.
