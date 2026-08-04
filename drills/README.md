# Drills

A separate package, on purpose: a half written drill never reds a chapter, and
`swift test --package-path drills` is a five minute spaced retrieval run that
does not build fourteen chapters first.

**A drill is a retrieval prompt, not an exercise.** An exercise teaches
something for the first time and ships as a stub you fill in. A drill asks you
to produce something you already learned, from memory, in a blank file, some
weeks later. That distinction is why a drill ships complete: you wrote it, you
solved it, and its value from then on is that you can re-solve it cold.

Four drills per chapter, contributed at the end of that chapter. A chapter that
ships without its four drills is not done, and it is item 3 of every chapter's
`Done when` checklist. Retrofitting fifty six drills after chapter 14 will not
happen, which is the entire reason the deadline is per chapter.

---

## Naming, which is the part that has to be exact

**Suite names begin with `ChNN`.** That prefix is the only stable selector.

```swift
@Suite("Ch01 optionals: nesting")
struct Ch01NestingDrills { ... }
```

```bash
swift test --package-path drills --filter Ch01          # every chapter 01 drill
swift test --package-path drills --filter Ch01Nesting   # one suite
```

**Never filter by topic alone.** `--filter Isolation` looks tidier and it is
wrong for the same reason `swift test --filter 11` is wrong in the root
package: the filter is a regex matched against a test ID that includes the
source file and line, so a bare topic word matches any test whose name or path
happens to contain it, and a bare number matches source lines. The `ChNN`
prefix is the only thing that partitions cleanly.

Files follow the suite:

```text
drills/
├── README.md
├── Package.swift
├── Sources/Drills/
│   ├── Ch00Format.swift        the worked format example, below
│   ├── Ch01Nesting.swift
│   └── Ch01Binding.swift
└── Tests/DrillsTests/
    ├── Ch00FormatTests.swift
    ├── Ch01NestingTests.swift
    └── Ch01BindingTests.swift
```

One concept per drill. If a drill needs two paragraphs of setup, it is an
exercise and it belongs in a chapter.

---

## Anatomy

Every drill is three things.

1. **A prompt**, as a doc comment on the function. One or two sentences,
   stating what to produce. It must be answerable without the chapter open,
   because that is the whole point.
2. **An implementation**, which you wrote when you contributed it.
3. **A suite**, with at least two assertions carrying distinct expected
   values, exactly as in the chapter tests, so that a constant return cannot
   pass when you re-solve it.

### Re-solving one

```bash
# Delete the body, leave the signature and the prompt.
$EDITOR drills/Sources/Drills/Ch01Nesting.swift
swift test --package-path drills --filter Ch01Nesting
```

That is the Cold open ritual in chapters 03 and later: a drill from two
chapters back, blank body, no reference, before you read anything.

---

## The worked format example

`Ch00Format` is shipped by the course, complete, as the format demonstration.
It is deliberately about nothing any chapter teaches, so that reading it gives
away no answer to anything. Read it for the shape and then delete it whenever
you like.

```swift
/// Sum the even numbers in `1...limit`, or zero when `limit` is below one.
public func formatDemoEvenSum(upTo limit: Int) -> Int
```

```bash
swift test --package-path drills --filter Ch00Format
```

Its suite carries four assertions with four distinct expected values,
including the two that catch a plausible first pass: `limit` below one, and a
`limit` that is itself even and therefore must be included.

---

## What a drill may not be

- **Not an exercise answer.** A drill must not share a function name, a type
  name, a property name, or a signature with any exercise stub in any chapter.
  That is the same rule as
  [docs/how-this-repo-works.md](../docs/how-this-repo-works.md) section 7, and
  it applies here because `drills/` is on `main` and `main` never holds
  answers.
- **Not a test of the compiler.** A drill asserting that a stored property
  returns what you assigned is a drill about Swift, not about you.
- **Not timing dependent.** No sleeps, no wall clock, no pointer addresses.
  See [docs/testing-policy.md](../docs/testing-policy.md) section A4.

---

## Contributing a chapter's four

At the end of a chapter, before you tick `Done when`:

1. Pick four things from the chapter you would want to still have in six
   weeks. Prefer the ones that surprised you, which are usually in your
   `NOTES/errors.md` entries for that chapter.
2. Write the prompt first, as a doc comment, without looking at the chapter.
   If you cannot state the prompt, the drill is not about one thing.
3. Write the implementation and the suite. Two distinct expected values,
   minimum.
4. `swift test --package-path drills --filter ChNN` is green.
5. Check the name against every exercise stub you have seen.
