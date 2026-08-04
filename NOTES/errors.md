# Errors

Append only. Newest entry at the bottom. One entry per diagnostic that cost
you more than ten minutes.

Three columns, always in this order:

1. **The verbatim text.** Paste it, do not summarize it. If you rewrite it you
   will not recognize it the next time it appears, and recognizing it is the
   entire point.
2. **What you thought it meant.** Write the wrong belief down honestly. The
   wrong model is the thing you are trying to correct, and it is invisible
   once it has been replaced.
3. **What it actually meant.** One sentence, plus the fix you applied.

This is the highest yield retention artifact in the repo, because Swift's real
difficulty for an experienced developer is diagnostic literacy rather than
syntax. It is also the most credible proof that you wrote the code: nobody
else's transcript of being wrong looks like yours.

A stuck exercise goes here too. Past a sixty minute time box, write the
specific question as an entry with the third column left blank, move on, and
fill it in when you come back.

---

## 2026-08-03, chapter 01, seeded example

This entry is written by the course as the format example. Every entry after
it is yours.

**Verbatim**

```text
modules/01-optionals/probes/errors.swift:18:14: error: value of optional type 'Int?' must be unwrapped to a value of type 'Int'
16 | // 2. Arithmetic on the wrapper, not on the payload.
17 | let n: Int? = 3
18 | let m: Int = n + 1
   |              |- error: value of optional type 'Int?' must be unwrapped to a value of type 'Int'
   |              |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
   |              `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
```

Reproduced with `make probe CH=01 P=errors`.

**What I thought it meant**

That Swift wanted me to prove `n` was not nil before doing arithmetic, the way
C# wants a null check before a dereference, and that the fix was a guard or an
`if`. So I read `must be unwrapped` as `must be checked`.

**What it actually meant**

`Int?` is not an `Int` with a flag on it, it is `Optional<Int>`, a different
type with no `+` operator. The compiler is not asking me to check anything, it
is telling me I applied an operator to the wrapper instead of to the payload.
The two notes are the two ways to get from the wrapper to the payload, and
neither is a check.

Fixed with `let m = n.map { $0 + 1 }` when I wanted an `Int?` back, and
`let m: Int = (n ?? 0) + 1` when I wanted an `Int` and could defend the
default. The force unwrap that the second note suggests is the one option that
was not a decision.

---
