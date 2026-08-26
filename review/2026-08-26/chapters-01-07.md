# swift-academy review ledger, chapters 01 to 07

## Chapter 01, optionals

Edits:
- modules/01-optionals/README.md (Swift's answer): "carrying an instruction to insert a force unwrap at every use, so the trap fires" -> "carrying an instruction to insert a force unwrap wherever a `String` is required, so the trap fires". Reason: an IUO is only force unwrapped where the context needs the wrapped type (SE-0054); `let y = handle` yields `String?` with no unwrap, so "at every use" is wrong.
- modules/01-optionals/README.md (Done when): grep -nE '[A-Za-z_)\]]!' -> grep -nE '[]A-Za-z_)]!'. Reason: inside a POSIX bracket expression a backslash is literal and `]` closes the bracket, so with stock /usr/bin/grep the original pattern matches nothing (verified: exit 1 on a file containing `port!`), and the force unwrap check silently passes. `]` first is the portable spelling, verified with both /usr/bin/grep and ugrep.
- modules/01-optionals/exercises/Optionals.swift (header comment): "swift test --filter 01" -> "swift test --filter Chapter01Tests". Reason: repo rule (CONTRIBUTING, Makefile) measured that a bare number filter selects tests in other chapters; the README already says Chapter01Tests.
- modules/01-optionals/probes/forceunwrap.swift (comment): "the ! moves from the declaration to every single use of it." -> "the ! moves from the declaration to each use that needs a `String`." Reason: same IUO precision as above.

Verified, no edit needed: layout probe numbers (String/String?/String?? size 16; Int 8, Int? 9, Int?? 10) match the diagram; predict probe output; all eight diagnostic strings in "Where it goes wrong" match swift 6.2 wording (rows 1 to 5 and 7 recompiled from probes/errors.swift blocks, row 6 from guardfall, row 8 from forceunwrap which trapped on line 28 with the "implicitly unwrapping" wording); every test asserts against a value the shipped stub cannot produce (displayName stub `nickname ?? fallback` fails only the empty nickname test, by design).

Open questions:
- Package.swift comment "Target names carry the chapter number so that `swift test --filter 03` selects exactly one chapter" contradicts CONTRIBUTING and the Makefile (measured: bare number over selects). Shared file, not edited.
- README "Coming from C#" claims C# `string??` "does not parse". It is a compile error in C#, but whether the parser or the binder rejects it was not checked; not a Swift claim, left alone.

## Chapter 02, functions

Edits:
- modules/02-functions/README.md (Done when): grep -nE '[A-Za-z_)\]]!' -> grep -nE '[]A-Za-z_)]!'. Reason: same broken bracket expression as chapter 01; matches nothing under /usr/bin/grep.

Verified, no edit needed: both print comments in the Swift's answer samples ("6 4 -4", "....ok 6 0 15", "Optional(-7)"); predict probe runs and prints ("a#1","b#2","c#0",2), (3, 1) (0, 0), get/set/6, rectangle transposed square, [5, 2, 4] ab 11; capture probe prints 12, [10, 20, 30], (99, 1), 2 as its comments say; all eight diagnostics recompiled from probes/errors.swift match Swift 6.2 wording, and rows 5 and 7 are indeed silent under -typecheck and fire under -c; Python comprehension claim [30, 30, 30] is right; every test asserts a value the shipped stub cannot return (either stub returns -1 and the not-evaluated test expects 7, so it fails); exercise 6's shipped signature produces exactly row 6 once a handler is stored; FF12 exists in docs/bridge-python.md.

Open questions: none.

## Chapter 03, value semantics

Edits:
- modules/03-value-semantics/README.md (Swift's answer): "storing into an array, and capturing in a closure." -> "storing into an array, and naming it in a closure's capture list." Reason: a closure captures the variable, not a copy (chapter 02's capture probe prints 12 and (99, 1) to show exactly that); only a capture list entry copies at creation. As written the sentence contradicted chapter 02.
- modules/03-value-semantics/README.md (Swift's answer): "`Equatable` and `Hashable` are synthesized as soon as every stored property conforms." -> "`Equatable` and `Hashable` are synthesized, once declared, as soon as every stored property conforms." Reason: nothing is synthesized for a struct that does not declare the conformance; the sample two lines down shows `: Hashable` but the sentence read as automatic.

Verified, no edit needed: cow probe prints shared true/false/false/false and unique true/false as the filmstrip and Done when say; predict probe prints 3 4, 1 7, true false, 3b varies per launch as claimed (1 on this run), true false; all eight diagnostics recompiled and match; the memberwise init used by the tests (Basket(lines:), Roster(byTeam:), Panel(cells:)) stays internal under private(set), confirmed by the build at the end; Ledger tests keep every `let` copy alive past the write they observe, so lifetime shortening cannot flip copiesMade; the cold open's `--filter Ch01` matches nothing today because drills/ holds only Ch00Format, which is by design (the learner contributes the chapter's drills).

Open questions:
- Hint 3 names `Substring.trimmingPrefix`; the standard library's `trimmingPrefix(while:)` is a Collection method that only strips the front, so it is half of exercise 3's job. Left as a hint, not a claim.

## Chapter 04, protocols

Edits:
- modules/04-protocols/README.md (Retrieval checkpoint 2): "Uncomment the last line of `probes/dispatch.swift` so `caption` becomes a requirement" -> "Replace the `Marker` declaration at the top of `probes/dispatch.swift` with its commented last line so `caption` becomes a requirement". Reason: the file already declares `protocol Marker` at the top, so uncommenting the last line gives "'Marker' is ambiguous for type lookup in this context" four times and nothing runs (verified); replacing the top declaration runs and changes exactly the two lines the probe promises.
- modules/04-protocols/probes/dispatch.swift (closing comment): "Uncommenting the line below changes two of the lines above, and predicting which two before you run it is the exercise." -> "Replacing the declaration at the top of this file with the line below changes two of the lines above, and predicting which two before you run it is the exercise." Reason: same redeclaration.
- modules/04-protocols/probes/layout.swift (print label): row("[any Sample] element", ...) -> row("[any Sample], the array", ...). Reason: the row measures MemoryLayout<[any Sample]>, which is the Array struct (8 bytes, one buffer pointer), not an element; an element of that array is the 40 byte box measured on the row above. The old label taught that a boxed element is 8 bytes.

Verified, no edit needed: predict prints "equatable plain", "bell [bell, default]", "true true true", so exactly one printed value changes under the existential as the README says; layout prints Small 8, Wide 40, any Sample 40, any Sample & Stamped 48 as the diagram says; dispatch prints the caption/tint matrix and 8/40 bytes as the diagram says; all eight diagnostics match, row 8 reproduced with -enable-upcoming-feature ExistentialAny; `\bclass\b` works under /usr/bin/grep and the stub contains no such word; every test asserts a value the shipped stub cannot produce (constant hash plus `==` false leaves the Set at 3, not 2).

Open questions:
- Hint 2 for exercise 3 says "the body you want is one comparison" against Array's own Equatable, which is close to naming the implementation. Within the hint tier CONTRIBUTING allows, so left alone.

## Chapter 05, enums

Edits:
- modules/05-enums/README.md (Where it goes wrong, row 8): "equality is synthesized for payload free enums only" -> "equality is synthesized without a declaration for payload free enums only". Reason: Equatable is synthesized for payload enums too once declared and every payload is Equatable; the chapter's own stubs (`Connection: Equatable`, `Event: Equatable`) depend on exactly that, and the row's Fix column already says so.
- modules/05-enums/probes/errors.swift (block 9 comment): "Equality is synthesized for a payload free enum and not for one with associated values, because the compiler will not assume the payloads are comparable." -> "Equality arrives without a declaration for a payload free enum and not for one with associated values, because the compiler will not assume the payloads are comparable." Reason: same.
- modules/05-enums/README.md (Done when): grep -n 'default' -> grep -n 'default:'. Reason: the stub's own header comment contains the word `default` twice (lines 9 and 11 of exercises/Enums.swift), so the check as written prints two lines on a clean file and can never pass; a switch arm is always spelled `default:`.

Verified, no edit needed: predict probe prints "@Sendable (Int) -> Pulse Pulse", "fast normal slow", "3 4 nil"; matching probe runs every form named in the table including the mixed label pattern `.failure(let code, retryable: true)`; states probe prints 16 / 4 / 12 as the model section says; all twelve diagnostics in probes/errors.swift match Swift 6.2 wording; the `Filter` sample with `case any([Filter])` compiles and runs; Band sample prints 8 / nil / declaration order; no lesson sample name (Player, Band, Filter) collides with any exercise stub; every test asserts a value the shipped stub cannot return (advance returns .closed(code: -1), which no test expects).

Open questions:
- The chapter tells you to reach for `default` "only over an enum you do not control, where a new case can arrive without your build breaking" but never names `@unknown default`, which is the tool built for that case. Scope is declared as chapter 09's, so left alone.
- Hint 3 points at "sections 3 and 5" of matching.swift for "a bare `let` in a pattern matches anything and binds it"; neither section shows a bare `let` pattern. Not a Swift claim, left alone.

## Chapter 06, collections

Edits:
- modules/06-collections/README.md (Swift's answer, Array row): "O(1) subscript and append" -> "O(1) subscript and amortized O(1) append". Reason: a single append that has to grow the buffer is O(n); the documented bound is amortized.
- modules/06-collections/README.md (Swift's answer, Set row): "O(1) membership and set algebra" -> "O(1) membership, and set algebra in linear time". Reason: union, intersection and subtraction walk their inputs; only membership is O(1).
- modules/06-collections/README.md (Done when): grep -nE '[A-Za-z_)\]]!|Array\(' -> grep -nE '[]A-Za-z_)]!|Array\(' . Reason: same broken bracket expression as chapters 01 and 02; under /usr/bin/grep the force unwrap half matched nothing.
- modules/06-collections/probes/views.swift (header comment): "a five character name, a space, and one family emoji" -> "a four character name, a space, and one family emoji". Reason: "Levi" is four characters; the probe itself prints a Character count of 6, which is 4 + 1 + 1.
- modules/06-collections/probes/lazy.swift (closing comment): "Drop the .lazy from the next line and the program does not run slower, it never finishes." -> "...it never reaches `first`: the eager map cubes an infinite sequence and traps on integer overflow within seconds." Reason: verified; the eager version exits with a SIGTRAP (status 5) after about two seconds because the cube of the 2,097,152nd element overflows Int, so "never finishes" is the wrong lesson.

Verified, no edit needed: views probe prints 6 / 10 / 23 / 13 and the composed/decomposed counts exactly as the diagram and prose say; String is bidirectional but not random access; slices probe prints startIndex 1 and the uncommented `middle[0]` traps with "Swift/SliceBuffer.swift:307: Fatal error: Index out of bounds" as row 8 says; predict probe output matches the prose comments; lazy probe interleaves and prints LazyMapSequence<Array<Int>, Int> versus Array<Int>; all seven diagnostics recompiled and match; the Python `len("Levi 👨‍👩‍👧")` claim of 10 is right (5 + 5 scalars); every test asserts a value the shipped stub cannot return.

Open questions:
- Done when bans every `Array(`, while the rule sentence only bans `Array(` over a String; `Array(slice)` is taught two sections earlier as the boundary idiom. Not a Swift claim, left alone.

## Chapter 07, generics

Edits:
- modules/07-generics/README.md (Swift's answer): "`any Feed<Int>` does not parse" -> "`any Feed<Int>` does not compile". Reason: it parses; the type checker rejects it with "protocol 'Feed' does not have primary associated types that can be constrained" (verified).
- modules/07-generics/README.md (Swift's answer): "a box whose `next()` returns `Any`" -> "a box whose `next()` returns `Any?`". Reason: the requirement returns `Payload?`, and erasing Payload gives `Optional<Any>` (verified by printing the type).
- modules/07-generics/README.md (Done when): grep -n 'any ' -> grep -nE 'any [A-Z]'. Reason: the shipped stub's own comments contain "any " five times ("in any signature", "how many times", "any caller"), so the check as written prints five lines on a clean file; an existential is always `any` followed by a capitalised protocol name, and the new pattern prints nothing on the stub (verified with /usr/bin/grep).
- modules/07-generics/probes/predict.swift (snippet 3 comment): "Does the type checker consider the two results the same type?" -> "This print compares their dynamic types. Predict it, then predict whether the type checker lets you assign one result to a variable holding the other." Reason: the print goes through `type(of:)`, so it prints true, but two functions returning `some Signal` are two distinct opaque types: `var v = hiddenA(); v = hiddenB()` fails with "cannot assign value of type 'some Signal' (result of 'hiddenB()') to type 'some Signal' (result of 'hiddenA()')" (verified). As written the probe taught the wrong answer to its own question.
- modules/07-generics/probes/layout.swift (comment and print label): "Opaque return types keep identity across calls, which is the whole difference..." -> "...across calls to one function, which is the whole difference... Two functions are two opaque types, even when the dynamic type behind both is the same."; label "same opaque type twice:" -> "same dynamic type behind both:". Reason: same as above; the compared values come from hidden() and alsoHidden().

Verified, no edit needed: every prose sample compiles under ExistentialAny (loudest, Bucket, Tick/Wave, steady, the mixed ternary, Feed with a primary associated type, drain, `any Feed<Int>`); predict prints 8 32 40, Burst, true, Optional<Signal> Optional<Blip>, 6 Array<Int>; layout prints 8/32/40/8/8, opened as Wave, 2 distinct dynamic types; all eleven diagnostics in probes/errors.swift match Swift 6.2 wording, and block 8's claim that the ExistentialAny warning fires in a loose file is true for a protocol with an associated type (while chapter 04's claim that its Self requirement block needs the package flag is also true; verified both without the flag); every test asserts a value the shipped stub cannot return (AnyGauge's cached read fails the ticking test on its second expectation, as the README promises).

Open questions:
- Stretch asks, of the specialize probe at 500,000 versus 2,000,000 elements, "which line grows linearly and which one stays flat". Measured: every timed row grows with the element count (boxing 0.10s to 0.23s, sums 0.08 to 0.21, 0.10 to 0.30, 0.09 to 0.24); only the two MemoryLayout lines stay flat. If that is the intended answer it is trivial; if a timing row was meant to stay flat, the claim is wrong at -Onone and needs rewording. Not edited.
- Hint 3 for exercise 4 names `stride(from:to:by:)`, which traps on a zero step ("Stride size must not be zero"), and the suite's repeatsOnZeroStep test asks for [7, 7, 7]. Likely a deliberate stumble; flagging in case it is not.

## Repo wide

- Package.swift's comment "Target names carry the chapter number so that `swift test --filter 03` selects exactly one chapter" contradicts CONTRIBUTING and the Makefile (both say the bare number over selects, measured 17 versus 15). Shared file, not edited.
- The checked in .build directory was produced at /Users/levimackay/swift-academy, so `swift build` at the root fails with "PCH was compiled with module cache path ..." until `make clean` is run. Built into a scratch path instead; nothing in the tree was deleted.
