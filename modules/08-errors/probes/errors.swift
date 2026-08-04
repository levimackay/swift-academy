// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain named in the
// chapter front matter, pasted verbatim. Uncomment one block at a time and
// check the wording yourself:
//
//     make probe CH=08 P=errors
//
// The chapter's "Where it goes wrong" table is built from blocks 1 through 8.
// Blocks 9 through 12 are not tabled: 9 and 10 are the async ones the chapter
// discusses in prose, 11 is `rethrows`, and 12 is the stale `try` warning.
//
// The file stays green on purpose: a probe that compiles today and stops
// compiling after a toolchain upgrade tells you the wording drifted, and a
// probe that never compiled cannot tell you anything.
//
// Uncomment exactly one block. Two blocks at once gives you two failures
// interleaved, and the first one usually explains the second.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// Every block below assumes one of these two declarations, so each block
// carries its own copy rather than sharing one and leaving you to guess.
//
// enum FuseError: Error { case blown }
// func check(_ n: Int) throws(FuseError) -> Int {
//     if n < 0 { throw FuseError.blown }
//     return n
// }
//
// enum ParseError: Error { case empty, badDigit(Character) }
// func digits(_ s: String) throws(ParseError) -> Int {
//     if s.isEmpty { throw ParseError.empty }
//     guard let n = Int(s) else { throw ParseError.badDigit(s.first ?? "?") }
//     return n
// }

// 1. `throws` on the enclosing function is not enough. The call site carries
//    its own marker, and the notes list all three markers you could mean.
//
// enum FuseError: Error { case blown }
// func check(_ n: Int) throws(FuseError) -> Int {
//     if n < 0 { throw FuseError.blown }
//     return n
// }
// func total(_ ns: [Int]) throws(FuseError) -> Int {
//     var sum = 0
//     for n in ns { sum += check(n) }
//     return sum
// }
//
// error: call can throw but is not marked with 'try'
// note: did you mean to use 'try'?
// note: did you mean to handle error as optional value?
// note: did you mean to disable error propagation?

// 2. The mirror image of block 1: the call site is marked, and the enclosing
//    function never signed up to propagate anything.
//
// enum FuseError: Error { case blown }
// func check(_ n: Int) throws(FuseError) -> Int {
//     if n < 0 { throw FuseError.blown }
//     return n
// }
// func safeTotal(_ ns: [Int]) -> Int {
//     var sum = 0
//     for n in ns { sum += try check(n) }
//     return sum
// }
//
// error: errors thrown from here are not handled

// 3. There is no root error class and no implicit conformance, so a string
//    is not throwable however convenient that would be.
//
// func refuse() throws { throw "nope" }
//
// error: thrown expression type 'String' does not conform to 'Error'

// 4. Typed throws means exactly one type comes out. An error from a
//    different subsystem has to be mapped at the boundary, not smuggled.
//
// enum FuseError: Error { case blown }
// enum WireError: Error { case dropped }
// func send() throws(FuseError) { throw WireError.dropped }
//
// error: thrown expression type 'WireError' cannot be converted to error type 'FuseError'

// 5. With typed throws the compiler knows the whole case list, so a `catch`
//    that covers some of it is an unhandled error rather than a style choice.
//    Note what makes this compile in one place and not another: wrap the same
//    `do` in a function that is itself `throws(ParseError)` and it is fine,
//    because the leftover cases have somewhere to go.
//
// enum ParseError: Error { case empty, badDigit(Character) }
// func digits(_ s: String) throws(ParseError) -> Int {
//     if s.isEmpty { throw ParseError.empty }
//     guard let n = Int(s) else { throw ParseError.badDigit(s.first ?? "?") }
//     return n
// }
// func run() {
//     do { _ = try digits("x") } catch .empty { print("empty") }
// }
//
// error: errors thrown from here are not handled because the enclosing catch is not exhaustive

// 6. `Result { }` infers `any Error` and the annotation on the left does not
//    reach back into it. A typed failure is built from an explicit do catch.
//
// enum ParseError: Error { case empty, badDigit(Character) }
// func digits(_ s: String) throws(ParseError) -> Int {
//     if s.isEmpty { throw ParseError.empty }
//     guard let n = Int(s) else { throw ParseError.badDigit(s.first ?? "?") }
//     return n
// }
// let r: Result<Int, ParseError> = Result { try digits("7") }
// print(r)
//
// error: invalid conversion of thrown error type 'any Error' to 'ParseError'

// 7. A deferred block runs during an exit that is already under way, so it
//    cannot begin a second one. This is where `finally { return x }` and
//    `defer` part company.
//
// func lastValue() -> Int {
//     defer { return 1 }
//     return 0
// }
//
// error: 'return' cannot transfer control out of a defer statement

// 8. `try?` is a type change, not a suppression. The expression stops being
//    an `Int` the moment you write it.
//
// enum ParseError: Error { case empty, badDigit(Character) }
// func digits(_ s: String) throws(ParseError) -> Int {
//     if s.isEmpty { throw ParseError.empty }
//     guard let n = Int(s) else { throw ParseError.badDigit(s.first ?? "?") }
//     return n
// }
// let n: Int = try? digits("7")
// print(n)
//
// error: value of optional type 'Int?' not unwrapped; did you mean to use 'try!' or chain with '?'?

// 9. `async` and `throws` are separate axes and each has its own call site
//    marker. Having written `try` does not cover the suspension.
//
// enum ParseError: Error { case empty, badDigit(Character) }
// func digits(_ s: String) throws(ParseError) -> Int {
//     if s.isEmpty { throw ParseError.empty }
//     guard let n = Int(s) else { throw ParseError.badDigit(s.first ?? "?") }
//     return n
// }
// func fetch() async throws(ParseError) -> Int { try digits("7") }
// func caller() async throws(ParseError) -> Int {
//     return try fetch()
// }
//
// error: expression is 'async' but is not marked with 'await'
// note: call is 'async'

// 10. And the other half: `throws` propagates into a synchronous caller,
//     `async` does not. The note names the fix rather than the mistake.
//
// enum ParseError: Error { case empty, badDigit(Character) }
// func digits(_ s: String) throws(ParseError) -> Int {
//     if s.isEmpty { throw ParseError.empty }
//     guard let n = Int(s) else { throw ParseError.badDigit(s.first ?? "?") }
//     return n
// }
// func fetch() async throws(ParseError) -> Int { try digits("7") }
// func caller() throws(ParseError) -> Int {
//     return try await fetch()
// }
//
// error: 'async' call in a function that does not support concurrency
// note: add 'async' to function 'caller()' to make it asynchronous

// 11. Not in the table, and worth knowing anyway. `rethrows` describes a
//     function whose throwing is borrowed from a closure parameter, so a
//     function with no such parameter cannot claim it. Typed throws
//     generalises this, which is why new code rarely writes `rethrows`.
//
// enum LinkError: Error { case broken }
// func broken(_ xs: [Int]) rethrows -> [Int] {
//     try xs.map { _ in throw LinkError.broken }
// }
//
// error: 'rethrows' function must take a throwing function argument

// 12. Not in the table either. The marker is checked even when it is
//     pointless, so a stale `try` left behind after a signature stopped
//     throwing tells you about it.
//
// func plain(_ s: String) -> Int { s.count }
// func widen(_ s: String) throws -> Int {
//     return try plain(s)
// }
//
// warning: no calls to throwing functions occur within 'try' expression

print("errors.swift compiles clean. Uncomment one block above and rerun.")
