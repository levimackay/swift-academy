// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=12 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. If a
// future toolchain changes the wording, fix it here first.
//
// One warning about how you check these. `swiftc -typecheck` misses two of
// them. Blocks 6 and 7 are produced later in the pipeline, by the pass that
// reasons about isolation regions, so they only appear once the compiler
// gets as far as emitting code. `make probe` compiles and runs the file, so
// it sees all of them.

func fetchCount() async -> Int { 1 }

// 1. Async is a property of the function's type, so a synchronous caller
//    cannot call one. This is the whole of "function colouring".
//
// func plainCaller() -> Int { fetchCount() }
//
// error: 'async' call in a function that does not support concurrency

// 2. Inside an async function the call is legal, and the suspension still
//    has to be written down, because everything you know may be stale after
//    it.
//
// func asyncCaller() async -> Int { fetchCount() }
//
// error: expression is 'async' but is not marked with 'await'

// 3. There is no .Result, no .Wait(), and no GetAwaiter().GetResult().
//    Reading a Task's value is itself an await, so a synchronous function
//    cannot do it and there is no escape hatch that blocks instead.
//
// func f() {
//     let handle = Task { 41 }
//     print(handle.value)
// }
//
// error: 'async' property access in a function that does not support
// concurrency

// 4. An AsyncSequence is not a Sequence. Its next() suspends, so the loop
//    that drives it has to be able to suspend too.
//
// func drain(_ stream: AsyncStream<Int>) async -> Int {
//     var last = 0
//     for value in stream { last = value }
//     return last
// }
//
// error: for-in loop requires 'AsyncStream<Int>' to conform to 'Sequence'

// 5. And the same wall from the other side: `for await` is not a way to make
//    an ordinary collection concurrent.
//
// func total(of values: [Int]) async -> Int {
//     var sum = 0
//     for await value in values { sum += value }
//     return sum
// }
//
// error: for-in loop requires '[Int]' to conform to 'AsyncSequence'

// 6. The reflex from Task.WhenAll: accumulate into a local while the
//    children run. Every child would be writing to `sum` at once, so the
//    closure cannot be handed over.
//
// func sumAll(_ values: [Int]) async -> Int {
//     var sum = 0
//     await withTaskGroup(of: Int.self) { group in
//         for value in values {
//             group.addTask { sum += value; return value }
//         }
//     }
//     return sum
// }
//
// error: passing closure as a 'sending' parameter risks causing data races
// between code in the current task and concurrent execution of the closure

// 7. A detached task inherits nothing, and that includes the isolation the
//    surrounding code was running under.
//
// @MainActor
// final class Screen {
//     var title = ""
// }
// func refresh(_ screen: Screen) {
//     Task.detached { screen.title = "loaded" }
// }
//
// error: main actor-isolated property 'title' can not be mutated from a
// nonisolated context

// 8. The eighth row of the chapter table is a run time trap rather than a
//    diagnostic, so it lives in its own probe:
//
//     make probe CH=12 P=continuation

print("errors.swift compiles when every block above stays commented out")
print("fetchCount answered \(await fetchCount())")
