# Contributing

This repo is a Swift course that is written and worked through at the same
time. Contributions are welcome, but the constraint below is the whole point
of the project, so read it before anything else.

## The one rule

**No answers on `main`.** Lesson prose may contain complete, runnable Swift
that teaches a concept. Exercise implementations, project implementations, and
quiz answer keys never land on `main`, in any form: not in a `solutions/`
directory, not in a spoiler fold, not in a comment, not in a commented out
block, not in a test fixture.

Solutions live on the long lived `solutions` branch, and they get there only
after the chapter they belong to is green. The property that makes this work
is that for an unsolved chapter the answer does not exist anywhere in the
repository, so grep, a fuzzy finder, and GitHub search all come back empty.
A pull request that puts an implementation on `main` cannot be merged, however
good the implementation is.

Two consequences that catch people out:

- A lesson sample may not share a **function name, type name, property name,
  or signature** with any exercise stub in any chapter. The name rule covers
  all three, because a sample that uses the same class name and the same
  property name as an exercise is the answer even when the function name
  differs. If your example needs a `func firstIndex(of:)`, or a `Screen` with
  an `onComplete`, rename it or pick a different example.
- Hints ship as progressive `<details>` folds in the chapter README, in three
  steps: a nudge, then an approach, then the name of the API to look up. Never
  an implementation.

## Getting set up

```bash
git clone https://github.com/levibmackay/swift-academy.git
cd swift-academy
make verify
```

`make verify` reports your Swift version, whether `xcode-select` points at
Xcode, which chapters are runnable right now, and the exact command to fix
anything that is wrong. It exits non zero only on a real failure, so warnings
are safe to read and ignore.

## Running things

| Command | What it does |
| --- | --- |
| `make test` | Every chapter, one process, one summary. |
| `make test CH=03` | Chapter 03 only. Wraps `swift test --filter Chapter03Tests`. |
| `make done CH=03` | The chapter 03 gate, then the rest of its checklist. |
| `make probe CH=03 P=predict` | Runs `modules/03-*/probes/predict.swift`. |
| `make next` | Prints the last line of `PROGRESS.md`, which is the next action. |
| `make clean` | Deletes every `.build` directory in the tree. |

Chapters 13 and 14 import SwiftUI and still build on the command line tools
alone, because SwiftUI and Observation ship in the macOS SDK. Verified: with
`xcode-select -p` reporting `/Library/Developer/CommandLineTools`,
`swift test --filter Chapter13Tests` runs its 20 tests and the chapter 13
diagnostics probe type checks.

What needs `xcode-select` pointed at Xcode is the simulator work, and nothing
else: the throwaway preview apps in chapters 13 and 14, and the app targets in
projects 02 and 06.

**The chapter gate is the target name.** `swift test --filter Chapter03Tests`,
never `swift test --filter 03`. Swift Testing matches the filter regex against
a test ID that includes the source line, so a bare number also selects tests
in other chapters declared on a line containing that number. Measured:
`--filter 10` runs 17 tests, `--filter Chapter10Tests` runs 15. `make test
CH=03` and `make done CH=03` build the target name from `CH`, so use them.

## Package layout

There is one root `Package.swift` covering all fourteen chapters as 28
targets, 14 exercise targets and 14 test targets, each with an explicit
`path:`. That is what makes `swift test` at the root answer "did chapter 03
still pass after I refactored".

Everything else is a separate package on purpose:

- `drills/` is its own package, so a half written drill never reds a chapter.
- Each directory under `projects/` is its own package. A project test iterates
  a type whose conformance you have not written yet, so an unstarted project
  is supposed to fail to build. Inside the root package that would red all
  fourteen chapters. Two projects demonstrate this today: `swift build
  --build-tests --package-path projects/01-life-grid` fails with `cannot find
  'Grid' in scope`, and project 05 fails the same way on `Bus`, while
  `swift build --build-tests` at the root stays clean.

Every manifest in this repo follows the same four rules, and the reasoning is
written down once in
[docs/how-this-repo-works.md](docs/how-this-repo-works.md):

1. `platforms:` is mandatory. Omit it and Swift Testing macro expansion fails
   with `'isolation()' is only available in macOS 10.15 or newer`, which names
   nothing you wrote.
2. No `swiftLanguageMode(.v6)` line. It is the default at tools version 6.2,
   and stating a default teaches that it is optional.
3. No `-strict-concurrency=complete`. That is a Swift 5 migration flag, and
   describing Swift 6 concurrency as opt in is wrong on this toolchain.
4. `ExistentialAny` is enabled on every target, so every existential has to be
   spelled `any Shape`.

## Writing an exercise stub

