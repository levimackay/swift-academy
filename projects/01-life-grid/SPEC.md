---
project: 01
slug: 01-life-grid
title: Life Grid
after_chapter: 03-value-semantics
difficulty: 1 of 5
estimated_hours: 6
package: standalone (projects/01-life-grid/Package.swift)
---

# Project 01. Life Grid

## What you are building

A Conway's Game of Life engine that runs in the terminal. It is a library target
holding a `Grid` type that stores live and dead cells for a fixed width and
height, exposes reading and writing by coordinate, and advances one generation at
a time under the standard birth and survival rules. A small executable renders
generations to stdout so you can watch a glider walk across the board. When it is
done, `swift run` prints a recognizable glider translating one cell diagonally
every four generations, `swift test` is green, and the grid behaves like a number:
handing it to another piece of code and mutating it there leaves your copy
untouched.

## What this project forces you to use

| Concept | Chapter |
|---|---|
| Copy versus share, and why a struct is the default here | `03-value-semantics` |
| `mutating func`, and what `let` on a struct actually freezes | `03-value-semantics` |
| Custom `subscript`, including a settable one | `03-value-semantics` |
| Optional returns for out of bounds reads, no force unwrap | `01-optionals` |
| Argument labels that read at the call site | `02-functions` |
| A closure parameter for the neighbor rule, passed as a value | `02-functions` |

The load bearing test copies a grid, mutates the original, and asserts the copy
did not change. A class cannot pass that test. Nothing in this spec says "use a
struct", and the test does not say it either. It just fails.

Verified: with `Grid` written as a struct the shipped suite is seven green
tests, and with the identical logic written as a `final class` five of the
seven fail, starting with `Expectation failed: (copy[1, 1] -> true) == false`.

## Pinned API

`Tests/LifeGridTests/CopyIndependenceTests.swift` is shipped, and it calls the
names below. Whatever else you add, these have to exist with these spellings,
because the tests are what pin the shape and stop a wrong language solution
from compiling at all. Right now the package does not build:

```text
error: cannot find 'Grid' in scope
```

That is the mechanism working, not a broken checkout. This package is
standalone, so it cannot red a chapter while you work on it.

| Symbol | Shape |
|---|---|
| `Grid` | a type conforming to `Equatable` |
| `Grid(width:height:)` | an all dead board |
| `grid[x, y]` | get and set, `Bool`, in bounds coordinates only |
| `mutating func step()` | advances one generation in place |

Nothing else is pinned. The out of bounds accessor, the string initializer,
the renderer, the neighbor counter, and the storage layout are all yours, and
the remaining suites for them are not written yet.

## Functional requirements

1. `Grid` stores a rectangular board of dead and live cells with a width and a
   height fixed at initialization.
2. An initializer builds an all dead grid from a width and a height.
3. An initializer builds a grid from a multi line string where one character
   means live and another means dead, and rejects ragged rows.
4. Reading a coordinate inside the bounds returns that cell's state.
5. Reading a coordinate outside the bounds does not trap and does not return a
   fabricated live cell. You decide the mechanism and defend it, on a member
   of your own naming. The subscript below is pinned as in bounds only, so
   this requirement is about the accessor you add next to it, not about the
   subscript.
6. Writing a coordinate inside the bounds changes exactly that cell.
7. A live neighbor count for any coordinate treats out of bounds neighbors as
   dead (a finite board, not a torus, for version one).
8. `step()` advances exactly one generation for every cell simultaneously. A cell
   born this generation must not influence any other cell in the same generation.
9. Standard rules: a live cell with two or three live neighbors survives, a dead
   cell with exactly three live neighbors becomes live, everything else is dead.
10. A block (2x2) is still, a blinker oscillates with period two, and a glider
    returns to its starting shape displaced by one cell diagonally after four
    generations.
11. Rendering a grid produces a deterministic string with one line per row and no
    trailing blank line.
12. An executable target runs a named starting pattern for a given number of
    generations and prints each one.
13. Copying a grid, mutating one copy, and then reading the other must show no
    effect from the mutation, in both directions.
14. Two grids with identical dimensions and identical cells compare equal, and
    grids differing in any cell or dimension compare unequal.

