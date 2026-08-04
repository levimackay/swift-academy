---
title: How this repo works
kind: specification
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# How this repo works

This is the specification every chapter, project, and document in this
repository is produced against. Where any other file disagrees with this one,
this one wins and the other file is the bug. The reasoning behind the shape
described here lives in [CURRICULUM-DESIGN.md](CURRICULUM-DESIGN.md); this
file is the operational form of it.

Read it before authoring anything. It is the answer to "how long, what
sections, in what order, what may I write, and what settles a dispute".

---

## 1. What is written today

The repository is authored and worked through at the same time, so it is
always partly built. The current state is on the front page of
[../README.md](../README.md) and in [../PROGRESS.md](../PROGRESS.md), and a
chapter is either authored or a placeholder with nothing in between. There is
no half authored chapter, because a half authored chapter is indistinguishable
from a wrong one.

A placeholder chapter README carries the front matter, the outcome, the three
planned concepts, and one line saying it has not been written. It carries no
prose sections and no exercises. It exists so that every cross reference in
the glossary and the bridges resolves to a real page, and so that a reader who
clicks a chapter link learns the truth immediately.

---

## 2. The canonical manifest

One root `Package.swift` covers all fourteen chapters as 28 targets, 14
exercise targets and 14 test targets, each with an explicit `path:`. Projects
and drills are separate packages.

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftAcademy",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "Chapter01",
            path: "modules/01-optionals/exercises",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "Chapter01Tests",
            dependencies: ["Chapter01"],
            path: "modules/01-optionals/tests",
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
        ),
        // Chapter02 through Chapter14, identical shape.
    ]
)
```

Four rules, all verified on the toolchain named in the front matter.

| Rule | Why |
|---|---|
| `platforms:` is mandatory | Omitting it fails Swift Testing macro expansion with `'isolation()' is only available in macOS 10.15 or newer`, which names nothing you wrote. `.macOS(.v13)` is sufficient; `.v14` is a safe arbitrary floor. |
| No `swiftLanguageMode(.v6)` line | It is the default at tools version 6.2, and stating a default teaches that it is optional. |
| No `-strict-concurrency=complete` | That is a Swift 5 migration flag. Describing Swift 6 concurrency as opt in is wrong on this toolchain. |
| `ExistentialAny` on every target | It produces `use of protocol 'Shape' as a type must be written 'any Shape' [#ExistentialAny]`, which turns `some` versus `any` into a compiler enforced habit. |

`.defaultIsolation(MainActor.self)` is deliberately not set on any target. It
works, and Apple recommends it for app targets, but it makes isolation
invisible, which is the exact thing chapter 11 exists to teach. Chapter 14
introduces it by toggling it on and reading the diff in errors.

Target names carry the chapter number: `Chapter07`, `Chapter07Tests`. That
naming is what makes the chapter gate in section 4 precise.

`probes/` is excluded from every target on purpose, because probe files
contain deliberately failing code.

---

## 3. Directory shape

```text
modules/NN-slug/
├── README.md      the chapter
├── exercises/     stubs, one file per exercise group, compiled as ChapterNN
├── tests/         the failing suite, compiled as ChapterNNTests
├── probes/        runnable and non compiling files the chapter links to
└── preview-app/   chapters 13 and 14 only, a README, never a committed project
```

Lowercase kebab case, no spaces, no capitals above the package level.
Everything a chapter needs is colocated. There is no parallel `solutions/`
tree, no parallel `exercises/` tree, and no directory with a space in its
name.

A directory that would otherwise be empty carries a `.gitkeep`, because an
empty directory does not survive a clone and the canonical tree is a promise
about what a fresh clone contains.

---

## 4. The chapter gate

The per chapter command is the test target name, not the chapter number:

```bash
swift test --filter Chapter07Tests
```

Never `swift test --filter 07`. Swift Testing matches the filter regex against
a test ID that includes the source file and line, so a bare number also
selects any test declared on a line containing that number in any other
chapter. Measured on this toolchain: `--filter 10` runs 17 tests across 5
suites, and `--filter Chapter10Tests` runs the 15 tests in 4 suites that
chapter 10 actually owns.

`make test CH=07` and `make done CH=07` build the target name from `CH`, so
they are correct by construction. Use them.

`make done` refuses to congratulate a chapter that ran zero tests. A filter
that matches nothing exits 0 with `Test run with 0 tests in 0 suites passed`,
which would make every unwritten chapter pass its own gate.

---

## 5. The chapter template

Section order is fixed. Seven sections are required and four are optional. An
optional section with nothing real to say is omitted, never padded.

```markdown
---
chapter: NN
slug: NN-slug
title: Chapter Title
anchor: csharp | python
concepts:
  - concept one
  - concept two
  - concept three
requires: [NN-earlier-slug]
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, YYYY-MM-DD
---
```

| # | Section | Required | Budget | Rule |
|---|---|---|---|---|
| 1 | Cold open | optional, chapters 03+ | ~30 words | Names one drill from two chapters back. No hint, no link back. |
| 2 | The question | required | 60 to 120 words | The design problem, zero syntax. |
| 3 | Swift's answer | required | 150 to 400 words | The largest code in the chapter. First Swift on the page. |
| 4 | Predict | optional | ~60 words plus snippets | Points at `probes/predict.swift`. No answers, ever. |
| 5 | Coming from C# or Python | required | hard cap 250 words | Exactly the anchor named in front matter. Two subheads. |
| 6 | The model | required | ~80 words plus one diagram | Exactly one diagram per chapter. |
| 7 | Where it goes wrong | required | 4 to 8 rows | Three columns, verbatim diagnostics only. |
| 8 | Exercises | required | ~100 words | Names that match the stubs exactly. |
| 9 | Retrieval checkpoint | optional | ~120 words | Five questions, four runnable, one judgment. No answer key. |
| 10 | Stretch | optional | ~50 words | Must carry the words "not required to advance". |
| 11 | Done when | required | ~60 words | The four standard items plus any chapter specific fifth. |

The four standard `Done when` items, verbatim:

```markdown
- [ ] `swift test --filter ChapterNNTests` is green
- [ ] Every diagnostic that cost more than ten minutes is in `NOTES/errors.md`
- [ ] I contributed this chapter's four drills to `drills/`
- [ ] I can explain the three concepts in the front matter out loud, no notes
```

### Word budget, and what counts

Prose target 900 to 1500 words, hard cap 1800. Exceeding it means split the
chapter, never raise the cap.

**Table cell text counts toward the word budget.** Tables replace comparative
prose, so exempting them would let a chapter route around the cap by turning
paragraphs into pipes. Front matter, code fences, diagram fences, and
`<details>` summary lines do not count.

Cap table cells at roughly 25 words and tables at three content columns. A
cell holding a paragraph renders as a two word column on a phone.

Counted precisely: body prose plus table cell text, excluding front matter,
everything inside a fence, `<details>` and `<summary>` tags, table separator
rows, HTML comments, and bare URLs.

The three reference chapters as measured on 2026-08-03, which is the
calibration for anything written against them:

| Chapter | Prose words | Comparison section | Prose lines to code lines |
|---|---|---|---|
| 01-optionals | 1792 | 210 | 0.76 to 1 |
| 10-classes-and-arc | 1792 | 248 | 0.56 to 1 |
| 13-swiftui-state | 1796 | 172 | 0.66 to 1 |

All three sit just under the cap rather than comfortably under it, which is
the honest state and is why the rule is "over the cap means split", not "over
the cap means trim harder next time".

### Prose to code ratio

Roughly 1:1 by line count, **counting the chapter's `probes/` files**. Probes
are chapter code that the chapter links to and the reader runs, and rule 13
sends every sample over 12 lines into `probes/`, so excluding them penalises
the chapter for following the rule. The fix for a bad ratio is more code, not
less prose.

Measure it with the chapter's own lines: non blank, non front matter README
lines that are not inside a fence, against fenced Swift lines plus
`probes/*.swift` lines.

### Concept budget

Three core concepts per chapter, declared in front matter and checked against
[keywords.md](keywords.md), which records which chapter owns which keyword. A
keyword belongs to exactly one chapter. Any other chapter that mentions it
either previews it with a forward pointer or recalls it with a backward one,
and either way it does not teach it a second time.

### Anchor language

Exactly one anchor per chapter, named in front matter, and the anchors are
assigned once in [keywords.md](keywords.md) section 2. Three chapters anchor
on Python (02, 06, 09) because Python's model is the closer and more
instructive one there. The other eleven anchor on C#. A chapter never carries
both comparison sections. At most two rows inside a comparison table may cite
the non anchor language, and only where it diverges enough to matter.

---

## 6. Probes, and the one convention

Every chapter's `probes/` directory follows the same three rules.

**1. A probe compiles and runs.** Every file in `probes/` builds clean under
`swift -swift-version 6`. Nothing in `probes/` is expected to fail to compile.

**2. A diagnostics probe is named `errors.swift`, compiles, and carries each
failing block commented out with the diagnostic pasted beneath it.** Chapter
10 models this and it is the convention. The reason it wins over a file that
does not compile: the file stays runnable, so a stale diagnostic shows up as
drift the next time you run it, and `make probe` can run it like anything
else. A file that never compiles can rot silently for a year.

Shape of one block:

```swift
// WEAK ON A LET
// final class Session {}
// final class Holder { weak let session: Session? = nil }
//
// error: 'weak' must be a mutable variable, because it may change at runtime
```

**3. Every probe runs through `make probe`.** Including probes that take an
argument:

```bash
make probe CH=10 P=cycle
make probe CH=10 P=dangling ARGS=unowned
```

Never document a raw `swiftc` or `swift file.swift` invocation for a probe in
a chapter. A loose `.swift` file run as a script defaults to Swift 5 mode,
which is not the mode any chapter is written against, and `make probe` passes
`-swift-version 6` for exactly that reason.

The `Where it goes wrong` table cites `make probe CH=NN P=errors` as its
source, and every row in it was pasted from that file's output on the
toolchain in the chapter's `verified:` line.

### Diagnostics that carry a per run value

A pointer address, a process id, and a timing number are different on every
run. Replace the varying part with a horizontal ellipsis and say so in the
same row, for example `... but object 0x… was already destroyed (the address
differs on every run)`. Rule 9 requires verbatim text; a value the reader
provably cannot reproduce is not the text, it is one sample of it.

---

## 7. The tutor rule, operationally

Lesson prose may contain complete, runnable, illustrative Swift. Exercise
answers, project answers, and quiz answer keys never land on `main`.

The mechanical checks:

1. No lesson sample shares a **function name, type name, or property name**
   with any exercise stub in any chapter. The name rule covers all three,
   because a sample using the same class name and the same property name as
   an exercise is the answer even when the function name differs. That was a
   real defect here: chapter 10's lesson once showed a `Screen` holding a
   `let uploader = Uploader()` and setting `uploader.onComplete` with a
   capture list, while exercise 2 asked you to set `screen.uploader.onComplete`
   on an `UploadScreen` holding `let uploader = Uploader()`. Different
   function name, same answer, transcribable line for line.

   The check is mechanical and takes one pass: collect every `func`, type, and
   stored property name declared under any `exercises/`, then scan every
   Swift fenced block in every chapter README for the same names. As of
   2026-08-03 that scan reports zero overlaps, and it is what caught
   `Connection.name` against `Listener.name` and `CounterView.count` against
   `TapCounter.count`, both of which were renamed rather than argued about.
   Generic nouns are not exempt: rename yours, because the sample is always
   the cheaper thing to change.
2. No lesson sample shares a signature with any exercise stub.
3. Hints are exactly three progressive `<details>` folds after the exercises:
   a nudge, then an approach, then the name of the API to look up. Never an
   implementation. Every chapter has all three.
4. Where a project scaffold must pre declare something for the package to
   parse, that declaration is part of the answer and the project's `SPEC.md`
   says so out loud.

---

## 8. Stubs and tests

A stub returns a compiling wrong value with a `// TODO:` comment. Never
`fatalError`: verified, a `fatalError` stub aborts the whole run with
`error: Exited with unexpected signal code 5`, prints no summary line, and
because Swift Testing runs in parallel in one process, which other tests
reported first is nondeterministic. The scoreboard is the point.

Two rules make sentinel stubs safe:

1. Every exercise's test suite contains at least two assertions with distinct
   expected values, so no constant return can pass.
2. At least one test per exercise fails a plausible first implementation, not
   only an empty one. Design the stumble in: negative zero, the empty
   collection, the multi scalar grapheme, integer overflow.

Never assert exact diagnostic text inside a test. Wording drifts between
toolchain releases. Diagnostics belong in the chapter table, pasted from
`probes/errors.swift`.

The full policy on what a test may and may not assert is
[testing-policy.md](testing-policy.md).

---

## 9. Drills

`drills/` is a separate package. Each chapter contributes four drills at
authoring time. A chapter that ships without its drills is not done.

**Naming convention: the suite name is `ChNN` followed by a short topic.**
One suite per chapter per topic, and the filter is the suite name:

```bash
swift test --package-path drills --filter Ch08
swift test --package-path drills --filter Ch11Isolation
```

Never filter drills by topic alone. The reason is the same line number
matching problem as section 4: a bare topic word can appear in a test name in
another chapter's drill file, and a bare number matches source lines. A
`ChNN` prefix on the suite name is the only stable selector.

The format, and one complete worked example written by the course rather than
by the learner, is [../drills/README.md](../drills/README.md).

---

## 10. Diagrams

Rule by kind, not by tool.

| Kind | Fence | Examples |
|---|---|---|
| Relationships, graphs, trees, state, timelines | ` ```mermaid ` | retain cycle graphs, task trees, view hierarchies |
| Spatial and to scale layouts | ` ```text `, wrapped at 72 columns | Optional discriminator bytes, the existential box, the copy on write filmstrip |

Committed raster images are banned: undiffable, uneditable, they go stale next
to the prose, and they bloat every clone.

Exactly one diagram per chapter, in the required `The model` section, so
fourteen in total, plus three cross cutting ones in `docs/diagrams/`. A
chapter without its diagram is unfinished.

---

## 11. Code fences

| Content | Fence |
|---|---|
| Swift | ` ```swift ` |
| C# | ` ```csharp ` |
| Python | ` ```python ` |
| Anything you type at a shell | ` ```bash ` |
| Pasted compiler or program output | ` ```text ` |
| ASCII diagrams | ` ```text ` |
| Mermaid diagrams | ` ```mermaid ` |

A bare fence is a defect. Every cold open and every `make probe` invocation is
` ```bash `.

---

## 12. Line wrapping and front matter

Hard wrap prose near 80 columns. Tables and URLs may run over; paragraphs may
not. The `.gitattributes` normalisation exists so that a pasted diagnostic
diffs cleanly, and an 800 character line defeats it.

Every document under `docs/` carries front matter with `title`, `kind`, and
`verified`. Every chapter README carries the full chapter front matter block.
`verified:` is a claim that every code sample in that file was compiled on
that toolchain on that date, and it is re-earned by re-running the samples
before the file is marked authored again.

---

## 13. Journals

Exactly two, both append only.

- [../NOTES/errors.md](../NOTES/errors.md): the verbatim diagnostic, what you
  thought it meant, what it actually meant.
- The Log at the bottom of [../PROGRESS.md](../PROGRESS.md), whose last line
  is always the single next concrete action.

`make next` prints from the `**Next action:**` marker to the end of the file,
so the next action may wrap across lines. Nothing else may follow it.

There is no third journal, and adding one is a change to this file first.

---

## 14. Settling a disagreement

In this order:

1. This file.
2. [CURRICULUM-DESIGN.md](CURRICULUM-DESIGN.md), for why the rule exists.
3. The compiler. If a rule here is contradicted by an actual diagnostic on the
   current toolchain, the compiler is right, the rule is wrong, and the fix is
   a pull request against this file with the reproduction pasted in. A rule
   the compiler visibly contradicts costs more trust than the rule was worth.

What is not an authority: an earlier proposal, a critique, a blog post, or the
way another chapter happens to be written.