A stub returns a compiling wrong value and carries a `// TODO:` comment.
Never `fatalError`: a `fatalError` stub aborts the whole run with
`error: Exited with unexpected signal code 5`, prints no summary line, and
because Swift Testing runs in parallel in one process, which other tests
reported first is nondeterministic. The scoreboard is the point, so the run
has to finish.

Two mechanical rules make sentinel stubs safe, and a test suite that breaks
either one will be sent back:

1. Every exercise's test suite contains at least two assertions with distinct
   expected values, so no constant return can pass.
2. At least one test per exercise fails a plausible first implementation, not
   only an empty one. Design the stumble in: negative zero, the empty
   collection, the multi scalar grapheme, integer overflow.

Never assert exact compiler diagnostic text inside a test. Wording drifts
between toolchain releases. Diagnostics belong in the chapter's "Where it goes
wrong" table, pasted verbatim from a file in that chapter's `probes/`.

## Writing chapter prose

The full template, section order, and word budget live in
[docs/how-this-repo-works.md](docs/how-this-repo-works.md). The parts that get
pull requests rejected most often:

- No em dashes, no en dashes, and no standalone hyphen used as a dash. Use
  commas, colons, periods, or parentheses.
- No emoji outside a code fence, and none in code comments.
- Second person. "You write", not "the student writes" and not "we write".
- Never explain what a variable, loop, conditional, function, class, generic
  parameter, or hash map is. Frame everything as how Swift differs and why.
- Write the precise claim, not the vague one. `Optional<Wrapped>` is an enum
  with cases `.some` and `.none`, not "a wrapper".
- 900 to 1500 words of prose, hard cap 1800. Over the cap means split the
  chapter, never raise the cap.
- No code block over 12 lines on the page. Longer samples go in `probes/` and
  are linked with the command that runs them.
- Exactly one diagram per chapter, in "The model". Mermaid for graphs, trees,
  state, and timelines. A `text` fence with ASCII wrapped at 72 columns for
  spatial and to scale layouts. Committed images are banned.
- Every chapter carries a `verified:` line in its front matter naming the
  toolchain and the date, and every sample in it has been compiled and, where
  it produces output, run.
- Never paste a value that varies between runs into a diagnostic and call it
  verbatim. A pointer address, a process id, and a timing number are different
  every time. Replace the varying part with a horizontal ellipsis and say so
  in the row.
- Every probe runs through `make probe CH=NN P=name`, including probes that
  take an argument, which take `ARGS=`. Never document a raw `swiftc` or
  `swift file.swift` invocation in a chapter: a loose file run as a script
  defaults to Swift 5 mode.
- Fence languages are not optional. ` ```bash ` for anything you type at a
  shell, ` ```text ` for pasted output and ASCII diagrams, ` ```swift `,
  ` ```csharp `, ` ```python `, ` ```mermaid ` for the rest. A bare fence is a
  defect.

Pinned terminology: "chapter" for a numbered unit under `modules/`, "exercise"
for a stub in `exercises/`, "drill" only for an entry in `drills/`, "project"
only for a directory under `projects/`, and "force unwrap" as two words.

## Naming and layout

Lowercase kebab case, no spaces, no capitals above the package level.
Everything a chapter needs is colocated under `modules/NN-slug/`. Parallel
lesson, exercise, and solution trees are not accepted: they turn a renumbering
into four coordinated renames with silently broken cross links, and a
solutions directory on `main` is fatal to the premise.

## Commit messages

Imperative mood, present tense, no trailing period. Say what changed and why,
in that order. No em dashes. No attribution of authorship to any tool.

```text
Add chapter 06 collections stubs and tests

Covers Array, Dictionary, and Set selection plus the lazy chain. The
compactMap exercise fails on a plausible first pass because the fixture
contains an empty string, not only a nil.
```

## Pull requests

Before opening one:

- `make verify` passes.
- `swift build --build-tests` succeeds at the root.
- `swift test --filter ChapterNNTests` behaves the way you claim it does. If
  you added an
  exercise, the stub must fail, and it must fail with a readable assertion and
  not a crash.
- Nothing you added is an answer.

CI runs a compile gate on every branch and treats `swift test` as a hard gate
only on the `solutions` branch. Unsolved exercises are supposed to be red on
`main`, so read the log rather than the check mark. The reasoning is in
`.github/workflows/ci.yml`.

The compile job also hard fails on a broken relative markdown link and on any
em dash, en dash, or standalone hyphen used as a dash. Both are five line
shell steps and both catch mechanically what a reviewer catches slowly. Links
into `modules/NN-slug/README.md` are allowlisted only where the chapter README
genuinely exists, which is all fourteen, so a new dead link is a failure and
not a warning.

## License

By contributing you agree that your contribution is licensed under the MIT
License in `LICENSE`.