## Non-goals

- No infinite or wrapping board. Bounded and finite, version one.
- No file input, no command line argument parsing beyond a pattern name and a
  generation count.
- No animation, cursor control, ANSI escapes, or clearing the screen.
- No performance work. A naive scan of every cell is the correct answer here.
- No concurrency. Not one `Task`, not one `async`.
- No classes anywhere in this project. If you think you need one, that belief is
  the thing this project exists to correct.

## Architecture: constraints and questions

**One type owns the board.** Everything else reads it or renders it. Nothing else
stores cells.

- Your storage is one dimensional or two dimensional. Pick one and write the
  reason in a comment at the declaration. If you pick a flat array, where does
  the index arithmetic live so that exactly one place can get it wrong?
- Your rendering code must not be able to mutate a grid. What in the signature
  makes that true, as opposed to merely being the case today?
- `step()` is a `mutating func` and returns nothing, or it is a nonmutating func
  returning a new grid. Both are defensible. Write the one you did not choose in
  a comment and say what it would cost the caller.
- Requirement 8 says births do not cascade within one generation. There are at
  least two ways to guarantee that. One of them makes the guarantee structural
  and the other makes it a thing you remember to do. Which did you write?
- A neighbor count reads nine coordinates, some of which do not exist. If your
  bounds check appears in more than one function, you have two chances to get it
  wrong. Can you get it to one?
- The out of bounds read in requirement 5 is an `Optional` decision. Is a
  nonexistent cell absent, or is it dead? Those are different claims. The
  neighbor counter wants one answer and a caller inspecting a coordinate wants
  the other. Do not let one of them lose silently.
- The executable target imports the library target. The library target must not
  import Foundation unless you can name the symbol you needed from it.

## Milestones

1. **Package builds.** Library plus executable plus test target, `swift build`
   clean, one placeholder test green.
2. **Storage and access.** Init from width and height, subscript get and set,
   bounds behavior settled, equality working.
3. **Copy independence.** The copy test in the suite goes green and you can say
   out loud why, in terms of what the assignment did.
4. **Parsing and rendering.** String in, string out, round trips exactly.
5. **One generation.** Neighbor counting, then `step()`, verified on the block
   and the blinker.
6. **The glider.** Four generations, displaced by one cell diagonally. This is
   the acceptance pattern because it fails loudly for a whole class of off by one
   errors that the blinker survives.
7. **The executable.** `swift run` shows the glider moving.

## Definition of done

- [ ] `swift build` from `projects/01-life-grid` completes with no warnings.
- [ ] `swift test` is green, including the copy independence suite and the
      glider suite.
- [ ] `swift run` prints twenty generations of the glider and the shape is intact
      at generation twenty.
- [ ] There is no `class` keyword in `Sources/`.
- [ ] There is no `!` used as a force unwrap in `Sources/`.
- [ ] Every diagnostic that cost you more than ten minutes is in `NOTES/errors.md`
      with the verbatim text.
- [ ] You can explain, out loud and without notes, what happens in memory when
      one grid is assigned to a second variable and then one of them is mutated.

## Stretch goals

Not required to advance.

- Make the board wrap at the edges, and keep the finite behavior available. Note
  which type in your design had to change and whether that surprised you.
- Add a step that reports whether the generation changed anything, so a still
  life can be detected without the caller diffing.
- Load a starting pattern from a plaintext file supplied on the command line.
- Read about run length encoded Life patterns and parse one.

## Self-review before you call it finished

1. Can I state, for every stored property in `Grid`, why it is stored rather
   than computed?
2. If I delete the copy independence test, does anything else in my suite still
   fail if I convert `Grid` to a class? If not, my suite is weaker than I thought.
3. Does any function take a grid and return nothing while still being useful? If
   so, what is it mutating and did I mean that?
4. Is there a coordinate to index calculation written more than once?
5. Did I write bounds checks with `<` and `<=` correctly at all four edges, and
   did I test the corners specifically rather than the middle?
6. Does my renderer produce identical output for two grids that compare equal?
7. Would a reader who has never seen Life be able to find the rule in
   requirement 9 in my code in under thirty seconds?
